import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/visionboard.dart';
import '../../services/storage_service.dart';
import '../../providers/app_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Visionboard> _visionboards = [];

  @override
  void initState() {
    super.initState();
    _loadVisionboards();
  }

  void _loadVisionboards() {
    setState(() {
      _visionboards = StorageService.getAllVisionboards();
    });
  }

  Future<void> _createVisionboard() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Create Visionboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'My Dream Life',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'What this visionboard represents...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final visionboard = Visionboard(
        id: const Uuid().v4(),
        title: titleController.text,
        description: descController.text.isEmpty ? null : descController.text,
        imagePaths: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await StorageService.saveVisionboard(visionboard);
      _loadVisionboards();
    }
  }

  Future<void> _deleteVisionboard(Visionboard visionboard) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Visionboard?'),
        content: Text('Are you sure you want to delete "${visionboard.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteVisionboard(visionboard.id);
      _loadVisionboards();
    }
  }

  Future<void> _editVisionboard(Visionboard visionboard) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      final newPaths = [...visionboard.imagePaths, ...images.map((e) => e.path)];
      final updated = Visionboard(
        id: visionboard.id,
        title: visionboard.title,
        description: visionboard.description,
        imagePaths: newPaths,
        createdAt: visionboard.createdAt,
        updatedAt: DateTime.now(),
        backgroundColor: visionboard.backgroundColor,
        tags: visionboard.tags,
      );

      await StorageService.saveVisionboard(updated);
      _loadVisionboards();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final colors = appProvider.currentThemeColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Goals & Vision'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _createVisionboard,
          ),
        ],
      ),
      body: _visionboards.isEmpty
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
                      Icons.star_rounded,
                      size: 64,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Visionboards Yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Create your first visionboard to visualize your dreams and goals!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _createVisionboard,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Visionboard'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _visionboards.length,
              itemBuilder: (context, index) {
                final visionboard = _visionboards[index];
                return _buildVisionboardCard(visionboard, colors);
              },
            ),
    );
  }

  Widget _buildVisionboardCard(Visionboard visionboard, colors) {
    return GestureDetector(
      onTap: () => _showVisionboardDetail(visionboard),
      child: Container(
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
            // Image Preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.primaryLight.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: visionboard.imagePaths.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 48,
                          color: colors.primary.withOpacity(0.5),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Image.file(
                              File(visionboard.imagePaths.first),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  size: 48,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                            if (visionboard.imagePaths.length > 1)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '+${visionboard.imagePaths.length - 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
            // Title & Description
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visionboard.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (visionboard.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      visionboard.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVisionboardDetail(Visionboard visionboard) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final colors = appProvider.currentThemeColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visionboard.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (visionboard.description != null)
                          Text(
                            visionboard.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colors.textSecondary,
                                ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.add_photo_alternate_rounded),
                            SizedBox(width: 12),
                            Text('Add Images'),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            _editVisionboard(visionboard);
                            Navigator.pop(context);
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, color: colors.error),
                            const SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: colors.error)),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            _deleteVisionboard(visionboard);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Images Grid
            Expanded(
              child: visionboard.imagePaths.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 64,
                            color: colors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No images yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: colors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              _editVisionboard(visionboard);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add Images'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: visionboard.imagePaths.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(visionboard.imagePaths[index]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: colors.surfaceVariant,
                              child: Icon(
                                Icons.broken_image_rounded,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
