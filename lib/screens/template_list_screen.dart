import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/template_provider.dart';
import '../models/prompt_template.dart';
import '../theme/app_theme.dart';
import 'template_edit_screen.dart';

class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テンプレート管理'),
        actions: [
          Consumer<TemplateProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.showFavoritesOnly
                      ? Icons.star
                      : Icons.star_border,
                  color: provider.showFavoritesOnly
                      ? Colors.amber
                      : AppTheme.textSecondary,
                ),
                onPressed: () => provider.toggleFavoritesOnly(),
                tooltip: 'お気に入りのみ表示',
              );
            },
          ),
        ],
      ),
      body: Consumer<TemplateProvider>(
        builder: (context, provider, child) {
          final templates = provider.templates;

          return Column(
            children: [
              // カテゴリフィルター（将来的にFutureBuilderで実装予定）
              // 現在はシンプルにスキップ
              const SizedBox.shrink(),

              // テンプレートリスト
              Expanded(
                child: templates.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: templates.length,
                        itemBuilder: (context, index) {
                          final template = templates[index];
                          return _TemplateListItem(
                            template: template,
                            onEdit: () => _navigateToEdit(context, template),
                            onDelete: () => _showDeleteDialog(context, template),
                            onToggleFavorite: () {
                              provider.toggleFavorite(template.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEdit(context, null),
        icon: const Icon(Icons.add),
        label: const Text('新規作成'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'テンプレートがありません',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '下のボタンから新規作成してください',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, PromptTemplate? template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditScreen(template: template),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PromptTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('テンプレートを削除'),
        content: Text('「${template.title}」を削除しますか？\nこの操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              context.read<TemplateProvider>().deleteTemplate(template.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('削除しました')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

class _TemplateListItem extends StatelessWidget {
  final PromptTemplate template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const _TemplateListItem({
    required this.template,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (template.isFavorite)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.star,
                                  size: 18,
                                  color: Colors.amber,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                template.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (template.category != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              template.category!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'favorite':
                          onToggleFavorite();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('編集'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: [
                            Icon(
                              template.isFavorite
                                  ? Icons.star_border
                                  : Icons.star,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(template.isFavorite ? 'お気に入り解除' : 'お気に入り'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppTheme.errorRed),
                            SizedBox(width: 12),
                            Text('削除', style: TextStyle(color: AppTheme.errorRed)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (template.description != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    template.description!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  template.content,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
