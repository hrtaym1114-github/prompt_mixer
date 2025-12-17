import 'package:flutter/foundation.dart';

/// URL起動サービス
/// Web/モバイル両対応でURLを開く
class UrlLauncherService {
  /// URLを開く
  static Future<bool> launchUrl(String url) async {
    try {
      // Web環境ではwindow.openを使用
      if (kIsWeb) {
        return _launchUrlWeb(url);
      }
      // モバイル環境（将来的にurl_launcherパッケージを使用）
      return _launchUrlWeb(url);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('URL launch error: $e');
      }
      return false;
    }
  }

  /// Web環境でURLを開く
  static bool _launchUrlWeb(String url) {
    try {
      // dart:html を使わずに JavaScript interop で実装
      _openUrl(url);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Web URL launch error: $e');
      }
      return false;
    }
  }

  /// JavaScript経由でURLを開く
  static void _openUrl(String url) {
    // dart:js_interop を使用
    _jsOpen(url);
  }
}

// JavaScript interop
@JS('window.open')
external void _jsOpen(String url);

// JS annotation
class JS {
  final String name;
  const JS([this.name = '']);
}
