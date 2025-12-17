import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/prompt_template.dart';
import '../models/app_shortcut.dart';

class StorageService {
  static const String _templateBoxName = 'prompt_templates';
  static const String _shortcutBoxName = 'app_shortcuts';
  static late Box<PromptTemplate> _templateBox;
  static late Box<AppShortcut> _shortcutBox;
  static const _uuid = Uuid();

  /// Hiveの初期化
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // アダプター登録
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PromptTemplateAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AppShortcutAdapter());
    }
    
    // Box を開く
    _templateBox = await Hive.openBox<PromptTemplate>(_templateBoxName);
    _shortcutBox = await Hive.openBox<AppShortcut>(_shortcutBoxName);
    
    // 初回起動時にサンプルデータを追加
    if (_templateBox.isEmpty) {
      await _addSampleTemplates();
    }
    if (_shortcutBox.isEmpty) {
      await _addDefaultShortcuts();
    }
  }

  // =====================
  // テンプレート関連
  // =====================

  /// サンプルテンプレートを追加
  static Future<void> _addSampleTemplates() async {
    final samples = [
      PromptTemplate(
        id: _uuid.v4(),
        title: '記事要約',
        content: '以下のURLの記事を読んで、主要なポイントを3つに絞って日本語で要約してください。\n\n{{URL}}',
        description: 'Webページの内容を簡潔に要約',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: true,
        category: '要約',
      ),
      PromptTemplate(
        id: _uuid.v4(),
        title: 'X投稿の分析',
        content: '以下のX(Twitter)投稿を分析し、投稿者の意図、感情、主張のポイントを解説してください。\n\n{{URL}}',
        description: 'X.comの投稿を分析',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
        category: 'SNS',
      ),
      PromptTemplate(
        id: _uuid.v4(),
        title: '技術記事の解説',
        content: '以下の技術記事を読んで、初心者にもわかりやすく解説してください。専門用語があれば簡単な説明を加えてください。\n\n{{URL}}',
        description: '技術的な内容をわかりやすく解説',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
        category: '技術',
      ),
      PromptTemplate(
        id: _uuid.v4(),
        title: 'お気に入り引用',
        content: '以下のコンテンツを私のお気に入りとして保存します。このコンテンツの魅力的なポイントと、なぜ興味深いのかを説明してください。\n\n{{URL}}',
        description: 'お気に入りコンテンツの引用と説明',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: true,
        category: '引用',
      ),
      PromptTemplate(
        id: _uuid.v4(),
        title: 'ニュース要点整理',
        content: '以下のニュース記事から、5W1H（誰が、何を、いつ、どこで、なぜ、どのように）の形式で要点を整理してください。\n\n{{URL}}',
        description: 'ニュース記事を5W1Hで整理',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
        category: 'ニュース',
      ),
    ];

    for (final template in samples) {
      await _templateBox.put(template.id, template);
    }
  }

  static List<PromptTemplate> getAllTemplates() {
    return _templateBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static List<PromptTemplate> getFavoriteTemplates() {
    return _templateBox.values.where((t) => t.isFavorite).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static List<PromptTemplate> getTemplatesByCategory(String category) {
    return _templateBox.values.where((t) => t.category == category).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static List<String> getAllCategories() {
    final categories = _templateBox.values
        .map((t) => t.category)
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  static Future<void> saveTemplate(PromptTemplate template) async {
    await _templateBox.put(template.id, template);
  }

  static Future<PromptTemplate> createTemplate({
    required String title,
    required String content,
    String? description,
    String? category,
  }) async {
    final template = PromptTemplate(
      id: _uuid.v4(),
      title: title,
      content: content,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: category,
    );
    await _templateBox.put(template.id, template);
    return template;
  }

  static Future<void> updateTemplate(PromptTemplate template) async {
    final updated = template.copyWith(updatedAt: DateTime.now());
    await _templateBox.put(updated.id, updated);
  }

  static Future<void> deleteTemplate(String id) async {
    await _templateBox.delete(id);
  }

  static Future<void> toggleFavorite(String id) async {
    final template = _templateBox.get(id);
    if (template != null) {
      final updated = template.copyWith(
        isFavorite: !template.isFavorite,
        updatedAt: DateTime.now(),
      );
      await _templateBox.put(id, updated);
    }
  }

  static PromptTemplate? getTemplateById(String id) {
    return _templateBox.get(id);
  }

  static Box<PromptTemplate> get templateBox => _templateBox;

  // =====================
  // ショートカット関連
  // =====================

  /// デフォルトのショートカットを追加
  static Future<void> _addDefaultShortcuts() async {
    final defaults = [
      AppShortcut(
        id: _uuid.v4(),
        name: 'ChatGPT',
        urlScheme: 'https://chat.openai.com/',
        iconName: 'chat',
        colorValue: 0xFF10A37F,
        sortOrder: 0,
        createdAt: DateTime.now(),
      ),
      AppShortcut(
        id: _uuid.v4(),
        name: 'Claude',
        urlScheme: 'https://claude.ai/',
        iconName: 'psychology',
        colorValue: 0xFFD97706,
        sortOrder: 1,
        createdAt: DateTime.now(),
      ),
      AppShortcut(
        id: _uuid.v4(),
        name: 'Gemini',
        urlScheme: 'https://gemini.google.com/',
        iconName: 'auto_awesome',
        colorValue: 0xFF4285F4,
        sortOrder: 2,
        createdAt: DateTime.now(),
      ),
    ];

    for (final shortcut in defaults) {
      await _shortcutBox.put(shortcut.id, shortcut);
    }
  }

  static List<AppShortcut> getAllShortcuts() {
    return _shortcutBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  static Future<AppShortcut> createShortcut({
    required String name,
    required String urlScheme,
    String? iconName,
    int? colorValue,
  }) async {
    final shortcuts = getAllShortcuts();
    final maxOrder = shortcuts.isEmpty 
        ? 0 
        : shortcuts.map((s) => s.sortOrder).reduce((a, b) => a > b ? a : b);
    
    final shortcut = AppShortcut(
      id: _uuid.v4(),
      name: name,
      urlScheme: urlScheme,
      iconName: iconName,
      colorValue: colorValue ?? 0xFF9C6ADE,
      sortOrder: maxOrder + 1,
      createdAt: DateTime.now(),
    );
    await _shortcutBox.put(shortcut.id, shortcut);
    return shortcut;
  }

  static Future<void> updateShortcut(AppShortcut shortcut) async {
    await _shortcutBox.put(shortcut.id, shortcut);
  }

  static Future<void> deleteShortcut(String id) async {
    await _shortcutBox.delete(id);
  }

  static AppShortcut? getShortcutById(String id) {
    return _shortcutBox.get(id);
  }

  static Box<AppShortcut> get shortcutBox => _shortcutBox;
}
