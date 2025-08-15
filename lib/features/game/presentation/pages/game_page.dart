import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/game/domain/entities/color_connect_game.dart';
import 'package:color_connect/features/game/domain/entities/puzzle_grid.dart';
import 'package:color_connect/features/game/domain/entities/level_data.dart';
import 'package:color_connect/features/progress/domain/entities/progress_manager.dart';

class GamePage extends StatefulWidget {
  final int levelId;

  const GamePage({
    super.key,
    required this.levelId,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late ColorConnectGame _game;
  late PuzzleGrid _puzzleGrid;
  late ProgressManager _progressManager;
  int _moves = 0;
  int _hints = 3;
  bool _isPaused = false;
  bool _isGameComplete = false;
  bool _showHint = false;
  Map<String, dynamic>? _hintData;
  
  @override
  void initState() {
    super.initState();
    _game = ColorConnectGame(
      gridSize: LevelData.getGridSize(widget.levelId),
      levelData: LevelData.getLevelData(widget.levelId),
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
    _progressManager = ProgressManager();
    _initializeProgress();
    print('🎮 Game created in initState: $_game');
  }
  
  Future<void> _initializeProgress() async {
    // await _progressManager.initialize(); // unnecessary here; state already updated in memory
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = LevelData.getGridSize(widget.levelId);
    final levelName = 'Level ${widget.levelId}';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(levelName),
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
                _buildStatItem('Grid', '${gridSize}x${gridSize}', Icons.grid_on),
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
                        child: GameWidget<ColorConnectGame>(game: _game),
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
    if (_game != null) {
      _game!.undoLastMove();
      // The game will call onMoveCount with the updated move count
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
    if (_hints > 0 && _game != null) {
      setState(() {
        _hints--;
      });
      
      // Get the puzzle grid and find the next best move
      final puzzleGrid = _game!.puzzleGrid;
      final hint = puzzleGrid.getHint();
      
      if (hint != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hint: Connect ${hint['color']} from ${hint['from']} to ${hint['to']}'),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hint available for this puzzle'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _handleGameTap(Offset localPosition) {
    final gridPosition = _getGridPosition(localPosition);
    if (gridPosition != null) {
      final cell = _game.puzzleGrid.getCell(gridPosition.x.toInt(), gridPosition.y.toInt());
      
      if (cell != null && cell.isEndpoint && cell.color != null) {
        // Call the game's path starting method
        _game.startPath(gridPosition, cell.color!);
      }
    }
  }

  void _handleGameDrag(Offset localPosition) {
    final gridPosition = _getGridPosition(localPosition);
    if (gridPosition != null) {
      // Continue the path
      _game.updatePath(gridPosition);
    }
  }

  void _handleGameDragEnd(Offset localPosition) {
    final gridPosition = _getGridPosition(localPosition);
    if (gridPosition != null) {
      _game.endPath(gridPosition);
    }
  }

  Vector2? _getGridPosition(Offset localPosition) {
    // Convert local position to game coordinates
    final gamePosition = Vector2(localPosition.dx, localPosition.dy);
    return _game.puzzleGrid.worldToGrid(gamePosition);
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
    final gridSize = LevelData.getGridSize(widget.levelId);
    final cellSize = _getCellSize(gridSize);
    return gridSize * cellSize;
  }

  double _getGameHeight() {
    final gridSize = LevelData.getGridSize(widget.levelId);
    final cellSize = _getCellSize(gridSize);
    return gridSize * cellSize;
  }

  void _showLevelCompleteDialog() async {
    final levelIndex = widget.levelId;
    final optimalMoves = LevelData.getOptimalMoves(levelIndex);
    final stars = LevelData.calculateStars(_moves, optimalMoves);
    final isLastLevel = widget.levelId >= LevelData.totalLevels;
    
    // Save progress first
    await _progressManager.completeLevel(levelIndex, stars);
    
    // Refresh progress manager to get updated data
    // await _progressManager.initialize(); // unnecessary here; state already updated in memory
    
    // Get progress summary for display
    final progressSummary = _progressManager.getProgressSummary();
    
    // Find next available level
    int nextLevelId = widget.levelId + 1;
    bool foundNextLevel = false;
    
    // Look for the next unsolved level within a reasonable range
    final maxSearchRange = 50;
    for (int i = 0; i < maxSearchRange && nextLevelId <= LevelData.totalLevels; i++) {
      if (!_progressManager.isLevelCompleted(nextLevelId)) {
        foundNextLevel = true;
        break;
      }
      nextLevelId++;
    }
    
    // If no unsolved level found ahead, find the first unsolved level
    if (!foundNextLevel) {
      nextLevelId = 1;
      for (int i = 1; i <= LevelData.totalLevels; i++) {
        if (!_progressManager.isLevelCompleted(i)) {
          nextLevelId = i;
          break;
        }
      }
    }
    
    // Debug information
    print('🎯 Level ${widget.levelId} completed with $_moves moves');
    print('🎯 Optimal moves: $optimalMoves');
    print('🎯 Stars earned: $stars');
    print('🎯 Total stars: ${progressSummary['totalStars']}');
    print('🎯 Completed levels: ${progressSummary['completedLevels']}');
    print('🎯 Next level: $nextLevelId');
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🎉 Level ${widget.levelId} Complete!'),
        content: SingleChildScrollView(
          child: Column(
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
              // Progress summary
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
                      'Overall Progress',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProgressItem('⭐ Total Stars', '${progressSummary['totalStars'] ?? 0}'),
                        _buildProgressItem('🎯 Completed', '${progressSummary['completedLevels'] ?? 0}/${progressSummary['totalLevels'] ?? 800}'),
                      ],
                    ),
                  ],
                ),
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
              if (!isLastLevel && foundNextLevel) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Next Level',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level $nextLevelId: ${LevelData.getGridSize(nextLevelId)}x${LevelData.getGridSize(nextLevelId)} grid, ${LevelData.getColorCount(nextLevelId)} colors',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.green,
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
        ),
        
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isLastLevel) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToNextLevel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Next Level'),
                  ),
                ],
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Level Select'),
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
    final currentLevelId = widget.levelId;
    
    // Find the next available unsolved level
    int nextLevelId = currentLevelId + 1;
    
    // Look for the next unsolved level within a reasonable range
    final maxSearchRange = 50; // Don't search too far ahead
    bool foundNextLevel = false;
    
    for (int i = 0; i < maxSearchRange && nextLevelId <= LevelData.totalLevels; i++) {
      if (!_progressManager.isLevelCompleted(nextLevelId)) {
        foundNextLevel = true;
        break;
      }
      nextLevelId++;
    }
    
    // If no unsolved level found ahead, go back to find the first unsolved level
    if (!foundNextLevel) {
      nextLevelId = 1;
      for (int i = 1; i <= LevelData.totalLevels; i++) {
        if (!_progressManager.isLevelCompleted(i)) {
          nextLevelId = i;
          break;
        }
      }
    }
    
    // Check if next level exists and is valid
    if (nextLevelId <= LevelData.totalLevels && nextLevelId != currentLevelId) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GamePage(levelId: nextLevelId),
        ),
      );
    } else {
      // No more levels to play, go back to level select
      Navigator.pop(context);
      Navigator.pop(context);
    }
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
  
  Widget _buildProgressItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
