// lib/models/place_model.dart

class CityModel {
  final String id;
  final String name;
  final String country;
  final String? countryCode;
  final double latitude;
  final double longitude;
  final int? population;

  const CityModel({
    required this.id,
    required this.name,
    required this.country,
    this.countryCode,
    required this.latitude,
    required this.longitude,
    this.population,
  });

  factory CityModel.fromGeoDB(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      country: json['country'] as String,
      countryCode: json['countryCode'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      population: json['population'] as int?,
    );
  }
}

class PlaceModel {
  final String id;
  final String name;
  final String? category;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final String? photoUrl;

  const PlaceModel({
    required this.id,
    required this.name,
    this.category,
    this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.photoUrl,
  });

  /// Parse from Foursquare Places API v3
  factory PlaceModel.fromFoursquare(Map<String, dynamic> json) {
    final cats = json['categories'] as List?;
    final loc = json['location'] as Map<String, dynamic>?;
    final geo = json['geocodes']?['main'] as Map<String, dynamic>?;

    return PlaceModel(
      id: json['fsq_id'] as String,
      name: json['name'] as String,
      category: cats != null && cats.isNotEmpty
          ? (cats.first as Map)['name'] as String?
          : null,
      address: loc?['formatted_address'] as String?,
      latitude: geo != null ? (geo['latitude'] as num).toDouble() : null,
      longitude: geo != null ? (geo['longitude'] as num).toDouble() : null,
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }
}
