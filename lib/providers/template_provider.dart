import 'package:flutter/foundation.dart';
import '../models/prompt_template.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class TemplateProvider extends ChangeNotifier {
  List<PromptTemplate> _templates = [];
  PromptTemplate? _selectedTemplate;
  String _currentUrl = '';
  String? _selectedCategory;
  bool _showFavoritesOnly = false;
  bool _isLoading = false;
  bool _isDevMode = false;

  /// 開発モードかどうか
  bool get isDevMode => _isDevMode;

  List<PromptTemplate> get templates {
    var result = _templates;
    
    if (_showFavoritesOnly) {
      result = result.where((t) => t.isFavorite).toList();
    }
    
    if (_selectedCategory != null) {
      result = result.where((t) => t.category == _selectedCategory).toList();
    }
    
    return result;
  }

  List<PromptTemplate> get allTemplates => _templates;
  PromptTemplate? get selectedTemplate => _selectedTemplate;
  String get currentUrl => _currentUrl;
  String? get selectedCategory => _selectedCategory;
  bool get showFavoritesOnly => _showFavoritesOnly;
  bool get isLoading => _isLoading;

  Future<List<String>> get categories async {
    if (_isDevMode) {
      return StorageService.getAllCategories();
    }
    return await FirestoreService.getAllCategories();
  }

  /// 生成されたプロンプト出力
  String get generatedOutput {
    if (_selectedTemplate == null) {
      return '';
    }
    if (_currentUrl.isEmpty) {
      return _selectedTemplate!.content;
    }
    return _selectedTemplate!.generateOutput(_currentUrl);
  }

  /// 初期化（Firestore または ローカルストレージからロード）
  Future<void> loadTemplates({String? userId, bool isDevMode = false}) async {
    _isLoading = true;
    _isDevMode = isDevMode;
    notifyListeners();

    try {
      if (_isDevMode) {
        // 開発モード: ローカルストレージを使用
        if (kDebugMode) {
          debugPrint('🔧 Dev mode: Loading templates from local storage');
        }
        _templates = StorageService.getAllTemplates();
        if (kDebugMode) {
          debugPrint('✅ Dev mode: Loaded ${_templates.length} templates from local storage');
        }
      } else {
        // 通常モード: Firestoreを使用
        if (kDebugMode) {
          debugPrint('🔄 Loading templates for user: ${userId ?? "current user"}');
        }
        _templates = await FirestoreService.getAllTemplates(userId: userId);
        if (kDebugMode) {
          debugPrint('✅ Loaded ${_templates.length} templates');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Load templates error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// テンプレートをリアルタイム監視
  void startListening({String? userId}) {
    FirestoreService.templatesStream(userId: userId).listen((templates) {
      _templates = templates;
      notifyListeners();
    });
  }

  /// テンプレートを選択
  void selectTemplate(PromptTemplate? template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  /// URLを設定
  void setUrl(String url) {
    _currentUrl = url.trim();
    notifyListeners();
  }

  /// カテゴリフィルターを設定
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// お気に入りフィルターをトグル
  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  /// フィルターをリセット
  void resetFilters() {
    _selectedCategory = null;
    _showFavoritesOnly = false;
    notifyListeners();
  }

  /// テンプレートを作成
  Future<void> createTemplate({
    required String title,
    required String content,
    String? description,
    String? category,
  }) async {
    try {
      if (_isDevMode) {
        // 開発モード: ローカルストレージに保存
        await StorageService.createTemplate(
          title: title,
          content: content,
          description: description,
          category: category,
        );
        await loadTemplates(isDevMode: true);
      } else {
        // 通常モード: Firestoreに保存
        await FirestoreService.createTemplate(
          title: title,
          content: content,
          description: description,
          category: category,
        );
        await loadTemplates();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Create template error: $e');
      }
      rethrow;
    }
  }

  /// テンプレートを更新
  Future<void> updateTemplate(PromptTemplate template) async {
    try {
      if (_isDevMode) {
        // 開発モード: ローカルストレージを更新
        await StorageService.updateTemplate(template);
        await loadTemplates(isDevMode: true);
      } else {
        // 通常モード: Firestoreを更新
        await FirestoreService.updateTemplate(template);
        await loadTemplates();
      }

      // 選択中のテンプレートが更新された場合、再取得
      if (_selectedTemplate?.id == template.id) {
        _selectedTemplate = _templates.firstWhere(
          (t) => t.id == template.id,
          orElse: () => template,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Update template error: $e');
      }
      rethrow;
    }
  }

  /// テンプレートを削除
  Future<void> deleteTemplate(String id) async {
    try {
      if (_isDevMode) {
        // 開発モード: ローカルストレージから削除
        await StorageService.deleteTemplate(id);
        await loadTemplates(isDevMode: true);
      } else {
        // 通常モード: Firestoreから削除
        await FirestoreService.deleteTemplate(id);
        await loadTemplates();
      }

      // 選択中のテンプレートが削除された場合、選択解除
      if (_selectedTemplate?.id == id) {
        _selectedTemplate = null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Delete template error: $e');
      }
      rethrow;
    }
  }

  /// お気に入りをトグル
  Future<void> toggleFavorite(String id) async {
    try {
      final template = _templates.firstWhere((t) => t.id == id);

      if (_isDevMode) {
        // 開発モード: ローカルストレージを更新
        await StorageService.toggleFavorite(id);
        await loadTemplates(isDevMode: true);
      } else {
        // 通常モード: Firestoreを更新
        await FirestoreService.toggleFavorite(id, template.isFavorite);
        await loadTemplates();
      }

      // 選択中のテンプレートの場合、再取得
      if (_selectedTemplate?.id == id) {
        _selectedTemplate = _templates.firstWhere(
          (t) => t.id == id,
          orElse: () => template,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Toggle favorite error: $e');
      }
      rethrow;
    }
  }

  /// 状態をクリア
  void clear() {
    _selectedTemplate = null;
    _currentUrl = '';
    notifyListeners();
  }
}
