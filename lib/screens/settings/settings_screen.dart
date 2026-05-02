import 'package:flutter/material.dart';
import './subcomponents/list_tiles.dart';
import 'smart_auth_menu.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final appearanceSettings = [
      const Text(
        "Appearance",
        style: TextStyle(fontWeight: .bold, fontSize: 14),
      ),
      middleSpacer(),
      Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh.withValues(alpha: 0.1),
          border: .all(color: colors.onSurface.withValues(alpha: 0.3)),
          borderRadius: .circular(16),
        ),
        child: Column(
          children: [
            const ListTileThemeMode(),
            Divider(color: colors.onSurface.withValues(alpha: 0.2), height: 1),
            const ListTileThemeColor(),
            Divider(color: colors.onSurface.withValues(alpha: 0.2), height: 1),
            const ListTileCurrency(),
            const ListTileExchangeRates(),
          ],
        ),
      ),
    ];

    final dataManagementSettings = [
      const Text(
        "Data Management",
        style: TextStyle(fontWeight: .bold, fontSize: 14),
      ),
      middleSpacer(),
      Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh.withValues(alpha: 0.1),
          border: .all(color: colors.onSurface.withValues(alpha: 0.3)),
          borderRadius: .circular(16),
        ),
        child: Column(
          children: [
            const ListTileGlobalExport(),
            Divider(color: colors.onSurface.withValues(alpha: 0.2), height: 1),
            const ListTileGlobalImport(),
          ],
        ),
      ),
    ];

    final cloudSyncSettings = [
      const Text(
        "Cloud Sync",
        style: TextStyle(fontWeight: .bold, fontSize: 14),
      ),
      middleSpacer(),
      const SmartAuthMenu(),
    ];

    final nuclearSettings = [
      Text(
        "Danger Zone",
        style: TextStyle(
          fontWeight: .bold,
          fontSize: 14,
          color: colors.error,
          letterSpacing: 1.2,
        ),
      ),
      middleSpacer(),

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
    ];

    final mainContent = [
      ...appearanceSettings,
      bottomPadding(),
      ...dataManagementSettings,
      bottomPadding(),
      ...cloudSyncSettings,
      bottomPadding(),
      const Divider(),
      const SizedBox(height: 16),
      ...nuclearSettings,
      bottomPadding(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Global Settings"),
        iconTheme: const IconThemeData(),
        elevation: 0,
      ),
      body: ListView(padding: const .all(16.0), children: mainContent),
    );
  }

  SizedBox bottomPadding() => const SizedBox(height: 32);
  SizedBox middleSpacer() => const SizedBox(height: 8);
}
