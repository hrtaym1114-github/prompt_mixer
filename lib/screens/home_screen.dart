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
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: AppTheme.textSecondary),
            tooltip: 'アカウント',
            onSelected: (value) async {
              if (value == 'logout') {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ログアウト'),
                    content: const Text('ログアウトしますか？\nデータはクラウドに保存されています。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                        ),
                        child: const Text('ログアウト'),
                      ),
                    ],
                  ),
                );
                
                if (shouldLogout == true && mounted) {
                  await context.read<AuthProvider>().signOut();
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'user',
                enabled: false,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.user;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'ユーザー',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (user?.email != null)
                          Text(
                            user!.email!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: AppTheme.errorRed),
                    SizedBox(width: 12),
                    Text('ログアウト'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
