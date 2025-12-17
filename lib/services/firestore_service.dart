import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/prompt_template.dart';
import 'auth_service.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final AuthService _authService = AuthService();
  static const _uuid = Uuid();

  /// ユーザーのテンプレートコレクションへの参照
  static CollectionReference<Map<String, dynamic>> _userTemplatesCollection({String? userId}) {
    final uid = userId ?? _authService.userId;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('templates');
  }

  /// 全テンプレートを取得
  static Future<List<PromptTemplate>> getAllTemplates({String? userId}) async {
    try {
      final snapshot = await _userTemplatesCollection(userId: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PromptTemplate(
          id: doc.id,
          title: data['title'] as String,
          content: data['content'] as String,
          description: data['description'] as String?,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
          isFavorite: data['isFavorite'] as bool? ?? false,
          category: data['category'] as String?,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// テンプレートをリアルタイム監視
  static Stream<List<PromptTemplate>> templatesStream({String? userId}) {
    return _userTemplatesCollection(userId: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PromptTemplate(
          id: doc.id,
          title: data['title'] as String,
          content: data['content'] as String,
          description: data['description'] as String?,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
          isFavorite: data['isFavorite'] as bool? ?? false,
          category: data['category'] as String?,
        );
      }).toList();
    });
  }

  /// テンプレートを作成
  static Future<PromptTemplate> createTemplate({
    required String title,
    required String content,
    String? description,
    String? category,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final template = PromptTemplate(
      id: id,
      title: title,
      content: content,
      description: description,
      createdAt: now,
      updatedAt: now,
      category: category,
    );

    await _userTemplatesCollection().doc(id).set({
      'title': title,
      'content': content,
      'description': description,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'isFavorite': false,
      'category': category,
    });

    return template;
  }

  /// テンプレートを更新
  static Future<void> updateTemplate(PromptTemplate template) async {
    final now = DateTime.now();
    
    await _userTemplatesCollection().doc(template.id).update({
      'title': template.title,
      'content': template.content,
      'description': template.description,
      'updatedAt': Timestamp.fromDate(now),
      'isFavorite': template.isFavorite,
      'category': template.category,
    });
  }

  /// テンプレートを削除
  static Future<void> deleteTemplate(String id) async {
    await _userTemplatesCollection().doc(id).delete();
  }

  /// お気に入りをトグル
  static Future<void> toggleFavorite(String id, bool currentValue) async {
    await _userTemplatesCollection().doc(id).update({
      'isFavorite': !currentValue,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// サンプルテンプレートを作成（初回ログイン時）
  static Future<void> createSampleTemplates() async {
    final templates = await getAllTemplates();
    if (templates.isNotEmpty) return; // 既にテンプレートがある場合はスキップ

    final samples = [
      {
        'title': '記事要約',
        'content': '以下のURLの記事を読んで、主要なポイントを3つに絞って日本語で要約してください。\n\n{{URL}}',
        'description': 'Webページの内容を簡潔に要約',
        'category': '要約',
        'isFavorite': true,
      },
      {
        'title': 'X投稿の分析',
        'content': '以下のX(Twitter)投稿を分析し、投稿者の意図、感情、主張のポイントを解説してください。\n\n{{URL}}',
        'description': 'X.comの投稿を分析',
        'category': 'SNS',
        'isFavorite': false,
      },
      {
        'title': '技術記事の解説',
        'content': '以下の技術記事を読んで、初心者にもわかりやすく解説してください。専門用語があれば簡単な説明を加えてください。\n\n{{URL}}',
        'description': '技術的な内容をわかりやすく解説',
        'category': '技術',
        'isFavorite': false,
      },
      {
        'title': 'お気に入り引用',
        'content': '以下のコンテンツを私のお気に入りとして保存します。このコンテンツの魅力的なポイントと、なぜ興味深いのかを説明してください。\n\n{{URL}}',
        'description': 'お気に入りコンテンツの引用と説明',
        'category': '引用',
        'isFavorite': true,
      },
      {
        'title': 'ニュース要点整理',
        'content': '以下のニュース記事から、5W1H（誰が、何を、いつ、どこで、なぜ、どのように）の形式で要点を整理してください。\n\n{{URL}}',
        'description': 'ニュース記事を5W1Hで整理',
        'category': 'ニュース',
        'isFavorite': false,
      },
    ];

    for (final sample in samples) {
      await createTemplate(
        title: sample['title'] as String,
        content: sample['content'] as String,
        description: sample['description'] as String,
        category: sample['category'] as String,
      );
    }
  }

  /// カテゴリ一覧を取得
  static Future<List<String>> getAllCategories() async {
    try {
      final templates = await getAllTemplates();
      final categories = templates
          .map((t) => t.category)
          .where((c) => c != null && c.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      categories.sort();
      return categories;
    } catch (e) {
      return [];
    }
  }
}
