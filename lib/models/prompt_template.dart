import 'package:hive/hive.dart';

part 'prompt_template.g.dart';

@HiveType(typeId: 0)
class PromptTemplate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String? description;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  bool isFavorite;

  @HiveField(7)
  String? category;

  PromptTemplate({
    required this.id,
    required this.title,
    required this.content,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.category,
  });

  /// URLを含んだ最終出力を生成
  String generateOutput(String url) {
    // {{URL}} プレースホルダーをURLに置換
    if (content.contains('{{URL}}')) {
      return content.replaceAll('{{URL}}', url);
    }
    // プレースホルダーがない場合は末尾にURLを追加
    return '$content\n\n参照URL: $url';
  }

  PromptTemplate copyWith({
    String? id,
    String? title,
    String? content,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? category,
  }) {
    return PromptTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
    );
  }
}
