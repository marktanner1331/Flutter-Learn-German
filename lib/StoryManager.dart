import './Story.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryManager {
  static Future<Story> getStory() async {
    String storyJSON =
        await rootBundle.loadString('assets/stories/TestStory.json');

    Map<String, dynamic> jsonMap = json.decode(storyJSON);

    Story story = Story(title: jsonMap["title"], body: jsonMap["body"]);

    final prefs = await SharedPreferences.getInstance();

    story.offset = prefs.getInt(story.title + "counter") ?? 0;
    print("laoding at offset: " + story.offset.toString());
    return story;
  }

  static void saveStoryPosition(Story story, TextPosition position) async {
    final prefs = await SharedPreferences.getInstance();
    print("saving at offset: " + position.offset.toString());
    story.offset = position.offset;
    prefs.setInt(story.title + "counter", position.offset);
  }
}
