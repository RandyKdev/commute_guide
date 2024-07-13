import 'package:commute_guide/enums/issue_enum.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class CommuteIssue extends Equatable {
  final List<String> images;
  final IssueEnum issue;
  final String description;
  final double lat;
  final double lng;
  final DateTime createdAt;
  final bool accepted;
  final String id;
  final String userId;
  final String? address;

  const CommuteIssue({
    required this.lat,
    required this.lng,
    required this.images,
    required this.issue,
    required this.description,
    required this.accepted,
    required this.createdAt,
    required this.id,
    required this.userId,
    required this.address,
  });

  CommuteIssue copy({
    List<String>? images,
    IssueEnum? issue,
    String? description,
    double? lat,
    double? lng,
    DateTime? createdAt,
    bool? accepted,
    String? id,
    String? userId,
    String? address,
  }) {
    return CommuteIssue(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      images: images ?? this.images,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      issue: issue ?? this.issue,
      accepted: accepted ?? this.accepted,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      address: address ?? this.address,
    );
  }

  factory CommuteIssue.fromJson(Map<String, dynamic> json) {
    return CommuteIssue(
      id: json["id"].toString(),
      lat: json["lat"],
      lng: json['lng'],
      description: json["description"].toString(),
      issue: IssueEnum.values.firstWhere(
        (e) => e.name == json["issue_type"],
        orElse: () => IssueEnum.accidents,
      ),
      accepted: json['accepted'],
      images: (json['images'] as List?)?.cast<String>() ?? [],
      createdAt: json["created_at"] == null
          ? DateTime.now()
          : DateFormat('dd/MM/yyyy HH:mm:ss')
              .parseUTC(json['created_at'])
              .toLocal(),
      userId: json['user_id'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toFullJson() {
    return {
      'id': id,
      'description': description,
      'lat': lat,
      'lng': lng,
      'issue_type': issue.name,
      'created_at': DateFormat('dd/MM/yyyy HH:mm:ss').format(createdAt.toUtc()),
      'accepted': accepted,
      'images': images,
      'user_id': userId,
      'address': address,
    };
  }

  @override
  List<Object?> get props => [
        lat,
        lng,
        description,
        id,
        images,
        accepted,
        issue,
        createdAt,
        userId,
        address,
      ];
}
