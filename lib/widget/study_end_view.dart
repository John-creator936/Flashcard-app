import 'package:flutter/material.dart';

/// Écran de fin d'un tour : score et boutons pour continuer.
class StudyEndView extends StatelessWidget {
  final int correctCount;
  final int totalCount;

  /// Relance les cartes ratées. `null` s'il n'y en a pas : le bouton est caché.
  final VoidCallback? onRetryFailed;

  /// Recommence tout le deck. `null` en Révision : le bouton est caché.
  final VoidCallback? onReset;

  const StudyEndView({
    super.key,
    required this.correctCount,
    required this.totalCount,
    this.onRetryFailed,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearProgressIndicator(value: correctCount / totalCount),
          Text('Score $correctCount / $totalCount'),
          (onRetryFailed == null)
              ? const SizedBox.shrink()
              : SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: onRetryFailed,
                    child: Text("Revoir les cartes ratées"),
                  ),
                ),
          (onReset != null)
              ? SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: onReset,
                    child: Text(
                      "Réinitialiser",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
