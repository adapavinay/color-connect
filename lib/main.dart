import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:color_connect/core/app.dart';
import 'package:color_connect/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  runApp(
    const ProviderScope(
      child: ColorConnectApp(),
    ),
  );
}

class ColorConnectApp extends ConsumerWidget {
  const ColorConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Color Connect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const App(),
      debugShowCheckedModeBanner: false,
    );
  }
}
