part of 'rich_text_writer.dart';

extension ObjectExtensions<T extends Object> on T {
  S tryCatch<S>(S Function(T obj) predicate, S fallback) {
    try {
      return predicate(this);
    } catch (e) {
      return fallback;
    }
  }

  S? tryCast<S>() {
    if (this is S) {
      return this as S;
    }
    return null;
  }
}
