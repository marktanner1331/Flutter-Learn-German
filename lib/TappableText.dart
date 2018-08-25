import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

typedef void DidTapWord(String word);

class TappableText extends StatelessWidget {
  final TextStyle style;
  final String text;
  final DidTapWord didTapWord;

  TappableText({Key key, this.style, this.text, this.didTapWord}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(text, style: style,),
      onTapUp: (TapUpDetails details) {
        RenderParagraph rp = findRenderParagraph(context);

        Offset localOffset = rp.globalToLocal(details.globalPosition);
        TextPosition tp = rp.getPositionForOffset(localOffset);
        TextRange range = rp.getWordBoundary(tp);

        didTapWord(range.textInside(text));
      },
    );
  }

  TextPosition getTextPositionForOffset(BuildContext context, Offset offset) {
    RenderParagraph rp = findRenderParagraph(context);

    Offset localOffset = rp.globalToLocal(offset);
    return rp.getPositionForOffset(localOffset);
  }

  String getWordUnderOffset(BuildContext context, Offset offset) {
    RenderParagraph rp = findRenderParagraph(context);

    Offset localOffset = rp.globalToLocal(offset);
    TextPosition tp = rp.getPositionForOffset(localOffset);

    return rp.getWordBoundary(tp).textInside(text);
  }

  RenderParagraph findRenderParagraph(BuildContext context) {
    RenderObject result;
    void visit(Element element) {
      assert(result == null); // this verifies that there's only one child
      if (element.renderObject is RenderParagraph)
        result = element.renderObject;
      else
        element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return result;
  }
}
