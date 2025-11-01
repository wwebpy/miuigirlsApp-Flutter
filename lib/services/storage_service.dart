import 'package:hive_flutter/hive_flutter.dart';
import '../models/visionboard.dart';
import '../models/note.dart';
import '../models/reminder.dart';
import '../models/mood.dart';

class StorageService {
  static const String visionboardBox = 'visionboards';
  static const String notesBox = 'notes';
  static const String remindersBox = 'reminders';
  static const String moodsBox = 'moods';

  // Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(VisionboardAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(ReminderAdapter());
    Hive.registerAdapter(MoodAdapter());

    // Open boxes
    await Hive.openBox<Visionboard>(visionboardBox);
    await Hive.openBox<Note>(notesBox);
    await Hive.openBox<Reminder>(remindersBox);
    await Hive.openBox<Mood>(moodsBox);
  }

  // Visionboards
  static Box<Visionboard> get visionboards => Hive.box<Visionboard>(visionboardBox);

  static Future<void> saveVisionboard(Visionboard visionboard) async {
    await visionboards.put(visionboard.id, visionboard);
  }

  static Future<void> deleteVisionboard(String id) async {
    await visionboards.delete(id);
  }

  static List<Visionboard> getAllVisionboards() {
    return visionboards.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // Notes
  static Box<Note> get notes => Hive.box<Note>(notesBox);

  static Future<void> saveNote(Note note) async {
    await notes.put(note.id, note);
  }

  static Future<void> deleteNote(String id) async {
    await notes.delete(id);
  }

  static List<Note> getAllNotes() {
    return notes.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static List<Note> getNotesByType(int type) {
    return notes.values.where((note) => note.noteType == type).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // Reminders
  static Box<Reminder> get reminders => Hive.box<Reminder>(remindersBox);

  static Future<void> saveReminder(Reminder reminder) async {
    await reminders.put(reminder.id, reminder);
  }

  static Future<void> deleteReminder(String id) async {
    await reminders.delete(id);
  }

  static List<Reminder> getAllReminders() {
    return reminders.values.toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  static List<Reminder> getActiveReminders() {
    return reminders.values.where((r) => r.isActive).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  // Moods
  static Box<Mood> get moods => Hive.box<Mood>(moodsBox);

  static Future<void> saveMood(Mood mood) async {
    await moods.put(mood.id, mood);
  }

  static Future<void> deleteMood(String id) async {
    await moods.delete(id);
  }

  static List<Mood> getAllMoods() {
    return moods.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Mood? getMoodForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    try {
      return moods.values.firstWhere(
        (mood) {
          final moodDate = DateTime(mood.date.year, mood.date.month, mood.date.day);
          return moodDate.isAtSameMomentAs(dateOnly);
        },
      );
    } catch (e) {
      return null;
    }
  }

  static List<Mood> getMoodsForDateRange(DateTime start, DateTime end) {
    return moods.values
        .where((mood) => mood.date.isAfter(start) && mood.date.isBefore(end))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
