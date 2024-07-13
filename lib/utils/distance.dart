import 'package:intl/intl.dart';

class DistanceUtility {
  static const numbers = '0123456789.';
  static String getDistance(num distance) {
    String t = NumberFormat.compact().format(distance);
    t = t.toLowerCase();
    int? indexOfSpace;
    for (int i = 0; i < t.length; i++) {
      if (numbers.contains(t[i])) {
        continue;
      }
      indexOfSpace = i;
    }

    if (indexOfSpace == null) {
      return '$t m';
    }

    t = '${t.substring(0, indexOfSpace)} ${t.substring(indexOfSpace)}';
    return '${t}m';
  }

  static String getDuration(num duration) {
    final dur = Duration(seconds: duration.toInt());

    if (dur.inSeconds < 60) {
      return '${dur.inSeconds}s';
    } else if (dur.inMinutes < 60) {
      return '${dur.inMinutes} min${dur.inMinutes == 1 ? '' : 's'}';
    } else if (dur.inHours < 24) {
      return '${dur.inHours} hr${dur.inHours == 1 ? '' : 's'}';
    } else {
      return '${dur.inDays} day${dur.inDays == 1 ? '' : 's'}';
    }
  }
}
