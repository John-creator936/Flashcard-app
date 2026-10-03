import 'package:flutter/material.dart';

class EditableExistingCard {
  final int cardId;
  final TextEditingController termController;
  final TextEditingController definitionController;
  final String originalTerm;
  final String originalDefinition;
  final DateTime originalCreatedTime;

  EditableExistingCard({
    required this.cardId,
    required this.termController,
    required this.definitionController,
    required this.originalTerm,
    required this.originalDefinition,
    required this.originalCreatedTime,
  });
}
