part of 'rich_text_writer.dart';

mixin ExtendedSpan {
  late final void Function()? onStart;
  late final void Function()? onComplete;

  void init({
    required final void Function()? onStart,
    required final void Function()? onComplete,
  }) {
    this.onStart = onStart;
    this.onComplete = onComplete;
  }
}

class ExtendedTextSpan extends TextSpan with ExtendedSpan {
  final Duration? duration;
  final String? delimiter;
  final bool traverse;

  ExtendedTextSpan({
    super.children,
    super.text,
    super.style,
    super.recognizer,
    this.delimiter,
    this.duration,
    this.traverse = true,
    final void Function()? onStart,
    final void Function()? onComplete,
  }) {
    init(onStart: onStart, onComplete: onComplete);
  }

  factory ExtendedTextSpan.clone(
    TextSpan span, {
    Duration? duration,
    String? delimiter,
    void Function()? onStart,
    void Function()? onComplete,
    TextStyle? style,
    GestureRecognizer? recognizer,
  }) {
    if (span is ExtendedTextSpan) {
      return ExtendedTextSpan(
        text: span.text,
        children: span.children,
        style: span.style ?? style,
        recognizer: span.recognizer ?? recognizer,
        duration: span.duration ?? duration,
        delimiter: span.delimiter ?? delimiter,
        traverse: span.traverse,
        onStart: () {
          span.onStart?.call();
          onStart?.call();
        },
        onComplete: () {
          span.onComplete?.call();
          onComplete?.call();
        },
      );
    }

    return ExtendedTextSpan(
      text: span.text,
      children: span.children,
      style: span.style ?? style,
      recognizer: span.recognizer ?? recognizer,
      duration: duration,
      delimiter: delimiter,
      onStart: onStart,
      onComplete: onComplete,
    );
  }
}

class ExtendedWidgetSpan extends WidgetSpan with ExtendedSpan {
  final Duration duration;

  ExtendedWidgetSpan({
    required super.child,
    required this.duration,
    super.alignment,
    super.baseline,
    super.style,
    final void Function()? onStart,
    final void Function()? onComplete,
  }) {
    init(onStart: onStart, onComplete: onComplete);
  }

  factory ExtendedWidgetSpan.clone(
    WidgetSpan span, {
    final void Function()? onStart,
    final void Function()? onComplete,
  }) {
    if (span is ExtendedWidgetSpan) {
      return ExtendedWidgetSpan(
        child: span.child,
        alignment: span.alignment,
        baseline: span.baseline,
        style: span.style,
        duration: span.duration,
        onStart: () {
          span.onStart?.call();
          onStart?.call();
        },
        onComplete: () {
          span.onComplete?.call();
          onComplete?.call();
        },
      );
    }

    return ExtendedWidgetSpan(
      child: span.child,
      alignment: span.alignment,
      baseline: span.baseline,
      style: span.style,
      duration: _defaultWidgetDuration,
      onStart: onStart,
      onComplete: onComplete,
    );
  }
}
