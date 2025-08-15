import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/game/domain/entities/puzzle_creator.dart';
import 'package:color_connect/features/game/presentation/pages/game_page.dart';
import 'package:color_connect/features/level_select/domain/entities/level.dart';
import 'package:color_connect/features/game/domain/entities/color_connect_game.dart';
import 'package:flame/game.dart';

class PuzzleCreatorPage extends StatefulWidget {
  const PuzzleCreatorPage({super.key});

  @override
  State<PuzzleCreatorPage> createState() => _PuzzleCreatorPageState();
}

class _PuzzleCreatorPageState extends State<PuzzleCreatorPage> {
  int _selectedGridSize = 5;
  int _selectedColorCount = 3;
  PuzzleDifficulty _selectedDifficulty = PuzzleDifficulty.medium;
  List<List<int?>>? _generatedPuzzle;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Puzzle Creator'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showPuzzleCreatorInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_fix_high,
                    size: 48,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Your Own Puzzles!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Design custom puzzles with different difficulty levels and challenge your friends!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid Size Selection
            _buildSectionTitle('Grid Size'),
            _buildGridSizeSelector(),
            const SizedBox(height: 24),

            // Color Count Selection
            _buildSectionTitle('Number of Colors'),
            _buildColorCountSelector(),
            const SizedBox(height: 24),

            // Difficulty Selection
            _buildSectionTitle('Difficulty Level'),
            _buildDifficultySelector(),
            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generatePuzzle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isGenerating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_fix_high, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Generate Puzzle',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Generated Puzzle Preview
            if (_generatedPuzzle != null) _buildPuzzlePreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGridSizeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedGridSize}x${_selectedGridSize}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_selectedGridSize * _selectedGridSize} cells',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedGridSize.toDouble(),
            min: 3,
            max: 10,
            divisions: 7,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() {
                _selectedGridSize = value.round();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('3x3', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('10x10', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorCountSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_selectedColorCount Colors',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_selectedColorCount * 2} endpoints',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedColorCount.toDouble(),
            min: 2,
            max: 6,
            divisions: 4,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() {
                _selectedColorCount = value.round();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('2 colors', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('6 colors', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDifficulty.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _selectedDifficulty.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedDifficulty.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedDifficulty.color.withOpacity(0.3)),
                ),
                child: Text(
                  _selectedDifficulty.displayName,
                  style: TextStyle(
                    color: _selectedDifficulty.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedDifficulty.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PuzzleDifficulty.values.map((difficulty) {
              final isSelected = difficulty == _selectedDifficulty;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDifficulty = difficulty;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? difficulty.color : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? difficulty.color : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    difficulty.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : difficulty.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzlePreview() {
    final optimalMoves = PuzzleCreator.calculateOptimalMoves(_generatedPuzzle!);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Generated Puzzle',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedDifficulty.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedDifficulty.color.withOpacity(0.3)),
                ),
                child: Text(
                  _selectedDifficulty.displayName,
                  style: TextStyle(
                    color: _selectedDifficulty.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Puzzle stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Grid', '${_selectedGridSize}x${_selectedGridSize}'),
              _buildStatItem('Colors', '$_selectedColorCount'),
              _buildStatItem('Optimal', '$optimalMoves'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Grid preview
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildGridPreview(),
            ),
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _playPuzzle(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 20),
                      SizedBox(width: 8),
                      Text('Play Puzzle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _generatePuzzle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text('Generate New', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
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

  Widget _buildGridPreview() {
    final cellSize = 20.0;
    final gridSize = _generatedPuzzle!.length;
    
    return Column(
      children: List.generate(gridSize, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(gridSize, (col) {
            final cell = _generatedPuzzle![row][col];
            Color cellColor = Colors.transparent;
            String cellText = '';
            
            if (cell != null) {
              if (cell >= 0) {
                // Regular color endpoint
                cellColor = _getColorForIndex(cell);
                cellText = '●';
              } else if (cell == -1) {
                // Blocked cell
                cellColor = Colors.grey;
                cellText = '■';
              } else if (cell == -2) {
                // Teleporter
                cellColor = Colors.purple;
                cellText = '⚡';
              } else if (cell == -3) {
                // Color changer
                cellColor = Colors.orange;
                cellText = '🔄';
              } else if (cell == -4) {
                // Multiplier
                cellColor = Colors.red;
                cellText = '✖';
              }
            }
            
            return Container(
              width: cellSize,
              height: cellSize,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  cellText,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];
    return colors[index % colors.length];
  }

  void _generatePuzzle() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Simulate generation time
      await Future.delayed(const Duration(milliseconds: 500));
      
      final puzzle = PuzzleCreator.createCustomPuzzle(
        gridSize: _selectedGridSize,
        colorCount: _selectedColorCount,
        difficulty: _selectedDifficulty,
      );
      
      setState(() {
        _generatedPuzzle = puzzle;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating puzzle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _playPuzzle() {
    if (_generatedPuzzle == null) return;
    
    final customLevel = Level(
      id: 999, // Special ID for custom puzzles
      name: 'Custom Puzzle',
      gridSize: _selectedGridSize,
      colors: _selectedColorCount,
      isCompleted: false,
      isUnlocked: true,
      stars: 0,
      optimalMoves: PuzzleCreator.calculateOptimalMoves(_generatedPuzzle!),
      bestMoves: null,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomGamePage(
          level: customLevel,
          customGridData: _generatedPuzzle!,
        ),
      ),
    );
  }

  void _showPuzzleCreatorInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎨 Puzzle Creator Info'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Create custom puzzles with different grid sizes'),
            Text('• Choose from 2-6 colors for variety'),
            Text('• Select difficulty: Easy, Medium, Hard, Expert'),
            Text('• Easy: Simple patterns, few obstacles'),
            Text('• Medium: Some obstacles, moderate complexity'),
            Text('• Hard: Many obstacles, teleporters'),
            Text('• Expert: Special cells, maximum complexity'),
            SizedBox(height: 16),
            Text('💡 Tip: Start with Easy difficulty and work your way up!'),
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

class CustomGamePage extends GamePage {
  final List<List<int?>> customGridData;
  
  const CustomGamePage({
    super.key,
    required super.level,
    required this.customGridData,
  });
  
  @override
  State<CustomGamePage> createState() => _CustomGamePageState();
}

class _CustomGamePageState extends State<CustomGamePage> {
  late ColorConnectGame _game;
  int _moves = 0;
  
  @override
  void initState() {
    super.initState();
    // Create game with custom grid data
    _game = ColorConnectGame(
      gridSize: widget.level.gridSize,
      levelData: widget.customGridData,
      onLevelComplete: (completed) {
        if (completed) {
          _showLevelCompleteDialog();
        }
      },
      onMoveCount: (moves) {
        setState(() {
          _moves += moves;
        });
      },
    );
  }
  
  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Puzzle Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Congratulations! You solved the custom puzzle!'),
            const SizedBox(height: 16),
            Text('Moves: $_moves'),
            Text('Optimal: ${widget.level.optimalMoves}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Puzzle - ${widget.level.name}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Game stats
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Moves', '$_moves'),
                _buildStatItem('Grid', '${widget.level.gridSize}x${widget.level.gridSize}'),
                _buildStatItem('Colors', '${widget.level.colors}'),
              ],
            ),
          ),
          // Game canvas
          Expanded(
            child: GameWidget(game: _game),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
