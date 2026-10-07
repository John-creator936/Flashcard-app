import 'package:flutter/material.dart';

class StudyEndView extends StatefulWidget {
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
  State<StudyEndView> createState() => _StudyEndViewState();
}

class _StudyEndViewState extends State<StudyEndView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearProgressIndicator(
            value: widget.correctCount / widget.totalCount,
          ),
          Text('Score ${widget.correctCount} / ${widget.totalCount}'),
          (widget.onRetryFailed == null)
              ? const SizedBox.shrink()
              : SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: widget.onRetryFailed,
                    child: Text("Revoir les cartes ratées"),
                  ),
                ),
          SizedBox(
            width: 250,
            child: ElevatedButton(
              onPressed: widget.onReset,
              child: Text("Réinitialiser", style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
