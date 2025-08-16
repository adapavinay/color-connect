// test/generator_v2_smoke_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:color_connect/features/game/domain/entities/level_data.dart';
import 'package:color_connect/features/game/domain/entities/level_validator.dart'
    as intval; // int-based validator used by runtime
import 'package:color_connect/features/game/domain/entities/level_schedule.dart';
import 'package:color_connect/core/config/feature_flags.dart';

void main() {
  test('V2 generates solvable grids for 300 levels', () {
    int ok = 0, bad = 0;
    final failedLevels = <String>[];
    
    print('🧪 Testing V2 algorithm for all 300 levels...');
    print('🔧 Feature flags: V2=${FeatureFlags.useNewGenerator}, Coverage=${FeatureFlags.requireFullCoverage}, Retries=${FeatureFlags.maxRetries}');
    print('─' * 60);
    
    for (int levelId = 1; levelId <= 300; levelId++) {
      try {
        final cfg = configForLevel(levelId);
        final grid = LevelData.generateLevel(
          gridSize: cfg.grid,
          colorCount: cfg.colors,
          seed: cfg.seed,
          minSegmentLen: cfg.minSegmentLen,
        );
        
        final solvable = intval.LevelValidator.isSolvable(grid);
        if (!solvable) {
          bad++;
          final failureInfo = '❌ Level $levelId: ${cfg.grid}×${cfg.grid} grid, ${cfg.colors} colors';
          failedLevels.add(failureInfo);
          print(failureInfo);
          
          // Print grid for debugging
          print('   Grid layout:');
          for (int y = 0; y < grid.length; y++) {
            String row = '   ';
            for (int x = 0; x < grid[y].length; x++) {
              final color = grid[y][x];
              if (color == null) {
                row += '. ';
              } else {
                row += '$color ';
              }
            }
            print(row);
          }
          print('');
        } else {
          ok++;
          if (levelId % 50 == 0) {
            print('✅ Level $levelId: ${cfg.grid}×${cfg.grid}, ${cfg.colors} colors - SOLVABLE');
          }
        }
      } catch (e) {
        bad++;
        final errorInfo = '💥 Level $levelId: ERROR - $e';
        failedLevels.add(errorInfo);
        print(errorInfo);
      }
    }
    
    print('─' * 60);
    print('📊 TEST RESULTS:');
    print('✅ Solvable levels: $ok');
    print('❌ Failed levels: $bad');
    print('📈 Success rate: ${((ok / 300) * 100).toStringAsFixed(1)}%');
    
    if (failedLevels.isNotEmpty) {
      print('\n❌ FAILED LEVELS:');
      for (final failure in failedLevels) {
        print('   $failure');
      }
    }
    
    // Expect all 300 to pass
    expect(bad, 0, reason: 'Some generated levels were unsolvable. Check the logs above for details.');
    print('\n🎉 ALL 300 LEVELS PASSED! V2 algorithm is working perfectly!');
  });
  
  test('V2 generator handles edge cases gracefully', () {
    // Test extreme cases
    final testCases = [
      {'grid': 3, 'colors': 2, 'seed': 1},
      {'grid': 5, 'colors': 3, 'seed': 42},
      {'grid': 7, 'colors': 4, 'seed': 123},
      {'grid': 9, 'colors': 5, 'seed': 999},
      {'grid': 10, 'colors': 6, 'seed': 777},
    ];
    
    for (final testCase in testCases) {
      final grid = LevelData.generateLevel(
        gridSize: testCase['grid']!,
        colorCount: testCase['colors']!,
        seed: testCase['seed']!,
      );
      
      expect(grid, isNotNull, reason: 'V2 should generate a grid for ${testCase['grid']}×${testCase['grid']} with ${testCase['colors']} colors');
      expect(intval.LevelValidator.isSolvable(grid), isTrue, reason: 'Generated grid should be solvable');
      
      // Verify grid dimensions
      expect(grid.length, equals(testCase['grid']), reason: 'Grid should have correct height');
      expect(grid[0].length, equals(testCase['grid']), reason: 'Grid should have correct width');
      
      // Verify endpoint count
      final endpoints = <int, int>{};
      for (int y = 0; y < grid.length; y++) {
        for (int x = 0; x < grid[y].length; x++) {
          final color = grid[y][x];
          if (color != null) {
            endpoints[color] = (endpoints[color] ?? 0) + 1;
          }
        }
      }
      
      expect(endpoints.length, equals(testCase['colors']), reason: 'Should have correct number of colors');
      for (final color in endpoints.keys) {
        expect(endpoints[color], equals(2), reason: 'Each color should have exactly 2 endpoints');
      }
    }
    
    print('✅ Edge case testing passed - V2 handles all grid sizes and color counts');
  });
}
