import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/daily_challenge/domain/entities/daily_challenge.dart';
import 'package:color_connect/features/daily_challenge/domain/entities/daily_challenge_generator.dart';
import 'package:color_connect/features/daily_challenge/domain/services/streak_service.dart';
import 'package:color_connect/features/game/domain/entities/color_connect_game.dart';
import 'package:color_connect/features/game/domain/entities/level_data.dart';

class DailyChallengePage extends StatefulWidget {
  const DailyChallengePage({super.key});

  @override
  State<DailyChallengePage> createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends State<DailyChallengePage> {
  late DailyChallenge _todayChallenge;
  late ColorConnectGame _game;
  int _moves = 0;
  int _hints = 3;
  bool _isCompleted = false;
  int? _stars;
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChallenge();
  }

  Future<void> _initializeChallenge() async {
    try {
      // Generate today's challenge
      _todayChallenge = DailyChallengeGenerator.generateTodayChallenge();
      print('🎯 Generated challenge: ${_todayChallenge.gridSize}x${_todayChallenge.gridSize}, ${_todayChallenge.colorCount} colors');
      print('📊 Grid data: ${_todayChallenge.gridData}');
      
      // Initialize the game
      _game = ColorConnectGame(
        gridSize: _todayChallenge.gridSize,
        levelData: _todayChallenge.gridData,
        onLevelComplete: (completed) {
          print('🎉 Level complete callback: $completed');
          if (completed) {
            _showDailyChallengeCompleteDialog();
          }
        },
        onMoveCount: (moves) {
          print('📈 Move count callback: $moves');
          setState(() {
            _moves += moves;
          });
        },
      );
      print('🎮 Game initialized successfully');
      
      // Load streak
      final streak = await StreakService.getCurrentStreak();
      print('🔥 Loaded streak: $streak');
      
      setState(() {
        _streak = streak;
        _isLoading = false;
      });
      print('✅ Challenge initialization complete');
    } catch (e) {
      print('❌ Error initializing challenge: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Daily Challenge'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showDailyChallengeInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Daily Challenge Header
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                // Date and streak info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _todayChallenge.formattedDate,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Daily Challenge',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    // Streak display
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _todayChallenge.streakEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          Text(
                            '$_streak',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'days',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Challenge stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Grid', '${_todayChallenge.gridSize}x${_todayChallenge.gridSize}', Icons.grid_on),
                    _buildStatItem('Colors', '${_todayChallenge.colorCount}', Icons.palette),
                    _buildStatItem('Optimal', '${_todayChallenge.optimalMoves}', Icons.star),
                  ],
                ),
              ],
            ),
          ),
          
          // Game Canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                          _handleGameTap(details.localPosition);
                        },
                        onPanUpdate: (details) {
                          _handleGameDrag(details.localPosition);
                        },
                        onPanEnd: (details) {
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
                  () => _resetChallenge(),
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

  void _handleGameTap(Offset localPosition) {
    if (_game == null) return;
    
    final gamePosition = Vector2(localPosition.dx, localPosition.dy);
    final puzzleGrid = _game!.puzzleGrid;
    final gridPosition = puzzleGrid.worldToGrid(gamePosition);
    
    if (gridPosition != null) {
      final cell = puzzleGrid.getCell(gridPosition.x.toInt(), gridPosition.y.toInt());
      
      if (cell != null && cell.isEndpoint && cell.color != null) {
        _game!.startPath(gridPosition, cell.color!);
      }
    }
  }

  void _handleGameDrag(Offset localPosition) {
    if (_game == null) return;
    
    final gamePosition = Vector2(localPosition.dx, localPosition.dy);
    final gridPosition = _game!.puzzleGrid.worldToGrid(gamePosition);
    
    if (gridPosition != null) {
      _game!.updatePath(gridPosition);
    }
  }

  void _handleGameDragEnd(Offset localPosition) {
    if (_game == null) return;
    
    final gamePosition = Vector2(localPosition.dx, localPosition.dy);
    final gridPosition = _game!.puzzleGrid.worldToGrid(gamePosition);
    
    if (gridPosition != null) {
      _game!.endPath(gridPosition);
    }
  }

  double _getCellSize(int gridSize) {
    if (gridSize <= 3) return 80.0;
    if (gridSize <= 4) return 80.0 * 0.8;
    if (gridSize <= 5) return 80.0 * 0.6;
    if (gridSize <= 6) return 80.0 * 0.5;
    return 80.0 * 0.4;
  }

  double _getGameWidth() {
    final cellSize = _getCellSize(_todayChallenge.gridSize);
    return _todayChallenge.gridSize * cellSize;
  }

  double _getGameHeight() {
    final cellSize = _getCellSize(_todayChallenge.gridSize);
    return _todayChallenge.gridSize * cellSize;
  }

  void _showDailyChallengeCompleteDialog() async {
    // Calculate stars based on moves vs optimal
    final stars = _calculateStars(_moves, _todayChallenge.optimalMoves);
    
    // Update streak
    await StreakService.updateStreak();
    final newStreak = await StreakService.getCurrentStreak();
    
    setState(() {
      _isCompleted = true;
      _stars = stars;
      _streak = newStreak;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🎉 Daily Challenge Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star rating display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: AppTheme.yellow,
                size: 40,
              )),
            ),
            const SizedBox(height: 16),
            Text(
              _getRatingText(stars),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _getRatingColor(stars),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Move count and rating
            Text(
              'Your moves: $_moves',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Optimal: ${_todayChallenge.optimalMoves} moves',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            // Streak update
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '🔥 Streak Updated!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _todayChallenge.streakText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Menu'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  int _calculateStars(int actualMoves, int optimalMoves) {
    if (actualMoves <= optimalMoves) return 3;
    if (actualMoves <= (optimalMoves * 1.2).round()) return 2;
    if (actualMoves <= (optimalMoves * 1.5).round()) return 1;
    return 0;
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

  void _showDailyChallengeInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎯 Daily Challenge Info'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• A new puzzle every day'),
            Text('• Same puzzle for everyone'),
            Text('• Build your streak by playing daily'),
            Text('• Earn stars based on efficiency'),
            Text('• Challenge your friends!'),
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

  void _undoMove() {
    if (_moves > 0) {
      setState(() {
        _moves--;
      });
      _game.undoLastMove();
    }
  }

  void _resetChallenge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Challenge'),
        content: const Text('Are you sure you want to reset today\'s challenge?'),
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
                _isCompleted = false;
                _stars = null;
              });
              _game.resetLevel();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💡 Hint: Try to find the shortest path between endpoints!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
