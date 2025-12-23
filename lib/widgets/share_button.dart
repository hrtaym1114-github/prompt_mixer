import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;
import '../providers/template_provider.dart';
import '../theme/app_theme.dart';

/// 共有ボタン
/// iOSではWeb Share APIがChatGPTアプリでフリーズするため、クリップボードコピーのみ使用
class ShareButton extends StatelessWidget {
  const ShareButton({super.key});

  /// iOSかどうかを判定
  bool _isIOS() {
    try {
      final userAgent = web.window.navigator.userAgent.toLowerCase();
      return userAgent.contains('iphone') || userAgent.contains('ipad');
    } catch (e) {
      return false;
    }
  }

  /// クリップボードにコピー
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppTheme.successGreen),
            SizedBox(width: 12),
            Text('クリップボードにコピーしました'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    final provider = context.read<TemplateProvider>();
    final output = provider.generatedOutput;

    if (output.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(child: Text('共有する内容がありません')),
            ],
          ),
        ),
      );
      return;
    }

    _copyToClipboard(context, output);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateProvider>(
      builder: (context, provider, child) {
        final hasOutput = provider.generatedOutput.isNotEmpty;
        final isIOS = _isIOS();

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
                        Icons.copy,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'コピー',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // コピーボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: hasOutput ? () => _handleTap(context) : null,
                    icon: const Icon(
                      Icons.copy,
                      size: 22,
                    ),
                    label: const Text(
                      'クリップボードにコピー',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasOutput 
                          ? AppTheme.primaryPurple 
                          : AppTheme.cardDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  isIOS
                      ? '💡 コピー後、ChatGPTやClaudeアプリに貼り付けてください'
                      : '💡 コピー後、AIアプリに貼り付けてください',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
