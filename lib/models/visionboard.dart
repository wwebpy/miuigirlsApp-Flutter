import 'package:hive/hive.dart';

part 'visionboard.g.dart';

@HiveType(typeId: 0)
class Visionboard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<String> imagePaths; // Local file paths or URLs

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  String? backgroundColor; // Hex color

  @HiveField(7)
  List<String>? tags;

  Visionboard({
    required this.id,
    required this.title,
    this.description,
    required this.imagePaths,
    required this.createdAt,
    required this.updatedAt,
    this.backgroundColor,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePaths': imagePaths,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'backgroundColor': backgroundColor,
      'tags': tags,
    };
  }

  factory Visionboard.fromJson(Map<String, dynamic> json) {
    return Visionboard(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      backgroundColor: json['backgroundColor'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}
