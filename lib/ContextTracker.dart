import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
typedef Widget WidgetBuilder(Key key);

class ContextTracker<T extends Widget> extends StatefulWidget {
  final GlobalKey<_ContextTrackerState> key;
  final T child;

  ContextTracker({Key key, @required WidgetBuilder widgetBuilder})
      : this.key = key ?? new GlobalKey<_ContextTrackerState>(),
        child = widgetBuilder(key),
        super();

  BuildContext getBuildContext() {
    return key?.currentContext;
  }

  Rect getRect() {
    var object = key?.currentContext?.findRenderObject();
    var translation = object?.getTransformTo(null)?.getTranslation();
    var size = object?.semanticBounds?.size;

    if (translation != null && size != null) {
      return new Rect.fromLTWH(
          translation.x, translation.y, size.width, size.height);
    } else {
      return null;
    }
  }

  @override
  _ContextTrackerState createState() => new _ContextTrackerState();
}

class _ContextTrackerState extends State<ContextTracker> {
  @override
  Widget build(BuildContext context) => widget.child;
}
