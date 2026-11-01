import 'package:flutter/material.dart';

/// Deux champs de saisie pour le terme et la définition d'une carte.
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
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          children: [
            TextField(controller: termController),
            TextField(controller: definitionController),
          ],
        ),
      ),
    );
  }
}
