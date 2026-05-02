import 'package:flutter/material.dart';
import 'package:pal_journal/services/theme_service.dart';

class ListTileThemeMode extends StatelessWidget {
  const ListTileThemeMode({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, currentMode, child) {
        IconData modeIcon = Icons.brightness_auto;
        String modeName = "System";

        if (currentMode == .light) {
          modeIcon = Icons.light_mode;
          modeName = "Light";
        } else if (currentMode == .dark) {
          modeIcon = Icons.dark_mode;
          modeName = "Dark";
        }

        return ListTile(
          shape: const RoundedRectangleBorder(
            borderRadius: .vertical(top: .circular(16)),
          ),
          tileColor: colors.surfaceContainer,
          leading: Icon(modeIcon, color: colors.primary),
          title: const Text("App Theme"),
          subtitle: const Text(
            "Choose Light, Dark, or System",
            style: TextStyle(fontSize: 12),
          ),
          // Show the current mode text on the right side
          trailing: Text(
            modeName,
            style: TextStyle(color: colors.primary, fontWeight: .bold),
          ),
          // The magic tap zone!
          onTap: () => _showThemeDialog(context, currentMode),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return ThemeModeDialog(colors: colors, themeMode: currentMode);
      },
    );
  }
}

class ThemeModeDialog extends StatelessWidget {
  final ColorScheme colors;
  final ThemeMode themeMode;

  const ThemeModeDialog({
    super.key,
    required this.colors,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final listTileColumn = Column(
      mainAxisSize: .min,
      children: [
        RadioListTile<ThemeMode>(
          title: const Text("System Default"),
          value: .system,
          activeColor: colors.primary,
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Light Mode"),
          value: .light,
          activeColor: colors.primary,
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Dark Mode"),
          value: .dark,
          activeColor: colors.primary,
        ),
      ],
    );

    return AlertDialog(
      title: const Text("App Theme"),
      contentPadding: const .only(top: 12, bottom: 24),
      content: RadioGroup<ThemeMode>(
        groupValue: themeMode,
        onChanged: (mode) {
          if (mode != null) ThemeService.updateThemeMode(mode);
          Navigator.pop(context);
        },
        child: listTileColumn,
      ),
    );
  }
}
