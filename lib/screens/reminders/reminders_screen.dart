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

  Future<void> _createReminder() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;

    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    List<int> selectedDays = [];

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'New Reminder',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Morning meditation',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Take 10 minutes to meditate...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Text(
                  'Time',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setStateDialog(() {
                        selectedTime = time;
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
                          selectedTime.format(context),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Icon(Icons.access_time_rounded),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    'title': titleController.text,
                    'description': descController.text,
                    'time': selectedTime,
                    'days': selectedDays,
                  });
                }
              },
              child: const Text('Create'),
            ),
          ],
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
      );

      await StorageService.saveReminder(reminder);
      await NotificationService.scheduleReminder(reminder);
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

  Future<void> _toggleReminder(Reminder reminder) async {
    final updated = Reminder(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      time: reminder.time,
      repeatDays: reminder.repeatDays,
      isActive: !reminder.isActive,
      createdAt: reminder.createdAt,
      icon: reminder.icon,
      color: reminder.color,
      notificationId: reminder.notificationId,
    );

    await StorageService.saveReminder(updated);

    if (updated.isActive) {
      await NotificationService.scheduleReminder(updated);
    } else {
      await NotificationService.cancelReminder(updated);
    }

    _loadReminders();
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Reminder?'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: colors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await NotificationService.cancelReminder(reminder);
      await StorageService.deleteReminder(reminder.id);
      _loadReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final colors = appProvider.currentThemeColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _createReminder,
          ),
        ],
      ),
      body: _reminders.isEmpty
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
                      Icons.notifications_rounded,
                      size: 64,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Reminders Yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Create reminders for daily routines, affirmations, and goals!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _createReminder,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Reminder'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return _buildReminderCard(reminder, colors);
              },
            ),
    );
  }

  Widget _buildReminderCard(Reminder reminder, colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: reminder.isActive
                  ? colors.primary.withOpacity(0.15)
                  : colors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: reminder.isActive ? colors.primary : colors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: reminder.isActive
                            ? colors.textPrimary
                            : colors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      TimeOfDay.fromDateTime(reminder.time).format(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                    if (reminder.isRepeating) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.repeat_rounded,
                        size: 14,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.repeatDaysText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
                if (reminder.description != null) ...[
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
          Column(
            children: [
              Switch(
                value: reminder.isActive,
                onChanged: (_) => _toggleReminder(reminder),
                activeColor: colors.primary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: colors.error,
                iconSize: 20,
                onPressed: () => _deleteReminder(reminder),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
