import 'package:flashcard_app/widget/study_options.dart';
import 'package:flutter/material.dart';

class StudyOptionsSheet extends StatefulWidget {
  final StudyOptions initialOptions;
  final ValueChanged<StudyOptions> onChanged;
  final VoidCallback onReset;

  const StudyOptionsSheet({
    super.key,
    required this.initialOptions,
    required this.onChanged,
    required this.onReset,
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
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                widget.onReset();
                Navigator.pop(context);
              },
              child: Text("Réinitialiser", style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
