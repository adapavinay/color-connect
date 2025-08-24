import 'package:flutter/material.dart';
import 'package:color_connect/core/config/feature_flags.dart';
import 'package:color_connect/services/ads_service.dart';
import 'package:color_connect/features/store/domain/daily_rewards_manager.dart';
import 'package:color_connect/features/progress/domain/entities/progress_manager.dart';

class StarStorePage extends StatefulWidget {
  const StarStorePage({super.key});

  @override
  State<StarStorePage> createState() => _StarStorePageState();
}

class _StarStorePageState extends State<StarStorePage> {
  bool _busy = false;

  Future<void> _onWatchPressed() async {
    debugPrint('🎯 _onWatchPressed called!');
    if (_busy) {
      debugPrint('🚫 Already busy, returning');
      return;
    }
    setState(() => _busy = true);
    debugPrint('🔄 Set busy to true');
    try {
      debugPrint('✅ StarRewards.enabled: ${StarRewards.enabled}');
      if (!StarRewards.enabled) {
        debugPrint('❌ StarRewards disabled');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Temporarily unavailable')),
        );
        return;
      }

      final remaining = await DailyRewardsManager.remainingToday(StarRewards.dailyCap);
      if (remaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily limit reached. Try again tomorrow!')),
        );
        return;
      }

      final granted = await AdsService().showRewardedForHint(onEarned: () async {
        await ProgressManager().addBonusStars(StarRewards.starsPerAd);
        await DailyRewardsManager.increment();
      });

      if (granted) {
        if (!mounted) return;
        final newRemaining =
            await DailyRewardsManager.remainingToday(StarRewards.dailyCap);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⭐ +${StarRewards.starsPerAd} star${StarRewards.starsPerAd == 1 ? '' : 's'} added. ($newRemaining left today)',
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad not available. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ StarStorePage build called');
    final getMoreStarsTile = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _busy ? null : () {
        debugPrint('👆 InkWell onTap triggered!');
        _onWatchPressed();
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.star, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Get more stars',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('Watch a short video to earn stars.',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _busy ? null : _onWatchPressed,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Watch'),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Star Store'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // your existing store tiles / packs here...
            const SizedBox(height: 8),
            getMoreStarsTile,
          ],
        ),
      ),
    );
  }
}
