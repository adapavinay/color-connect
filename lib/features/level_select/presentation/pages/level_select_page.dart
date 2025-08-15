import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/game/presentation/pages/game_page.dart';
import 'package:color_connect/features/level_select/domain/entities/level.dart';
import 'package:color_connect/features/game/domain/entities/level_data.dart';

class LevelSelectPage extends StatelessWidget {
  const LevelSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual level data from provider
    final levels = _generateSampleLevels();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a level to play',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return _LevelCard(
                    level: level,
                    onTap: () => _startLevel(context, level),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startLevel(BuildContext context, Level level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(level: level),
      ),
    );
  }

                List<Level> _generateSampleLevels() {
                // Use actual level data from LevelData
                final actualLevels = LevelData.levels;
                print('🎯 LevelSelectPage: Found ${actualLevels.length} levels in LevelData');

                final levels = List.generate(actualLevels.length, (index) {
                  final levelNumber = index + 1;
                  final levelData = actualLevels[index];
                  final gridSize = levelData.length;
                  final colorCount = LevelData.getColorCount(index);
                  final optimalMoves = LevelData.getOptimalMoves(index);

                  final level = Level(
                    id: levelNumber,
                    name: 'Level $levelNumber',
                    gridSize: gridSize,
                    colors: colorCount,
                    isCompleted: false, // No levels completed initially
                    isUnlocked: true, // Unlock all levels for testing
                    stars: 0, // No stars initially
                    optimalMoves: optimalMoves,
                    bestMoves: null, // No best score initially
                  );

                  print('🎯 LevelSelectPage: Generated Level $levelNumber: ${gridSize}x${gridSize}, $colorCount colors, optimal: $optimalMoves moves');
                  return level;
                });

                print('🎯 LevelSelectPage: Total levels generated: ${levels.length}');
                return levels;
              }
}

class _LevelCard extends StatelessWidget {
  final Level level;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = level.isUnlocked;
    final isCompleted = level.isCompleted;
    
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Card(
        color: isUnlocked 
          ? (isCompleted ? AppTheme.green.withOpacity(0.2) : Colors.white)
          : Colors.grey.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnlocked 
                ? (isCompleted ? AppTheme.green : AppTheme.primaryColor)
                : Colors.grey,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUnlocked) ...[
                Text(
                  level.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppTheme.green : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${level.gridSize}x${level.gridSize} • ${level.colors} colors',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (level.optimalMoves != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Optimal: ${level.optimalMoves} moves',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
                if (isCompleted) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(3, (index) => Icon(
                        index < level.stars ? Icons.star : Icons.star_border,
                        color: AppTheme.yellow,
                        size: 16,
                      )),
                      const SizedBox(width: 4),
                      if (level.bestMoves != null)
                        Text(
                          '${level.bestMoves}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ],
              ] else ...[
                Icon(
                  Icons.lock,
                  size: 32,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 4),
                Text(
                  level.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
