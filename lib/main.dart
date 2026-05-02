import 'package:flutter/material.dart';

import 'package:pal_journal/screens/main_layout.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/services/theme_service.dart';

late IsarService isarService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isarService = IsarService();
  await ThemeService.init();
  await ThemeService.loadThemeMode();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, currentMode, _) {
        return ValueListenableBuilder(
          valueListenable: ThemeService.seedColorNotifier,
          builder: (context, currentSeedColor, _) {
            return CustomizableMaterialApp(
              themeMode: currentMode,
              seedColor: currentSeedColor,
            );
          },
        );
      },
    );
  }
}

class CustomizableMaterialApp extends StatelessWidget {
  final ThemeMode themeMode;
  final Color seedColor;

  const CustomizableMaterialApp({
    super.key,
    this.themeMode = .dark,
    this.seedColor = Colors.tealAccent,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PAL: Journal",
      themeMode: themeMode,

      // 1. Define the Light Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: .light,
        ),
        useMaterial3: true,
      ),

      // 2. Define the Dark Theme
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: .dark,
        ),
        useMaterial3: true,
      ),

      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
