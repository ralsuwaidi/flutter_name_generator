import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Add this line.
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData.dark(),
      home: RedditWritingPrompts(),
    );
  }
}

class RedditWritingPrompts extends StatefulWidget {
  @override
  _RedditWritingPromptsState createState() => _RedditWritingPromptsState();
}

class _RedditWritingPromptsState extends State<RedditWritingPrompts> {
  var _redditList = List<RedditPost>();
  String _period = 'week';
  @override
  void initState() {
    _populateWP(_period);
    super.initState();
  }

  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('  Writing Prompts: ' +
            _period.replaceFirst(_period[0], _period[0].toUpperCase())),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("Daily"),
              ),
              PopupMenuItem(
                value: 2,
                child: Text("Weekly"),
              ),
              PopupMenuItem(
                value: 3,
                child: Text("Monthly"),
              ),
            ],
            onSelected: (value) {
              if (value == 1) {
                _period = 'day';
              }
              if (value == 2) {
                _period = 'week';
              }
              if (value == 3) {
                _period = 'month';
              }
              _select(_period);
              Fluttertoast.showToast(
                  msg: 'Top of the ' + _period,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
          )
        ],
      ),
      body: _buildWPList(_period),
    );
  }

  // build list of stories
  Widget _buildWPList(String period) {
    return FutureBuilder(
      future: _response(period),
      builder: (_context, snapshot) {
        return Scrollbar(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _redditList.length * 2,
                itemBuilder: (BuildContext _context, int i) {
                  if (i.isOdd) {
                    return Divider();
                  }
                  final int index = i ~/ 2;

                  return _buildRow(_redditList[index], index);
                }));
      },
    );
  }

  // story after it is clicked
  Widget _buildStory(RedditPost post) {
    final theStory = new RedditPost()._getStory(post.url);
    return FutureBuilder(
      future: theStory,
      builder: (_context, snapshot) {
        if (snapshot.hasData) {
          return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return null;
              },
              child: Scrollbar(
                  child: Markdown(
                data: snapshot.data,
                styleSheet: MarkdownStyleSheet(p: TextStyle(fontSize: 16)),
              )));
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildRow(RedditPost post, int index) {
    return Container(
        child: ListTile(
      title: Text(
        post.title,
      ),
      subtitle: Column(
        children: <Widget>[
          if (post.awards != 0) _printAwards(post.awards, size: 12),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      onTap: () {
        _pushSaved(_redditList[index]);
      },
    ));
  }

  void _pushSaved(RedditPost post) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          // appBar: AppBar(
          //   title: Text("Story"),
          // ),
          // body: _buildStory(_redditList[index].url),
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.grey[850],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                        margin: const EdgeInsets.fromLTRB(15, 80, 15, 9),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              post.title,
                              style: TextStyle(fontSize: 14),
                            ),
                            if (post.awards != 0) _printAwards(post.awards, size: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                      text: 'Score: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: post.score.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal)),
                                      ]),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: 'Date: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: DateFormat('dd-MM-yyyy ')
                                                .format(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        post.date.toInt() *
                                                            1000))
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal)),
                                      ]),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                ),
              ];
            },
            body: Center(
              child: _buildStory(post),
            ),
          ),
        );
      },
    ));
  }

  Widget _printAwards(int awardNumber, {double size=15}) {
    if (awardNumber == 1) {
      return Row(children: <Widget>[
        Icon(Icons.stars, size: size, color: Colors.yellow)
      ]);
    } else {
      return Row(children: <Widget>[
        Icon(Icons.stars, size: size, color: Colors.yellow),
        Text(
          awardNumber.toString(),style: TextStyle(fontSize: size),
        )
      ]);
    }
  }

  void _select(String period) {
    setState(() {
      _populateWP(period);
    });
  }

  Future _response(String period) {
    if (period == 'week') {
      return http
          .get('https://www.reddit.com/r/WritingPrompts/top/.json?t=week');
    }
    if (period == 'day') {
      return http
          .get('https://www.reddit.com/r/WritingPrompts/top/.json?t=day');
    }
    return http
        .get('https://www.reddit.com/r/WritingPrompts/top/.json?t=month');
  }

  _populateWP(period) async {
    final responseresult = await _response(period);
    final List posts = jsonDecode(responseresult.body)['data']['children'];
    final titleList = posts.map((e) => e['data']['title']).toList();
    final urlList = posts.map((e) => e['data']['url']).toList();
    final dateList = posts.map((e) => e['data']['created']).toList();
    final scoreList = posts.map((e) => e['data']['ups']).toList();
    final awaredList =
        posts.map((e) => e['data']['total_awards_received']).toList();

    // make new list of RedditPost with url and title
    _redditList = new List<RedditPost>();
    for (var i = 0; i < titleList.length; i++) {
      var newPost = RedditPost(
          title: titleList[i],
          url: urlList[i],
          awards: awaredList[i],
          score: scoreList[i],
          date: dateList[i]);
      _redditList.add(newPost);
    }
  }
}

// json serialisation (to save to shared pref)
// https://flutter.dev/docs/development/data-and-backend/json
class RedditPost {
  const RedditPost({this.title, this.url, this.awards, this.date, this.score});

  final String title;
  final String url;
  final int awards;
  final int score;
  final double date;

  Future<String> _getStory(String url) async {
    final _response = await http.get(url + '.json');
    final String comment = jsonDecode(_response.body)[1]['data']['children'][1]
            ['data']['body']
        .toString();
    return comment;
  }

// to save to shared pref
  RedditPost.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        url = json['url'],
        score = json['score'],
        awards = json['awards'],
        date = json['date'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'awards': awards,
        'score': score,
        'date': date,
      };
}
