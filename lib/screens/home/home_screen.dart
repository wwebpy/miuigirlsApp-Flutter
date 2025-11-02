import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  Mood? _todaysMood;
  List<Note> _recentNotes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
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
        'You are stronger than you think. Keep going!',
        'Every day is a fresh start. Make it count.',
        'Believe in yourself and magic will happen.',
        'Your potential is endless. Go chase your dreams.',
        'You deserve all the good things coming your way.',
        'Small steps every day lead to big changes.',
        'You are capable of amazing things.',
        'Trust the process. Your time is coming.',
        'Be proud of how far you have come.',
        'Your vibe attracts your tribe. Stay positive.',
      ];

  String _getDailyMotivation() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _motivations[dayOfYear % _motivations.length];
  }

  Future<void> _setMood(int moodLevel) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;
    final noteController = TextEditingController(text: _todaysMood?.note ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(
              Mood(
                id: '',
                moodLevel: moodLevel,
                date: DateTime.now(),
              ).emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'How are you feeling?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us why you feel ${Mood(id: '', moodLevel: moodLevel, date: DateTime.now()).label.toLowerCase()} today',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.textSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary, width: 2),
                ),
              ),
              maxLines: 4,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, noteController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      final mood = Mood(
        id: _todaysMood?.id ?? const Uuid().v4(),
        moodLevel: moodLevel,
        date: DateTime.now(),
        note: result.isEmpty ? null : result,
      );

      await StorageService.saveMood(mood);
      setState(() {
        _todaysMood = mood;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood saved!'),
            duration: Duration(seconds: 1),
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
      backgroundColor: colors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting with Profile Icon
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                _getGreeting(),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(_getGreetingEmoji(), style: const TextStyle(fontSize: 28)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              color: colors.primary,
                              size: 22,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to make today amazing?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Daily Motivation Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Daily Motivation',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getDailyMotivation(),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mood Check
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sentiment_satisfied_alt_rounded,
                                color: colors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'How are you feeling today?',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMoodButton('😢', 0, colors.moodTerrible),
                              _buildMoodButton('😕', 1, colors.moodBad),
                              _buildMoodButton('😐', 2, colors.moodOkay),
                              _buildMoodButton('😊', 3, colors.moodGood),
                              _buildMoodButton('🤩', 4, colors.moodAmazing),
                            ],
                          ),
                          if (_todaysMood != null) ...[
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                'Today you feel ${_todaysMood!.label.toLowerCase()}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Goals',
                            StorageService.getAllVisionboards().length.toString(),
                            Icons.star_rounded,
                            colors.accentGold,
                            3, // Goals page index
                            colors,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Notes',
                            StorageService.getAllNotes().length.toString(),
                            Icons.edit_note_rounded,
                            colors.secondary,
                            2, // Notes page index
                            colors,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Activity Header
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Recent Notes
                    if (_recentNotes.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'No notes yet. Start journaling!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colors.textSecondary,
                                ),
                          ),
                        ),
                      )
                    else
                      ..._recentNotes.map((note) => _buildNoteCard(note, colors)),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodButton(String emoji, int level, Color color) {
    final isSelected = _todaysMood?.moodLevel == level;
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;

    return GestureDetector(
      onTap: () => _setMood(level),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: isSelected ? 32 : 28),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, int pageIndex, colors) {
    return InkWell(
      onTap: () {
        if (widget.onNavigate != null) {
          widget.onNavigate!(pageIndex);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note, colors) {
    IconData icon;
    Color iconColor;

    switch (note.noteType) {
      case 0: // journal
        icon = Icons.menu_book_rounded;
        iconColor = colors.primary;
        break;
      case 1: // affirmation
        icon = Icons.favorite_rounded;
        iconColor = colors.accentGold;
        break;
      case 2: // todo
        icon = Icons.check_circle_outline_rounded;
        iconColor = colors.secondary;
        break;
      default:
        icon = Icons.note_rounded;
        iconColor = colors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
