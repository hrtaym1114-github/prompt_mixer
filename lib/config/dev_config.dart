import 'package:flutter/foundation.dart';

/// 開発モード設定
class DevConfig {
  /// 開発モードが有効かどうか（デバッグビルドのみ有効）
  static bool get isDevModeAvailable => kDebugMode;

  /// 開発用ユーザーID
  static const String devUserId = 'dev-user-001';

  /// 開発用ユーザー名
  static const String devUserName = '開発者テスト';

  /// 開発用メールアドレス
  static const String devUserEmail = 'dev@example.com';
}
