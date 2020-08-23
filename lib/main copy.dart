import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart'; // Add this line.
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(primaryColor: Colors.white),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = TextStyle(fontSize: 18.0);
  var _savedList = List<String>();
  List<String> myadjectives = adjectives.toList()..shuffle();
  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        // The itemBuilder callback is called once per suggested
        // word pairing, and places each suggestion into a ListTile
        // row. For even rows, the function adds a ListTile row for
        // the word pairing. For odd rows, the function adds a
        // Divider widget to visually separate the entries. Note that
        // the divider may be difficult to see on smaller devices.
        itemBuilder: (BuildContext _context, int i) {
          // Add a one-pixel-high divider widget before each row
          // in the ListView.
          if (i.isOdd) {
            return Divider();
          }

          // The syntax "i ~/ 2" divides i by 2 and returns an
          // integer result.
          // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
          // This calculates the actual number of word pairings
          // in the ListView,minus the divider widgets.
          final int index = i ~/ 2;
          // If you've reached the end of the available word
          // pairings...
          if (index >= _suggestions.length) {
            // ...then generate 10 more and add them to the
            // suggestions list.
            _suggestions.addAll(generateWordPairs().take(10));
            //log(_suggestions.length.toString());
          }
          if (i % 4 == 0) {
            return _buildRow(_suggestions[index]);
          } else {
            return _buildRowAdjective(_suggestions[index], index);
          }
        });
  }

// widget with listtiles and tile list inside that
  Widget _buildRow(WordPair pair) {
    final alreadySaved = _savedList.contains(pair.asLowerCase);
    return ListTile(
      title: Text(
        pair.asLowerCase
            .replaceFirst(pair.asLowerCase[0], pair.asPascalCase[0]),
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _savedList.remove(pair.asLowerCase);
          } else {
            _savedList.add(pair.asLowerCase);
          }
        });
        _updateSaved();
      },
    );
  }

  // widget with listtiles and tile list inside that
  Widget _buildRowAdjective(WordPair pair, int i) {
    WordPair newpair = new WordPair(myadjectives[i], pair.second);
    final alreadySaved = _savedList.contains(newpair.asLowerCase);
    return ListTile(
      title: Text(
        newpair.asLowerCase
            .replaceFirst(newpair.first[0], newpair.first[0].toUpperCase()),
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _savedList.remove(newpair.asLowerCase);
          } else {
            _savedList.add(newpair.asLowerCase);
          }
        });
        _updateSaved();
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      // NEW lines from here...
      builder: (BuildContext context) {
        final tiles = _savedList.map(
          (String pair) {
            return ListTile(
              title: Text(
                pair.replaceFirst(pair[0], pair[0].toUpperCase()),
                style: _biggerFont,
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _savedList.remove(pair);
                    _updateSaved();
                    _testReddit();
                  });
                },
              ),
            );
          },
        );
        final divided = ListTile.divideTiles(
          context: context,
          tiles: tiles,
        ).toList();

        _loadSaved();
        return Scaffold(
          appBar: AppBar(
            title: Text('Saved Suggestions'),
          ),
          body: ListView(children: divided),
        );
      }, // ...to here.
    ));
  }

  _updateSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('saved', _savedList);
    });
  }

  //Loading counter value on start
  _loadSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedList = (prefs.getStringList('saved') ?? []);
    });
  }

  _testReddit() async {
    final response =
        await http.get('https://www.reddit.com/r/WritingPrompts.json');

    log(jsonDecode(response.body)['data']['children'][0]['data']['title']
        .toString());
  }
}
