import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/level_select/presentation/pages/level_select_page.dart';
import 'package:color_connect/features/settings/presentation/pages/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryVariant,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Logo/Title
                const Spacer(),
                Icon(
                  Icons.palette,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Color Connect',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect the colors to solve the puzzle!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                
                // Menu Buttons
                _buildMenuButton(
                  context,
                  'Play',
                  Icons.play_arrow,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LevelSelectPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildMenuButton(
                  context,
                  'Settings',
                  Icons.settings,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildMenuButton(
                  context,
                  'How to Play',
                  Icons.help_outline,
                  () => _showHowToPlayDialog(context),
                ),
                const Spacer(),
                
                // Version info
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Objective:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Connect all matching colors with paths.'),
            SizedBox(height: 16),
            Text(
              '📱 Controls:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Tap and drag to draw paths\n• Paths cannot cross\n• Fill the entire grid'),
            SizedBox(height: 16),
            Text(
              '💡 Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Plan your paths carefully\n• Use hints when stuck\n• Undo moves if needed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
