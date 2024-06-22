import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  final Map<String, List<String>> favoriteQuotesByCategory;

  FavoritesPage(this.favoriteQuotesByCategory);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.favoriteQuotesByCategory.clear();
      (prefs.getStringList('favorites') ?? []).forEach((quote) {
        final parts = quote.split('||');
        final category = parts[0];
        final text = parts[1];
        if (!widget.favoriteQuotesByCategory.containsKey(category)) {
          widget.favoriteQuotesByCategory[category] = [];
        }
        widget.favoriteQuotesByCategory[category]!.add(text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Quotes'),
        backgroundColor: Colors.teal, // Customize app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: widget.favoriteQuotesByCategory.keys.map((category) {
            final quotes = widget.favoriteQuotesByCategory[category]!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Card(
                elevation: 4, // Add elevation for a card-like appearance
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        color: colors[widget.favoriteQuotesByCategory.keys.toList().indexOf(category) % colors.length],
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: quotes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                            child: Text(
                              quotes[index],
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          tileColor: index % 2 == 0 ? Colors.grey[200] : Colors.white, // Alternate row colors
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
