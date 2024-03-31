part of 'rich_text_writer.dart';

typedef RhythmBuilder = Duration Function(
  String token,
  int index,
  int total,
  Duration duration,
);

const _defaultWidgetDuration = Duration(milliseconds: 100);
const _defaultTokenDuration = Duration(milliseconds: 80);

/// The word rhythm builder uses a natural typing duration for word output.
Duration wordRhythmBuilder(
  String word,
  int index,
  int totalWords,
  Duration duration,
) {
  // Base adjustments
  int resolvedDuration = duration.inMilliseconds + word.length * 10;

  // Random variability
  var rnd = Random();
  resolvedDuration +=
      rnd.nextInt(20) - 10; // Add a random value between -10ms to +10ms

  return Duration(milliseconds: resolvedDuration);
}

/// The default rhythm behavior is to just apply the delay to the given token, which may be a word
/// or alternatively deliminated text.
Duration defaultRhythmBuilder(
  String token,
  int spanIndex,
  int totalSpans,
  Duration duration,
) {
  return duration;
}
