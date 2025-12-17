import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shortcut_provider.dart';
import '../models/app_shortcut.dart';
import '../theme/app_theme.dart';

class ShortcutManageScreen extends StatelessWidget {
  const ShortcutManageScreen({super.key});

  /// アイコン名からIconDataを取得
  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'search':
        return Icons.search;
      case 'assistant':
        return Icons.assistant_outlined;
      case 'bolt':
        return Icons.bolt;
      case 'smart_toy':
        return Icons.smart_toy_outlined;
      case 'hub':
        return Icons.hub_outlined;
      default:
        return Icons.open_in_new;
    }
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _ShortcutEditDialog(),
    );
  }

  void _showEditDialog(BuildContext context, AppShortcut shortcut) {
    showDialog(
      context: context,
      builder: (context) => _ShortcutEditDialog(shortcut: shortcut),
    );
  }

  void _showDeleteDialog(BuildContext context, AppShortcut shortcut) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ショートカットを削除'),
        content: Text('「${shortcut.name}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              context.read<ShortcutProvider>().deleteShortcut(shortcut.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ショートカット管理'),
      ),
      body: Consumer<ShortcutProvider>(
        builder: (context, provider, child) {
          final shortcuts = provider.shortcuts;

          if (shortcuts.isEmpty) {
            return _buildEmptyState(context);
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shortcuts.length,
            onReorder: (oldIndex, newIndex) {
              provider.reorderShortcuts(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final shortcut = shortcuts[index];
              return _ShortcutListItem(
                key: ValueKey(shortcut.id),
                shortcut: shortcut,
                icon: _getIconData(shortcut.iconName),
                onEdit: () => _showEditDialog(context, shortcut),
                onDelete: () => _showDeleteDialog(context, shortcut),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('新規追加'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'ショートカットがありません',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '下のボタンから追加してください',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutListItem extends StatelessWidget {
  final AppShortcut shortcut;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ShortcutListItem({
    super.key,
    required this.shortcut,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(shortcut.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          shortcut.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          shortcut.urlScheme,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: AppTheme.textSecondary,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: AppTheme.errorRed,
              onPressed: onDelete,
            ),
            const Icon(Icons.drag_handle, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ShortcutEditDialog extends StatefulWidget {
  final AppShortcut? shortcut;

  const _ShortcutEditDialog({this.shortcut});

  @override
  State<_ShortcutEditDialog> createState() => _ShortcutEditDialogState();
}

class _ShortcutEditDialogState extends State<_ShortcutEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  String _selectedIcon = 'chat';
  int _selectedColor = 0xFF9C6ADE;

  bool get isEditing => widget.shortcut != null;

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'chat', 'icon': Icons.chat_bubble_outline, 'label': 'チャット'},
    {'name': 'psychology', 'icon': Icons.psychology_outlined, 'label': '心理'},
    {'name': 'auto_awesome', 'icon': Icons.auto_awesome, 'label': 'スパーク'},
    {'name': 'search', 'icon': Icons.search, 'label': '検索'},
    {'name': 'assistant', 'icon': Icons.assistant_outlined, 'label': 'アシスタント'},
    {'name': 'bolt', 'icon': Icons.bolt, 'label': 'ボルト'},
    {'name': 'smart_toy', 'icon': Icons.smart_toy_outlined, 'label': 'ロボット'},
    {'name': 'hub', 'icon': Icons.hub_outlined, 'label': 'ハブ'},
  ];

  final List<int> _colorOptions = [
    0xFF10A37F, // ChatGPT Green
    0xFFD97706, // Claude Orange
    0xFF4285F4, // Google Blue
    0xFF20B2AA, // Perplexity Teal
    0xFF0078D4, // Microsoft Blue
    0xFF000000, // Black
    0xFF9C6ADE, // Purple
    0xFFEF4444, // Red
    0xFFEC4899, // Pink
    0xFF8B5CF6, // Violet
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shortcut?.name ?? '');
    _urlController = TextEditingController(text: widget.shortcut?.urlScheme ?? '');
    _selectedIcon = widget.shortcut?.iconName ?? 'chat';
    _selectedColor = widget.shortcut?.colorValue ?? 0xFF9C6ADE;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名前を入力してください')),
      );
      return;
    }

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URLを入力してください')),
      );
      return;
    }

    final provider = context.read<ShortcutProvider>();

    if (isEditing) {
      final updated = widget.shortcut!.copyWith(
        name: name,
        urlScheme: url,
        iconName: _selectedIcon,
        colorValue: _selectedColor,
      );
      provider.updateShortcut(updated);
    } else {
      provider.createShortcut(
        name: name,
        urlScheme: url,
        iconName: _selectedIcon,
        colorValue: _selectedColor,
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isEditing ? '更新しました' : '追加しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'ショートカット編集' : '新規ショートカット'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'アプリ名 *',
                hintText: '例: ChatGPT',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL / URLスキーム *',
                hintText: '例: https://chat.openai.com/',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            
            // プリセット追加ボタン
            const Text(
              'プリセットから追加',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PresetChip(
                  label: 'ChatGPT',
                  onTap: () {
                    _nameController.text = 'ChatGPT';
                    _urlController.text = 'https://chat.openai.com/';
                    setState(() {
                      _selectedIcon = 'chat';
                      _selectedColor = 0xFF10A37F;
                    });
                  },
                ),
                _PresetChip(
                  label: 'Claude',
                  onTap: () {
                    _nameController.text = 'Claude';
                    _urlController.text = 'https://claude.ai/';
                    setState(() {
                      _selectedIcon = 'psychology';
                      _selectedColor = 0xFFD97706;
                    });
                  },
                ),
                _PresetChip(
                  label: 'Gemini',
                  onTap: () {
                    _nameController.text = 'Gemini';
                    _urlController.text = 'https://gemini.google.com/';
                    setState(() {
                      _selectedIcon = 'auto_awesome';
                      _selectedColor = 0xFF4285F4;
                    });
                  },
                ),
                _PresetChip(
                  label: 'Perplexity',
                  onTap: () {
                    _nameController.text = 'Perplexity';
                    _urlController.text = 'https://www.perplexity.ai/';
                    setState(() {
                      _selectedIcon = 'search';
                      _selectedColor = 0xFF20B2AA;
                    });
                  },
                ),
                _PresetChip(
                  label: 'Grok',
                  onTap: () {
                    _nameController.text = 'Grok';
                    _urlController.text = 'https://x.com/i/grok';
                    setState(() {
                      _selectedIcon = 'bolt';
                      _selectedColor = 0xFF000000;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Text(
              'アイコン',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconOptions.map((opt) {
                final isSelected = _selectedIcon == opt['name'];
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = opt['name']),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryPurple
                          : AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppTheme.primaryPurple, width: 2)
                          : null,
                    ),
                    child: Icon(
                      opt['icon'],
                      size: 22,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'カラー',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((colorValue) {
                final isSelected = _selectedColor == colorValue;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = colorValue),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(colorValue).withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(isEditing ? '更新' : '追加'),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.dividerColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
