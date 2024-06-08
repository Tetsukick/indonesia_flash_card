extension Shuffle on String {
  String get shuffled => (split('')..shuffle()).join('');
}