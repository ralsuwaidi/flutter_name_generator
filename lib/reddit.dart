import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

/// class to deal with reddit writing prompts
class RedditPost {
  const RedditPost(
      {this.title, this.url, this.awards, this.date, this.score, this.story});

  final String title;
  final String url;
  final int awards;
  final int score;
  final double date;
  final String story;

  /// return story when given a reddit url as string
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

  /// return list of RedditPost from sharedPref
  Future<List<RedditPost>> getSavedPostList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedJsonList =
        (prefs.getStringList('savedjson') ?? <String>[]);
    var postMap = savedJsonList.map((e) => jsonDecode(e));
    var postList = postMap.map((e) => RedditPost.fromJson(e)).toList();

    return postList;
  }

  /// return bool if post is available in List of RedditPost
  bool isSaved(List<RedditPost> postList, RedditPost post) {
    bool alreadySaved = false;
    for (var i = 0; i < postList.length; i++) {
      if (postList[i].title == post.title) {
        alreadySaved = true;
      } else {
        alreadySaved = false;
      }
    }

    return alreadySaved;
  }

  /// return Future List of reddit post depending on the period selected
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
