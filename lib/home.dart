import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites_page.dart';

class QuoteHomePage extends StatefulWidget {
  @override
  _QuoteHomePageState createState() => _QuoteHomePageState();
}

class _QuoteHomePageState extends State<QuoteHomePage> {
  final Map<String, List<String>> quotesByCategory = {
    "Inspirational": [
      "The only way to do great work is to love what you do. - Steve Jobs",
      "The best way to predict the future is to invent it. - Alan Kay",
      "You miss 100% of the shots you don’t take. - Wayne Gretzky",
    ],
    "Life": [
      "In three words I can sum up everything I've learned about life: it goes on. - Robert Frost",
      "Life is what happens when you're busy making other plans. - John Lennon",
      "The purpose of life is not to be happy. It is to be useful, to be honorable, to be compassionate, to have it make some difference that you have lived and lived well. - Ralph Waldo Emerson",
    ],
    "Success": [
      "Success is not the key to happiness. Happiness is the key to success. If you love what you are doing, you will be successful. - Albert Schweitzer",
      "The road to success and the road to failure are almost exactly the same. - Colin R. Davis",
      "Success usually comes to those who are too busy to be looking for it. - Henry David Thoreau",
    ],
    "Love": [
      "To love and be loved is to feel the sun from both sides. -David Viscott",
      "Love all, trust a few, do wrong to none. - William Shakespeare",
      "Love is composed of a single soul inhabiting two bodies. - Aristotle"
    ],
    "Friendship": [
      "A friend is someone who knows all about you and still loves you.- Elbert Hubbard",
      "Friendship is born at that moment when one person says to another, ‘What! You too? I thought I was the only one.- C.S. Lewis",
      "A real friend is one who walks in when the rest of the world walks out.- Walter Winchell"
    ],
    "Humor": [
      "I am so clever that sometimes I don't understand a single word of what I am saying.- Oscar Wilde",
      "People say nothing is impossible, but I do nothing every day.- A.A. Milne",
      "I find television very educating. Every time somebody turns on the set, I go into the other room and read a book.- Groucho Marx"
    ]
  };

  final CardSwiperController swiperController = CardSwiperController();
  Map<String, List<String>> favoriteQuotesByCategory = {};
  String currentQuote = "";
  String currentCategory = "";

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _updateCurrentQuote(); // Update the quote on app launch
  }

  void _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteQuotesByCategory = (prefs.getStringList('favorites') ?? [])
          .fold<Map<String, List<String>>>(
          {},
              (Map<String, List<String>> acc, String quote) {
            final parts = quote.split('||');
            final category = parts[0];
            final text = parts[1];
            if (!acc.containsKey(category)) {
              acc[category] = [];
            }
            acc[category]?.add(text);
            return acc;
          });
    });
  }

  void _updateCurrentQuote() {
    final allQuotes = quotesByCategory.entries.expand((entry) {
      final category = entry.key;
      return entry.value.map((quote) => {'quote': quote, 'category': category});
    }).toList();

    if (allQuotes.isNotEmpty) {
      final random = Random();
      final randomQuoteData = allQuotes[random.nextInt(allQuotes.length)];
      setState(() {
        currentQuote = randomQuoteData['quote']!;
        currentCategory = randomQuoteData['category']!;
      });
      _saveCurrentQuote();
    }
  }

  void _saveCurrentQuote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currentQuote', currentQuote);
    prefs.setString('currentCategory', currentCategory);
  }

  Future<void> _refreshQuote() async {
    _updateCurrentQuote();
  }

  void _saveFavorite(String quote) {
    if (!favoriteQuotesByCategory.containsKey(currentCategory)) {
      favoriteQuotesByCategory[currentCategory] = [];
    }
    if (!favoriteQuotesByCategory[currentCategory]!.contains(quote)) {
      setState(() {
        favoriteQuotesByCategory[currentCategory]!.add(quote);
      });
      SharedPreferences.getInstance().then((prefs) {
        final List<String> flatFavorites = favoriteQuotesByCategory.entries
            .expand((entry) =>
            entry.value.map((quote) => '${entry.key}||$quote'))
            .toList();
        prefs.setStringList('favorites', flatFavorites);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote of the Day'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FavoritesPage(favoriteQuotesByCategory)),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshQuote, // Call _refreshQuote on pull-to-refresh
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(

                children: [

                  Container(
                    height: 390,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(243, 7, 149, 1),
                          Color.fromRGBO(164, 5, 194, 1),
                          Color.fromRGBO(173, 3, 190, 1),
                          Color.fromRGBO(101, 2, 232, 1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentCategory,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentQuote,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),


                      ],

                    ),
                  ),
                const SizedBox(height: 30,),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        InkWell(child: const Icon(Icons.share,size: 40,),onTap: ()=>{},),
                        SizedBox(width: 200,),
                        InkWell(child: const Icon(Icons.save,size: 40,),onTap: ()=>_saveFavorite(currentQuote),),
                      ],
                    ),
                  )
                ],

              ),

            ),
          ],
        ),
      ),
    );
  }
}
