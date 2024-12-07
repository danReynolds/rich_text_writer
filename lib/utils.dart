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
  Duration baseDuration,
) {
  // Initialize with base duration adjusted by word length
  double resolvedDuration =
      baseDuration.inMilliseconds + max(0, (word.length - 3) * 10);

  // Additional timing for readability and natural flow
  if (word.endsWith('.') || word.endsWith('!') || word.endsWith('?')) {
    // Longer pause for sentence-ending punctuation
    resolvedDuration += 250;
  } else if (word.endsWith(',')) {
    // Shorter pause for commas
    resolvedDuration += 100;
  } else if (word.endsWith(';') || word.endsWith(':')) {
    // Medium pause for semi-colons and colons
    resolvedDuration += 150;
  }

  // Reduce the effect of the word length adjustment for very short words
  if (word.length <= 3) {
    resolvedDuration -= 5;
  }

  // Dynamic adjustment based on sentence position
  double positionFactor = index / totalWords;
  if (positionFactor < 0.1) {
    // Beginning of the sentence: slightly faster
    resolvedDuration *= 0.9;
  } else if (positionFactor > 0.9) {
    // End of the sentence: slow down a bit
    resolvedDuration *= 1.1;
  }

  // Random variability to mimic human inconsistency
  var rnd = Random();
  resolvedDuration +=
      rnd.nextInt(20) - 10; // Random value between -10ms to +10ms

  return Duration(milliseconds: resolvedDuration.toInt());
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
