import 'package:flutter/material.dart';

import 'package:pal_journal/screens/main_layout.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/services/theme_service.dart';

late IsarService isarService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isarService = IsarService();
  await ThemeService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeService.seedColorNotifier,
      builder: (context, currentSeedColor, child) {
        return MaterialApp(
          title: "PAL: Journal",
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: currentSeedColor,
              brightness: .dark,
            ),
            useMaterial3: true,
          ),
          home: const MainLayout(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
