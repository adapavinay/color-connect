import 'package:flutter/material.dart';
import 'package:color_connect/features/themes/domain/entities/game_theme.dart';
import 'package:color_connect/core/theme/app_theme.dart';

class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});

  @override
  State<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  List<GameTheme> _themes = [];
  GameTheme? _selectedTheme;
  int _playerLevel = 5; // Mock player level

  @override
  void initState() {
    super.initState();
    _loadThemes();
    _selectedTheme = _themes.first; // Default theme
  }

  void _loadThemes() {
    _themes = [
      // Classic theme (always unlocked)
      GameTheme(
        id: 'classic_default',
        name: 'Classic',
        description: 'The original Color Connect theme',
        category: ThemeCategory.classic,
        primaryColor: AppTheme.primaryColor,
        secondaryColor: AppTheme.secondaryColor,
        accentColor: AppTheme.secondaryColor,
        backgroundColor: Colors.white,
        surfaceColor: Colors.grey[100]!,
        textColor: Colors.black,
        pathColor: AppTheme.primaryColor,
        gridColor: Colors.grey[300]!,
        isUnlocked: true,
        requiredLevel: 1,
      ),
      
      // Dark theme
      GameTheme(
        id: 'dark_theme',
        name: 'Dark Mode',
        description: 'Elegant dark color scheme',
        category: ThemeCategory.modern,
        primaryColor: Colors.blue[700]!,
        secondaryColor: Colors.grey[800]!,
        accentColor: Colors.orange,
        backgroundColor: Colors.black,
        surfaceColor: Colors.grey[900]!,
        textColor: Colors.white,
        pathColor: Colors.cyan,
        gridColor: Colors.grey[700]!,
        isUnlocked: true,
        requiredLevel: 2,
      ),
      
      // Neon theme
      GameTheme(
        id: 'neon_theme',
        name: 'Neon',
        description: 'Bright neon colors',
        category: ThemeCategory.modern,
        primaryColor: Colors.pink,
        secondaryColor: Colors.purple,
        accentColor: Colors.cyan,
        backgroundColor: Colors.black,
        surfaceColor: Colors.grey[900]!,
        textColor: Colors.white,
        pathColor: Colors.yellow,
        gridColor: Colors.grey[800]!,
        isUnlocked: false,
        requiredLevel: 5,
        hasGlow: true,
      ),
      
      // Golden theme
      GameTheme(
        id: 'golden_theme',
        name: 'Golden',
        description: 'Premium golden appearance',
        category: ThemeCategory.fantasy,
        primaryColor: const Color(0xFFFFD700),
        secondaryColor: const Color(0xFFDAA520),
        accentColor: const Color(0xFFFFA500),
        backgroundColor: const Color(0xFF2F2F2F),
        surfaceColor: const Color(0xFF1F1F1F),
        textColor: Colors.white,
        pathColor: const Color(0xFFFFF8DC),
        gridColor: const Color(0xFF696969),
        isUnlocked: false,
        requiredLevel: 10,
        isPremium: true,
        hasParticles: true,
      ),
      
      // Nature theme
      GameTheme(
        id: 'nature_theme',
        name: 'Nature',
        description: 'Inspired by natural colors',
        category: ThemeCategory.nature,
        primaryColor: Colors.green[700]!,
        secondaryColor: Colors.brown[600]!,
        accentColor: Colors.orange[600]!,
        backgroundColor: const Color(0xFFF5F5DC),
        surfaceColor: Colors.green[50]!,
        textColor: Colors.brown[800]!,
        pathColor: Colors.green[600]!,
        gridColor: Colors.brown[200]!,
        isUnlocked: false,
        requiredLevel: 8,
      ),
      
      // Retro theme
      GameTheme(
        id: 'retro_theme',
        name: 'Retro',
        description: '80s inspired retro colors',
        category: ThemeCategory.retro,
        primaryColor: Colors.purple[600]!,
        secondaryColor: Colors.orange[400]!,
        accentColor: Colors.cyan[400]!,
        backgroundColor: Colors.grey[100]!,
        surfaceColor: Colors.white,
        textColor: Colors.black,
        pathColor: Colors.pink[400]!,
        gridColor: Colors.grey[400]!,
        isUnlocked: false,
        requiredLevel: 6,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Custom Themes'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _previewTheme,
            tooltip: 'Preview Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          // Current theme preview
          if (_selectedTheme != null) _buildCurrentThemePreview(),
          
          // Themes grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                final theme = _themes[index];
                return _buildThemeCard(theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentThemePreview() {
    final theme = _selectedTheme!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Theme',
            style: TextStyle(
              color: theme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Theme preview grid
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.gridColor),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                if (index == 0 || index == 2) {
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                } else if (index == 3 || index == 5) {
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.secondaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                } else if (index == 6 || index == 8) {
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.accentColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.gridColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Theme info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    theme.categoryText,
                    style: TextStyle(
                      color: theme.textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (theme.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(GameTheme theme) {
    final isAvailable = _playerLevel >= theme.requiredLevel;
    final isSelected = _selectedTheme?.id == theme.id;
    
    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: isAvailable ? () => _selectTheme(theme) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Theme preview
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.gridColor),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    if (index == 0 || index == 2) {
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    } else if (index == 3 || index == 5) {
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.secondaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    } else if (index == 6 || index == 8) {
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.accentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.gridColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Theme name
              Text(
                theme.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected ? theme.primaryColor : Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Theme description
              Text(
                theme.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Theme features
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (theme.hasParticles)
                    Icon(Icons.auto_awesome, size: 16, color: Colors.orange),
                  if (theme.hasGlow)
                    Icon(Icons.lightbulb, size: 16, color: Colors.yellow),
                  if (theme.isPremium)
                    Icon(Icons.star, size: 16, color: Colors.orange),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.primaryColor),
                ),
                child: Text(
                  theme.categoryText,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              if (!isAvailable) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(
                    'Level ${theme.requiredLevel}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              
              if (isSelected) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SELECTED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectTheme(GameTheme theme) {
    setState(() {
      _selectedTheme = theme;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎨 Theme "${theme.name}" selected!'),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  void _previewTheme() {
    if (_selectedTheme == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preview: ${_selectedTheme!.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This theme will be applied to:'),
            const SizedBox(height: 16),
            _buildPreviewItem('Game Grid', _selectedTheme!.gridColor),
            _buildPreviewItem('Paths', _selectedTheme!.pathColor),
            _buildPreviewItem('UI Elements', _selectedTheme!.primaryColor),
            _buildPreviewItem('Background', _selectedTheme!.backgroundColor),
            if (_selectedTheme!.hasParticles)
              _buildPreviewItem('Particle Effects', Colors.orange),
            if (_selectedTheme!.hasGlow)
              _buildPreviewItem('Glow Effects', Colors.yellow),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _selectTheme(_selectedTheme!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedTheme!.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Apply Theme'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
