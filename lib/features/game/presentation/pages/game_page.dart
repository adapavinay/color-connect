import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/level_select/domain/entities/level.dart';
import 'package:color_connect/features/game/domain/entities/color_connect_game.dart';
import 'package:color_connect/features/game/domain/entities/level_data.dart';

class GamePage extends StatefulWidget {
  final Level level;

  const GamePage({
    super.key,
    required this.level,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _moves = 0;
  int _hints = 3;
  bool _isPaused = false;
  ColorConnectGame? _game;

  @override
  void initState() {
    super.initState();
    // Create the game instance once
    _game = ColorConnectGame(
      gridSize: LevelData.getGridSize(widget.level.id - 1),
      levelData: LevelData.getLevel(widget.level.id - 1),
      onLevelComplete: (completed) {
        if (completed) {
          _showLevelCompleteDialog();
        }
      },
      onMoveCount: (moves) {
        setState(() {
          _moves += moves;  // Add to the total move count
        });
      },
    );
    print('🎮 Game created in initState: $_game');
  }

  @override
  Widget build(BuildContext context) {
    final levelIndex = widget.level.id - 1;
    final gridSize = LevelData.getGridSize(widget.level.id - 1);
    final levelData = LevelData.getLevel(widget.level.id - 1);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.level.name),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () => _togglePause(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Game Stats Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Moves', _moves.toString(), Icons.touch_app),
                _buildStatItem('Hints', _hints.toString(), Icons.lightbulb),
                _buildStatItem('Grid', '${widget.level.gridSize}x${widget.level.gridSize}', Icons.grid_on),
              ],
            ),
          ),
          
                     // Game Canvas with Flame Engine
           Expanded(
             child: Container(
               margin: const EdgeInsets.all(16.0),
               decoration: BoxDecoration(
                 border: Border.all(color: AppTheme.primaryColor, width: 2),
                 borderRadius: BorderRadius.circular(12),
               ),
                              child: ClipRRect(
                 borderRadius: BorderRadius.circular(10),
                 child: Builder(
                   builder: (context) {
                     final width = _getGameWidth();
                     final height = _getGameHeight();
                     return Container(
                       width: width,
                       height: height,
                       child: GestureDetector(
                     onPanStart: (details) {
                       // Start the path when pan begins
                       _handleGameTap(details.localPosition);
                     },
                     onPanUpdate: (details) {
                       // Continue the path as user drags
                       _handleGameDrag(details.localPosition);
                     },
                     onPanEnd: (details) {
                       // Complete the path
                       _handleGameDragEnd(details.localPosition);
                     },
                     child: GameWidget<ColorConnectGame>(game: _game!),
                       ),
                     );
                   },
                 ),
               ),
             ),
           ),
          
          // Game Controls
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  'Undo',
                  Icons.undo,
                  _moves > 0 ? () => _undoMove() : null,
                ),
                _buildControlButton(
                  'Reset',
                  Icons.refresh,
                  () => _resetLevel(),
                ),
                _buildControlButton(
                  'Hint',
                  Icons.lightbulb,
                  _hints > 0 ? () => _useHint() : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(String label, IconData icon, VoidCallback? onPressed) {
    final isEnabled = onPressed != null;
    
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? AppTheme.primaryColor : Colors.grey,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isEnabled ? AppTheme.primaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      _showPauseDialog();
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Paused'),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isPaused = false);
            },
            child: const Text('Resume'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit Level'),
          ),
        ],
      ),
    );
  }

  void _undoMove() {
    if (_moves > 0) {
      setState(() {
        _moves--;
      });
      // TODO: Implement actual undo logic
    }
  }

  void _resetLevel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Level'),
        content: const Text('Are you sure you want to reset this level?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _moves = 0;
                _hints = 3;
              });
              // Reset the game instance
              _game?.resetLevel();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _useHint() {
    if (_hints > 0) {
      setState(() {
        _hints--;
      });
      // TODO: Implement actual hint logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hint used!')),
      );
    }
  }

  void _handleGameTap(Offset localPosition) {
    if (_game == null) return;
    
    // Convert local position to game coordinates
    final gamePosition = Vector2(localPosition.dx, localPosition.dy);
    
    // Get the puzzle grid from the game
    final puzzleGrid = _game!.puzzleGrid;
    final gridPosition = puzzleGrid.worldToGrid(gamePosition);
    
    if (gridPosition != null) {
      final cell = puzzleGrid.getCell(gridPosition.x.toInt(), gridPosition.y.toInt());
      
      if (cell != null && cell.isEndpoint && cell.color != null) {
        // Call the game's path starting method
        _game!.startPath(gridPosition, cell.color!);
      }
    }
  }

  void _handleGameDrag(Offset localPosition) {
    if (_game == null) return;
    
    // Convert local position to game coordinates
    final gamePosition = Vector2(localPosition.dx, localPosition.dy);
    final gridPosition = _game!.puzzleGrid.worldToGrid(gamePosition);
    
    if (gridPosition != null) {
      // Continue the path
      _game!.updatePath(gridPosition);
    }
  }

  void _handleGameDragEnd(Offset localPosition) {
    if (_game == null) return;
    
    // Convert local position to game coordinates
    final gamePosition = Vector2(localPosition.dx, localPosition.dy);
    final gridPosition = _game!.puzzleGrid.worldToGrid(gamePosition);
    
    if (gridPosition != null) {
      _game!.endPath(gridPosition);
    }
  }

  double _getCellSize(int gridSize) {
    // Match the cell size calculation from PuzzleGrid
    if (gridSize <= 3) return 80.0;
    if (gridSize <= 4) return 80.0 * 0.8; // 64px
    if (gridSize <= 5) return 80.0 * 0.6; // 48px
    if (gridSize <= 6) return 80.0 * 0.5; // 40px
    return 80.0 * 0.4; // 32px for very large grids
  }

  double _getGameWidth() {
    final gridSize = LevelData.getGridSize(widget.level.id - 1);
    final cellSize = _getCellSize(gridSize);
    return gridSize * cellSize;
  }

  double _getGameHeight() {
    final gridSize = LevelData.getGridSize(widget.level.id - 1);
    final cellSize = _getCellSize(gridSize);
    return gridSize * cellSize;
  }

  void _showLevelCompleteDialog() {
    final levelIndex = widget.level.id - 1;
    final optimalMoves = LevelData.getOptimalMoves(levelIndex);
    final stars = LevelData.calculateStars(levelIndex, _moves);
    final isLastLevel = widget.level.id >= 10;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🎉 Level ${widget.level.id} Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLastLevel 
                ? '🎊 Congratulations! You completed all levels! 🎊'
                : 'Great job! Ready for the next challenge?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // Star rating display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: AppTheme.yellow,
                size: 32,
              )),
            ),
            const SizedBox(height: 16),
            // Move count and rating
            Text(
              'Your moves: $_moves',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Optimal: $optimalMoves moves',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getRatingText(stars),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _getRatingColor(stars),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isLastLevel) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Next Level Preview',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${widget.level.id + 1}: ${LevelData.getGridSize(widget.level.id)}x${LevelData.getGridSize(widget.level.id)} grid, ${LevelData.getColorCount(widget.level.id)} colors',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            
            // Add subtitle above buttons
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                isLastLevel 
                  ? 'You\'ve completed all levels! 🎊'
                  : 'Choose your next action:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Back to Stages button (always visible)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.pop(context); // Go back to level select
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.list, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Back to Stages',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  ),
                ),
                
                const SizedBox(width: 12), // Reduced spacing for better balance
                
                // Next Level or Back to Menu button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      
                      if (!isLastLevel) {
                        // Navigate to next level
                        _navigateToNextLevel();
                      } else {
                        // This was the last level, go back to menu
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastLevel ? 'Back to Menu' : 'Next Level',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (!isLastLevel) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ],
                  ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int stars) {
    switch (stars) {
      case 3:
        return 'Perfect! 🏆';
      case 2:
        return 'Great! 🌟';
      case 1:
        return 'Good! 👍';
      default:
        return 'Try again! 💪';
    }
  }

  void _navigateToNextLevel() {
    final currentLevelId = widget.level.id;
    final nextLevelIndex = currentLevelId; // Next level data index
    
    final nextLevel = Level(
      id: currentLevelId + 1,
      name: 'Level ${currentLevelId + 1}',
      gridSize: LevelData.getGridSize(nextLevelIndex),
      colors: LevelData.getColorCount(nextLevelIndex),
      isCompleted: false,
      isUnlocked: true,
      stars: 0,
      optimalMoves: LevelData.getOptimalMoves(nextLevelIndex),
      bestMoves: null,
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(level: nextLevel),
      ),
    );
  }

  Color _getRatingColor(int stars) {
    switch (stars) {
      case 3:
        return AppTheme.yellow;
      case 2:
        return AppTheme.blue;
      case 1:
        return AppTheme.green;
      default:
        return Colors.grey;
    }
  }
}
