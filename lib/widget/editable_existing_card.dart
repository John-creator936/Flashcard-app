import 'package:flashcard_app/model/card.dart';
import 'package:flutter/material.dart';

class EditableExistingCard {
  final Flashcard original;
  final TextEditingController termController;
  final TextEditingController definitionController;

  EditableExistingCard(this.original)
    : termController = TextEditingController(text: original.term),
      definitionController = TextEditingController(text: original.definition);
}
