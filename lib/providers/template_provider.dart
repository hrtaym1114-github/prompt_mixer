import 'package:flutter/foundation.dart';
import '../models/prompt_template.dart';
import '../services/storage_service.dart';

class TemplateProvider extends ChangeNotifier {
  List<PromptTemplate> _templates = [];
  PromptTemplate? _selectedTemplate;
  String _currentUrl = '';
  String? _selectedCategory;
  bool _showFavoritesOnly = false;

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

  List<String> get categories => StorageService.getAllCategories();

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

  /// 初期化
  void loadTemplates() {
    _templates = StorageService.getAllTemplates();
    notifyListeners();
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
    await StorageService.createTemplate(
      title: title,
      content: content,
      description: description,
      category: category,
    );
    loadTemplates();
  }

  /// テンプレートを更新
  Future<void> updateTemplate(PromptTemplate template) async {
    await StorageService.updateTemplate(template);
    loadTemplates();
    
    // 選択中のテンプレートが更新された場合、再取得
    if (_selectedTemplate?.id == template.id) {
      _selectedTemplate = StorageService.getTemplateById(template.id);
      notifyListeners();
    }
  }

  /// テンプレートを削除
  Future<void> deleteTemplate(String id) async {
    await StorageService.deleteTemplate(id);
    
    // 選択中のテンプレートが削除された場合、選択解除
    if (_selectedTemplate?.id == id) {
      _selectedTemplate = null;
    }
    
    loadTemplates();
  }

  /// お気に入りをトグル
  Future<void> toggleFavorite(String id) async {
    await StorageService.toggleFavorite(id);
    loadTemplates();
    
    // 選択中のテンプレートの場合、再取得
    if (_selectedTemplate?.id == id) {
      _selectedTemplate = StorageService.getTemplateById(id);
      notifyListeners();
    }
  }

  /// 状態をクリア
  void clear() {
    _selectedTemplate = null;
    _currentUrl = '';
    notifyListeners();
  }
}
