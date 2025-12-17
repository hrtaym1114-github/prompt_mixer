import 'package:flutter/foundation.dart';
import '../models/app_shortcut.dart';
import '../services/storage_service.dart';

class ShortcutProvider extends ChangeNotifier {
  List<AppShortcut> _shortcuts = [];

  List<AppShortcut> get shortcuts => _shortcuts;

  void loadShortcuts() {
    _shortcuts = StorageService.getAllShortcuts();
    notifyListeners();
  }

  Future<void> createShortcut({
    required String name,
    required String urlScheme,
    String? iconName,
    int? colorValue,
  }) async {
    await StorageService.createShortcut(
      name: name,
      urlScheme: urlScheme,
      iconName: iconName,
      colorValue: colorValue,
    );
    loadShortcuts();
  }

  Future<void> updateShortcut(AppShortcut shortcut) async {
    await StorageService.updateShortcut(shortcut);
    loadShortcuts();
  }

  Future<void> deleteShortcut(String id) async {
    await StorageService.deleteShortcut(id);
    loadShortcuts();
  }

  Future<void> reorderShortcuts(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _shortcuts.removeAt(oldIndex);
    _shortcuts.insert(newIndex, item);

    // sortOrderを更新
    for (int i = 0; i < _shortcuts.length; i++) {
      final updated = _shortcuts[i].copyWith(sortOrder: i);
      await StorageService.updateShortcut(updated);
    }
    
    loadShortcuts();
  }
}
