import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:pal_journal/services/auth_service.dart';
import 'cloud_sync_card.dart';
import 'subcomponents/settings_list_tiles.dart';
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
            Divider(color: colors.onSurface.withValues(alpha: 0.2), height: 1),
            const ListTileGoalsExport(),
            Divider(color: colors.onSurface.withValues(alpha: 0.2), height: 1),
            const ListTilesGoalsImport(),
          ],
        ),
      ),
    ];

    final cloudSyncSettings = [
      Text(
        "Cloud Sync${Platform.isWindows ? " (Android Only)" : ""}",
        style: TextStyle(fontWeight: .bold, fontSize: 14),
      ),
      middleSpacer(),
      Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh.withValues(alpha: 0.1),
          border: .all(color: colors.onSurface.withValues(alpha: 0.3)),
          borderRadius: .circular(16),
        ),
        child: AuthView(),
      ),
    ];

    final historySettings = [
      Text("History", style: TextStyle(fontWeight: .bold, fontSize: 14)),
      middleSpacer(),
      Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh.withValues(alpha: 0.1),
          border: .all(color: colors.onSurface.withValues(alpha: 0.3)),
          borderRadius: .circular(16),
        ),
        child: Column(children: [ListTileHistory()]),
      ),
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
      ...historySettings,
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

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: AuthService.currentUserNotifier,
      builder: (context, _) {
        final user = AuthService.currentUserNotifier.value;

        if (user == null) {
          final loggedOutContent = [
            const SmartAuthMenu(),
            if (!Platform.isWindows) const CloudSyncCard(),
          ];
          return Column(children: loggedOutContent);
        }

        final loggedInContent = [
          Divider(color: colors.onSurface.withValues(alpha: 0.2), height: 1),
          const CloudSyncCard(),
        ];
        return Column(
          children: [
            const SmartAuthMenu(),
            if (!Platform.isWindows) ...loggedInContent,
          ],
        );
      },
    );
  }
}
