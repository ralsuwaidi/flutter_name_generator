import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';

// json serialisation (to save to shared pref)
// https://flutter.dev/docs/development/data-and-backend/json
class RedditPost {
  const RedditPost(
      {this.title, this.url, this.awards, this.date, this.score, this.story});

  final String title;
  final String url;
  final int awards;
  final int score;
  final double date;
  final String story;

  

  Future<String> getStory(String url) async {
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
        date = json['date'],
        story = json['story'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'awards': awards,
        'score': score,
        'date': date,
        'story': story,
      };

  Future<RedditPost> postFromUrl(String url) async {
    final http.Response responseresult = await http.get(url);
    final List data = jsonDecode(responseresult.body);
    final post = data[0]['data']['children'][0]['data'];
    final String title = post['title'].toString();
    final int awards = post['total_awards_received'].toInt();
    final int score = post['ups'].toInt();
    final double date = post['created'].toDouble();
    final String story =
        data[1]['data']['children'][1]['data']['body'].toString();

    // log(story);
    return RedditPost(
        awards: awards, title: title, score: score, date: date, story: story);
  }
}
