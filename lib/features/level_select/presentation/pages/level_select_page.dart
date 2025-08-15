import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/game/presentation/pages/game_page.dart';
import 'package:color_connect/features/game/domain/entities/level_data.dart';
import 'package:color_connect/features/game/domain/entities/level_schedule.dart';
import 'package:color_connect/features/progress/domain/entities/progress_manager.dart';

class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({super.key});

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> {
  final ProgressManager _progressManager = ProgressManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pm = _progressManager;
    final totalLevels = LevelData.totalLevels;
    final nextUnsolved = pm.getNextUnsolvedLevel(1) ?? 1;
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jump to level…',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (v) {
                      final n = int.tryParse(v) ?? 0;
                      if (n >= 1 && n <= totalLevels) {
                        _startLevel(context, n);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _startLevel(context, nextUnsolved),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: totalLevels,
              itemBuilder: (context, i) {
                final id = i + 1;
                final completed = pm.isLevelCompleted(id);
                final stars = pm.getLevelStars(id);
                final cfg = configForLevel(id);
                return ListTile(
                  onTap: () => _startLevel(context, id),
                  leading: CircleAvatar(
                    backgroundColor: completed ? Colors.green : AppTheme.primaryColor.withOpacity(0.15),
                    foregroundColor: completed ? Colors.white : AppTheme.primaryColor,
                    child: Text('$id'),
                  ),
                  title: Text('Level $id · ${cfg.grid}×${cfg.colors}'),
                  subtitle: stars > 0
                    ? Row(children: List.generate(3, (s) => Icon(s < stars ? Icons.star : Icons.star_border, size: 16, color: Colors.amber)))
                    : const Text('Not completed'),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startLevel(BuildContext context, int levelId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(levelId: levelId),
      ),
    );
    
    // Refresh the page to show updated progress
    if (mounted) {
      setState(() {});
    }
  }
}
