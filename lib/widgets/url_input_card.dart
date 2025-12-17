import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UrlInputCard extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onPaste;

  const UrlInputCard({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onPaste,
  });

  @override
  State<UrlInputCard> createState() => _UrlInputCardState();
}

class _UrlInputCardState extends State<UrlInputCard> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.link,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'URL入力',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: 'https://example.com または x.com/...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // クリアボタン（常時表示、テキストがある時のみアクティブ）
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: hasText 
                            ? AppTheme.textSecondary 
                            : AppTheme.textSecondary.withValues(alpha: 0.3),
                      ),
                      onPressed: hasText
                          ? () {
                              widget.controller.clear();
                              widget.onChanged('');
                            }
                          : null,
                      tooltip: 'クリア',
                    ),
                    // 貼り付けボタン
                    IconButton(
                      icon: const Icon(Icons.content_paste),
                      color: AppTheme.primaryPurple,
                      onPressed: widget.onPaste,
                      tooltip: '貼り付け',
                    ),
                  ],
                ),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildQuickChip('x.com'),
                const SizedBox(width: 8),
                _buildQuickChip('note.com'),
                const SizedBox(width: 8),
                _buildQuickChip('qiita.com'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String domain) {
    return InkWell(
      onTap: () {
        final currentText = widget.controller.text;
        if (!currentText.contains(domain)) {
          widget.controller.text = 'https://$domain/';
          widget.onChanged(widget.controller.text);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.dividerColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          domain,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
