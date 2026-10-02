import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/widget/flashcard_input.dart';
import 'package:flutter/material.dart';

class CreateDeckPage extends StatefulWidget {
  const CreateDeckPage({super.key});

  @override
  State<CreateDeckPage> createState() => _CreateDeckPageState();
}

class _CreateDeckPageState extends State<CreateDeckPage> {
  final TextEditingController titleController = TextEditingController();
  final List<TextEditingController> termControllers = [];
  final List<TextEditingController> definitionControllers = [];

  void _addCard() {
    setState(() {
      final TextEditingController termController = TextEditingController();
      final TextEditingController definitionController =
          TextEditingController();
      termControllers.add(termController);
      definitionControllers.add(definitionController);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var termController in termControllers) {
      termController.dispose();
    }
    for (var definitionController in definitionControllers) {
      definitionController.dispose();
    }
    super.dispose();
  }

  Future<void> _saveDeck() async {
    final DateTime createdTime = DateTime.now();
    final deck = Deck(name: titleController.text, createdTime: createdTime);
    final deckRepository = DeckRepository();
    final savedDeck = await deckRepository.create(deck);
    final cardRepository = CardRepository();

    for (int i = 0; i < termControllers.length; i++) {
      final DateTime flashcardCreatedTime = DateTime.now();
      final flashcard = Flashcard(
        deckId: savedDeck.id!,
        definition: definitionControllers[i].text,
        term: termControllers[i].text,
        createdTime: flashcardCreatedTime,
      );
      await cardRepository.create(flashcard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Création d'unité"),
        actions: [
          IconButton(
            onPressed: () async {
              await _saveDeck();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Titre de l'unité"),
            ),
            ...List.generate(termControllers.length, (index) {
              return Dismissible(
                key: ObjectKey(termControllers[index]),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  setState(() {
                    final removedTermController = termControllers.removeAt(
                      index,
                    );
                    final removedDefinitonController = definitionControllers
                        .removeAt(index);
                    removedTermController.dispose();
                    removedDefinitonController.dispose();
                  });
                },
                child: FlashcardInput(
                  termController: termControllers[index],
                  definitionController: definitionControllers[index],
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: Icon(Icons.add),
      ),
    );
  }
}
