import 'package:hive/hive.dart';

part 'note.g.dart';

enum NoteType {
  journal,
  affirmation,
  todo,
}

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  int noteType; // 0: journal, 1: affirmation, 2: todo

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  bool isCompleted; // For to-dos

  @HiveField(7)
  String? color; // Hex color for personalization

  @HiveField(8)
  bool isFavorite;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.noteType,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.color,
    this.isFavorite = false,
  });

  NoteType get type {
    switch (noteType) {
      case 0:
        return NoteType.journal;
      case 1:
        return NoteType.affirmation;
      case 2:
        return NoteType.todo;
      default:
        return NoteType.journal;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'noteType': noteType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'color': color,
      'isFavorite': isFavorite,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      noteType: json['noteType'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isCompleted: json['isCompleted'] ?? false,
      color: json['color'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
