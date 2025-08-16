import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:color_connect/core/app.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/level/levels.dart';
import 'package:color_connect/level/level_validator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  assert(() {
    // Debug-only validation of levels
    for (int i = 0; i < levels.length; i++) {
      final ok = LevelValidator.isSolvable(levels[i]);
      if (!ok) {
        debugPrint('⚠️ Level ${i + 1} is UNSOLVABLE. Please fix its endpoints.');
      }
    }
    return true;
  }());
  
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
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      home: const App(),
      debugShowCheckedModeBanner: false,
    );
  }
}
