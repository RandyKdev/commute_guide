import 'package:commute_guide/enums/place_type_enum.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class CommutePlace extends Equatable {
  final double lat;
  final double lng;
  final String address;
  final String placeId;
  final PlaceTypeEnum placeType;
  final DateTime createdAt;

  const CommutePlace({
    required this.lat,
    required this.lng,
    required this.address,
    required this.placeId,
    this.placeType = PlaceTypeEnum.other,
    required this.createdAt,
  });

  CommutePlace copy({
    double? lat,
    double? lng,
    String? address,
    String? placeId,
    PlaceTypeEnum? placeType,
    DateTime? createdAt,
  }) {
    return CommutePlace(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      placeId: placeId ?? this.placeId,
      createdAt: createdAt ?? this.createdAt,
      placeType: placeType ?? this.placeType,
    );
  }

  factory CommutePlace.fromJson(Map<String, dynamic> json) {
    return CommutePlace(
      placeId: json["place_id"].toString(),
      lat: json["lat"],
      lng: json['lng'],
      address: json["address"].toString(),
      placeType: PlaceTypeEnum.values.firstWhere(
        (e) => e.name == json["place_type"],
        orElse: () => PlaceTypeEnum.other,
      ),
      createdAt: json["created_at"] == null
          ? DateTime.now()
          : DateFormat('dd/MM/yyyy HH:mm:ss')
              .parseUTC(json['created_at'])
              .toLocal(),
    );
  }

  factory CommutePlace.fromGoogleGeocodeJson(Map<String, dynamic> json) {
    return CommutePlace(
      placeId: json["place_id"],
      lat: json["geometry"]['location']['lat'],
      lng: json["geometry"]['location']['lng'],
      address: json['formatted_address'],
      placeType: PlaceTypeEnum.other,
      createdAt: DateTime.now(),
    );
  }

  factory CommutePlace.fromGooglePlacesJson(Map<String, dynamic> json) {
    final name = json['displayName']['text'];
    final placeFormatted = json['formattedAddress'];
    return CommutePlace(
      placeId: json["id"],
      lat: json["location"]['latitude'],
      lng: json["location"]['longitude'],
      address: '$name${placeFormatted == null ? '' : ', $placeFormatted'}',
      placeType: PlaceTypeEnum.other,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toFullJson() {
    return {
      'place_id': placeId,
      'address': address,
      'lat': lat,
      'lng': lng,
      'place_type': placeType.name,
      'created_at': DateFormat('dd/MM/yyyy HH:mm:ss').format(createdAt.toUtc()),
    };
  }

  @override
  List<Object?> get props => [
        lat,
        lng,
        address,
        placeId,
        placeType,
        createdAt,
      ];
}
