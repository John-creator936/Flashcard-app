import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/database/deck_card_repository.dart';
import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/deck_card.dart';
import 'package:flashcard_app/page/card_picker_page.dart';
import 'package:flashcard_app/page/deck_picker_page.dart';
import 'package:flashcard_app/widget/editable_existing_card.dart';
import 'package:flashcard_app/widget/flashcard_input.dart';
import 'package:flutter/material.dart';

class CreateDeckPage extends StatefulWidget {
  final Deck? existingDeck;
  const CreateDeckPage({super.key, this.existingDeck});

  @override
  State<CreateDeckPage> createState() => _CreateDeckPageState();
}

class _CreateDeckPageState extends State<CreateDeckPage> {
  final TextEditingController titleController = TextEditingController();
  final List<TextEditingController> termControllers = [];
  final List<TextEditingController> definitionControllers = [];
  final List<EditableExistingCard> selectedExistingCards = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingDeck != null) {
      titleController.text = widget.existingDeck!.name;
      _loadExistingDeckCards();
    }
  }

  Future<void> _loadExistingDeckCards() async {
    final loadedCards = await CardRepository().readCardsByDeck(
      widget.existingDeck!.id!,
    );
    setState(() {
      final List<EditableExistingCard> editableExistingCards = loadedCards
          .map(
            (loadedCard) => EditableExistingCard(
              cardId: loadedCard.id!,
              termController: TextEditingController(text: loadedCard.term),
              definitionController: TextEditingController(
                text: loadedCard.definition,
              ),
              originalTerm: loadedCard.term,
              originalDefinition: loadedCard.definition,
              originalCreatedTime: loadedCard.createdTime,
            ),
          )
          .toList();
      selectedExistingCards.addAll(editableExistingCards);
    });
  }

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
    for (var selectedExistingCard in selectedExistingCards) {
      selectedExistingCard.termController.dispose();
      selectedExistingCard.definitionController.dispose();
    }
    super.dispose();
  }

  /// Enregistre le deck en cours de création ou de modification.
  ///
  /// Si `widget.existingDeck` est fourni, le deck est mis à jour (nouveau titre,
  /// date de création conservée) ; sinon, un nouveau deck est créé.
  Future<void> _saveDeck() async {
    final DateTime createdTime = DateTime.now();
    final deckRepository = DeckRepository();
    final Deck savedDeck;
    if (widget.existingDeck == null) {
      final Deck deck = Deck(
        name: titleController.text,
        createdTime: createdTime,
      );
      savedDeck = await deckRepository.create(deck);
    } else {
      final Deck deck = Deck(
        id: widget.existingDeck!.id,
        name: titleController.text,
        createdTime: widget.existingDeck!.createdTime,
      );
      await deckRepository.update(deck);
      savedDeck = deck;
    }
    final cardRepository = CardRepository();

    for (int i = 0; i < termControllers.length; i++) {
      final DateTime flashcardCreatedTime = DateTime.now();
      final flashcard = Flashcard(
        definition: definitionControllers[i].text,
        term: termControllers[i].text,
        createdTime: flashcardCreatedTime,
      );
      Flashcard savedFlashcard = await cardRepository.create(flashcard);
      DeckCardLink link = DeckCardLink(
        deckId: savedDeck.id!,
        cardId: savedFlashcard.id!,
        createdTime: createdTime,
      );
      await DeckCardRepository().linkCardToDeck(link);
    }

    for (int i = 0; i < selectedExistingCards.length; i++) {
      if (selectedExistingCards[i].termController.text !=
              selectedExistingCards[i].originalTerm ||
          selectedExistingCards[i].definitionController.text !=
              selectedExistingCards[i].originalDefinition) {
        final flashcard = Flashcard(
          id: selectedExistingCards[i].cardId,
          definition: selectedExistingCards[i].definitionController.text,
          term: selectedExistingCards[i].termController.text,
          createdTime: selectedExistingCards[i].originalCreatedTime,
        );
        await cardRepository.update(flashcard);
      }
      DeckCardLink link = DeckCardLink(
        deckId: savedDeck.id!,
        cardId: selectedExistingCards[i].cardId,
        createdTime: createdTime,
      );
      await DeckCardRepository().linkCardToDeck(link);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget.existingDeck == null)
            ? Text("Création d'unité")
            : Text("Modification d'unité"),
        actions: [
          IconButton(
            onPressed: () async {
              final Deck? chosenDeck = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeckPickerPage()),
              );
              if (chosenDeck != null) {
                if (context.mounted) {
                  List<Flashcard>? selectedCards = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardPickerPage(deck: chosenDeck),
                    ),
                  );
                  if (selectedCards != null) {
                    final List<EditableExistingCard> editableExistingCards =
                        selectedCards
                            .map(
                              (selectedCard) => EditableExistingCard(
                                cardId: selectedCard.id!,
                                termController: TextEditingController(
                                  text: selectedCard.term,
                                ),
                                definitionController: TextEditingController(
                                  text: selectedCard.definition,
                                ),
                                originalTerm: selectedCard.term,
                                originalDefinition: selectedCard.definition,
                                originalCreatedTime: selectedCard.createdTime,
                              ),
                            )
                            .toList();
                    setState(() {
                      selectedExistingCards.addAll(editableExistingCards);
                    });
                  }
                }
              }
            },
            icon: const Icon(Icons.library_add),
          ),
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
            ...List.generate(selectedExistingCards.length, (index) {
              return Dismissible(
                key: ObjectKey(selectedExistingCards[index]),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  if (widget.existingDeck != null) {
                    await DeckCardRepository().unlinkCardFromDeck(
                      widget.existingDeck!.id!,
                      selectedExistingCards[index].cardId,
                    );
                  }
                  setState(() {
                    final removedCard = selectedExistingCards.removeAt(index);
                    removedCard.termController.dispose();
                    removedCard.definitionController.dispose();
                  });
                },
                child: FlashcardInput(
                  termController: selectedExistingCards[index].termController,
                  definitionController:
                      selectedExistingCards[index].definitionController,
                ),
              );
            }),
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
