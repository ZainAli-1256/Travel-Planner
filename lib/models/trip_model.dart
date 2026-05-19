// lib/models/trip_model.dart

class TripModel {
  final String tripId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy; // uid of owner
  final List<String> members; // list of uids
  final String? notes;
  final String? coverImageUrl;
  final DateTime createdAt;

  const TripModel({
    required this.tripId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    this.members = const [],
    this.notes,
    this.coverImageUrl,
    required this.createdAt,
  });

  // ── Firestore serialisation ───────────────────────────────────────
  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      tripId: map['tripId'] as String,
      title: map['title'] as String,
      destination: map['destination'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int),
      createdBy: map['createdBy'] as String,
      members: List<String>.from(map['members'] as List? ?? []),
      notes: map['notes'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as int?) ?? 0),
    );
  }

  Map<String, dynamic> toMap() => {
        'tripId': tripId,
        'title': title,
        'destination': destination,
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
        'createdBy': createdBy,
        'members': members,
        'notes': notes,
        'coverImageUrl': coverImageUrl,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  TripModel copyWith({
    String? tripId,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    List<String>? members,
    String? notes,
    String? coverImageUrl,
    DateTime? createdAt,
  }) {
    return TripModel(
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      notes: notes ?? this.notes,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get durationDays => endDate.difference(startDate).inDays + 1;

  @override
  String toString() =>
      'TripModel(tripId: $tripId, title: $title, destination: $destination)';
}
