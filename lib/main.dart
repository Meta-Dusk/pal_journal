import 'package:flutter/material.dart';

import 'package:pal_journal/screens/main_layout.dart';
import 'package:pal_journal/services/currency_service.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/services/theme_service.dart';

late IsarService isarService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isarService = IsarService();
  await ThemeService.init();
  await ThemeService.loadThemeMode();
  await CurrencyService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeService.themeModeNotifier,
        ThemeService.seedColorNotifier,
        CurrencyService.exchangeRateNotifier,
      ]),
      builder: (context, _) {
        return CustomizableMaterialApp(
          themeMode: ThemeService.themeModeNotifier.value,
          seedColor: ThemeService.seedColorNotifier.value,
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

      // Define the Light Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: .light,
        ),
        useMaterial3: true,
      ),

      // Define the Dark Theme
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
