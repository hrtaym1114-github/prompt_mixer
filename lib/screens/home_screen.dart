import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/template_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/url_input_card.dart';
import '../widgets/template_selector.dart';
import '../widgets/output_preview.dart';
import '../widgets/share_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    final provider = context.read<TemplateProvider>();
    final output = provider.generatedOutput;
    
    if (output.isEmpty) {
      _showSnackBar('コピーする内容がありません', isError: true);
      return;
    }

    Clipboard.setData(ClipboardData(text: output));
    _showSnackBar('クリップボードにコピーしました！', isError: false);
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppTheme.errorRed : AppTheme.successGreen,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearAll() {
    _urlController.clear();
    context.read<TemplateProvider>().clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            _buildHeader(),
            
            // メインコンテンツ
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // URL入力カード
                    UrlInputCard(
                      controller: _urlController,
                      onChanged: (url) {
                        context.read<TemplateProvider>().setUrl(url);
                      },
                      onPaste: () async {
                        final provider = context.read<TemplateProvider>();
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null && mounted) {
                          _urlController.text = data!.text!;
                          provider.setUrl(data.text!);
                        }
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // テンプレート選択
                    const TemplateSelector(),
                    
                    const SizedBox(height: 20),
                    
                    // 出力プレビュー
                    const OutputPreview(),
                    
                    const SizedBox(height: 20),
                    
                    // 共有ボタン（iOS/Android標準共有機能）
                    const ShareButton(),
                    
                    const SizedBox(height: 100), // FABの余白
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<TemplateProvider>(
        builder: (context, provider, child) {
          final hasOutput = provider.generatedOutput.isNotEmpty;
          return FloatingActionButton.extended(
            onPressed: hasOutput ? _copyToClipboard : null,
            backgroundColor: hasOutput 
                ? AppTheme.primaryPurple 
                : AppTheme.cardDark,
            icon: const Icon(Icons.copy),
            label: const Text('コピーのみ'),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    final authProvider = context.watch<AuthProvider>();
    // 値を事前にキャプチャ（PopupMenuのオーバーレイでProvider問題を回避）
    final userName = authProvider.user?.displayName ?? 'ユーザー';
    final userEmail = authProvider.user?.email;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.secondaryPurple],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prompt Mixer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'URLとプロンプトを組み合わせ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: AppTheme.textSecondary,
            onPressed: _clearAll,
            tooltip: 'クリア',
          ),
          // アカウントメニューボタン
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppTheme.textSecondary),
            tooltip: 'アカウント',
            onPressed: () => _showAccountMenu(userName, userEmail, authProvider),
          ),
        ],
      ),
    );
  }

  void _showAccountMenu(String userName, String? userEmail, AuthProvider authProvider) {
    // SimpleDialogを使用（Flutter Webでより安定）
    showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.account_circle,
                size: 40,
                color: Colors.white70,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (userEmail != null)
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                _confirmLogout(authProvider);
              },
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Text(
                    'ログアウト',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(AuthProvider authProvider) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'ログアウト',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'ログアウトしますか？\nデータはクラウドに保存されています。',
          style: TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF5350),
            ),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await authProvider.signOut();
    }
  }
}
