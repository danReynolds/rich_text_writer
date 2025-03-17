// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:rich_text_writer/rich_text_writer.dart';

class DemoWidget extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  final Widget? code;

  const DemoWidget({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.code,
  });

  @override
  build(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, color: Colors.black)),
        const Padding(padding: EdgeInsets.only(bottom: 4)),
        Text(description,
            style: const TextStyle(fontSize: 12, color: Colors.black)),
        const Padding(padding: EdgeInsets.only(bottom: 14)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: child,
            ),
            const Padding(padding: EdgeInsets.only(left: 20)),
            if (code != null) code!,
          ],
        )
      ],
    );
  }
}

final basicDemo = (BuildContext context) => DemoWidget(
      key: const Key('Basic demo'),
      title: 'Basic writer demo',
      description:
          'The text is printed using the specified delimiter and duration.',
      code: HighlightView(
        """RichTextWriter(
  '''
  Whether you're a brother or whether you're a mother
  You're stayin' alive, stayin' alive
  Feel the city breakin' and everybody shakin'
  And we're stayin' alive, stayin' alive
  Ah, ha, ha, ha, stayin' alive, stayin' alive
  Ah, ha, ha, ha, stayin' alive.
  '''.trim(),
  duration: const Duration(milliseconds: 25),
  delimiter: " ",
  onStart: () {
    print('Started');
  },
  onComplete: () {
    print('Complete');
  },
),""",
        language: 'dart',
        theme: githubTheme,
        padding: const EdgeInsets.all(12),
        textStyle: const TextStyle(
          fontFamily: 'My awesome monospace font',
          fontSize: 16,
        ),
      ),
      child: RichTextWriter(
        '''
Whether you're a brother or whether you're a mother
You're stayin' alive, stayin' alive
Feel the city breakin' and everybody shakin'
And we're stayin' alive, stayin' alive
Ah, ha, ha, ha, stayin' alive, stayin' alive
Ah, ha, ha, ha, stayin' alive
              '''
            .trim(),
        duration: const Duration(milliseconds: 100),
        delimiter: " ",
        textAlign: TextAlign.center,
      ),
    );

final basicRichDemo = (BuildContext context) => DemoWidget(
      key: const Key('Rich demo'),
      title: 'Rich demo',
      description: 'Write rich elements using normal TextSpans.',
      child: RichTextWriter.span(
        TextSpan(
          children: [
            const TextSpan(
              text: 'You can also compose the text with a ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const TextSpan(
              text: 'TextSpan',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text:
                  "\nwhich let's you do all the normal rich features including widgets:\n",
              style: TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
            WidgetSpan(
              child: Container(
                height: 40,
                width: 40,
                color: Colors.green,
              ),
            ),
            const TextSpan(text: " "),
            TextSpan(
                text: "and tappable text.",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('AlertDialog Title'),
                        content: const Text('AlertDialog description'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }),
          ],
        ),
        duration: const Duration(milliseconds: 25),
        delimiter: " ",
      ),
    );

final extendedDemo = (BuildContext context) => DemoWidget(
      key: const Key('Extended demo'),
      title: 'Extended demo',
      description: 'ExtendedTextSpan and ExtendedWidgetSpan',
      child: RichTextWriter.span(
        TextSpan(
          children: [
            const TextSpan(
              text: 'You can use an ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const TextSpan(
              text: 'ExtendedTextSpan',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: " In place of a TextSpan to add additional behavior, like ",
              style: TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
            ExtendedTextSpan(
              children: [
                ExtendedTextSpan(
                  text: 'Variable text duration',
                  duration: const Duration(milliseconds: 300),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const TextSpan(text: ' and an '),
                ExtendedTextSpan(
                  text: 'onComplete',
                  style: const TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                  duration: const Duration(milliseconds: 100),
                ),
                const TextSpan(
                  text:
                      ' handler that should be making a dialog show up right about...',
                ),
                ExtendedTextSpan(
                  text: 'Now',
                  duration: const Duration(milliseconds: 200),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              onComplete: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('AlertDialog Title'),
                    content: const Text('AlertDialog description'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        duration: const Duration(milliseconds: 25),
        delimiter: " ",
      ),
    );

final demos = [
  basicDemo,
  basicRichDemo,
  extendedDemo,
];
