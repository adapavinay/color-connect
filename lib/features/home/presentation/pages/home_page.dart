import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/level_select/presentation/pages/level_select_page.dart';
import 'package:color_connect/features/settings/presentation/pages/settings_page.dart';
import 'package:color_connect/features/store/presentation/pages/star_store_page.dart';
import 'package:color_connect/features/progress/domain/entities/progress_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ProgressManager _progressManager;
  Map<String, dynamic> _progressSummary = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Remove refresh logic from here - it doesn't fire on pop
  }

  Future<void> _loadProgress() async {
    _progressManager = ProgressManager();
    await _progressManager.initialize();
    setState(() {
      _progressSummary = _progressManager.getProgressSummary();
    });
  }

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // Game Title
                  const Text(
                    'Color Connect',
                    style: TextStyle(
                      fontSize: 42,
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
                  const SizedBox(height: 6),
                  Text(
                    'Connect the colors, solve the puzzle!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Progress Display Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildProgressItem(
                              '⭐ Stars',
                              '${_progressSummary['totalStars'] ?? 0}',
                              AppTheme.yellow,
                            ),
                            _buildProgressItem(
                              '🎯 Completed',
                              '${_progressSummary['completedLevels'] ?? 0}/${_progressSummary['totalLevels'] ?? 800}',
                              AppTheme.blue,
                            ),
                            _buildProgressItem(
                              '📊 Progress',
                              '${(_progressSummary['completionPercentage'] ?? 0.0).toStringAsFixed(1)}%',
                              AppTheme.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Main Action Buttons
                  Column(
                    children: [
                      _buildActionButton(
                        context,
                        '🎮 Play',
                        'Start your puzzle adventure',
                        Icons.play_arrow,
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LevelSelectPage(),
                            ),
                          );
                          if (!mounted) return;
                          setState(() {
                            _progressSummary = _progressManager.getProgressSummary(); // total stars, completion %
                          });
                        },
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
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
                  
                  const SizedBox(height: 20),
                ],
              ),
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
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.primaryColor.withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14, // Reduced from 16
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 6), // Reduced from 8
        Text(
          value,
          style: TextStyle(
            fontSize: 20, // Reduced from 24
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
