import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pal_journal/screens/auth/auth_screen.dart';
import 'package:pal_journal/services/auth_service.dart';

class SmartAuthMenu extends StatelessWidget {
  const SmartAuthMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.currentUserNotifier,
      builder: (context, _) {
        final user = AuthService.currentUserNotifier.value;

        // GUEST MODE
        if (user == null) {
          return ListTileGuestMode();
        }

        // LOGGED IN MODE
        return LoggedInView(user: user);
      },
    );
  }
}

class LoggedInView extends StatelessWidget {
  const LoggedInView({super.key, required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final mainContent = [
      ListTile(
        leading: Icon(Icons.cloud_done, color: colors.primary),
        title: Text(
          "Syncing as",
          style: TextStyle(color: colors.primary, fontSize: 12),
        ),
        subtitle: Text(
          user?.email ?? "Unknown User",
          style: const TextStyle(fontWeight: .bold, fontSize: 16),
        ),
      ),
      const Divider(height: 1),
      ListTile(
        leading: Icon(Icons.logout, color: colors.error, size: 20),
        title: Text(
          "Log Out",
          style: TextStyle(color: colors.error, fontWeight: .bold),
        ),
        onTap: () async {
          await AuthService.signOut();
        },
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.1),
        borderRadius: .circular(12),
        border: .all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(children: mainContent),
    );
  }
}

class ListTileGuestMode extends StatelessWidget {
  const ListTileGuestMode({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    void openAuthScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }

    return ListTile(
      shape: const RoundedRectangleBorder(borderRadius: .all(.circular(16))),
      leading: Icon(Icons.cloud_off, color: colors.onSurfaceVariant),
      title: const Text("Enable Cloud Sync"),
      subtitle: const Text("Tap to log in or create an account"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: openAuthScreen,
    );
  }
}
