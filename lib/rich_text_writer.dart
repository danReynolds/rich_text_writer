library rich_text_writer;

import 'dart:async';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

part 'extensions.dart';
part 'utils.dart';
part 'spans.dart';

class RichTextWriter extends StatefulWidget {
  final InlineSpan span;
  final RhythmBuilder? rhythmBuilder;

  const RichTextWriter._(
    this.span, {
    super.key,
    this.rhythmBuilder,
  });

  factory RichTextWriter.span(
    TextSpan span, {
    Key? key,
    double? delay,
    String? delimiter,
    void Function()? onStart,
    void Function()? onComplete,
    RhythmBuilder? rhythmBuilder,
  }) {
    return RichTextWriter._(
      ExtendedTextSpan.clone(
        span,
        delay: delay,
        delimiter: delimiter,
        onStart: onStart,
        onComplete: onComplete,
      ),
      key: key,
      rhythmBuilder: rhythmBuilder,
    );
  }

  factory RichTextWriter(
    String text, {
    Key? key,
    double? delay,
    TextStyle? style,
    String? delimiter,
    GestureRecognizer? recognizer,
    void Function()? onStart,
    void Function()? onComplete,
    RhythmBuilder? rhythmBuilder,
  }) {
    return RichTextWriter._(
      ExtendedTextSpan(
        text: text,
        style: style,
        recognizer: recognizer,
        delimiter: delimiter,
        delay: delay,
        onStart: onStart,
        onComplete: onComplete,
      ),
      rhythmBuilder: rhythmBuilder,
      key: key,
    );
  }

  @override
  RichTextWriterState createState() => RichTextWriterState();
}

class RichTextWriterState extends State<RichTextWriter> {
  Timer? _timer;

  List<InlineSpan> _writtenSpans = [];
  late List<InlineSpan> _remainingSpans;
  late InlineSpan _shadowSpan;

  @override
  void initState() {
    super.initState();

    _remainingSpans = _traverseSpan(widget.span);
    _shadowSpan = TextSpan(children: [..._remainingSpans]);

    _writeNextSpan();
  }

  Duration _getDuration(InlineSpan span) {
    switch (span) {
      case TextSpan resolvedSpan:
        final delay =
            (resolvedSpan is ExtendedTextSpan ? resolvedSpan.delay : null) ??
                _defaultTextDelay;

        final text = resolvedSpan.text!;
        final writtenSpanCount = _writtenSpans.length;
        final totalSpanCount = writtenSpanCount + _remainingSpans.length;

        return widget.rhythmBuilder?.call(
              text,
              writtenSpanCount,
              totalSpanCount,
              delay,
            ) ??
            _defaultRhythmBuilder(
              resolvedSpan.text!,
              _writtenSpans.length,
              _remainingSpans.length + _writtenSpans.length,
              delay,
            );
      case WidgetSpan resolvedSpan:
        return resolvedSpan is ExtendedWidgetSpan
            ? resolvedSpan.duration
            : _defaultWidgetDuration;
      default:
        throw 'Unsupported span';
    }
  }

  /// Traverses the root span, generating a list of all of the InlineSpan elements
  /// to display, flattening children and deliminating any TextSpan with a delimiter.
  List<InlineSpan> _traverseSpan(InlineSpan span) {
    switch (span) {
      case WidgetSpan resolvedSpan:
        return [resolvedSpan];
      case ExtendedTextSpan resolvedSpan:
        final text = resolvedSpan.text;
        final children = resolvedSpan.children;

        // If a TextSpan has children, then traverse them depth-first.
        if (children != null) {
          if (children.isEmpty) {
            return [];
          }

          List<InlineSpan> spans = [];
          for (int i = 0; i < children.length; i++) {
            final child = children[i];
            final isLast = i == children.length - 1;
            final onStart = i == 0 ? resolvedSpan.onStart : null;
            final onComplete = isLast ? resolvedSpan.onComplete : null;

            switch (child) {
              case TextSpan resolvedChild:
                spans.addAll(
                  _traverseSpan(
                    ExtendedTextSpan.clone(
                      resolvedChild,
                      delay: resolvedSpan.delay,
                      delimiter: resolvedSpan.delimiter,
                      recognizer: resolvedSpan.recognizer,
                      style: resolvedSpan.style,
                      onStart: onStart,
                      onComplete: onComplete,
                    ),
                  ),
                );
                break;
              case WidgetSpan resolvedChild:
                spans.addAll(
                  _traverseSpan(
                    ExtendedWidgetSpan.clone(
                      resolvedChild,
                      onStart: onStart,
                      onComplete: onComplete,
                    ),
                  ),
                );
                break;
            }
          }

          return spans;
        }

        // Alternatively, the ExtendedTextSpan must have a single span then.
        // If it does not, it is an error.
        if (text == null) {
          throw 'Invalid ExtendedTextSpan. Either children or span must be specified';
        }

        // If the span has a delimiter, then deliminate the text and process the
        // resolved children.
        if (resolvedSpan.delimiter != null) {
          final delimiter = resolvedSpan.delimiter!;

          final List<TextSpan> children = [];
          final subtexts = text.split(delimiter);

          for (int i = 0; i < subtexts.length; i++) {
            final subtext = subtexts[i];
            final isLast = i == subtexts.length - 1;

            children.add(
              TextSpan(text: "$subtext${isLast ? '' : delimiter}"),
            );
          }

          return _traverseSpan(
            ExtendedTextSpan(
              children: children,
              style: resolvedSpan.style,
              recognizer: resolvedSpan.recognizer,
              delay: resolvedSpan.delay,
              onStart: resolvedSpan.onStart,
              onComplete: resolvedSpan.onComplete,
            ),
          );
        }

        return [resolvedSpan];
      default:
        throw 'Unsupported span';
    }
  }

  void _writeNextSpan() {
    if (_remainingSpans.isEmpty) {
      return;
    }

    final span = _remainingSpans.removeAt(0);
    final duration = _getDuration(span);

    setState(() {
      _writtenSpans = [
        ..._writtenSpans,
        span,
      ];
    });
    span.tryCast<ExtendedSpan>()?.onStart?.call();

    _timer = Timer(duration, () {
      span.tryCast<ExtendedSpan>()?.onComplete?.call();
      _writeNextSpan();
    });
  }

  @override
  dispose() {
    super.dispose();

    if (_timer != null) {
      _timer!.cancel();
    }
  }

  @override
  build(context) {
    return Stack(
      children: [
        Visibility(
          visible: _remainingSpans.isEmpty,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,

          /// The shadow [RichText] is a replicate of the visible [RichText] that is stacked beneath
          /// the visible one as it is written. This is necessary so that the full space for displaying
          /// the completed RichText is allocated up front and the surrounding layout just does get moved around as
          /// it is written out.
          child: RichText(text: _shadowSpan),
        ),
        if (_remainingSpans.isNotEmpty)
          RichText(text: TextSpan(children: _writtenSpans)),
      ],
    );
  }
}
