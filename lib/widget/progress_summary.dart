import 'package:flashcard_app/model/progress_stats.dart';
import 'package:flutter/material.dart';

class ProgressSummary extends StatelessWidget {
  final ProgressStats stats;
  const ProgressSummary({super.key, required this.stats});

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 14),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: _buildStat("Aujourd'hui", stats.reviewedToday)),
            Expanded(child: _buildStat("Nouvelles", stats.newCount)),
            Expanded(child: _buildStat("En cours", stats.learningCount)),
            Expanded(child: _buildStat("Maîtrisées", stats.masteredCount)),
          ],
        ),
      ),
    );
  }
}
