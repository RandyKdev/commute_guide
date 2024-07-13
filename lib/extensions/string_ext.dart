extension StringExt on String {
  String get getFirstName {
    final indexOfSpace = indexOf(' ');
    return substring(0, indexOfSpace == -1 ? null : indexOfSpace);
  }

  String get getWordsCapitalized {
    final words = split(' ');
    return words.map((e) {
      final firstLetter = e.isNotEmpty ? e[0] : '';
      if (firstLetter.isEmpty) return '';
      return firstLetter.toUpperCase() + e.substring(1);
    }).join(' ');
  }

  String get getUncloggedWords {
    final indices = [];
    final chars = split('');
    for (int i = 0; i < length; i++) {
      if (chars[i].toUpperCase() == chars[i]) {
        indices.add(i);
      }
    }
    for (final index in indices) {
      chars.insert(index, ' ');
    }
    return chars.join();
  }
}
