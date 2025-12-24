import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../providers/template_provider.dart';
import '../models/prompt_template.dart';
import '../theme/app_theme.dart';

class TemplateSelector extends StatefulWidget {
  const TemplateSelector({super.key});

  @override
  State<TemplateSelector> createState() => _TemplateSelectorState();
}

class _TemplateSelectorState extends State<TemplateSelector> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// テンプレートをフィルタリング
  List<PromptTemplate> _filterTemplates(List<PromptTemplate> templates) {
    var filtered = templates;

    // お気に入りフィルター
    if (_showFavoritesOnly) {
      filtered = filtered.where((t) => t.isFavorite).toList();
    }

    // カテゴリフィルター
    if (_selectedCategory != null) {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    }

    // 検索フィルター
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) =>
        t.title.toLowerCase().contains(query) ||
        (t.description?.toLowerCase().contains(query) ?? false) ||
        (t.category?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    return filtered;
  }

  /// カテゴリ一覧を取得
  List<String> _getCategories(List<PromptTemplate> templates) {
    final categories = templates
        .map((t) => t.category)
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateProvider>(
      builder: (context, provider, child) {
        final allTemplates = provider.allTemplates;
        final filteredTemplates = _filterTemplates(allTemplates);
        final selectedTemplate = provider.selectedTemplate;
        final categories = _getCategories(allTemplates);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'テンプレート選択',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // テンプレート数表示
                    Text(
                      '${filteredTemplates.length}/${allTemplates.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // フィルターバー
                if (allTemplates.length > 3) ...[
                  _buildFilterBar(categories),
                  const SizedBox(height: 12),
                ],
                
                // テンプレートリスト
                if (allTemplates.isEmpty)
                  _buildEmptyState()
                else if (filteredTemplates.isEmpty)
                  _buildNoResultsState()
                else
                  _buildTemplateList(filteredTemplates, selectedTemplate, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterBar(List<String> categories) {
    return Column(
      children: [
        // 検索バー
        SizedBox(
          height: 40,
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'テンプレートを検索...',
              hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryPurple),
              ),
              filled: true,
              fillColor: AppTheme.darkBackground,
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),
        
        // フィルターチップ
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // お気に入りフィルター
              _FilterChip(
                label: '★ お気に入り',
                isSelected: _showFavoritesOnly,
                onTap: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
              ),
              const SizedBox(width: 8),
              // 全てボタン
              _FilterChip(
                label: 'すべて',
                isSelected: _selectedCategory == null && !_showFavoritesOnly,
                onTap: () => setState(() {
                  _selectedCategory = null;
                  _showFavoritesOnly = false;
                }),
              ),
              const SizedBox(width: 8),
              // カテゴリフィルター
              ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: category,
                  isSelected: _selectedCategory == category,
                  onTap: () => setState(() {
                    _selectedCategory = _selectedCategory == category ? null : category;
                  }),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'テンプレートがありません\n下部の「テンプレート」タブから追加してください',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 32, color: AppTheme.textSecondary),
            const SizedBox(height: 8),
            const Text(
              '条件に一致するテンプレートがありません',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _searchQuery = '';
                _selectedCategory = null;
                _showFavoritesOnly = false;
              }),
              child: const Text('フィルターをクリア'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateList(
    List<PromptTemplate> templates,
    PromptTemplate? selectedTemplate,
    TemplateProvider provider,
  ) {
    return SizedBox(
      height: 120,
      child: Listener(
        // マウスホイールで横スクロール対応（PC用）
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _scrollController.animateTo(
              _scrollController.offset + event.scrollDelta.dy,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
            );
          }
        },
        child: ScrollConfiguration(
          // ドラッグでもスクロール可能に
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final isSelected = selectedTemplate?.id == template.id;
              
              return Padding(
                padding: EdgeInsets.only(
                  right: index < templates.length - 1 ? 10 : 0,
                ),
                child: _TemplateChip(
                  template: template,
                  isSelected: isSelected,
                  onTap: () {
                    provider.selectTemplate(
                      isSelected ? null : template,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// フィルターチップ
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// テンプレートチップ
class _TemplateChip extends StatelessWidget {
  final PromptTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateChip({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryPurple 
                : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (template.isFavorite)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.star,
                      size: 14,
                      color: isSelected ? Colors.white : Colors.amber,
                    ),
                  ),
                Expanded(
                  child: Text(
                    template.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (template.category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withValues(alpha: 0.2) 
                      : AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  template.category!,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              template.description ?? template.content,
              style: TextStyle(
                fontSize: 11,
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.8) 
                    : AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
