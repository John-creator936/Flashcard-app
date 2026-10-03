import 'package:flashcard_app/model/deck.dart';
import 'package:flashcard_app/page/deck_detail_page.dart';
import 'package:flutter/material.dart';

class DeckSearchView extends StatefulWidget {
  final List<Deck> allDecks;
  const DeckSearchView({super.key, required this.allDecks});

  @override
  State<DeckSearchView> createState() => _DeckSearchViewState();
}

class _DeckSearchViewState extends State<DeckSearchView> {
  final TextEditingController searchController = TextEditingController();
  late List<Deck> filteredDecks;

  @override
  void initState() {
    super.initState();
    filteredDecks = widget.allDecks;
  }

  void _filterDecks(String query) {
    setState(() {
      filteredDecks = widget.allDecks
          .where((eachDeck) => eachDeck.name.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60),
        TextField(
          controller: searchController,
          decoration: InputDecoration(labelText: "Barre de recherche"),
          onChanged: _filterDecks,
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: filteredDecks.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredDecks[index].name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DeckDetailPage(deck: filteredDecks[index]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
