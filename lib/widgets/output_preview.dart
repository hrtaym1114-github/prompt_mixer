import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/template_provider.dart';
import '../theme/app_theme.dart';

class OutputPreview extends StatelessWidget {
  const OutputPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateProvider>(
      builder: (context, provider, child) {
        final output = provider.generatedOutput;
        final hasTemplate = provider.selectedTemplate != null;
        final hasUrl = provider.currentUrl.isNotEmpty;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Icons.preview_outlined,
                            color: AppTheme.primaryPurple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '出力プレビュー',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (output.isNotEmpty)
                      Row(
                        children: [
                          // 文字数カウント
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.dividerColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${output.length}文字',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            color: AppTheme.primaryPurple,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: output));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('コピーしました'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            tooltip: 'コピー',
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // ステータスインジケーター
                _buildStatusRow(hasTemplate, hasUrl),
                
                const SizedBox(height: 12),
                
                // プレビューエリア
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 150),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: output.isEmpty
                      ? _buildEmptyState(hasTemplate, hasUrl)
                      : SelectableText(
                          output,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            height: 1.6,
                          ),
                        ),
                ),
                
                // ヒント
                if (output.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '下のコピーボタンを押して、AIチャットに貼り付けてください',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(bool hasTemplate, bool hasUrl) {
    return Row(
      children: [
        _StatusBadge(
          icon: Icons.description_outlined,
          label: 'テンプレート',
          isActive: hasTemplate,
        ),
        const SizedBox(width: 8),
        const Icon(Icons.add, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        _StatusBadge(
          icon: Icons.link,
          label: 'URL',
          isActive: hasUrl,
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        _StatusBadge(
          icon: Icons.auto_awesome,
          label: '出力',
          isActive: hasTemplate && hasUrl,
          isHighlight: true,
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool hasTemplate, bool hasUrl) {
    String message;
    IconData icon;
    
    if (!hasTemplate && !hasUrl) {
      message = 'テンプレートを選択し、\nURLを入力してください';
      icon = Icons.touch_app_outlined;
    } else if (!hasTemplate) {
      message = 'テンプレートを選択してください';
      icon = Icons.description_outlined;
    } else {
      message = 'URLを入力してください';
      icon = Icons.link;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isHighlight;

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.isActive,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color fgColor;
    
    if (isActive) {
      if (isHighlight) {
        bgColor = AppTheme.primaryPurple;
        fgColor = Colors.white;
      } else {
        bgColor = AppTheme.successGreen.withValues(alpha: 0.2);
        fgColor = AppTheme.successGreen;
      }
    } else {
      bgColor = AppTheme.dividerColor;
      fgColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fgColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
