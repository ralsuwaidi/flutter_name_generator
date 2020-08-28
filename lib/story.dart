import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'reddit.dart';
import 'package:flutter/rendering.dart'; // Add this line.
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Story extends StatelessWidget {
  final String story;
  final RedditPost post;
  final Function(RedditPost post) onPress;
  final List<String> favList;
  final List<RedditPost> favPostList;

  const Story(
      {Key key,
      this.story,
      this.post,
      this.onPress,
      this.favList,
      this.favPostList})
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
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FavoriteWidget(
                  favList: favList,
                  post: post,
                  favPostList: favPostList,
                )
              ],
            ),
          )
        ]));
  }
}

// widget with the hart at the end of the story
class FavoriteWidget extends StatefulWidget {
  final List<String> favList;
  final RedditPost post;
  final List<RedditPost> favPostList;

  const FavoriteWidget({Key key, this.favList, this.post, this.favPostList})
      : super(key: key);
  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: IconButton(
        icon: (RedditPost().isSaved(widget.favPostList, widget.post)
            ? Icon(Icons.favorite)
            : Icon(Icons.favorite_border)),
        onPressed: _toggleFavorite,
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      if (RedditPost().isSaved(widget.favPostList, widget.post)) {
        widget.favPostList.removeWhere((element) => element.title==widget.post.title);
        // log(RedditPost().isSaved(widget.favPostList, widget.post).toString());
        _saveJsonList(widget.favPostList);
      } else {
        widget.favPostList.add(widget.post);
        log(RedditPost().isSaved(widget.favPostList, widget.post).toString());
        _saveJsonList(widget.favPostList);
      }
    });
  }

  //Incrementing counter after click
  _saveJsonList(List<RedditPost> savedRedditPost) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedJsonList =
        savedRedditPost.map((e) => jsonEncode(e)).toList();
    setState(() {
      prefs.setStringList('savedjson', savedJsonList);
    });
    // Map postMap = jsonDecode(savedJsonList[0]);
    // var post = RedditPost.fromJson(postMap);
    // log(post.title);
  }
}
