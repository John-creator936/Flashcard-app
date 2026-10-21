import 'package:flashcard_app/model/deck.dart';
import 'package:flutter/material.dart';

class DeckSettingsSheet extends StatefulWidget {
  final String initialDeckType;
  final String? initialTermLanguage;
  final String? initialDefinitionLanguage;
  final void Function(
    String deckType,
    String? termLanguage,
    String? definitionLanguage,
  )
  onChanged;

  const DeckSettingsSheet({
    super.key,
    required this.initialDeckType,
    this.initialTermLanguage,
    this.initialDefinitionLanguage,
    required this.onChanged,
  });

  @override
  State<DeckSettingsSheet> createState() => _DeckSettingsSheetState();
}

class _DeckSettingsSheetState extends State<DeckSettingsSheet> {
  late String deckType;
  late String? termLanguage;
  late String? definitionLanguage;
  final languageItems = deckLanguages.entries
      .map(
        (entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    deckType = widget.initialDeckType;
    termLanguage = widget.initialTermLanguage;
    definitionLanguage = widget.initialDefinitionLanguage;
  }

  void _notify() {
    widget.onChanged(deckType, termLanguage, definitionLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Type de deck"),
          RadioGroup<String>(
            groupValue: deckType,
            onChanged: (value) {
              setState(() {
                deckType = value!;
              });
              _notify();
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'translation',
                  title: Text("Vocabulaire"),
                  subtitle: Text(
                    "Un mot et sa traduction. Ex. : Haus → maison",
                  ),
                ),
                RadioListTile<String>(
                  value: 'definition',
                  title: Text("Définitions"),
                  subtitle: Text(
                    "Un terme et son explication. Ex. : photosynthèse → processus par lequel…",
                  ),
                ),
                RadioListTile<String>(
                  value: 'other',
                  title: Text("Réponses courtes"),
                  subtitle: Text(
                    "Dates, noms, nombres… Ex. : Révolution française → 1789",
                  ),
                ),
              ],
            ),
          ),
          if (deckType == 'translation') ...[
            ListTile(
              title: Text("Langue du terme"),
              trailing: DropdownButton<String>(
                value: termLanguage,
                hint: Text("Choisir"),
                items: languageItems,
                onChanged: (value) {
                  setState(() {
                    termLanguage = value;
                  });
                  _notify();
                },
              ),
            ),
            ListTile(
              title: Text("Langue de la définition"),
              trailing: DropdownButton<String>(
                value: definitionLanguage,
                hint: Text("Choisir"),
                items: languageItems,
                onChanged: (value) {
                  setState(() {
                    definitionLanguage = value;
                  });
                  _notify();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
