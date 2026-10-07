import 'package:flutter/material.dart';

class StudyEndView extends StatelessWidget {
  final int correctCount;
  final int totalCount;
  final VoidCallback? onRetryFailed;
  final VoidCallback onReset;

  const StudyEndView({
    super.key,
    required this.correctCount,
    required this.totalCount,
    this.onRetryFailed,
    required this.onReset,
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
          SizedBox(
            width: 250,
            child: ElevatedButton(
              onPressed: onReset,
              child: Text("Réinitialiser", style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
