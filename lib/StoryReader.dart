import 'package:flutter/material.dart';
import './Story.dart';
import './StoryManager.dart';
import 'package:flutter/gestures.dart';
import './TappableText.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import './ContextTracker.dart';

class StoryReader extends StatefulWidget {
  StoryReader({Key key}) : super(key: key);

  @override
  _StoryReaderState createState() => new _StoryReaderState();
}

class _StoryReaderState extends State<StoryReader> {
  ContextTracker<TappableText> mainTextView;
  ContextTracker<TappableText> previousTextView;
  Story story;
  ScrollController listViewController;
  ContextTracker listViewTracker;

  _StoryReaderState() {
    listViewController = new ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: StoryManager.getStory(),
        builder: (_, AsyncSnapshot<Story> snapshot) {
          if (snapshot.hasData) {
            story = snapshot.data;
            WidgetsBinding.instance
                .addPostFrameCallback((_) => afterFirstLayout(context));
            return buildWithStory(context);
          } else {
            return buildWithoutStory();
          }
        });
  }

  void afterFirstLayout(BuildContext context) {
    Rect listViewRect = listViewTracker.getRect();
    print(mainTextView.getRect());

    listViewController.animateTo(mainTextView.getRect().top - listViewRect.top, duration: Duration(milliseconds: 100), curve: Curves.linear);
  }

  Widget buildWithoutStory() {
    return Scaffold(
        appBar: new AppBar(
          title: new Text("Loading Story"),
        ),
        body: CircularProgressIndicator());
  }

  Widget buildWithStory(BuildContext context) {
    print("offset: " + story.offset.toString());
    Widget previousText = TappableText(
        text: story.body.substring(0, story.offset),
        style: TextStyle(fontSize: 32.0),
        didTapWord: (word) {
          launchWebView(context, word,
              "https://translate.google.co.uk/m/translate#de/en/" + word);
        });

    Widget currentText = mainTextView = ContextTracker(
        widgetBuilder: (key) => TappableText(
            key: key,
            text: story.body.substring(story.offset),
            style: TextStyle(fontSize: 32.0),
            didTapWord: (word) {
              launchWebView(context, word,
                  "https://translate.google.co.uk/m/translate#de/en/" + word);
            }));

    return Scaffold(
        appBar: new AppBar(
          title: new Text(story.title),
        ),
        body: NotificationListener<ScrollEndNotification>(
            child: listViewTracker = ContextTracker(widgetBuilder: (key) => ListView(
              cacheExtent: 10000000.0,
              key: key,
              controller: listViewController,
              scrollDirection: Axis.vertical,
              children: <Widget>[
                previousText,
                Divider(height: 10.0,color: Colors.grey),
                currentText
              ],
            )),
            onNotification: onScrollEndNotification));
  }

  bool onScrollEndNotification(ScrollEndNotification notification) {

    Rect listViewRect = listViewTracker.getRect();
    Offset offset = listViewRect.topLeft;
    offset = offset.translate(0.0, 16.0);

    String s = mainTextView.child.getWordUnderOffset(mainTextView.getBuildContext(), offset);
    print("word: " + s);

    TextPosition position = mainTextView.child
        .getTextPositionForOffset(mainTextView.getBuildContext(), listViewRect.topLeft);

    if(position.offset == 0) {
      return false;
    }

    //the position so far is relative to the second portion of the story
    //we add on the original offset to make it absolute
    position = TextPosition(offset: position.offset + story.offset);

    StoryManager.saveStoryPosition(story, position);
    return false;
  }

  void launchWebView(BuildContext context, String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return new WebviewScaffold(
            url: url,
            appBar: new AppBar(
              title: new Text(title),
            ),
          );
        },
      ),
    );
  }
}
