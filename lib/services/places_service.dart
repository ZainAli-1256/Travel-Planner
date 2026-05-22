// lib/services/places_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';
import '../core/constants/api_keys.dart';

class PlacesApiException implements Exception {
  final String source;
  final int statusCode;
  final String? message;

  const PlacesApiException({
    required this.source,
    required this.statusCode,
    this.message,
  });

  @override
  String toString() {
    final detail = (message == null || message!.trim().isEmpty)
        ? 'No details'
        : message!.trim();
    return '$source error $statusCode: $detail';
  }
}

class PlacesService {
  // GeoDB Cities API (RapidAPI)
  static const String _geoDbHost = 'wft-geo-db.p.rapidapi.com';
  static const String _geoDbKey = ApiKeys.geoDbRapidApi;
  static const String _overpassHost = 'overpass-api.de';

  /// Search cities by name using GeoDB
  Future<List<CityModel>> searchCities(String query) async {
    try {
      final url = Uri.https(
        _geoDbHost,
        '/v1/geo/cities',
        {'namePrefix': query, 'limit': '10', 'sort': '-population'},
      );

      final response = await http.get(
        url,
        headers: {
          'X-RapidAPI-Host': _geoDbHost,
          'X-RapidAPI-Key': _geoDbKey,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = (json['data'] as List).cast<Map<String, dynamic>>();
        return data.map((d) => CityModel.fromGeoDB(d)).toList();
      }
      throw PlacesApiException(
        source: 'GeoDB',
        statusCode: response.statusCode,
        message: _extractErrorMessage(response.body),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Search attractions/places near a city using Overpass (OpenStreetMap)
  Future<List<PlaceModel>> searchPlaces({
    required double latitude,
    required double longitude,
    String? query,
    List<String>? categories,
  }) async {
    try {
      final overpassQuery = _buildOverpassQuery(
        latitude: latitude,
        longitude: longitude,
        query: query,
        categories: categories,
      );

      final url = Uri.https(_overpassHost, '/api/interpreter');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'User-Agent': 'smart-travel-planner/1.0 (student project)',
        },
        body: 'data=${Uri.encodeQueryComponent(overpassQuery)}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final elements =
            (json['elements'] as List?)?.cast<Map<String, dynamic>>();
        if (elements == null || elements.isEmpty) return [];
        return elements.map((e) => PlaceModel.fromOverpass(e)).toList();
      }
      throw PlacesApiException(
        source: 'Overpass',
        statusCode: response.statusCode,
        message: _extractErrorMessage(response.body),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'format': 'jsonv2',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'zoom': '18',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'smart-travel-planner/1.0 (student project)',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final display = json['display_name'] as String?;
        if (display != null && display.trim().isNotEmpty) {
          return display.trim();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractErrorMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        if (json['message'] is String) return json['message'] as String;
        if (json['error'] is String) return json['error'] as String;
        if (json['errors'] is List && (json['errors'] as List).isNotEmpty) {
          final first = (json['errors'] as List).first;
          if (first is Map && first['message'] is String) {
            return first['message'] as String;
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  String _buildOverpassQuery({
    required double latitude,
    required double longitude,
    String? query,
    List<String>? categories,
  }) {
    const radius = 10000;
    final filters = <String>[];

    if (categories != null && categories.isNotEmpty) {
      filters.addAll(categories);
    } else {
      filters.addAll(_defaultCategoryFilters);
    }

    final queryFilter = (query != null && query.trim().isNotEmpty)
        ? '["name"~"${_escapeOverpass(query.trim())}",i]'
        : '';

    final buffer = StringBuffer('[out:json][timeout:25];(');
    for (final filter in filters) {
      buffer
        ..write('node(around:$radius,$latitude,$longitude)[$filter]')
        ..write(queryFilter)
        ..write(';')
        ..write('way(around:$radius,$latitude,$longitude)[$filter]')
        ..write(queryFilter)
        ..write(';')
        ..write('relation(around:$radius,$latitude,$longitude)[$filter]')
        ..write(queryFilter)
        ..write(';');
    }
    buffer.write(');out center 30;');
    return buffer.toString();
  }

  String _escapeOverpass(String value) {
    return value.replaceAll('"', '\\"');
  }

  static const Map<String, List<String>> categories = {
    'Attractions': ['tourism=attraction'],
    'Food': ['amenity=restaurant', 'amenity=cafe', 'amenity=fast_food'],
    'Hotels': ['tourism=hotel', 'tourism=hostel', 'tourism=guest_house'],
    'Shopping': ['shop'],
    'Outdoors': ['leisure=park', 'leisure=garden', 'nature=reserve'],
    'Arts': ['tourism=museum', 'tourism=gallery', 'amenity=arts_centre'],
  };

  static const List<String> _defaultCategoryFilters = [
    'tourism=attraction',
    'amenity=restaurant',
    'amenity=cafe',
    'amenity=fast_food',
    'tourism=hotel',
    'tourism=hostel',
    'tourism=guest_house',
    'shop',
    'leisure=park',
    'tourism=museum',
  ];
}
