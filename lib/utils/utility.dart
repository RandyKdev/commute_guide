import 'dart:async';

import 'package:commute_guide/enums/travel_mode_enum.dart';

class Utility {
  static Timer setTimeout(callback, [int duration = 1200]) {
    return Timer(Duration(milliseconds: duration), callback);
  }

  static void clearTimeout(Timer t) {
    t.cancel();
  }

  static int getDurationWRTTravelMode({
    required int distance,
    required TravelModeEnum mode,
    required int duration,
  }) {
    if (mode == TravelModeEnum.driving) {
      return duration;
    } else if (mode == TravelModeEnum.bicycling) {
      return distance ~/ 3;
    } else {
      return duration;
    }
  }
}
