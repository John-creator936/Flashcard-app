import 'package:flutter/material.dart';

class StudyEndView extends StatefulWidget {
  final int correctCount;
  final int totalCount;
  final VoidCallback? onRetryFailed;
  const StudyEndView({
    super.key,
    required this.correctCount,
    required this.totalCount,
    this.onRetryFailed,
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
              : IconButton(
                  onPressed: widget.onRetryFailed,
                  icon: Icon(Icons.restart_alt),
                ),
        ],
      ),
    );
  }
}
