import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../providers/template_provider.dart';
import '../theme/app_theme.dart';

/// iOS/Android標準の共有機能を呼び出すボタン
class ShareButton extends StatefulWidget {
  const ShareButton({super.key});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> with WidgetsBindingObserver {
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// アプリがフォアグラウンドに戻ったときの処理
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isSharing) {
      // 共有から戻ってきたらフラグをリセット
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  /// Web Share APIが利用可能かチェック
  bool _canShare() {
    try {
      final navigator = web.window.navigator;
      return navigator.canShare(web.ShareData(text: 'test'));
    } catch (e) {
      return false;
    }
  }

  /// 標準の共有シートを開く（awaitしない方式でフリーズ防止）
  void _share(String text) {
    if (_isSharing) return;
    
    setState(() {
      _isSharing = true;
    });

    // 先にクリップボードにコピーしておく（フォールバック用）
    Clipboard.setData(ClipboardData(text: text));

    try {
      final shareData = web.ShareData(
        text: text,
        title: 'Prompt Mixer',
      );
      
      // awaitせずに共有を開始（Promiseの完了を待たない）
      // これによりiOSでアプリに戻った際のフリーズを防止
      web.window.navigator.share(shareData).toDart.then((_) {
        // 成功時（ユーザーが共有を完了）
        if (mounted) {
          setState(() {
            _isSharing = false;
          });
        }
      }).catchError((e) {
        // キャンセルまたはエラー時
        if (mounted) {
          setState(() {
            _isSharing = false;
          });
        }
      });
    } catch (e) {
      // 同期エラーの場合
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
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
  }

  void _handleTap() {
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

    _share(output);
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
                    onPressed: hasOutput && !_isSharing ? () => _handleTap() : null,
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
