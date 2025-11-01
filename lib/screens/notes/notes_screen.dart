import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/note.dart';
import '../../services/storage_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Note> _journals = [];
  List<Note> _affirmations = [];
  List<Note> _todos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    final notes = StorageService.getAllNotes();
    setState(() {
      _journals = notes.where((n) => n.noteType == 0).toList();
      _affirmations = notes.where((n) => n.noteType == 1).toList();
      _todos = notes.where((n) => n.noteType == 2).toList();
    });
  }

  Future<void> _createNote(int noteType) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    String dialogTitle;
    String hintTitle;
    String hintContent;

    switch (noteType) {
      case 0: // Journal
        dialogTitle = 'New Journal Entry';
        hintTitle = 'Today\'s thoughts';
        hintContent = 'Write about your day, feelings, or experiences...';
        break;
      case 1: // Affirmation
        dialogTitle = 'New Affirmation';
        hintTitle = 'Affirmation title';
        hintContent = 'I am strong, capable, and worthy of all good things...';
        break;
      case 2: // To-Do
        dialogTitle = 'New To-Do';
        hintTitle = 'Task';
        hintContent = 'What needs to be done?';
        break;
      default:
        return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          dialogTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: hintTitle,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  hintText: hintContent,
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final note = Note(
        id: const Uuid().v4(),
        title: titleController.text,
        content: contentController.text,
        noteType: noteType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await StorageService.saveNote(note);
      _loadNotes();
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Note?'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteNote(note.id);
      _loadNotes();
    }
  }

  Future<void> _toggleTodo(Note todo) async {
    final updated = Note(
      id: todo.id,
      title: todo.title,
      content: todo.content,
      noteType: todo.noteType,
      createdAt: todo.createdAt,
      updatedAt: DateTime.now(),
      isCompleted: !todo.isCompleted,
      color: todo.color,
      isFavorite: todo.isFavorite,
    );

    await StorageService.saveNote(updated);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _createNote(_tabController.index),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Journal'),
            Tab(text: 'Affirmations'),
            Tab(text: 'To-Dos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotesList(_journals, 0),
          _buildNotesList(_affirmations, 1),
          _buildTodosList(_todos),
        ],
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes, int type) {
    if (notes.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildTodosList(List<Note> todos) {
    if (todos.isEmpty) {
      return _buildEmptyState(2);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _buildTodoCard(todo);
      },
    );
  }

  Widget _buildEmptyState(int type) {
    String title;
    String message;
    IconData icon;

    switch (type) {
      case 0:
        title = 'No Journal Entries';
        message = 'Start journaling to track your thoughts and experiences.';
        icon = Icons.menu_book_rounded;
        break;
      case 1:
        title = 'No Affirmations';
        message = 'Create affirmations to boost your confidence and positivity.';
        icon = Icons.favorite_rounded;
        break;
      case 2:
        title = 'No To-Dos';
        message = 'Add tasks to stay organized and productive.';
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        return const SizedBox();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNote(type),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    IconData icon;
    Color iconColor;

    switch (note.noteType) {
      case 0: // journal
        icon = Icons.menu_book_rounded;
        iconColor = AppColors.primary;
        break;
      case 1: // affirmation
        icon = Icons.favorite_rounded;
        iconColor = AppColors.accentGold;
        break;
      default:
        icon = Icons.note_rounded;
        iconColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(note.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.error,
            onPressed: () => _deleteNote(note),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(Note todo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleTodo(todo),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: todo.isCompleted
                    ? AppColors.success
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: todo.isCompleted
                      ? AppColors.success
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: todo.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  todo.content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.error,
            onPressed: () => _deleteNote(todo),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
