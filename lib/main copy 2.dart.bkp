import 'dart:convert';

import 'package:http/http.dart' as http;
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
  final _biggerFont = TextStyle(fontSize: 18.0);
  var _savedList = List<String>();
  List<String> myadjectives = adjectives.toList()..shuffle();
  var _redditList = List<String>();
  final response =
      http.get('https://www.reddit.com/r/WritingPrompts/top/.json?t=week');
  final RedditPost testReddit = new RedditPost();
  final redditList = List<RedditPost>();
  String story;
  @override
  void initState() {
    super.initState();
    _loadSaved();
    _testReddit();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Name Generator'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              _pushSaved(3);
            },
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return FutureBuilder(
      future: response,
      builder: (_context, index) {
        return ListView.builder(
            padding: const EdgeInsets.all(16),
            // The itemBuilder callback is called once per suggested
            // word pairing, and places each suggestion into a ListTile
            // row. For even rows, the function adds a ListTile row for
            // the word pairing. For odd rows, the function adds a
            // Divider widget to visually separate the entries. Note that
            // the divider may be difficult to see on smaller devices.
            itemCount: _redditList.length * 2,
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

                return _buildRow(_redditList[index], index);
              
            });
      },
    );
  }

  Widget _buildStory(String url){
    final theStory = new RedditPost()._getStory(url);
    String story;
    theStory.then((value) => story=value);
    return FutureBuilder(
      future: theStory,
      builder: (_context, index) {
        return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 1,
            itemBuilder: (BuildContext _context, int i) {

              final int index = i ~/ 2;

              
                return _buildRow(story, index);
              
            });
      },
    );
  }

// widget with listtiles and tile list inside that
  Widget _buildRow(String pair, index) {
    return ListTile(
      title: Text(
        pair,
      ),
      onTap: () {_pushSaved(index);
      },
    );
  }

  void _pushSaved(index) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      // NEW lines from here...
      builder: (BuildContext context) {
        final tiles = _redditList.map(
          (String pair) {
            return ListTile(
              title: Text(
                'story',
                style: _biggerFont,
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _savedList.remove(pair);
                    _updateSaved();
                  });
                },
              ),
            );
          },
        );
      
        _loadSaved();
        return Scaffold(
          appBar: AppBar(
            title: Text(index.toString()),
          ),
          body: _buildStory(redditList[index].url),
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
    final responseresult = await response;
    final List posts = jsonDecode(responseresult.body)['data']['children'];
    final postList = posts.map((e) => e['data']['title']).toList();
    final urlList = posts.map((e) => e['data']['url']).toList();
    var ints = new List<String>.from(postList);

    for (var i = 0; i < postList.length; i++) {
      var newPost = RedditPost();
      newPost.title = postList[i];
      newPost.url = urlList[i];
      redditList.add(newPost);
    }

    testReddit.url = new List<String>.from(urlList)[0];
    testReddit
        ._getStory(testReddit.url)
        .then((value) => testReddit.title = value);

    _redditList = ints;
  }
}

class RedditPost {
  String _title;
  String _url;

  String get title {
    return _title;
  }

  set title(String _title) {
    this._title = _title;
  }

  String get url {
    return _url;
  }

  set url(String _url) {
    this._url = _url;
  }

  Future<String> _getStory(String url) async {
    final _response = await http.get(url + '.json');
    final String comment = jsonDecode(_response.body)[1]['data']['children'][1]
            ['data']['body']
        .toString();
    return comment;
  }

}


