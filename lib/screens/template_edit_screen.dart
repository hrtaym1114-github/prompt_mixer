import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/template_provider.dart';
import '../models/prompt_template.dart';
import '../theme/app_theme.dart';

class TemplateEditScreen extends StatefulWidget {
  final PromptTemplate? template;

  const TemplateEditScreen({super.key, this.template});

  @override
  State<TemplateEditScreen> createState() => _TemplateEditScreenState();
}

class _TemplateEditScreenState extends State<TemplateEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  bool _isFavorite = false;
  bool _isLoading = false;

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.template?.title ?? '');
    _contentController = TextEditingController(text: widget.template?.content ?? '');
    _descriptionController = TextEditingController(text: widget.template?.description ?? '');
    _categoryController = TextEditingController(text: widget.template?.category ?? '');
    _isFavorite = widget.template?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      _showError('タイトルを入力してください');
      return;
    }

    if (content.isEmpty) {
      _showError('プロンプト内容を入力してください');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<TemplateProvider>();
      
      if (isEditing) {
        final updated = widget.template!.copyWith(
          title: title,
          content: content,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
          isFavorite: _isFavorite,
        );
        await provider.updateTemplate(updated);
      } else {
        await provider.createTemplate(
          title: title,
          content: content,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '更新しました' : '作成しました'),
          ),
        );
      }
    } catch (e) {
      _showError('保存に失敗しました: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorRed),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.cardDark,
      ),
    );
  }

  void _insertPlaceholder() {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final newText = '${text.substring(0, selection.start)}{{URL}}${text.substring(selection.end)}';
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: selection.start + 7,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'テンプレート編集' : '新規テンプレート'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite ? Colors.amber : AppTheme.textSecondary,
              ),
              onPressed: () {
                setState(() => _isFavorite = !_isFavorite);
              },
            ),
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル *',
                hintText: '例: 記事要約、X投稿の分析',
                prefixIcon: Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // カテゴリ
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'カテゴリ',
                hintText: '例: 要約、SNS、技術',
                prefixIcon: Icon(Icons.category),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 説明
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明（任意）',
                hintText: 'このテンプレートの用途を簡単に記述',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),

            // プロンプト内容
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'プロンプト内容 *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _insertPlaceholder,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('{{URL}}を挿入'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '例: 以下のURLの記事を読んで、主要なポイントを3つに絞って日本語で要約してください。\n\n{{URL}}',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 10,
              minLines: 6,
              textAlignVertical: TextAlignVertical.top,
            ),
            const SizedBox(height: 12),

            // ヒント
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: AppTheme.primaryPurple.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '{{URL}} プレースホルダー',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'プロンプト内の {{URL}} は、メイン画面で入力したURLに自動的に置き換えられます。',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // FABの余白
          ],
        ),
      ),
    );
  }
}
