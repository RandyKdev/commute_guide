extension IntExt on int {
  String get atleastTwoDigits {
    if (this < 10) return '0$this';
    return '$this';
  }
}
