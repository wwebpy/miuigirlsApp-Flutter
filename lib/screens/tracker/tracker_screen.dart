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
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Calendar
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.surface,
                  colors.background.withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colors.primary.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: colors.primary.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                // Today - nur Border, keine Füllung
                todayDecoration: BoxDecoration(
                  border: Border.all(
                    color: colors.primary,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                // Selected day
                selectedDecoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.2),
                  border: Border.all(
                    color: colors.primary,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                // Marker ausblenden (wir nutzen calendarBuilders)
                markerDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                // Custom day builder für volle Farbe oder Gradient
                defaultBuilder: (context, day, focusedDay) {
                  final events = _getEventsForDay(day);
                  final hasMood = events.isNotEmpty;
                  final isToday = isSameDay(day, DateTime.now());
                  final isSelected = isSameDay(day, _selectedDay);

                  if (hasMood) {
                    // Ein Mood = volle Farbe
                    if (events.length == 1) {
                      final moodColor = _getMoodColor(events.first.moodLevel);

                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: moodColor,
                          border: isToday
                              ? Border.all(
                                  color: colors.primary,
                                  width: 2.5,
                                )
                              : isSelected
                                  ? Border.all(
                                      color: colors.primary,
                                      width: 2,
                                    )
                                  : null,
                          boxShadow: [
                            BoxShadow(
                              color: moodColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    // Mehrere Moods = Gradient
                    final moodColors = events.map((e) => _getMoodColor(e.moodLevel)).toList();

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: moodColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: isToday
                            ? Border.all(
                                color: colors.primary,
                                width: 2.5,
                              )
                            : isSelected
                                ? Border.all(
                                    color: colors.primary,
                                    width: 2,
                                  )
                                : null,
                        boxShadow: [
                          BoxShadow(
                            color: moodColors.first.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  // Tage OHNE Mood - normale Darstellung
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                      border: isToday
                          ? Border.all(
                              color: colors.primary,
                              width: 2.5,
                            )
                          : isSelected
                              ? Border.all(
                                  color: colors.primary.withOpacity(0.4),
                                  width: 2,
                                )
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
                // Today builder
                todayBuilder: (context, day, focusedDay) {
                  final events = _getEventsForDay(day);
                  final hasMood = events.isNotEmpty;

                  if (hasMood) {
                    // Ein Mood = volle Farbe
                    if (events.length == 1) {
                      final moodColor = _getMoodColor(events.first.moodLevel);

                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: moodColor,
                          border: Border.all(
                            color: colors.primary,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: moodColor.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    // Mehrere Moods = Gradient
                    final moodColors = events.map((e) => _getMoodColor(e.moodLevel)).toList();

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: moodColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: colors.primary,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: moodColors.first.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  // Today ohne Mood
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                      border: Border.all(
                        color: colors.primary,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 12),
                leftChevronIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_left, color: colors.primary, size: 20),
                ),
                rightChevronIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_right, color: colors.primary, size: 20),
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
                weekendStyle: TextStyle(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
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
