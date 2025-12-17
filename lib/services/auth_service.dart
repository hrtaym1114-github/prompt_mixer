import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;

  /// ユーザーIDを取得
  String? get userId => _auth.currentUser?.uid;

  /// ログイン状態の変更を監視
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Googleでサインイン
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web環境
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // モバイル環境
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Google sign in error: $e');
      }
      rethrow;
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign out error: $e');
      }
      rethrow;
    }
  }

  /// ユーザー表示名を取得
  String get displayName =>
      _auth.currentUser?.displayName ?? 'ゲスト';

  /// ユーザーメールアドレスを取得
  String get email => _auth.currentUser?.email ?? '';

  /// ユーザープロフィール画像URLを取得
  String? get photoURL => _auth.currentUser?.photoURL;
}
