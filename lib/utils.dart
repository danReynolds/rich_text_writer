part of 'rich_text_writer.dart';

typedef RhythmBuilder = Duration Function(
  String token,
  int spanIndex,
  int totalSpans,
  int speed,
);

const _defaultWidgetDuration = Duration(milliseconds: 100);
const int _defaultTokenDelay = 80;

/// The word rhythm builder uses a natural typing duration for word output combined
/// with a randomness factor to add unpredictability and a curve to simulate typing rhythm.
Duration wordRhythmBuilder(
  String word,
  int spanIndex,
  int totalSpans,
  int delay,
) {
  // Get word length
  int wordLength = word.length;

  // Calculate the position of the word in the sine wave, ranging from 0 to 2π
  double positionInWave = 2 * pi * (spanIndex / totalSpans);

  // Use the sine function for general rhythm across the entire text
  double rhythmFactor = (sin(positionInWave) + 1) / 2;
  rhythmFactor = rhythmFactor.clamp(0.6, 1.0); // Flatten the sine wave

  // Adjust word length factor
  double lengthFactor = 1.0 - (wordLength / 20);
  lengthFactor = lengthFactor.clamp(0.7, 1.0);

  // Punctuation factor remains the same
  double punctuationFactor = word.contains(RegExp(r'[.,?!]')) ? 1.5 : 1.0;

  // Adjust random variability
  double randomFactor = 0.9 + Random().nextDouble() * 0.2;

  double totalFactor =
      rhythmFactor * lengthFactor * punctuationFactor * randomFactor;

  // Compute total duration for this word and ensure a minimum delay
  int rhythmicDelay = max(delay, (delay * wordLength * totalFactor)).toInt();
  return Duration(milliseconds: rhythmicDelay);
}

/// The default rhythm behavior is to just apply the delay to the given token, which may be a word
/// or alternatively deliminated text.
Duration defaultRhythmBuilder(
  String token,
  int spanIndex,
  int totalSpans,
  int delay,
) {
  return Duration(milliseconds: delay);
}
