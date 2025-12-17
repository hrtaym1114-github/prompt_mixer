import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// 認証状態を管理する Provider
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider({required AuthService authService})
      : _authService = authService {
    // Firebase Auth の状態変更を監視
    _authService.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  User? _user;
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
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
}
