import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flashcard_app/database/card_repository.dart';
import 'package:flashcard_app/database/deck_card_repository.dart';
import 'package:flashcard_app/model/app_clock.dart';
import 'package:flashcard_app/model/deck_review_info.dart';
import 'package:flashcard_app/model/deck_share.dart';
import 'package:flashcard_app/model/progress_stats.dart';
import 'package:flashcard_app/model/text_utils.dart';
import 'package:flashcard_app/page/create_deck_page.dart';
import 'package:flashcard_app/widget/deck_search_view.dart';
import 'package:flashcard_app/widget/deck_tile.dart';
import 'package:flashcard_app/widget/progress_summary.dart';
import 'package:flashcard_app/widget/review_deck_tile.dart';
import 'package:flashcard_app/widget/study_mode_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/database/deck_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  List<Deck> allDecks = [];
  Map<int, DeckReviewInfo> reviewInfos = {};
  Map<int, int> cardCounts = {};
  ProgressStats? progressStats;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final decks = await DeckRepository().readAllDecks();
    final now = AppClock.now();
    Map<int, DeckReviewInfo> infos = {};
    for (final deck in decks) {
      infos[deck.id!] = await DeckReviewInfo.load(deck.id!, now);
    }
    final counts = await DeckCardRepository().countCardsPerDeck();
    final stats = await CardRepository().readProgressStats(now);
    if (!mounted) return;
    setState(() {
      allDecks = decks;
      reviewInfos = infos;
      cardCounts = counts;
      progressStats = stats;
    });
  }

  Future<void> _importDeck() async {
    PlatformFile? pickedFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (pickedFile == null) return;
    final bytes = await pickedFile.readAsBytes();
    final text = utf8.decode(bytes, allowMalformed: true);
    final shared = DeckShare.decode(text);
    if (!mounted) return;
    if (shared == null || shared.cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ce fichier n'est pas un deck valide.")),
      );
      return;
    }
    final DateTime now = DateTime.now();
    final savedDeck = await DeckRepository().create(
      Deck(
        name: shared.name,
        createdTime: now,
        deckType: shared.deckType,
        termLanguage: shared.termLanguage,
        definitionLanguage: shared.definitionLanguage,
      ),
    );
    for (final pair in shared.cards) {
      await DeckCardRepository().createCardInDeck(
        deckId: savedDeck.id!,
        term: pair.term,
        definition: pair.definition,
        createdTime: now,
      );
    }
    await _loadDecks();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deck importé : ${cardCountLabel(shared.cards.length)}"),
      ),
    );
  }

  List<Deck> get decksToReview => allDecks
      .where((deck) => reviewInfos[deck.id]?.reviewCards.isNotEmpty ?? false)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (currentPage == 2)
          ? DeckSearchView(allDecks: allDecks)
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 60),
                  Text(
                    "Révisions du jour",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (decksToReview.isEmpty)
                    Text("Tout est à jour !")
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        itemCount: decksToReview.length,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        itemBuilder: (context, index) {
                          final deck = decksToReview[index];
                          final info = reviewInfos[deck.id]!;
                          return ReviewDeckTile(
                            deck: deck,
                            cardCount: info.reviewCards.length,
                            onTap: () => showStudyModeSheet(
                              context,
                              deck: deck,
                              flashcards: info.reviewCards,
                              allCards: info.cards,
                              isReview: true,
                              onFinished: _loadDecks,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 10);
                        },
                      ),
                    ),
                  SizedBox(height: 60),
                  Text(
                    "Mes unités",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      itemCount: allDecks.length,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      itemBuilder: (context, index) {
                        return DeckTile(
                          deck: allDecks[index],
                          onDeckChanged: _loadDecks,
                          cardCount: cardCounts[allDecks[index].id!] ?? 0,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(width: 10);
                      },
                    ),
                  ),
                  SizedBox(height: 60),
                  Text(
                    "Ma progression",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (progressStats != null)
                    ProgressSummary(stats: progressStats!),
                  SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 35,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        onTap: (value) async {
          if (value == 1) {
            showModalBottomSheet(
              context: context,
              builder: (sheetContext) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text("Créer un deck"),
                      leading: Icon(Icons.edit),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateDeckPage(),
                          ),
                        );
                        _loadDecks();
                      },
                    ),
                    ListTile(
                      title: Text("Importer un deck"),
                      leading: Icon(Icons.file_download),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        _importDeck();
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            setState(() {
              currentPage = value;
            });
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ' '),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ' '),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ' '),
        ],
      ),
    );
  }
}
