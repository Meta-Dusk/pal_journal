import 'package:flutter/material.dart';
import './subcomponents/list_tiles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Global Settings"),
        iconTheme: const IconThemeData(),
        elevation: 0,
      ),
      body: ListView(
        padding: const .all(16.0),
        children: [
          const Text(
            "Appearance",
            style: TextStyle(fontWeight: .bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const ListTileThemeMode(),
          const SizedBox(height: 12),
          const ListTileThemeColor(),
          const SizedBox(height: 32),

          const Text(
            "Data Management",
            style: TextStyle(fontWeight: .bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const ListTileGlobalExport(),
          const SizedBox(height: 12),
          const ListTileGlobalImport(),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            "Danger Zone",
            style: TextStyle(
              fontWeight: .bold,
              fontSize: 14,
              color: colors.error,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Visual warning container for destructive actions
          Container(
            decoration: BoxDecoration(
              color: colors.errorContainer.withValues(alpha: 0.1),
              border: .all(color: colors.error.withValues(alpha: 0.3)),
              borderRadius: .circular(16),
            ),
            child: Column(
              children: [
                const ListTileResetPreferences(),
                Divider(color: colors.error.withValues(alpha: 0.2), height: 1),
                const ListTileFactoryReset(),
              ],
            ),
          ),
          const SizedBox(height: 32), // Bottom padding
        ],
      ),
    );
  }
}
