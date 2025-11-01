import 'package:hive/hive.dart';

part 'mood.g.dart';

enum MoodLevel {
  terrible,
  bad,
  okay,
  good,
  amazing,
}

@HiveType(typeId: 3)
class Mood extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int moodLevel; // 0: terrible, 1: bad, 2: okay, 3: good, 4: amazing

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? note;

  @HiveField(4)
  List<String>? tags; // e.g., "productive", "tired", "energetic"

  Mood({
    required this.id,
    required this.moodLevel,
    required this.date,
    this.note,
    this.tags,
  });

  MoodLevel get level {
    switch (moodLevel) {
      case 0:
        return MoodLevel.terrible;
      case 1:
        return MoodLevel.bad;
      case 2:
        return MoodLevel.okay;
      case 3:
        return MoodLevel.good;
      case 4:
        return MoodLevel.amazing;
      default:
        return MoodLevel.okay;
    }
  }

  String get emoji {
    switch (moodLevel) {
      case 0:
        return '😢';
      case 1:
        return '😕';
      case 2:
        return '😐';
      case 3:
        return '😊';
      case 4:
        return '🤩';
      default:
        return '😐';
    }
  }

  String get label {
    switch (moodLevel) {
      case 0:
        return 'Terrible';
      case 1:
        return 'Bad';
      case 2:
        return 'Okay';
      case 3:
        return 'Good';
      case 4:
        return 'Amazing';
      default:
        return 'Okay';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moodLevel': moodLevel,
      'date': date.toIso8601String(),
      'note': note,
      'tags': tags,
    };
  }

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'],
      moodLevel: json['moodLevel'],
      date: DateTime.parse(json['date']),
      note: json['note'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}
