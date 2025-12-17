import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../providers/template_provider.dart';
import '../theme/app_theme.dart';

/// iOS/Android標準の共有機能を呼び出すボタン
class ShareButton extends StatelessWidget {
  const ShareButton({super.key});

  /// Web Share APIが利用可能かチェック
  bool _canShare() {
    try {
      // Check if share function exists using hasProperty
      final navigator = web.window.navigator;
      return navigator.canShare(web.ShareData(text: 'test'));
    } catch (e) {
      return false;
    }
  }

  /// 標準の共有シートを開く
  Future<void> _share(BuildContext context, String text) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final shareData = web.ShareData(
        text: text,
        title: 'Prompt Mixer',
      );
      
      await web.window.navigator.share(shareData).toDart;
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppTheme.successGreen),
              SizedBox(width: 12),
              Text('共有しました'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // ユーザーがキャンセルした場合やエラーの場合
      // クリップボードにコピーするフォールバック
      await Clipboard.setData(ClipboardData(text: text));
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.content_copy, color: AppTheme.primaryPurple),
              SizedBox(width: 12),
              Text('クリップボードにコピーしました'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
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

    _share(context, output);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateProvider>(
      builder: (context, provider, child) {
        final hasOutput = provider.generatedOutput.isNotEmpty;
        final canShare = _canShare();

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
                        Icons.ios_share,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '共有',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 共有ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: hasOutput ? () => _handleTap(context) : null,
                    icon: Icon(
                      canShare ? Icons.ios_share : Icons.copy,
                      size: 22,
                    ),
                    label: Text(
                      canShare ? '共有シートを開く' : 'クリップボードにコピー',
                      style: const TextStyle(
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
                  canShare 
                      ? '📱 ChatGPT、Claude、LINE等のアプリに直接共有できます'
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
