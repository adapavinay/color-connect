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
    // Load progress and update UI immediately
    _loadProgressAndUpdate();
  }
  
  Future<void> _loadProgressAndUpdate() async {
    await _progressManager.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pm = _progressManager;
    final totalLevels = LevelData.totalLevels;
    final nextPlayable = pm.getNextPlayableLevel(1) ?? 1;
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels'),
        backgroundColor: CCColors.primary,
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
                  onPressed: () => _startLevel(context, nextPlayable),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CCColors.primary,
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
                final requiredStars = starsRequiredForLevel(id);
                final totalStars = pm.totalStars;
                final isUnlocked = totalStars >= requiredStars;
                
                return ListTile(
                  onTap: isUnlocked ? () => _startLevel(context, id) : null,
                  leading: CircleAvatar(
                    backgroundColor: completed ? Colors.green : 
                                   isUnlocked ? CCColors.primary.withOpacity(0.15) : Colors.grey,
                    foregroundColor: completed ? Colors.white : 
                                   isUnlocked ? CCColors.primary : Colors.grey[600],
                    child: isUnlocked ? Text('$id') : const Icon(Icons.lock, size: 16),
                  ),
                  title: Text('Level $id · ${cfg.grid}×${cfg.colors}'),
                  subtitle: isUnlocked 
                    ? (stars > 0
                        ? Row(children: List.generate(3, (s) => Icon(s < stars ? Icons.star : Icons.star_border, size: 16, color: Colors.amber)))
                        : const Text('Not completed'))
                    : Text('Requires $requiredStars★', style: TextStyle(color: Colors.orange)),
                  trailing: isUnlocked ? const Icon(Icons.chevron_right) : 
                           IconButton(
                             icon: const Icon(Icons.star, color: Colors.orange),
                             onPressed: () => _showGetStarsDialog(context, requiredStars),
                           ),
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
    
    // Reload progress and refresh the page to show updated progress immediately
    if (mounted) {
      await _progressManager.initialize();
      setState(() {});
    }
  }

  void _showGetStarsDialog(BuildContext context, int requiredStars) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need More Stars'),
        content: Text('This level requires $requiredStars★ to unlock.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to store or show rewarded ad
            },
            child: const Text('Get Stars'),
          ),
        ],
      ),
    );
  }
}
