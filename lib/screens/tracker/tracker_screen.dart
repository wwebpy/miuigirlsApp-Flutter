import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<void> _showMoodDetails(Mood mood) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;
    final moodColor = _getMoodColor(mood.moodLevel);
    final moodEmoji = _getMoodEmoji(mood.moodLevel);
    final moodLabel = _getMoodLabel(mood.moodLevel);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 44),
                child: Column(
                  children: [
                    // Large Liquid Fill Circle with Glow
                    SizedBox(
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Background Glow Effect
                          OverflowBox(
                            maxWidth: 400,
                            maxHeight: 400,
                            child: Container(
                              width: 400,
                              height: 400,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    moodColor.withOpacity(0.3),
                                    moodColor.withOpacity(0.15),
                                    moodColor.withOpacity(0.05),
                                    moodColor.withOpacity(0),
                                  ],
                                  stops: const [0.0, 0.4, 0.7, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // The actual circle
                          Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: moodColor.withOpacity(0.6),
                                  blurRadius: 50,
                                  offset: const Offset(0, 0),
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Gradient fill
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        moodColor.withOpacity(0.3),
                                        moodColor,
                                      ],
                                    ),
                                  ),
                                ),
                                // Emoji
                                Text(
                                  moodEmoji,
                                  style: const TextStyle(fontSize: 100),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // "I'm feeling..." text
                    Column(
                      children: [
                        Text(
                          'I\'m feeling',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                            letterSpacing: 0,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          moodLabel,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            color: moodColor,
                            letterSpacing: 0,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Date & Time Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.textSecondary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${mood.date.day}.${mood.date.month}.${mood.date.year} • ${mood.date.hour}:${mood.date.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Journal Entry (if exists)
                    if (mood.note != null && mood.note!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colors.textSecondary.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  mood.note!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Activities (if exists)
                    if (mood.activities != null && mood.activities!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'What you were doing',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: mood.activities!.map((activity) =>
                            _buildActivityPill(colors, moodColor, activity)
                          ).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // People (if exists)
                    if (mood.people != null && mood.people!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Who you were with',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: mood.people!.map((person) =>
                            _buildActivityPill(colors, moodColor, person)
                          ).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Places (if exists)
                    if (mood.places != null && mood.places!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Where you were',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: mood.places!.map((place) =>
                            _buildActivityPill(colors, moodColor, place)
                          ).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityPill(dynamic colors, Color moodColor, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: moodColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: moodColor,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
    );
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
          // Calendar - Full width
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: colors.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                    // Custom day builder mit Mini-Emoji-Kreisen
                    defaultBuilder: (context, day, focusedDay) {
                      final events = _getEventsForDay(day);
                      final hasMood = events.isNotEmpty;
                      final isToday = isSameDay(day, DateTime.now());
                      final isSelected = isSameDay(day, _selectedDay);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tag-Nummer
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? colors.primary.withOpacity(0.2)
                                  : Colors.transparent,
                              border: isToday
                                  ? Border.all(
                                      color: colors.primary,
                                      width: 2,
                                    )
                                  : isSelected
                                      ? Border.all(
                                          color: colors.primary,
                                          width: 1.5,
                                        )
                                      : null,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Mini-Farb-Kreise
                          if (hasMood)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: events.take(3).map((event) {
                                final moodColor = _getMoodColor(event.moodLevel);
                                return Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: moodColor,
                                    border: Border.all(
                                      color: colors.background,
                                      width: 1,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      );
                    },
                    // Today builder - gleich wie defaultBuilder, nur isToday ist immer true
                    todayBuilder: (context, day, focusedDay) {
                      final events = _getEventsForDay(day);
                      final hasMood = events.isNotEmpty;
                      final isSelected = isSameDay(day, _selectedDay);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tag-Nummer
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? colors.primary.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: colors.primary,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Mini-Farb-Kreise
                          if (hasMood)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: events.take(3).map((event) {
                                final moodColor = _getMoodColor(event.moodLevel);
                                return Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: moodColor,
                                    border: Border.all(
                                      color: colors.background,
                                      width: 1,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
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
          ),

          // Selected day entries
          Expanded(
            flex: 1,
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
                : Column(
                    children: [
                      // Header Text
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'On that day..',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: selectedDayEntries.length,
                          itemBuilder: (context, index) {
                      final entry = selectedDayEntries[index];
                      return GestureDetector(
                        onTap: () => _showMoodDetails(entry),
                        child: Container(
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
                                    Text(
                                      'You felt ${_getMoodLabel(entry.moodLevel).toLowerCase()}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap to view details',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _getMoodColor(entry.moodLevel),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: colors.textSecondary,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
