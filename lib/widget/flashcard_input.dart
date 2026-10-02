import 'package:flutter/material.dart';

class FlashcardInput extends StatelessWidget {
  final TextEditingController termController;
  final TextEditingController definitionController;

  const FlashcardInput({
    super.key,
    required this.termController,
    required this.definitionController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          TextField(controller: termController),
          TextField(controller: definitionController),
        ],
      ),
    );
  }
}
