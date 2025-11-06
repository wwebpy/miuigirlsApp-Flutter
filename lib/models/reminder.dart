import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 2)
class Reminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime time; // Time of day for the reminder

  @HiveField(4)
  List<int> repeatDays; // 1=Monday, 7=Sunday (empty = once)

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String? icon; // Icon name or emoji

  @HiveField(8)
  String? color; // Hex color

  @HiveField(9)
  int? notificationId; // For flutter_local_notifications

  @HiveField(10)
  String? category; // Work, Home, Health, Personal, etc.

  @HiveField(11)
  bool isCompleted;

  @HiveField(12)
  DateTime? dueDate; // Optional due date

  Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.time,
    this.repeatDays = const [],
    this.isActive = true,
    required this.createdAt,
    this.icon,
    this.color,
    this.notificationId,
    this.category,
    this.isCompleted = false,
    this.dueDate,
  });

  bool get isRepeating => repeatDays.isNotEmpty;

  String get repeatDaysText {
    if (repeatDays.isEmpty) return 'Once';
    if (repeatDays.length == 7) return 'Every day';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.map((day) => days[day - 1]).join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time.toIso8601String(),
      'repeatDays': repeatDays,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'icon': icon,
      'color': color,
      'notificationId': notificationId,
      'category': category,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      time: DateTime.parse(json['time']),
      repeatDays: List<int>.from(json['repeatDays'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      icon: json['icon'],
      color: json['color'],
      notificationId: json['notificationId'],
      category: json['category'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }
}
