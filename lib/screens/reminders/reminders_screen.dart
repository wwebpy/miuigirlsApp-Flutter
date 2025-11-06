import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reminder.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../providers/app_provider.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _reminders = [];
  String _selectedFilter = 'All'; // All, Today, Completed
  Set<String> _animatingReminderIds = {}; // IDs der Tasks die gerade animiert werden

  // Categories
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Work', 'icon': Icons.work_rounded, 'color': Color(0xFF6366F1)},
    {'name': 'Home', 'icon': Icons.home_rounded, 'color': Color(0xFFEC4899)},
    {'name': 'Health', 'icon': Icons.favorite_rounded, 'color': Color(0xFFEF4444)},
    {'name': 'Personal', 'icon': Icons.person_rounded, 'color': Color(0xFF8B5CF6)},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded, 'color': Color(0xFF10B981)},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded, 'color': Color(0xFF6B7280)},
  ];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      _reminders = StorageService.getAllReminders();
    });
  }

  List<Reminder> get _filteredReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case 'Today':
        return _reminders.where((r) {
          // Animierende Tasks immer anzeigen
          if (_animatingReminderIds.contains(r.id)) return true;

          if (r.dueDate != null) {
            final dueDay = DateTime(r.dueDate!.year, r.dueDate!.month, r.dueDate!.day);
            return dueDay == today && !r.isCompleted;
          }
          return false;
        }).toList();
      case 'Completed':
        return _reminders.where((r) => r.isCompleted).toList();
      default:
        // 'All' zeigt nur nicht-abgeschlossene Tasks
        return _reminders.where((r) {
          // Animierende Tasks immer anzeigen, auch wenn completed
          if (_animatingReminderIds.contains(r.id)) return true;
          return !r.isCompleted;
        }).toList();
    }
  }

  Future<void> _createReminder() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;

    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    DateTime? selectedDueDate;
    String? selectedCategory;
    List<int> selectedDays = [];

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'New Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Complete project report',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Add details...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = selectedCategory == cat['name'];
                    return GestureDetector(
                      onTap: () {
                        setStateDialog(() {
                          selectedCategory = isSelected ? null : cat['name'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? cat['color'].withOpacity(0.2) : colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? cat['color'] : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'],
                              size: 18,
                              color: isSelected ? cat['color'] : colors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? cat['color'] : colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Text(
                  'Due Date',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setStateDialog(() {
                        selectedDueDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDueDate != null
                              ? '${selectedDueDate!.day}.${selectedDueDate!.month}.${selectedDueDate!.year}'
                              : 'Select date',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Icon(Icons.calendar_today_rounded),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Repeat',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDayChip('Mon', 1, selectedDays, setStateDialog, colors),
                    _buildDayChip('Tue', 2, selectedDays, setStateDialog, colors),
                    _buildDayChip('Wed', 3, selectedDays, setStateDialog, colors),
                    _buildDayChip('Thu', 4, selectedDays, setStateDialog, colors),
                    _buildDayChip('Fri', 5, selectedDays, setStateDialog, colors),
                    _buildDayChip('Sat', 6, selectedDays, setStateDialog, colors),
                    _buildDayChip('Sun', 7, selectedDays, setStateDialog, colors),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
                ),
              ),
              // Bottom Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          Navigator.pop(context, {
                            'title': titleController.text,
                            'description': descController.text,
                            'time': selectedTime,
                            'days': selectedDays,
                            'category': selectedCategory,
                            'dueDate': selectedDueDate,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Create Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      final now = DateTime.now();
      final time = result['time'] as TimeOfDay;
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      final reminder = Reminder(
        id: const Uuid().v4(),
        title: result['title'],
        description: result['description'].isEmpty ? null : result['description'],
        time: reminderTime,
        repeatDays: result['days'],
        createdAt: DateTime.now(),
        category: result['category'],
        dueDate: result['dueDate'],
      );

      await StorageService.saveReminder(reminder);
      await NotificationService.scheduleReminder(reminder);
      _loadReminders();
    }
  }

  Future<void> _editReminder(Reminder reminder) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;

    final titleController = TextEditingController(text: reminder.title);
    final descController = TextEditingController(text: reminder.description ?? '');
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(reminder.time);
    DateTime? selectedDueDate = reminder.dueDate;
    String? selectedCategory = reminder.category;
    List<int> selectedDays = List.from(reminder.repeatDays);

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Edit Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Complete project report',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Add details...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = selectedCategory == cat['name'];
                    return GestureDetector(
                      onTap: () {
                        setStateDialog(() {
                          selectedCategory = isSelected ? null : cat['name'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? cat['color'].withOpacity(0.2) : colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? cat['color'] : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'],
                              size: 18,
                              color: isSelected ? cat['color'] : colors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? cat['color'] : colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Text(
                  'Due Date',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setStateDialog(() {
                        selectedDueDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDueDate != null
                              ? '${selectedDueDate!.day}.${selectedDueDate!.month}.${selectedDueDate!.year}'
                              : 'Select date',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Row(
                          children: [
                            if (selectedDueDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setStateDialog(() {
                                    selectedDueDate = null;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            const SizedBox(width: 8),
                            const Icon(Icons.calendar_today_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Repeat',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDayChip('Mon', 1, selectedDays, setStateDialog, colors),
                    _buildDayChip('Tue', 2, selectedDays, setStateDialog, colors),
                    _buildDayChip('Wed', 3, selectedDays, setStateDialog, colors),
                    _buildDayChip('Thu', 4, selectedDays, setStateDialog, colors),
                    _buildDayChip('Fri', 5, selectedDays, setStateDialog, colors),
                    _buildDayChip('Sat', 6, selectedDays, setStateDialog, colors),
                    _buildDayChip('Sun', 7, selectedDays, setStateDialog, colors),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
                ),
              ),
              // Bottom Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          Navigator.pop(context, {
                            'title': titleController.text,
                            'description': descController.text,
                            'time': selectedTime,
                            'days': selectedDays,
                            'category': selectedCategory,
                            'dueDate': selectedDueDate,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      final now = DateTime.now();
      final time = result['time'] as TimeOfDay;
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      final updated = Reminder(
        id: reminder.id,
        title: result['title'],
        description: result['description'].isEmpty ? null : result['description'],
        time: reminderTime,
        repeatDays: result['days'],
        createdAt: reminder.createdAt,
        category: result['category'],
        dueDate: result['dueDate'],
        isActive: reminder.isActive,
        isCompleted: reminder.isCompleted,
        icon: reminder.icon,
        color: reminder.color,
        notificationId: reminder.notificationId,
      );

      await StorageService.saveReminder(updated);
      await NotificationService.cancelReminder(reminder);
      if (updated.isActive) {
        await NotificationService.scheduleReminder(updated);
      }
      _loadReminders();
    }
  }

  Widget _buildDayChip(
    String label,
    int day,
    List<int> selectedDays,
    StateSetter setStateDialog,
    colors,
  ) {
    final isSelected = selectedDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setStateDialog(() {
          if (selected) {
            selectedDays.add(day);
          } else {
            selectedDays.remove(day);
          }
        });
      },
      selectedColor: colors.primary.withOpacity(0.3),
      checkmarkColor: colors.primary,
    );
  }

  Future<void> _toggleCompleted(Reminder reminder) async {
    final newCompletedState = !reminder.isCompleted;

    // Füge ID zum animating Set hinzu damit der Task sichtbar bleibt
    setState(() {
      _animatingReminderIds.add(reminder.id);
    });

    final updated = Reminder(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      time: reminder.time,
      repeatDays: reminder.repeatDays,
      isActive: reminder.isActive,
      createdAt: reminder.createdAt,
      icon: reminder.icon,
      color: reminder.color,
      notificationId: reminder.notificationId,
      category: reminder.category,
      isCompleted: newCompletedState,
      dueDate: reminder.dueDate,
    );

    // Speichere zuerst
    await StorageService.saveReminder(updated);

    // Update UI für Animation - ändere den Status im lokalen Array
    setState(() {
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index].isCompleted = newCompletedState;
      }
    });

    // Delay damit man die Checkbox-Animation sieht (3 Sekunden)
    await Future.delayed(const Duration(milliseconds: 3000));

    // Entferne ID aus dem animating Set und lade neu
    setState(() {
      _animatingReminderIds.remove(reminder.id);
    });
    _loadReminders();
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    await NotificationService.cancelReminder(reminder);
    await StorageService.deleteReminder(reminder.id);
    _loadReminders();
  }

  Map<String, dynamic>? _getCategoryData(String? category) {
    if (category == null) return null;
    return _categories.firstWhere(
      (cat) => cat['name'] == category,
      orElse: () => _categories.last,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final colors = appProvider.currentThemeColors;
    final filteredReminders = _filteredReminders;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          'ToDo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _createReminder,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: ['All', 'Today', 'Completed'].asMap().entries.map((entry) {
                final index = entry.key;
                final filter = entry.value;
                final isSelected = _selectedFilter == filter;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primary : colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Reminders List
          Expanded(
            child: filteredReminders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.primaryLight.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 64,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _selectedFilter == 'Completed'
                              ? 'No completed tasks'
                              : 'No tasks yet',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            _selectedFilter == 'Completed'
                                ? 'Tasks you complete will appear here'
                                : 'Create your first task to get started!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colors.textSecondary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = filteredReminders[index];
                      return Dismissible(
                        key: Key(reminder.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onDismissed: (_) => _deleteReminder(reminder),
                        child: _buildReminderCard(reminder, colors),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder, colors) {
    final categoryData = _getCategoryData(reminder.category);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isOverdue = false;
    bool isDueToday = false;
    if (reminder.dueDate != null) {
      final dueDay = DateTime(reminder.dueDate!.year, reminder.dueDate!.month, reminder.dueDate!.day);
      isOverdue = dueDay.isBefore(today) && !reminder.isCompleted;
      isDueToday = dueDay == today && !reminder.isCompleted;
    }

    return GestureDetector(
      onTap: () => _editReminder(reminder),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: reminder.isCompleted ? colors.surface.withOpacity(0.5) : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isOverdue
              ? Border.all(color: colors.error, width: 2)
              : isDueToday
                  ? Border.all(color: colors.primary, width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
          // Checkbox with liquid fill animation
          GestureDetector(
            onTap: () => _toggleCompleted(reminder),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: reminder.isCompleted
                      ? colors.primary
                      : colors.textSecondary.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: reminder.isCompleted
                    ? [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    // Background
                    Container(
                      color: colors.surface,
                    ),
                    // Liquid fill animation
                    if (reminder.isCompleted)
                      TweenAnimationBuilder<double>(
                        key: ValueKey('fill_${reminder.id}_${reminder.isCompleted}'),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOutCubic,
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 28 * value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colors.primary.withOpacity(0.9),
                                    colors.primary,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    // Checkmark with scale animation
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: reminder.isCompleted
                            ? Icon(
                                key: ValueKey('check_${reminder.id}'),
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : SizedBox(
                                key: ValueKey('empty_${reminder.id}'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: reminder.isCompleted
                            ? colors.textSecondary
                            : colors.textPrimary,
                        decoration: reminder.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
                if (reminder.dueDate != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: isOverdue
                            ? colors.error
                            : isDueToday
                                ? colors.primary
                                : colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      if (isOverdue) ...[
                        Text(
                          'Due ${reminder.dueDate!.day}.${reminder.dueDate!.month}.${reminder.dueDate!.year}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.error,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Overdue',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.error,
                            ),
                          ),
                        ),
                      ] else if (isDueToday) ...[
                        Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Due ${reminder.dueDate!.day}.${reminder.dueDate!.month}.${reminder.dueDate!.year}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reminder.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Edit Icon
          GestureDetector(
            onTap: () => _editReminder(reminder),
            child: Icon(
              Icons.edit_outlined,
              size: 20,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
