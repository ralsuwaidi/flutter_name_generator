import 'package:flutter/material.dart';
import 'reddit.dart';
import 'package:flutter/rendering.dart'; // Add this line.
import 'package:flutter_markdown/flutter_markdown.dart';

class Story extends StatelessWidget {
  final String story;
  final RedditPost post;
  final Function(String url) onPress;
  final bool saved;

  const Story({Key key, this.story, this.post, this.onPress, this.saved})
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
              padding: EdgeInsets.fromLTRB(15, 10, 0, 20),
              color: Colors.grey[800],
              child: Row(
                children: <Widget>[
                  InkWell(
                    child: saved? Icon(Icons.favorite):Icon(Icons.favorite_border) ,
                    onTap: () => onPress(post.url),
                  )
                ],
              ),
            )
          ]));
  }

  
}
