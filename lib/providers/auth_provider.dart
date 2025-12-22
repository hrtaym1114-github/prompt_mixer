import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../config/dev_config.dart';

/// 認証状態を管理する Provider
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider({required AuthService authService})
      : _authService = authService {
    // Firebase Auth の状態変更を監視
    _authService.authStateChanges.listen((user) {
      // 開発モードでログイン中は Firebase の状態変更を無視
      if (!_isDevMode) {
        _user = user;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  User? _user;
  bool _isLoading = true;
  String? _error;
  bool _isDevMode = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null || _isDevMode;
  bool get isLoading => _isLoading;
  bool get isDevMode => _isDevMode;
  String? get error => _error;

  /// アプリ起動時に認証状態をチェック
  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    _user = _authService.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  /// Google ログイン
  Future<void> signInWithGoogle() async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      _user = userCredential?.user;

      // 初回ログイン時にサンプルテンプレートを作成
      if (_user != null) {
        if (kDebugMode) {
          debugPrint('✅ User logged in: ${_user!.uid}');
          debugPrint('🔄 Creating sample templates...');
        }
        try {
          await FirestoreService.createSampleTemplates();
          if (kDebugMode) {
            debugPrint('✅ Sample templates created successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error creating sample templates: $e');
          }
          // エラーがあってもログイン自体は成功させる
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'ログインに失敗しました: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// ログアウト
  Future<void> signOut() async {
    try {
      _error = null;
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = 'ログアウトに失敗しました: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// エラーをクリア
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 開発モードでログイン（認証をスキップ）
  Future<void> signInAsDevUser() async {
    if (!DevConfig.isDevModeAvailable) {
      _error = '開発モードはデバッグビルドでのみ利用可能です';
      notifyListeners();
      return;
    }

    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      _isDevMode = true;
      _user = null; // Firebase User は null だが isAuthenticated は true になる

      if (kDebugMode) {
        debugPrint('🔧 Dev mode login: ${DevConfig.devUserName}');
        debugPrint('📦 Dev mode: Using local storage (Hive) for templates');
      }

      // 開発モードではローカルストレージを使うため、Firestoreへのサンプル作成はスキップ

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '開発モードログインに失敗しました: ${e.toString()}';
      _isLoading = false;
      _isDevMode = false;
      notifyListeners();
    }
  }

  /// 開発モード用のユーザーIDを取得
  String? get devUserId => _isDevMode ? DevConfig.devUserId : null;

  /// 実効ユーザーID（Firebase または 開発モード）
  String? get effectiveUserId => _isDevMode ? DevConfig.devUserId : _user?.uid;

  /// 実効ユーザー名
  String get effectiveUserName =>
      _isDevMode ? DevConfig.devUserName : (_user?.displayName ?? 'ゲスト');
}
