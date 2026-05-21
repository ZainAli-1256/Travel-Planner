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

  /// Parse from Overpass (OpenStreetMap)
  factory PlaceModel.fromOverpass(Map<String, dynamic> json) {
    final tags = (json['tags'] as Map<String, dynamic>?) ?? {};
    final name = tags['name'] as String? ?? 'Unnamed place';
    final type = json['type']?.toString() ?? 'node';
    final id = '${type}_${json['id']}';
    final lat = (json['lat'] as num?)?.toDouble() ??
        (json['center']?['lat'] as num?)?.toDouble();
    final lon = (json['lon'] as num?)?.toDouble() ??
        (json['center']?['lon'] as num?)?.toDouble();

    return PlaceModel(
      id: id,
      name: name,
      category: _mapOverpassCategory(tags),
      address: _buildOverpassAddress(tags),
      latitude: lat,
      longitude: lon,
    );
  }

  static String? _mapOverpassCategory(Map<String, dynamic> tags) {
    final tourism = tags['tourism'] as String?;
    final amenity = tags['amenity'] as String?;
    final leisure = tags['leisure'] as String?;
    final shop = tags['shop'] as String?;
    final nature = tags['nature'] as String?;

    return tourism ?? amenity ?? leisure ?? shop ?? nature;
  }

  static String? _buildOverpassAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    final full = tags['addr:full'] as String?;
    if (full != null && full.trim().isNotEmpty) return full.trim();

    final house = tags['addr:housenumber'] as String?;
    final street = tags['addr:street'] as String?;
    final place = tags['addr:place'] as String?;
    final suburb = tags['addr:suburb'] as String?;
    final district = tags['addr:district'] as String?;
    final city = tags['addr:city'] as String?;
    final town = tags['addr:town'] as String?;
    final village = tags['addr:village'] as String?;
    final hamlet = tags['addr:hamlet'] as String?;
    final state = tags['addr:state'] as String?;
    final region = tags['addr:region'] as String?;
    final province = tags['addr:province'] as String?;
    final postcode = tags['addr:postcode'] as String?;
    final country = tags['addr:country'] as String?;

    final firstLine = [house, street].whereType<String>().join(' ').trim();
    if (firstLine.isNotEmpty) parts.add(firstLine);
    if (place != null && place.trim().isNotEmpty) parts.add(place.trim());
    if (suburb != null && suburb.trim().isNotEmpty) parts.add(suburb.trim());
    if (district != null && district.trim().isNotEmpty) {
      parts.add(district.trim());
    }
    if (city != null && city.trim().isNotEmpty) parts.add(city.trim());
    if (town != null && town.trim().isNotEmpty) parts.add(town.trim());
    if (village != null && village.trim().isNotEmpty) parts.add(village.trim());
    if (hamlet != null && hamlet.trim().isNotEmpty) parts.add(hamlet.trim());
    if (state != null && state.trim().isNotEmpty) parts.add(state.trim());
    if (region != null && region.trim().isNotEmpty) parts.add(region.trim());
    if (province != null && province.trim().isNotEmpty) {
      parts.add(province.trim());
    }
    if (postcode != null && postcode.trim().isNotEmpty) {
      parts.add(postcode.trim());
    }
    if (country != null && country.trim().isNotEmpty) {
      parts.add(country.trim());
    }

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }
}
