import 'package:flashcard_app/model/card.dart';
import 'package:flutter/material.dart';

/// Une carte déjà en base, avec des champs pour la modifier.
///
/// [original] garde la version de départ, pour savoir si la carte a changé
/// et pour conserver son progrès SM-2.
class EditableExistingCard {
  final Flashcard original;
  final TextEditingController termController;
  final TextEditingController definitionController;

  EditableExistingCard(this.original)
    : termController = TextEditingController(text: original.term),
      definitionController = TextEditingController(text: original.definition);
}
