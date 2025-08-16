import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/game/domain/entities/color_connect_game.dart';
import 'package:color_connect/features/game/domain/entities/level_schedule.dart';
import 'package:color_connect/features/game/domain/entities/level_data.dart';
import 'package:color_connect/features/game/presentation/widgets/success_dialog.dart';
import 'package:color_connect/features/progress/domain/entities/progress_manager.dart';
import 'package:color_connect/level/level_with_auto_repair.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:color_connect/services/ads_service.dart';
import 'package:color_connect/core/config/feature_flags.dart';
import 'package:color_connect/services/hints_manager.dart';

class GamePage extends StatefulWidget {
  final int levelId;
  const GamePage({super.key, required this.levelId});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _successShown = false;
  late ColorConnectGame _game;
  late ProgressManager _progressManager;
  int _moves = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _progressManager = ProgressManager();
    _initializeGame();
    _loadHints();
  }
  
  Future<void> _loadHints() async {
    // Ensure hints manager is initialized
    if (!HintsManager().initialized) {
      await HintsManager().init();
    }
    setState(() {});
  }

  void _initializeGame() {
    final cfg = configForLevel(widget.levelId);
    _game = ColorConnectGame(
      gridSize: cfg.grid,
      levelData: LevelData.generateLevel(
        gridSize: cfg.grid,
        colorCount: cfg.colors,
        seed: cfg.seed,
        minSegmentLen: cfg.minSegmentLen,
      ),
      onLevelComplete: (completed) async {
        if (completed && !_successShown) {
          _successShown = true;
          // Award stars (simple heuristic for now: 3 stars)
          final int stars = 3;
          await _progressManager.completeLevel(widget.levelId, stars);
          
          // Show interstitial ad if eligible
          await AdsService().showInterstitialIfEligible(
            widget.levelId, 
            MonetizationFlags.interstitialEveryNLevels
          );
          
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => SuccessDialog(
              levelId: widget.levelId,
              stars: stars,
              onLevelList: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // back to level select
              },
              onNext: () {
                Navigator.of(context).pop(); // close dialog
                final next = _progressManager.getNextPlayableLevel(widget.levelId) ?? widget.levelId;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => GamePage(levelId: next)),
                );
              },
            ),
          );
        }
      },
      onMoveCount: (moves) {
        setState(() {
          _moves += moves;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch a repaired (if necessary) level grid here and pass to your board.
    // final levelGrid = levelWithAutoRepair(widget.levelId);
    return SafeArea(
      child: LayoutBuilder(builder: (context, c) {
        final double maxBoard = (c.maxWidth < 560 ? c.maxWidth : 560) - 24;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                _GameTopBar(levelId: widget.levelId, moves: _moves),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: Container(
                      width: maxBoard,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: CCColors.board, // black board ONLY here
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.all(10),
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
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SafeArea(
                  top: false,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Undo'),
                        onPressed: _moves > 0 ? _undoMove : null,
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reset'),
                        onPressed: _resetLevel,
                      ),
                      // Hint = accent filled for visibility
                      FilledButton(
                        onPressed: HintsManager().hasHints ? _useHint : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: CCColors.accent,
                          foregroundColor: CCColors.text,
                          shape: const StadiumBorder(),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.lightbulb_outline_rounded),
                          SizedBox(width: 8),
                          Text('Hint'),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _handleGameTap(Offset localPosition) {
    final gridPosition = _getGridPosition(localPosition);
    if (gridPosition != null) {
      final cell = _game.puzzleGrid.getCell(gridPosition.x.toInt(), gridPosition.y.toInt());
      
      if (cell != null && cell.isEndpoint && cell.color != null) {
        print('🎯 Tapped endpoint at grid position $gridPosition with color ${cell.color}');
        _game.startPath(gridPosition, cell.color!);
      }
    }
  }

  void _handleGameDrag(Offset localPosition) {
    final gridPosition = _getGridPosition(localPosition);
    if (gridPosition != null) {
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

  void _undoMove() {
    if (_game != null) {
      _game.undoLastMove();
      setState(() {
        _moves = (_moves - 1).clamp(0, double.infinity).toInt();
      });
    }
  }

  void _resetLevel() {
    setState(() {
      _moves = 0;
    });
    _game.resetLevel();
  }

  Future<void> _useHint() async {
    final hintsManager = HintsManager();
    
    // Try to use a hint
    final hintUsed = await hintsManager.use();
    
    if (hintUsed) {
      setState(() {});
      // TODO: Implement actual hint logic (show next move, highlight path, etc.)
      debugPrint('Hint used. Remaining: ${hintsManager.hintCount}');
    } else {
      // No hints available, show rewarded ad if enabled
      if (MonetizationFlags.rewardedForHints) {
        final granted = await AdsService().showRewardedForHint(
          onEarned: () async {
            // Grant +1 hint on successful ad view
            await hintsManager.add(1);
            setState(() {});
            debugPrint('Hint granted from ad. New balance: ${hintsManager.hintCount}');
          },
        );
        
        if (!granted) {
          // Ad failed or user didn't watch, navigate to store
          _showStorePrompt();
        }
      } else {
        // Rewarded ads disabled, show store prompt
        _showStorePrompt();
      }
    }
  }
  
  void _showStorePrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Out of Hints'),
        content: const Text('Watch a short ad to earn a free hint, or purchase hint packs from the store.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to store page
              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StorePage()));
            },
            child: const Text('Go to Store'),
          ),
        ],
      ),
    );
  }
}

class _GameTopBar extends StatelessWidget {
  final int levelId;
  final int moves;
  const _GameTopBar({required this.levelId, required this.moves});

  @override
  Widget build(BuildContext context) {
    final cfg = configForLevel(levelId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Text('Level $levelId', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Text('Grid ${cfg.grid}×${cfg.grid}',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: CCColors.subt)),
          const Spacer(),
          Text(
            'Moves $moves · Hints ${HintsManager().hintCount}',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: CCColors.subt),
          ),
        ],
      ),
    );
  }
}
