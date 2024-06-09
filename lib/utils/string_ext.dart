extension StringExt on String {
  String removeLast() {
    if (length > 0) {
      return substring(0, length - 1);
    } else {
      return this;
    }
  }
}