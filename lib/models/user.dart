import 'package:commute_guide/enums/avoid_enum.dart';
import 'package:commute_guide/enums/issue_enum.dart';
import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/models/commute_trip.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class AppUser extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final DateTime? createdAt;
  final List<String>? fcmTokens;
  final List<CommutePlace>? favorites;
  final List<CommutePlace>? recents;
  final List<CommuteTrip>? scheduledTrips;
  final TravelModeEnum? preferredTravelMode;
  final List<AvoidEnum>? drivingPreferences;
  final List<AvoidEnum>? walkingPreferences;
  final List<AvoidEnum>? cyclingPreferences;
  final List<IssueEnum>? notificationPreferences;
  final bool auth;

  static const dBID = 'id';
  static const dBName = 'name';
  static const dBProfileImageUrl = 'profile_image_url';
  static const dBEmail = 'email';
  static const dBhasOnboarded = 'has_onboarded';
  static const dBCreatedAt = 'created_at';
  static const dBFcmTokens = 'fcm_tokens';

  List<CommuteTrip> get getCurrentScheduledTrips {
    final temp = scheduledTrips ?? [];
    final now = DateTime.now();
    final useTime = DateTime(now.year, now.month, now.day, now.hour);
    return temp.where((t) => t.scheduledAt.isAfter(useTime)).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.fcmTokens,
    required this.recents,
    required this.favorites,
    required this.scheduledTrips,
    required this.preferredTravelMode,
    required this.drivingPreferences,
    required this.walkingPreferences,
    required this.cyclingPreferences,
    required this.notificationPreferences,
    required this.auth,
  });

  AppUser copy({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    List<String>? fcmTokens,
    List<CommutePlace>? recents,
    List<CommutePlace>? favorites,
    List<CommuteTrip>? scheduledTrips,
    TravelModeEnum? preferredTravelMode,
    List<AvoidEnum>? drivingPreferences,
    List<AvoidEnum>? walkingPreferences,
    List<AvoidEnum>? cyclingPreferences,
    List<IssueEnum>? notificationPreferences,
    bool? auth,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      recents: recents ?? this.recents,
      favorites: favorites ?? this.favorites,
      scheduledTrips: scheduledTrips ?? this.scheduledTrips,
      preferredTravelMode: preferredTravelMode ?? this.preferredTravelMode,
      drivingPreferences: drivingPreferences ?? this.drivingPreferences,
      cyclingPreferences: cyclingPreferences ?? this.cyclingPreferences,
      walkingPreferences: walkingPreferences ?? this.walkingPreferences,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      auth: auth ?? this.auth,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      email: json["email"]?.toString(),
      createdAt: json["created_at"] == null
          ? null
          : DateFormat('dd/MM/yyyy HH:mm:ss').parseUTC(json['created_at']),
      fcmTokens: (json[dBFcmTokens] as List?)?.map((e) => e as String).toList(),
      recents: (json['recents'] as List?)
          ?.map((e) => CommutePlace.fromJson(e))
          .toList(),
      favorites: (json['favorites'] as List?)
          ?.map((e) => CommutePlace.fromJson(e))
          .toList(),
      scheduledTrips: (json['scheduled_trips'] as List?)
          ?.map((e) => CommuteTrip.fromJson(e))
          .toList(),
      preferredTravelMode: TravelModeEnum.values.firstWhere(
        (e) => e.name == json['preferred_travel_mode'],
        orElse: () => TravelModeEnum.driving,
      ),
      drivingPreferences: (json['driving_preferences'] as List?)
          ?.map((e) => AvoidEnum.values.firstWhere((e1) => e1.name == e))
          .toList(),
      walkingPreferences: (json['walking_preferences'] as List?)
          ?.map((e) => AvoidEnum.values.firstWhere((e1) => e1.name == e))
          .toList(),
      cyclingPreferences: (json['cycling_preferences'] as List?)
          ?.map((e) => AvoidEnum.values.firstWhere((e1) => e1.name == e))
          .toList(),
      notificationPreferences: (json['notification_preferences'] as List?)
          ?.map((e) => IssueEnum.values.firstWhere((e1) => e1.name == e))
          .toList(),
      auth: json['auth'] ?? false,
    );
  }

  Map<String, dynamic> toFullJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt == null
          ? null
          : DateFormat('dd/MM/yyyy HH:mm:ss').format(createdAt!.toUtc()),
      dBFcmTokens: fcmTokens,
      'recents': recents?.map((e) => e.toFullJson()).toList(),
      'favorites': favorites?.map((e) => e.toFullJson()).toList(),
      'scheduled_trips': scheduledTrips?.map((e) => e.toFullJson()).toList(),
      'preferred_travel_mode': preferredTravelMode?.name,
      'driving_preferences': drivingPreferences?.map((e) => e.name).toList(),
      'walking_preferences': walkingPreferences?.map((e) => e.name).toList(),
      'cycling_preferences': cyclingPreferences?.map((e) => e.name).toList(),
      'notification_preferences':
          notificationPreferences?.map((e) => e.name).toList(),
      'auth': auth,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      dBFcmTokens: fcmTokens,
      'recents': recents?.map((e) => e.toFullJson()).toList(),
      'favorites': favorites?.map((e) => e.toFullJson()).toList(),
      'scheduled_trips': scheduledTrips?.map((e) => e.toFullJson()).toList(),
      'preferred_travel_mode': preferredTravelMode?.name,
      'driving_preferences': drivingPreferences?.map((e) => e.name).toList(),
      'walking_preferences': walkingPreferences?.map((e) => e.name).toList(),
      'cycling_preferences': cyclingPreferences?.map((e) => e.name).toList(),
      'notification_preferences':
          notificationPreferences?.map((e) => e.name).toList(),
      'auth': auth,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        createdAt,
        fcmTokens,
        recents,
        scheduledTrips,
        favorites,
        preferredTravelMode,
        drivingPreferences,
        walkingPreferences,
        cyclingPreferences,
        notificationPreferences,
        auth,
      ];
}
