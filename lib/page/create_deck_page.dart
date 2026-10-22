import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/database/deck_card_repository.dart';
import 'package:flashcard_app/database/deck_repository.dart';
import 'package:flashcard_app/model/card.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/model/deck_card.dart';
import 'package:flashcard_app/model/vocabulary_parser.dart';
import 'package:flashcard_app/page/card_picker_page.dart';
import 'package:flashcard_app/page/deck_picker_page.dart';
import 'package:flashcard_app/widget/deck_settings_sheet.dart';
import 'package:flashcard_app/widget/editable_existing_card.dart';
import 'package:flashcard_app/widget/flashcard_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
  late String deckType;
  String? termLanguage;
  String? definitionLanguage;

  @override
  void initState() {
    super.initState();
    deckType = widget.existingDeck?.deckType ?? 'translation';
    termLanguage = widget.existingDeck?.termLanguage;
    definitionLanguage = widget.existingDeck?.definitionLanguage;
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
          .map((loadedCard) => EditableExistingCard(loadedCard))
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
  /// mis à jour (nouveau titre, type et langues, date de création conservée)
  Future<void> _saveDeck() async {
    final DateTime createdTime = DateTime.now();
    final deckRepository = DeckRepository();
    final Deck savedDeck;
    if (widget.existingDeck == null) {
      final Deck deck = Deck(
        name: titleController.text,
        createdTime: createdTime,
        deckType: deckType,
        termLanguage: termLanguage,
        definitionLanguage: definitionLanguage,
      );
      savedDeck = await deckRepository.create(deck);
    } else {
      final Deck deck = Deck(
        id: widget.existingDeck!.id,
        name: titleController.text,
        createdTime: widget.existingDeck!.createdTime,
        deckType: deckType,
        termLanguage: termLanguage,
        definitionLanguage: definitionLanguage,
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
              selectedExistingCards[i].original.term ||
          selectedExistingCards[i].definitionController.text !=
              selectedExistingCards[i].original.definition) {
        final flashcard = selectedExistingCards[i].original.copy(
          term: selectedExistingCards[i].termController.text,
          definition: selectedExistingCards[i].definitionController.text,
        );
        await cardRepository.update(flashcard);
      }
      DeckCardLink link = DeckCardLink(
        deckId: savedDeck.id!,
        cardId: selectedExistingCards[i].original.id!,
        createdTime: createdTime,
      );
      await DeckCardRepository().linkCardToDeck(link);
    }
  }

  Future<void> _pickExistingCards() async {
    final Deck? chosenDeck = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeckPickerPage()),
    );
    if (chosenDeck != null) {
      if (mounted) {
        List<Flashcard>? selectedCards = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardPickerPage(deck: chosenDeck),
          ),
        );
        if (selectedCards != null) {
          final List<EditableExistingCard> editableExistingCards = selectedCards
              .map((selectedCard) => EditableExistingCard(selectedCard))
              .toList();
          setState(() {
            selectedExistingCards.addAll(editableExistingCards);
          });
        }
      }
    }
  }

  Future<void> _scanVocabulary() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    final InputImage inputImage = InputImage.fromFilePath(pickedFile.path);
    final TextRecognizer textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    textRecognizer.close();
    final List<OcrLine> ocrLines = [];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        ocrLines.add(
          OcrLine(
            text: line.text,
            left: line.cornerPoints[0].x.toDouble(),
            top: line.cornerPoints[0].y.toDouble(),
          ),
        );
      }
    }

    final pairs = VocabularyParser.parse(ocrLines);
    if (!mounted) return;
    if (pairs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Aucun mot reconnu sur cette photo.")),
      );
      return;
    }
    setState(() {
      for (final pair in pairs) {
        termControllers.add(TextEditingController(text: pair.term));
        definitionControllers.add(TextEditingController(text: pair.definition));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${pairs.length} ${(pairs.length > 1) ? "cartes ajoutées" : "carte ajoutée"} : vérifie-les avant d'enregistrer.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget.existingDeck == null)
            ? Text("Création")
            : Text("Modification"),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => DeckSettingsSheet(
                  initialDeckType: deckType,
                  initialTermLanguage: termLanguage,
                  initialDefinitionLanguage: definitionLanguage,
                  onChanged: (newType, newTermLanguage, newDefinitionLanguage) {
                    setState(() {
                      deckType = newType;
                      termLanguage = newTermLanguage;
                      definitionLanguage = newDefinitionLanguage;
                    });
                  },
                ),
              );
            },
            icon: Icon(Icons.tune),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.playlist_add),
            onSelected: (value) {
              if (value == 'deck') {
                _pickExistingCards();
              } else if (value == 'photo') {
                _scanVocabulary();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'deck',
                child: ListTile(
                  leading: Icon(Icons.library_add),
                  title: Text("Depuis un autre deck"),
                ),
              ),
              PopupMenuItem(
                value: 'photo',
                child: ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text("Depuis une photo"),
                ),
              ),
            ],
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
                      selectedExistingCards[index].original.id!,
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
