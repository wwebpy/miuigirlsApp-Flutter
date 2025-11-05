import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/mood.dart';
import '../../models/note.dart';
import '../../services/storage_service.dart';
import '../../providers/app_provider.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Mood? _todaysMood;
  List<Note> _recentNotes = [];
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late PageController _carouselController;
  int? _selectedMoodIndex;
  int _currentCarouselIndex = 3; // Start in der Mitte (leerer Kreis)

  @override
  void initState() {
    super.initState();
    _loadData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _carouselController = PageController(
      initialPage: 3, // Start beim leeren Kreis (Index 3)
      viewportFraction: 0.25, // Zeigt mehr Buttons gleichzeitig
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  void _loadData() {
    final mood = StorageService.getMoodForDate(DateTime.now());
    if (mood != null && mood.id.isNotEmpty) {
      setState(() {
        _todaysMood = mood;
      });
    }

    final notes = StorageService.getAllNotes();
    setState(() {
      _recentNotes = notes.take(3).toList();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    if (hour < 17) return '☀️';
    return '🌙';
  }

  List<String> get _motivations => [
        'You are stronger than you think',
        'Every day is a fresh start',
        'Believe in yourself and magic will happen',
        'Your potential is endless',
        'You deserve all the good things',
        'Small steps lead to big changes',
        'You are capable of amazing things',
        'Trust the process',
        'Be proud of how far you have come',
        'Your vibe attracts your tribe',
      ];

  String _getDailyMotivation() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _motivations[dayOfYear % _motivations.length];
  }

  Future<void> _showMoodDetails(Mood mood) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;
    final moodColor = _getMoodColor(mood.moodLevel);
    final moodEmoji = mood.emoji;
    final moodLabel = mood.label;

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
                            _buildActivityPill(colors, moodColor, activity, true, () {})
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
                            _buildActivityPill(colors, moodColor, person, true, () {})
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
                            _buildActivityPill(colors, moodColor, place, true, () {})
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

  Future<void> _showMoodDetailsWithEdit(Mood mood) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;
    final moodColor = _getMoodColor(mood.moodLevel);
    final moodEmoji = mood.emoji;
    final moodLabel = mood.label;

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
            // Drag handle and Edit button
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60), // Balance the space
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _setMood(mood.moodLevel);
                    },
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24),
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
                            _buildActivityPill(colors, moodColor, activity, true, () {})
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
                            _buildActivityPill(colors, moodColor, person, true, () {})
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
                            _buildActivityPill(colors, moodColor, place, true, () {})
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

  Future<void> _setMood(int moodLevel) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;
    final noteController = TextEditingController(text: _todaysMood?.note ?? '');
    final moodColor = _getMoodColor(moodLevel);
    final moodEmoji = Mood(id: '', moodLevel: moodLevel, date: DateTime.now()).emoji;
    final moodLabel = Mood(id: '', moodLevel: moodLevel, date: DateTime.now()).label;

    // State for activity pills
    final selectedActivities = <String>{};
    final selectedPeople = <String>{};
    final selectedPlaces = <String>{};

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
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
                              // Background Glow Effect (using OverflowBox to not take vertical space)
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
                                  // Wave effect (simplified liquid fill)
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
                            '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year} • ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Journal Entry Block
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GestureDetector(
                          onTap: () async {
                            final text = await Navigator.of(context).push<String>(
                              MaterialPageRoute(
                                builder: (context) => _buildTextInputScreen(colors, moodColor, noteController),
                              ),
                            );
                            if (text != null) {
                              noteController.text = text;
                            }
                          },
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
                                    noteController.text.isEmpty ? 'Add Journal Entry' : noteController.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: noteController.text.isEmpty
                                        ? colors.textSecondary.withOpacity(0.6)
                                        : colors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.edit_rounded, color: colors.textSecondary, size: 22),
                                const SizedBox(width: 8),
                                Icon(Icons.camera_alt_rounded, color: colors.textSecondary, size: 22),
                                const SizedBox(width: 8),
                                Icon(Icons.mic_rounded, color: colors.textSecondary, size: 22),
                              ],
                            ),
                          ),
                        ),
                        ),

                        const SizedBox(height: 32),

                        // What are you doing?
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'What are you doing?',
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
                            children: [
                              _buildActivityPill(colors, moodColor, 'Working', selectedActivities.contains('Working'), () {
                                setState(() {
                                  if (selectedActivities.contains('Working')) {
                                    selectedActivities.remove('Working');
                                  } else {
                                    selectedActivities.add('Working');
                                  }
                                });
                              }),
                              _buildActivityPill(colors, moodColor, 'Relaxing', selectedActivities.contains('Relaxing'), () {
                                setState(() {
                                  if (selectedActivities.contains('Relaxing')) {
                                    selectedActivities.remove('Relaxing');
                                  } else {
                                    selectedActivities.add('Relaxing');
                                  }
                                });
                              }),
                              _buildActivityPill(colors, moodColor, 'Exercising', selectedActivities.contains('Exercising'), () {
                                setState(() {
                                  if (selectedActivities.contains('Exercising')) {
                                    selectedActivities.remove('Exercising');
                                  } else {
                                    selectedActivities.add('Exercising');
                                  }
                                });
                              }),
                              _buildActivityPill(colors, moodColor, 'Eating', selectedActivities.contains('Eating'), () {
                                setState(() {
                                  if (selectedActivities.contains('Eating')) {
                                    selectedActivities.remove('Eating');
                                  } else {
                                    selectedActivities.add('Eating');
                                  }
                                });
                              }),
                              _buildActivityPill(colors, moodColor, 'Socializing', selectedActivities.contains('Socializing'), () {
                                setState(() {
                                  if (selectedActivities.contains('Socializing')) {
                                    selectedActivities.remove('Socializing');
                                  } else {
                                    selectedActivities.add('Socializing');
                                  }
                                });
                              }),
                              _buildAddPill(colors, moodColor),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Who are you with?
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Who are you with?',
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
                            children: [
                              _buildActivityPill(colors, moodColor, 'Alone', selectedPeople.contains('Alone'), () {
                                setState(() {
                                  if (selectedPeople.contains('Alone')) {
                                    selectedPeople.remove('Alone');
                                  } else {
                                    selectedPeople.add('Alone');
                                  }
                                });
                              }),
                              _buildActivityPill(colors, moodColor, 'Friends', selectedPeople.contains('Friends'), () {
                                setState(() {
                                  if (selectedPeople.contains('Friends')) {
                                    selectedPeople.remove('Friends');
                                  } else {
                                    selectedPeople.add('Friends');
                                  }
                                });
                              }),
                              _buildActivityPill(colors, moodColor, 'Family', selectedPeople.contains('Family'), () {
                                setState(() {
                                  if (selectedPeople.contains('Family')) {
                                    selectedPeople.remove('Family');
                                  } else {
                                    selectedPeople.add('Family');
                                  }
                                });
                              }),
                              _buildActivityPill(colors, moodColor, 'Partner', selectedPeople.contains('Partner'), () {
                                setState(() {
                                  if (selectedPeople.contains('Partner')) {
                                    selectedPeople.remove('Partner');
                                  } else {
                                    selectedPeople.add('Partner');
                                  }
                                });
                              }),
                              _buildAddPill(colors, moodColor),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Where are you?
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Where are you?',
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
                            children: [
                              _buildActivityPill(colors, moodColor, 'Home', selectedPlaces.contains('Home'), () {
                                setState(() {
                                  if (selectedPlaces.contains('Home')) {
                                    selectedPlaces.remove('Home');
                                  } else {
                                    selectedPlaces.add('Home');
                                  }
                                });
                              }),
                              _buildActivityPill(colors, moodColor, 'Work', selectedPlaces.contains('Work'), () {
                                setState(() {
                                  if (selectedPlaces.contains('Work')) {
                                    selectedPlaces.remove('Work');
                                  } else {
                                    selectedPlaces.add('Work');
                                  }
                                });
                              }),
                              _buildActivityPill(colors, moodColor, 'Outside', selectedPlaces.contains('Outside'), () {
                                setState(() {
                                  if (selectedPlaces.contains('Outside')) {
                                    selectedPlaces.remove('Outside');
                                  } else {
                                    selectedPlaces.add('Outside');
                                  }
                                });
                              }),
                              _buildActivityPill(colors, moodColor, 'Traveling', selectedPlaces.contains('Traveling'), () {
                                setState(() {
                                  if (selectedPlaces.contains('Traveling')) {
                                    selectedPlaces.remove('Traveling');
                                  } else {
                                    selectedPlaces.add('Traveling');
                                  }
                                });
                              }),
                              _buildAddPill(colors, moodColor),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Complete Check-in Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, noteController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: moodColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Complete check-in',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        ),

                        const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );

    if (result != null) {
      final mood = Mood(
        id: _todaysMood?.id ?? const Uuid().v4(),
        moodLevel: moodLevel,
        date: DateTime.now(),
        note: result.isEmpty ? null : result,
        activities: selectedActivities.isNotEmpty ? selectedActivities.toList() : null,
        people: selectedPeople.isNotEmpty ? selectedPeople.toList() : null,
        places: selectedPlaces.isNotEmpty ? selectedPlaces.toList() : null,
      );

      await StorageService.saveMood(mood);
      setState(() {
        _todaysMood = mood;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mood saved!'),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final colors = appProvider.currentThemeColors;

    return Scaffold(
      body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header with greeting
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Profile Button (without pill background)
                          IconButton(
                            icon: Icon(Icons.person_rounded, color: colors.primary, size: 28),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              );
                            },
                          ),

                          // Greeting Pill (Center)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: colors.surface.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: colors.primary.withOpacity(0.2), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getGreetingEmoji(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Notifications Button (without pill background)
                          IconButton(
                            icon: Icon(Icons.notifications_outlined, color: colors.primary, size: 28),
                            onPressed: () {
                              // TODO: Navigate to notifications
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Mood Map Section
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _animationController,
                    child: _buildMoodMap(colors),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
    );
  }

  Color _getMoodColor(int moodLevel) {
    switch (moodLevel) {
      case 0:
        return const Color(0xFFFF6B6B);
      case 1:
        return const Color(0xFFFFB347);
      case 2:
        return const Color(0xFFFFE66D);
      case 3:
        return const Color(0xFFB8E994);
      case 4:
        return const Color(0xFFFFD700);
      default:
        return Colors.grey;
    }
  }

  Map<String, String> _getMoodMessage(int moodLevel) {
    switch (moodLevel) {
      case 0:
        return {'bold': 'Schade,', 'text': 'dass es dir nicht gut geht'};
      case 1:
        return {'bold': 'Kopf hoch!', 'text': 'Morgen wird besser'};
      case 2:
        return {'bold': 'Okay', 'text': 'ist auch in Ordnung'};
      case 3:
        return {'bold': 'Wunderbar!', 'text': 'Schön, dass es dir gut geht'};
      case 4:
        return {'bold': 'Fantastisch!', 'text': 'Du strahlst heute'};
      default:
        return {'bold': 'Hallo', 'text': 'wie geht es dir?'};
    }
  }

  Widget _buildMoodMap(colors) {
    final moodData = [
      {'label': 'Terrible', 'emoji': '😢', 'color': const Color(0xFFFF6B6B), 'level': 0, 'isEmpty': false},
      {'label': 'Not Great', 'emoji': '😕', 'color': const Color(0xFFFFB347), 'level': 1, 'isEmpty': false},
      {'label': 'Okay', 'emoji': '😐', 'color': const Color(0xFFFFE66D), 'level': 2, 'isEmpty': false},
      {'label': 'No Selection', 'emoji': '', 'color': colors.textSecondary, 'level': -1, 'isEmpty': true}, // Leerer Kreis in der Mitte
      {'label': 'Good', 'emoji': '😊', 'color': const Color(0xFFB8E994), 'level': 3, 'isEmpty': false},
      {'label': 'Amazing', 'emoji': '🤩', 'color': const Color(0xFFFFD700), 'level': 4, 'isEmpty': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Title
          Center(
            child: Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
                letterSpacing: -1.2,
                height: 1.05,
                shadows: [
                  Shadow(
                    color: colors.textPrimary.withOpacity(0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Liquid Fill Container
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  // Subtle wobble effect
                  final wobbleX = math.sin(_pulseController.value * 2 * math.pi) * 2;
                  final wobbleY = math.cos(_pulseController.value * 2 * math.pi) * 1.5;
                  final pulseValue = 1.0 + (math.sin(_pulseController.value * 2 * math.pi) * 0.03);

                  return Transform.translate(
                    offset: Offset(wobbleX, wobbleY),
                    child: Transform.scale(
                      scale: pulseValue,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow rings - MEGA VERSTÄRKT
                          if (_todaysMood != null) ...[
                            // Äußerster Glow Ring (sehr groß)
                            Container(
                              width: 500,
                              height: 500,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0),
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.2),
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.12),
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.06),
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0),
                                  ],
                                  stops: const [0.2, 0.5, 0.7, 0.85, 1.0],
                                ),
                              ),
                            ),
                            // Mittlerer Glow Ring
                            Container(
                              width: 380,
                              height: 380,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0),
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.3),
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.15),
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0),
                                  ],
                                  stops: const [0.3, 0.6, 0.8, 1.0],
                                ),
                              ),
                            ),
                            // Innerer Glow Ring
                            Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0),
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.35),
                                    _getMoodColor(_todaysMood!.moodLevel).withOpacity(0),
                                  ],
                                  stops: const [0.4, 0.7, 1.0],
                                ),
                              ),
                            ),
                          ],

                          // Main liquid container
                          GestureDetector(
                            onTap: _todaysMood != null ? () {
                              _showMoodDetails(_todaysMood!);
                            } : null,
                            child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.primary.withOpacity(0.2),
                                width: 3,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  colors.background.withOpacity(0.95),
                                  colors.surface.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withOpacity(0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                                // MEGA VERSTÄRKTER Glow Shadow
                                if (_todaysMood != null) ...[
                                  BoxShadow(
                                    color: _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.6),
                                    blurRadius: 100,
                                    offset: const Offset(0, 0),
                                    spreadRadius: 30,
                                  ),
                                  BoxShadow(
                                    color: _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.4),
                                    blurRadius: 70,
                                    offset: const Offset(0, 5),
                                    spreadRadius: 20,
                                  ),
                                  BoxShadow(
                                    color: _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.3),
                                    blurRadius: 50,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ],
                            ),
                            child: ClipOval(
                              child: Stack(
                                children: [
                                  // Background gradient
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colors.background.withOpacity(0.95),
                                          colors.surface.withOpacity(0.5),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                  // Liquid fill with wave effect
                                  if (_todaysMood != null)
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 1200),
                                        curve: Curves.easeInOutCubic,
                                        height: 250 * ((_todaysMood!.moodLevel + 1) / 5.0),
                                        child: CustomPaint(
                                          painter: WavePainter(
                                            color: _getMoodColor(_todaysMood!.moodLevel),
                                            waveOffset: _pulseController.value * 2 * math.pi,
                                          ),
                                          size: const Size(250, 250),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          ),

                          // Shine effect
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.5, -0.5),
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.3, 1.0],
                              ),
                            ),
                          ),

                          // Center text with fade-in animation
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 1500),
                            switchOutCurve: Curves.easeOut,
                            switchInCurve: Curves.easeInOutCubic,
                            reverseDuration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _todaysMood != null
                                ? Container(
                                    key: ValueKey(_todaysMood!.moodLevel),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _getMoodMessage(_todaysMood!.moodLevel)['bold']!,
                                          style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w900,
                                            color: colors.textPrimary,
                                            height: 1.05,
                                            letterSpacing: -0.8,
                                            shadows: [
                                              Shadow(
                                                color: colors.textPrimary.withOpacity(0.2),
                                                offset: const Offset(0, 1),
                                                blurRadius: 1,
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _getMoodMessage(_todaysMood!.moodLevel)['text']!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: colors.textSecondary,
                                            height: 1.25,
                                            letterSpacing: -0.3,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    key: const ValueKey('empty'),
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      'Wähle dein Mood',
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                        color: colors.textSecondary.withOpacity(0.5),
                                        letterSpacing: -0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 50),

          // Option A: Clean Carousel (neu gebaut)
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _carouselController,
              clipBehavior: Clip.none,
              onPageChanged: (index) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
              itemCount: moodData.length,
              itemBuilder: (context, index) {
                final mood = moodData[index];
                final moodLevel = mood['level'] as int;
                final color = mood['color'] as Color;
                final label = mood['label'] as String;
                final emoji = mood['emoji'] as String;
                final isEmpty = mood['isEmpty'] as bool;
                final isCenter = index == _currentCarouselIndex;

                return GestureDetector(
                  onTap: () {
                    if (!isCenter) {
                      _carouselController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else if (!isEmpty) {
                      setState(() => _selectedMoodIndex = moodLevel);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _setMood(moodLevel);
                      });
                    }
                  },
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: isCenter ? 90 : 65,
                      height: isCenter ? 90 : 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isCenter && !isEmpty
                            ? LinearGradient(
                                colors: [
                                  color,
                                  color.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isEmpty
                            ? colors.surface.withOpacity(0.5)
                            : (isCenter ? null : color.withOpacity(0.15)),
                        boxShadow: isCenter
                            ? [
                                BoxShadow(
                                  color: isEmpty
                                      ? colors.shadow.withOpacity(0.1)
                                      : color.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                        border: Border.all(
                          color: isEmpty
                              ? colors.textSecondary.withOpacity(0.3)
                              : (isCenter ? Colors.white.withOpacity(0.9) : color.withOpacity(0.3)),
                          width: isCenter ? 2.5 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: isEmpty
                            ? Icon(
                                Icons.remove,
                                color: colors.textSecondary.withOpacity(0.4),
                                size: isCenter ? 28 : 20,
                              )
                            : Text(
                                emoji,
                                style: TextStyle(
                                  fontSize: isCenter ? 40 : 28,
                                ),
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Label unter dem Carousel
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              moodData[_currentCarouselIndex]['label'] as String,
              key: ValueKey(_currentCarouselIndex),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Instruction Text
          Text(
            'Swipe to select',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),

          if (_todaysMood != null) ...[
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Emotionen von Heute',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showMoodDetailsWithEdit(_todaysMood!),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.15),
                      _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getMoodColor(_todaysMood!.moodLevel),
                            _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getMoodColor(_todaysMood!.moodLevel).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _todaysMood!.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You\'re feeling ${_todaysMood!.label.toLowerCase()} today!',
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
                              color: _getMoodColor(_todaysMood!.moodLevel),
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRadialMoodItem({
    required String emoji,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseValue = isSelected
              ? 1.0 + (_pulseController.value * 0.12)
              : 1.0 + (_pulseController.value * 0.05);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Transform.scale(
              scale: isSelected ? 1.2 : pulseValue,
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          color,
                          color.withOpacity(0.6),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(isSelected ? 0.6 : 0.4),
                          blurRadius: isSelected ? 24 : 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isSelected ? 13 : 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? color : color.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodBlob({
    required String label,
    required Color color,
    required double size,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseValue = isSelected
              ? 1.0 + (_pulseController.value * 0.15)
              : 1.0 + (_pulseController.value * 0.08);

          return Transform.scale(
            scale: isSelected ? 1.15 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: Column(
                children: [
                  Container(
                    width: size * pulseValue,
                    height: size * pulseValue,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          color,
                          color.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(isSelected ? 0.6 : 0.3),
                          blurRadius: isSelected ? 32 : 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Center(
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: size * 0.4,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isSelected ? 15 : 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? color : color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper: Build Activity Pill
  Widget _buildActivityPill(dynamic colors, Color moodColor, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? moodColor.withOpacity(0.2) : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? moodColor : colors.textSecondary.withOpacity(0.15),
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
      ),
    );
  }

  // Helper: Build Add Pill
  Widget _buildAddPill(dynamic colors, Color moodColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.add_rounded,
        color: colors.textPrimary,
        size: 20,
      ),
    );
  }

  // Helper: Build Text Input Screen
  Widget _buildTextInputScreen(dynamic colors, Color moodColor, TextEditingController controller) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_rounded, color: moodColor, size: 28),
            onPressed: () => Navigator.pop(context, controller.text),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'What\'s on your mind?',
            hintStyle: TextStyle(
              color: colors.textSecondary.withOpacity(0.5),
              fontSize: 18,
            ),
            border: InputBorder.none,
          ),
          maxLines: null,
          autofocus: true,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

// Custom painter for wave animation
class WavePainter extends CustomPainter {
  final Color color;
  final double waveOffset;

  WavePainter({required this.color, required this.waveOffset});

  @override
  void paint(Canvas canvas, Size size) {
    // Main wave with gradient (light on top, dark at bottom)
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 20);

    // Create smooth wave
    for (double i = 0; i <= size.width; i += 0.5) {
      final wave1 = math.sin((i / size.width * 4 * math.pi) + waveOffset) * 8;
      final wave2 = math.sin((i / size.width * 2 * math.pi) - waveOffset * 0.5) * 5;
      final y = 15 + wave1 + wave2;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, 20);
    path.lineTo(size.width, size.height);
    path.close();

    // Gradient paint - lighter on top, darker at bottom
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _lightenColor(color, 0.3), // Much lighter at top
          _lightenColor(color, 0.15), // Slightly lighter
          color, // Original color in middle
          _darkenColor(color, 0.15), // Slightly darker
          _darkenColor(color, 0.25), // Darker at bottom
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Second wave layer with lighter gradient overlay
    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, 10);

    for (double i = 0; i <= size.width; i += 0.5) {
      final wave1 = math.sin((i / size.width * 3 * math.pi) - waveOffset * 1.5) * 6;
      final wave2 = math.sin((i / size.width * 1.5 * math.pi) + waveOffset) * 4;
      final y = 8 + wave1 + wave2;
      path2.lineTo(i, y);
    }

    path2.lineTo(size.width, 10);
    path2.lineTo(size.width, size.height);
    path2.close();

    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.4), // Bright highlight at top
          Colors.white.withOpacity(0.2),
          color.withOpacity(0.3),
          color.withOpacity(0.5),
        ],
        stops: const [0.0, 0.2, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path2, paint2);

    // Subtle shimmer effect on top
    final shimmerPath = Path();
    shimmerPath.moveTo(0, 0);
    for (double i = 0; i <= size.width; i += 0.5) {
      final wave = math.sin((i / size.width * 6 * math.pi) + waveOffset * 2) * 3;
      shimmerPath.lineTo(i, wave);
    }
    shimmerPath.lineTo(size.width, 0);
    shimmerPath.close();

    final shimmerPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    canvas.drawPath(shimmerPath, shimmerPaint);
  }

  // Helper function to lighten a color
  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Helper function to darken a color
  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.waveOffset != waveOffset;
  }
}
