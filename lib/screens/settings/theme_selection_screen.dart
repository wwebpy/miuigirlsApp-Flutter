import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme_model.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_colors.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final currentThemeColors = appProvider.currentThemeColors;

    return Scaffold(
      backgroundColor: currentThemeColors.background,
      appBar: AppBar(
        backgroundColor: currentThemeColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: currentThemeColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Choose Theme',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: currentThemeColors.textPrimary,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Feminine Themes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: currentThemeColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          ...AppThemes.allThemes.entries
              .where((entry) =>
                  AppThemes.themeCategories[entry.key] == 'Feminine')
              .map((entry) => _buildThemeCard(
                    context,
                    entry.key,
                    AppThemes.themeNames[entry.key]!,
                    entry.value,
                    appProvider.currentThemeId == entry.key,
                    appProvider,
                  )),
          const SizedBox(height: 24),
          Text(
            'Pride & Vibrant',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: currentThemeColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          ...AppThemes.allThemes.entries
              .where((entry) =>
                  AppThemes.themeCategories[entry.key] == 'Pride' ||
                  AppThemes.themeCategories[entry.key] == 'Vibrant')
              .map((entry) => _buildThemeCard(
                    context,
                    entry.key,
                    AppThemes.themeNames[entry.key]!,
                    entry.value,
                    appProvider.currentThemeId == entry.key,
                    appProvider,
                  )),
          const SizedBox(height: 24),
          Text(
            'Neutral Themes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: currentThemeColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          ...AppThemes.allThemes.entries
              .where((entry) =>
                  AppThemes.themeCategories[entry.key] == 'Neutral')
              .map((entry) => _buildThemeCard(
                    context,
                    entry.key,
                    AppThemes.themeNames[entry.key]!,
                    entry.value,
                    appProvider.currentThemeId == entry.key,
                    appProvider,
                  )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    String themeId,
    String themeName,
    ThemeColors colors,
    bool isSelected,
    AppProvider appProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? colors.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          await appProvider.setTheme(themeId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$themeName theme applied!'),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color preview circles
              Row(
                children: [
                  _buildColorCircle(colors.primary),
                  const SizedBox(width: 6),
                  _buildColorCircle(colors.secondary),
                  const SizedBox(width: 6),
                  _buildColorCircle(colors.accent),
                ],
              ),
              const SizedBox(width: 16),
              // Theme name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      themeName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppThemes.themeCategories[themeId]!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Selected indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
