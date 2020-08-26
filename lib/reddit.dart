import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

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
    final http.Response responseresult = await http.get(url+'.json');
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

Future<List<RedditPost>> postListFromUrl() async{
  List<String> savedUrlList = await _loadCounter();
  List<RedditPost> redditPost= new List<RedditPost>();
  log(savedUrlList.length.toString());
  for (var i = 0; i < savedUrlList.length; i++) {
    var test = await postFromUrl(savedUrlList[i]);
    redditPost.add(test );
    
  }

  return redditPost;

}
  //Loading counter value on start
  Future<List<String>>_loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
      return (prefs.getStringList('favourite') ?? <String>[]);
    
  }
Future<List<RedditPost>> updateRedditList(String period) async {
    Future<http.Response> _response(String period) {
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
  
    final responseresult = await _response(period);
    final List posts = jsonDecode(responseresult.body)['data']['children'];
    final titleList = posts.map((e) => e['data']['title']).toList();
    final urlList = posts.map((e) => e['data']['url']).toList();
    final dateList = posts.map((e) => e['data']['created']).toList();
    final scoreList = posts.map((e) => e['data']['ups']).toList();
    final awaredList =
        posts.map((e) => e['data']['total_awards_received']).toList();

    // make new list of RedditPost with url and title
    var redditList = new List<RedditPost>();
    for (var i = 0; i < titleList.length; i++) {
      var newPost = RedditPost(
          title: titleList[i],
          url: urlList[i],
          awards: awaredList[i],
          score: scoreList[i],
          date: dateList[i]);
      redditList.add(newPost);
    }
    return redditList;
  }
  
}
