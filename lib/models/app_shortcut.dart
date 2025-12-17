import 'package:hive/hive.dart';

part 'app_shortcut.g.dart';

@HiveType(typeId: 1)
class AppShortcut extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String urlScheme;

  @HiveField(3)
  String? iconName;

  @HiveField(4)
  int colorValue;

  @HiveField(5)
  int sortOrder;

  @HiveField(6)
  DateTime createdAt;

  AppShortcut({
    required this.id,
    required this.name,
    required this.urlScheme,
    this.iconName,
    this.colorValue = 0xFF9C6ADE,
    this.sortOrder = 0,
    required this.createdAt,
  });

  AppShortcut copyWith({
    String? id,
    String? name,
    String? urlScheme,
    String? iconName,
    int? colorValue,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return AppShortcut(
      id: id ?? this.id,
      name: name ?? this.name,
      urlScheme: urlScheme ?? this.urlScheme,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 人気のAIアプリのプリセット
class AppShortcutPresets {
  static List<Map<String, dynamic>> get presets => [
    {
      'name': 'ChatGPT',
      'urlScheme': 'chatgpt://',
      'webUrl': 'https://chat.openai.com/',
      'iconName': 'chat',
      'colorValue': 0xFF10A37F,
    },
    {
      'name': 'Claude',
      'urlScheme': 'claude://',
      'webUrl': 'https://claude.ai/',
      'iconName': 'psychology',
      'colorValue': 0xFFD97706,
    },
    {
      'name': 'Gemini',
      'urlScheme': 'gemini://',
      'webUrl': 'https://gemini.google.com/',
      'iconName': 'auto_awesome',
      'colorValue': 0xFF4285F4,
    },
    {
      'name': 'Perplexity',
      'urlScheme': 'perplexity://',
      'webUrl': 'https://www.perplexity.ai/',
      'iconName': 'search',
      'colorValue': 0xFF20B2AA,
    },
    {
      'name': 'Copilot',
      'urlScheme': 'mscopilot://',
      'webUrl': 'https://copilot.microsoft.com/',
      'iconName': 'assistant',
      'colorValue': 0xFF0078D4,
    },
    {
      'name': 'Grok',
      'urlScheme': 'twitter://grok',
      'webUrl': 'https://x.com/i/grok',
      'iconName': 'bolt',
      'colorValue': 0xFF000000,
    },
  ];
}
