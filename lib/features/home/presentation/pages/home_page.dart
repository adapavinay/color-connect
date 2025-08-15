import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/level_select/presentation/pages/level_select_page.dart';
import 'package:color_connect/features/settings/presentation/pages/settings_page.dart';
import 'package:color_connect/features/store/presentation/pages/star_store_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Flexible space at top
                const Spacer(flex: 1),
                
                // Game Title
                const Text(
                  'Color Connect',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect the colors, solve the puzzle!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Main Action Buttons
                Column(
                  children: [
                    _buildActionButton(
                      context,
                      '🎮 Play',
                      'Start your puzzle adventure',
                      Icons.play_arrow,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LevelSelectPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(
                      context,
                      '⭐ Store',
                      'Get more stars to unlock packs',
                      Icons.store,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StarStorePage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(
                      context,
                      '⚙️ Settings',
                      'Customize your experience',
                      Icons.settings,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Flexible space at bottom
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.95),
          foregroundColor: AppTheme.primaryColor,
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
