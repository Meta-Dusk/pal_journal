import 'package:flutter/material.dart';

import 'package:pal_journal/screens/main_layout.dart';
import 'package:pal_journal/services/isar_service.dart';

late IsarService isarService;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  isarService = IsarService();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: .dark(useMaterial3: true),
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
