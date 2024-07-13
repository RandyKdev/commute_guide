import 'package:commute_guide/enums/avoid_enum.dart';
import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class CommuteTrip extends Equatable {
  final List<CommutePlace> places;
  final List<AvoidEnum> avoids;
  final List<LatLng> points;
  final double distance;
  final double duration;
  final DateTime createdAt;
  final DateTime scheduledAt;
  final TravelModeEnum travelModeEnum;
  final String id;
  final double speed;
  final double durationLeft;
  final double durationCovered;
  final double distanceLeft;
  final double distanceCovered;
  final bool done;
  final LatLng? currentPosition;

  const CommuteTrip({
    required this.id,
    required this.points,
    required this.distance,
    required this.travelModeEnum,
    required this.createdAt,
    required this.duration,
    required this.scheduledAt,
    required this.avoids,
    required this.places,
    required this.speed,
    required this.durationLeft,
    required this.durationCovered,
    required this.distanceLeft,
    required this.distanceCovered,
    required this.done,
    this.currentPosition,
  });

  CommuteTrip copy({
    String? polyline,
    List<CommutePlace>? places,
    double? distance,
    double? duration,
    DateTime? createdAt,
    DateTime? scheduledAt,
    TravelModeEnum? travelModeEnum,
    String? id,
    List<AvoidEnum>? avoids,
    List<LatLng>? points,
    double? speed,
    double? durationLeft,
    double? durationCovered,
    double? distanceLeft,
    double? distanceCovered,
    bool? done,
    LatLng? currentPosition,
  }) {
    return CommuteTrip(
      id: id ?? this.id,
      points: points ?? this.points,
      distance: distance ?? this.distance,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      travelModeEnum: travelModeEnum ?? this.travelModeEnum,
      places: places ?? this.places,
      avoids: avoids ?? this.avoids,
      speed: speed ?? this.speed,
      durationLeft: durationLeft ?? this.durationLeft,
      durationCovered: durationCovered ?? this.durationCovered,
      distanceLeft: distanceLeft ?? this.distanceLeft,
      distanceCovered: distanceCovered ?? this.distanceCovered,
      done: done ?? this.done,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }

  factory CommuteTrip.fromJson(Map<String, dynamic> json) {
    return CommuteTrip(
      id: json["id"].toString(),
      places: (json['places'] as List)
          .map((e) => CommutePlace.fromJson(e))
          .toList(),
      distance: double.parse(json["distance"].toString()),
      travelModeEnum: TravelModeEnum.values.firstWhere(
        (e) => e.name == json["travel_mode"],
        orElse: () => TravelModeEnum.driving,
      ),
      createdAt: json["created_at"] == null
          ? DateTime.now()
          : DateFormat('dd/MM/yyyy HH:mm:ss')
              .parseUTC(json['created_at'])
              .toLocal(),
      duration: double.parse(json['duration'].toString()),
      scheduledAt: json['scheduled_at'] == null
          ? DateTime.now()
          : DateFormat('dd/MM/yyyy HH:mm:ss')
              .parseUTC(json['scheduled_at'])
              .toLocal(),
      points: (json['points'] as List).map((e) => LatLng.fromJson(e)).toList(),
      avoids: (json['avoids'] as List)
          .map((e) => AvoidEnum.values.firstWhere((e1) => e1.name == e))
          .toList(),
      speed: double.parse(json['speed'].toString()),
      durationLeft: double.parse(json['duration_left'].toString()),
      durationCovered: double.parse(json['duration_covered'].toString()),
      distanceLeft: double.parse(json['distance_left'].toString()),
      distanceCovered: double.parse(json['distance_covered'].toString()),
      done: json['done'],
      currentPosition: json['current_position'] == null
          ? null
          : LatLng.fromJson(json['current_position']),
    );
  }

  Map<String, dynamic> toFullJson() {
    return {
      'id': id,
      'points': points.map((e) => e.toJson()).toList(),
      'distance': distance,
      'travel_mode': travelModeEnum.name,
      'created_at': DateFormat('dd/MM/yyyy HH:mm:ss').format(createdAt.toUtc()),
      'duration': duration,
      'scheduled_at':
          DateFormat('dd/MM/yyyy HH:mm:ss').format(scheduledAt.toUtc()),
      'places': places.map((e) => e.toFullJson()).toList(),
      'avoids': avoids.map((e) => e.name).toList(),
      'speed': speed,
      'duration_left': durationLeft,
      'duration_covered': durationCovered,
      'distance_left': distanceLeft,
      'distance_covered': distanceCovered,
      'done': done,
      'current_position': currentPosition?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        points,
        distance,
        duration,
        createdAt,
        scheduledAt,
        travelModeEnum,
        id,
        places,
        avoids,
        speed,
        durationLeft,
        durationCovered,
        distanceLeft,
        distanceCovered,
        done,
        currentPosition,
      ];
}
