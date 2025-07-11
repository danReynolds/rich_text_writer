library rich_text_writer;

import 'dart:async';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

part 'extensions.dart';
part 'utils.dart';
part 'spans.dart';

class RichTextWriter extends StatefulWidget {
  final ExtendedTextSpan span;
  final RhythmBuilder? rhythmBuilder;
  final TextAlign textAlign;
  final bool enabled;

  const RichTextWriter._(
    this.span, {
    super.key,
    this.rhythmBuilder,
    this.textAlign = TextAlign.start,
    this.enabled = true,
  });

  factory RichTextWriter.span(
    TextSpan span, {
    Key? key,
    Duration? duration,
    String? delimiter,
    TextAlign textAlign = TextAlign.start,
    void Function()? onStart,
    void Function()? onComplete,
    RhythmBuilder? rhythmBuilder,
    bool enabled = true,
  }) {
    return RichTextWriter._(
      ExtendedTextSpan.clone(
        span,
        duration: duration,
        delimiter: delimiter,
        onStart: onStart,
        onComplete: onComplete,
      ),
      key: key,
      textAlign: textAlign,
      rhythmBuilder: rhythmBuilder,
      enabled: enabled,
    );
  }

  factory RichTextWriter(
    String text, {
    Key? key,
    Duration? duration,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    String? delimiter,
    GestureRecognizer? recognizer,
    void Function()? onStart,
    void Function()? onComplete,
    RhythmBuilder? rhythmBuilder,
    bool enabled = true,
  }) {
    return RichTextWriter._(
      ExtendedTextSpan(
        text: text,
        style: style,
        recognizer: recognizer,
        delimiter: delimiter,
        duration: duration,
        onStart: onStart,
        onComplete: onComplete,
      ),
      rhythmBuilder: rhythmBuilder,
      textAlign: textAlign,
      key: key,
      enabled: enabled,
    );
  }

  @override
  RichTextWriterState createState() => RichTextWriterState();
}

class RichTextWriterState extends State<RichTextWriter> {
  Timer? _timer;

  List<InlineSpan> _writtenSpans = [];
  late List<HiddenSpan> _hiddenSpans;

  @override
  void initState() {
    super.initState();

    if (widget.enabled) {
      _hiddenSpans = _traverseSpan(widget.span);
      _writeNextSpan();
    } else {
      _hiddenSpans = [];
    }
  }

  Duration _getDuration(InlineSpan span) {
    switch (span) {
      case TextSpan resolvedSpan:
        final duration =
            (resolvedSpan is ExtendedTextSpan ? resolvedSpan.duration : null) ??
                _defaultTokenDuration;

        final text = resolvedSpan.text!;
        final writtenSpanCount = _writtenSpans.length;
        final totalSpanCount = writtenSpanCount + _hiddenSpans.length;

        return widget.rhythmBuilder?.call(
              text,
              writtenSpanCount,
              totalSpanCount,
              duration,
            ) ??
            defaultRhythmBuilder(
              resolvedSpan.text!,
              _writtenSpans.length,
              _hiddenSpans.length + _writtenSpans.length,
              duration,
            );
      case WidgetSpan resolvedSpan:
        return resolvedSpan is ExtendedWidgetSpan
            ? resolvedSpan.duration
            : _defaultWidgetDuration;
      default:
        throw 'Unsupported span';
    }
  }

  HiddenSpan _hideSpan<T extends InlineSpan>(T span) {
    return switch (span) {
      TextSpan resolvedSpan => HiddenTextSpan(
          resolvedSpan,
          resolvedSpan.children?.map(_hideSpan).toList(),
        ),
      WidgetSpan resolvedSpan => HiddenWidgetSpan(resolvedSpan),
      _ => throw 'Unsupported span',
    };
  }

  /// Traverses the root span, generating a list of all of the InlineSpan elements
  /// to display, flattening children and deliminating any TextSpan with a delimiter.
  List<HiddenSpan> _traverseSpan(ExtendedSpan span) {
    switch (span) {
      case WidgetSpan resolvedSpan:
        return [_hideSpan(resolvedSpan)];
      case ExtendedTextSpan resolvedSpan:
        if (!resolvedSpan.traverse) {
          return [_hideSpan(resolvedSpan)];
        }

        final text = resolvedSpan.text;
        final children = resolvedSpan.children;

        // If a TextSpan has children, then traverse them depth-first.
        if (children != null) {
          if (children.isEmpty) {
            return [];
          }

          List<HiddenSpan> spans = [];
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
                      duration: resolvedSpan.duration,
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
              duration: resolvedSpan.duration,
              onStart: resolvedSpan.onStart,
              onComplete: resolvedSpan.onComplete,
            ),
          );
        }

        return [_hideSpan(resolvedSpan)];
      default:
        throw 'Unsupported span';
    }
  }

  void _writeNextSpan() {
    if (_hiddenSpans.isEmpty) {
      return;
    }

    final span = _hiddenSpans.removeAt(0).span;
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
    return RichText(
      text: _hiddenSpans.isEmpty
          ? widget.span
          : TextSpan(children: [..._writtenSpans, ..._hiddenSpans]),
      textAlign: widget.textAlign,
    );
  }
}
