import 'package:flutter/material.dart';
import 'reddit.dart';
import 'package:flutter/rendering.dart'; // Add this line.
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Story extends StatelessWidget {
  final String story;
  final RedditPost post;
  final Function(String url) onPress;
  final List<String> favList;

  const Story({Key key, this.story, this.post, this.onPress, this.favList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
    child: Column(

          // padding: EdgeInsets.all(15),
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(15),
                child: MarkdownBody(
                  data: story,
                  styleSheet: MarkdownStyleSheet(p: TextStyle(fontSize: 16)),
                )),
            Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
              color: Colors.grey[800],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FavoriteWidget(favList: favList, post: post,)
                ],
              ),
            )
          ]));
  }

  
}

class FavoriteWidget extends StatefulWidget {
  final List<String> favList;
  final RedditPost post;

  const FavoriteWidget({Key key, this.favList, this.post}):super(key:key);
  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  
  
  @override
  Widget build(BuildContext context) {
    return Container(
          padding: EdgeInsets.all(0),
          child: IconButton(
            icon: (widget.favList.contains(widget.post.url) ? Icon(Icons.favorite) : Icon(Icons.favorite_border)),
            onPressed: _toggleFavorite,
          ),
        
    );
  }

  void _toggleFavorite() {
  setState(() {
    if (widget.favList.contains(widget.post.url)) {
      widget.favList.remove(widget.post.url);
      _incrementCounter(widget.favList);
    } else {
      widget.favList.add(widget.post.url);
      _incrementCounter(widget.favList);
    }
  });
}

  //Incrementing counter after click
  _incrementCounter(List<String> favList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('favourite', favList);
    });
  }
}


