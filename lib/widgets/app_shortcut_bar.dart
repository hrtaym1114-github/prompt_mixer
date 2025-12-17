import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;
import '../models/app_shortcut.dart';
import '../providers/shortcut_provider.dart';
import '../providers/template_provider.dart';
import '../theme/app_theme.dart';
import '../screens/shortcut_manage_screen.dart';

class AppShortcutBar extends StatelessWidget {
  const AppShortcutBar({super.key});

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

  void _copyAndLaunch(BuildContext context, AppShortcut shortcut) {
    final templateProvider = context.read<TemplateProvider>();
    final output = templateProvider.generatedOutput;

    if (output.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(child: Text('コピーする内容がありません')),
            ],
          ),
        ),
      );
      return;
    }

    // クリップボードにコピー
    Clipboard.setData(ClipboardData(text: output));

    // フィードバック表示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.successGreen),
            const SizedBox(width: 12),
            Expanded(child: Text('コピーしました → ${shortcut.name}を開きます')),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // 少し遅延してからURLを開く（コピー完了を確実にするため）
    Future.delayed(const Duration(milliseconds: 300), () {
      _launchUrl(shortcut.urlScheme);
    });
  }

  void _launchUrl(String url) {
    web.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShortcutProvider>(
      builder: (context, provider, child) {
        final shortcuts = provider.shortcuts;

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
                            Icons.rocket_launch_outlined,
                            color: AppTheme.primaryPurple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'コピー & アプリ起動',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, size: 20),
                      color: AppTheme.textSecondary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShortcutManageScreen(),
                          ),
                        );
                      },
                      tooltip: 'ショートカット管理',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (shortcuts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'ショートカットがありません\n右上の設定から追加してください',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  Consumer<TemplateProvider>(
                    builder: (context, templateProvider, child) {
                      final hasOutput = templateProvider.generatedOutput.isNotEmpty;
                      
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: shortcuts.map((shortcut) {
                          return _ShortcutButton(
                            shortcut: shortcut,
                            icon: _getIconData(shortcut.iconName),
                            isEnabled: hasOutput,
                            onTap: () => _copyAndLaunch(context, shortcut),
                          );
                        }).toList(),
                      );
                    },
                  ),

                const SizedBox(height: 8),
                const Text(
                  '💡 ボタンを押すとクリップボードにコピーし、アプリを開きます',
                  style: TextStyle(
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

class _ShortcutButton extends StatelessWidget {
  final AppShortcut shortcut;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ShortcutButton({
    required this.shortcut,
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(shortcut.colorValue);
    
    return Material(
      color: isEnabled ? color : color.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isEnabled ? Colors.white : Colors.white54,
              ),
              const SizedBox(width: 8),
              Text(
                shortcut.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
