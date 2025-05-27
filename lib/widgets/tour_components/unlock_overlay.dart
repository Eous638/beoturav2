import 'package:beotura/models/immersive_tour_page.dart';
import 'package:flutter/material.dart';

/// Overlay shown when a tour page needs unlocking via distance traveled
class UnlockOverlay extends StatelessWidget {
  final String message;
  final double progress;
  final VoidCallback onOverride;

  const UnlockOverlay({
    super.key,
    required this.message,
    required this.progress,
    required this.onOverride, required UnlockCondition unlockCondition, required Null Function() onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Walking icon animation
              const Icon(
                Icons.directions_walk,
                size: 64,
                color: Colors.white70,
              ),

              const SizedBox(height: 24),

              // Unlock message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // Progress indicator with percentage label
              Stack(
                alignment: Alignment.center,
                children: [
                  // Progress circle
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),

                  // Percentage text
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Override button for development purposes
              ElevatedButton(
                onPressed: onOverride,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Unlock Anyway',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
