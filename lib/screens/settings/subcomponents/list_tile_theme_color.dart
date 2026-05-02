import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pal_journal/services/theme_service.dart';

class ListTileThemeColor extends StatelessWidget {
  const ListTileThemeColor({super.key});

  void _showDialog(BuildContext context, Color currentColor) {
    // Temporary variable to hold the color while they drag the wheel
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a theme color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (Color color) {
              pickerColor = color;
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false, // Only solid colors for theme seed
            displayThumbColor: true,
            paletteType: .hsvWithHue,
            labelTypes: const [], // Hides hex codes for cleaner UI
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Apply'),
            onPressed: () {
              ThemeService.updateSeedColor(pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.seedColorNotifier,
      builder: (context, currentColor, child) {
        return ListTile(
          tileColor: colors.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: .circular(12)),
          leading: Icon(Icons.palette, color: colors.primary),
          title: Text("App Theme Color"),
          subtitle: Text(
            "Choose your custom accent color",
            style: TextStyle(fontSize: 12),
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: currentColor,
              shape: .circle,
              border: .all(width: 1),
            ),
          ),
          onTap: () => _showDialog(context, currentColor),
        );
      },
    );
  }
}
