import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/app_provider.dart';
import '../../services/storage_service.dart';
import '../../models/mood.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Mood>> _moodEvents = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMoodEntries();
  }

  void _loadMoodEntries() {
    final allMoods = StorageService.getAllMoods();
    final Map<DateTime, List<Mood>> events = {};

    for (var mood in allMoods) {
      final day = DateTime(mood.date.year, mood.date.month, mood.date.day);
      if (events[day] == null) {
        events[day] = [];
      }
      events[day]!.add(mood);
    }

    setState(() {
      _moodEvents = events;
    });
  }

  List<Mood> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _moodEvents[normalizedDay] ?? [];
  }

  Color _getMoodColor(int moodLevel) {
    switch (moodLevel) {
      case 0:
        return const Color(0xFFFF6B6B); // Terrible
      case 1:
        return const Color(0xFFFFB347); // Bad
      case 2:
        return const Color(0xFFFFE66D); // Okay
      case 3:
        return const Color(0xFFB8E994); // Good
      case 4:
        return const Color(0xFFFFD700); // Amazing
      default:
        return Colors.grey;
    }
  }

  String _getMoodEmoji(int moodLevel) {
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

  String _getMoodLabel(int moodLevel) {
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
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final colors = appProvider.currentThemeColors;
    final selectedDayEntries = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          'Mood Tracker',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Calendar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: colors.textPrimary),
                rightChevronIcon: Icon(Icons.chevron_right, color: colors.textPrimary),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: colors.textSecondary),
                weekendStyle: TextStyle(color: colors.textSecondary),
              ),
            ),
          ),

          // Selected day entries
          Expanded(
            child: selectedDayEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sentiment_neutral_rounded,
                          size: 64,
                          color: colors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No mood entries for this day',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: selectedDayEntries.length,
                    itemBuilder: (context, index) {
                      final entry = selectedDayEntries[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mood indicator
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getMoodColor(entry.moodLevel).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _getMoodEmoji(entry.moodLevel),
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _getMoodLabel(entry.moodLevel),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${entry.date.hour.toString().padLeft(2, '0')}:${entry.date.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.note!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
