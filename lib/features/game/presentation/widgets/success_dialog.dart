import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';

class SuccessDialog extends StatelessWidget {
  final int levelId;
  final int stars;
  final VoidCallback onNext;
  final VoidCallback onLevelList;

  const SuccessDialog({
    super.key,
    required this.levelId,
    required this.stars,
    required this.onNext,
    required this.onLevelList,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉 Level $levelId Complete!', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Great job! Ready for the next challenge?',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: CCColors.subt)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Icon(
                  i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 28, color: CCColors.accent,
                )),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CCColors.subt.withOpacity(.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Total Stars: 126   ·   Completed: 88/300',
                    style: Theme.of(context).textTheme.labelMedium),
              ),
              const SizedBox(height: 14),
              // Buttons: Level List (left), Next (right). Wrap to avoid overflow.
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onLevelList,
                      icon: const Icon(Icons.list_alt_rounded),
                      label: const Text('Level List'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onNext,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
