part of 'rich_text_writer.dart';

extension ObjectExtensions<T extends Object> on T {
  S? tryCast<S>() {
    if (this is S) {
      return this as S;
    }
    return null;
  }
}
