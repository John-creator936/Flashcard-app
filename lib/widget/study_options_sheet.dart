import 'package:flashcard_app/model/study_options.dart';
import 'package:flutter/material.dart';

/// Menu des options d'un mode : inverser, mélanger et, en QCM, pièges d'orthographe.
///
/// Les options s'appliquent dès qu'on les change, sans bouton de validation.
class StudyOptionsSheet extends StatefulWidget {
  final StudyOptions initialOptions;
  final ValueChanged<StudyOptions> onChanged;

  /// Bouton « Réinitialiser », caché si `null` (en Révision).
  final VoidCallback? onReset;

  /// Affiche l'option des pièges, seulement en QCM.
  final bool showSpellingTraps;

  const StudyOptionsSheet({
    super.key,
    required this.initialOptions,
    required this.onChanged,
    this.onReset,
    this.showSpellingTraps = false,
  });

  @override
  State<StudyOptionsSheet> createState() => _StudyOptionsSheetState();
}

class _StudyOptionsSheetState extends State<StudyOptionsSheet> {
  late StudyOptions options;

  @override
  void initState() {
    super.initState();
    options = widget.initialOptions;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: Text("Inverser"),
            value: options.reversed,
            onChanged: (value) {
              setState(() {
                options = options.copy(reversed: value);
              });
              widget.onChanged(options);
            },
          ),
          SwitchListTile(
            title: Text("Mélanger"),
            value: options.shuffled,
            onChanged: (value) {
              setState(() {
                options = options.copy(shuffled: value);
              });
              widget.onChanged(options);
            },
          ),
          if (widget.showSpellingTraps)
            SwitchListTile(
              title: Text("Pièges d'orthographe"),
              subtitle: Text(
                "Fausses réponses inventées au lieu d'autres cartes",
              ),
              value: options.spellingTraps,
              onChanged: (value) {
                setState(() {
                  options = options.copy(spellingTraps: value);
                });
                widget.onChanged(options);
              },
            ),
          (widget.onReset != null)
              ? SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onReset!();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Réinitialiser",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
