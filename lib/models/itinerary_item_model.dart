// lib/models/itinerary_item_model.dart

class ItineraryItemModel {
  final String itemId;
  final String tripId;
  final String dayLabel; // e.g. "Day 1 – Jan 05"
  final DateTime date;
  final String title;
  final String? description;
  final String? place;
  final String
      category; // 'activity' | 'food' | 'transport' | 'hotel' | 'other'
  final String? startTime; // "09:30"
  final String? endTime; // "11:00"
  final int sortOrder;
  final DateTime createdAt;

  const ItineraryItemModel({
    required this.itemId,
    required this.tripId,
    required this.dayLabel,
    required this.date,
    required this.title,
    this.description,
    this.place,
    this.category = 'activity',
    this.startTime,
    this.endTime,
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory ItineraryItemModel.fromMap(Map<String, dynamic> map) {
    return ItineraryItemModel(
      itemId: map['itemId'] as String,
      tripId: map['tripId'] as String,
      dayLabel: map['dayLabel'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      title: map['title'] as String,
      description: map['description'] as String?,
      place: map['place'] as String?,
      category: (map['category'] as String?) ?? 'activity',
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      sortOrder: (map['sortOrder'] as int?) ?? 0,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as int?) ?? 0),
    );
  }

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'tripId': tripId,
        'dayLabel': dayLabel,
        'date': date.millisecondsSinceEpoch,
        'title': title,
        'description': description,
        'place': place,
        'category': category,
        'startTime': startTime,
        'endTime': endTime,
        'sortOrder': sortOrder,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  ItineraryItemModel copyWith({
    String? itemId,
    String? tripId,
    String? dayLabel,
    DateTime? date,
    String? title,
    String? description,
    String? place,
    String? category,
    String? startTime,
    String? endTime,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return ItineraryItemModel(
      itemId: itemId ?? this.itemId,
      tripId: tripId ?? this.tripId,
      dayLabel: dayLabel ?? this.dayLabel,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      place: place ?? this.place,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
