import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/game/presentation/pages/game_page.dart';
import 'package:color_connect/features/game/domain/entities/level_data.dart';
import 'package:color_connect/features/progress/domain/entities/progress_manager.dart';

class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({super.key});

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> {
  final ProgressManager _progressManager = ProgressManager();
  List<Map<String, dynamic>> _packsProgress = [];
  bool _isLoading = true;

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
    setState(() {
      _packsProgress = _progressManager.getAllPacksProgress();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Select Level Pack'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${_progressManager.totalStars}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Progress Summary
                      _buildProgressSummary(),
                      const SizedBox(height: 24),
                      
                      // Packs List
                      Expanded(
                        child: ListView.builder(
                          itemCount: _packsProgress.length,
                          itemBuilder: (context, index) {
                            final pack = _packsProgress[index];
                            return _buildPackCard(context, pack);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    final summary = _progressManager.getProgressSummary();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total Stars',
                '${summary['totalStars']}',
                Icons.star,
                Colors.amber,
              ),
              _buildSummaryItem(
                'Completed',
                '${summary['completedLevels']}/${summary['totalLevels']}',
                Icons.check_circle,
                Colors.green,
              ),
              _buildSummaryItem(
                'Progress',
                '${summary['completionPercentage'].toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: summary['completionPercentage'] / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
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

  Widget _buildPackCard(BuildContext context, Map<String, dynamic> pack) {
    final isUnlocked = pack['isUnlocked'] as bool;
    final packNumber = pack['packNumber'] as int;
    final packName = pack['packName'] as String;
    final totalLevels = pack['totalLevels'] as int;
    final completedLevels = pack['completedLevels'] as int;
    final totalStars = pack['totalStars'] as int;
    final maxPossibleStars = pack['maxPossibleStars'] as int;
    final unlockRequirement = pack['unlockRequirement'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isUnlocked
              ? BorderSide(color: AppTheme.primaryColor, width: 2)
              : BorderSide(color: Colors.grey, width: 1),
        ),
        child: InkWell(
          onTap: isUnlocked ? () => _selectPack(context, packNumber) : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: isUnlocked ? AppTheme.primaryColor : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Pack $packNumber • $totalLevels levels',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isUnlocked ? Colors.grey[600] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUnlocked ? AppTheme.primaryColor : Colors.grey,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isUnlocked ? Icons.play_arrow : Icons.lock,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress bar
                LinearProgressIndicator(
                  value: totalLevels > 0 ? completedLevels / totalLevels : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUnlocked ? AppTheme.primaryColor : Colors.grey,
                  ),
                  minHeight: 6,
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completedLevels/$totalLevels completed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isUnlocked ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(
                          '$totalStars/$maxPossibleStars',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isUnlocked ? Colors.grey[600] : Colors.grey[500],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                if (!isUnlocked) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Need $unlockRequirement stars to unlock',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectPack(BuildContext context, int packNumber) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackLevelsPage(packNumber: packNumber),
      ),
    );
    if (!mounted) return;
    setState(() {
      _packsProgress = _progressManager.getAllPacksProgress(); // refresh pack progress
    });
  }
}

class PackLevelsPage extends StatefulWidget {
  final int packNumber;

  const PackLevelsPage({super.key, required this.packNumber});

  @override
  State<PackLevelsPage> createState() => _PackLevelsPageState();
}

class _PackLevelsPageState extends State<PackLevelsPage> {
  final ProgressManager _progressManager = ProgressManager();
  List<int> _levelsInPack = [];
  String _packName = '';

  @override
  void initState() {
    super.initState();
    _loadPackData();
  }

  void _loadPackData() {
    _levelsInPack = LevelData.getLevelsInPack(widget.packNumber);
    _packName = LevelData.getPackName(widget.packNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_packName Pack'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: _levelsInPack.length,
              itemBuilder: (context, index) {
                final levelId = _levelsInPack[index];
                return _buildLevelButton(context, levelId);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, int levelId) {
    final isCompleted = _progressManager.isLevelCompleted(levelId);
    final starsEarned = _progressManager.getLevelStars(levelId);
    final gridSize = LevelData.getGridSize(levelId);

    return InkWell(
      onTap: () => _startLevel(context, levelId),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? Colors.green : AppTheme.primaryColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$levelId',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isCompleted ? Colors.white : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${gridSize}x$gridSize',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isCompleted ? Colors.white70 : Colors.grey[600],
              ),
            ),
            if (isCompleted) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < starsEarned ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startLevel(BuildContext context, int levelId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(levelId: levelId)),
    );
    if (!mounted) return;
    // Refresh the level data to show updated completion status
    setState(() {
      _loadPackData();
    });
  }
}
