// lib/services/places_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';

class PlacesService {
  // GeoDB Cities API (RapidAPI)
  static const String _geoDbHost = 'wft-geo-db.p.rapidapi.com';
  static const String _geoDbKey = 'YOUR_RAPIDAPI_KEY'; // Replace with yours

  // Foursquare Places API v3
  static const String _foursquareKey = 'YOUR_FOURSQUARE_API_KEY'; // Replace

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
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Search attractions/places near a city using Foursquare
  Future<List<PlaceModel>> searchPlaces({
    required double latitude,
    required double longitude,
    String? query,
    String categories = '16000', // "Arts & Entertainment"
  }) async {
    try {
      final params = {
        'll': '$latitude,$longitude',
        'radius': '10000',
        'limit': '20',
        'categories': categories,
        if (query != null && query.isNotEmpty) 'query': query,
      };

      final url = Uri.https(
        'api.foursquare.com',
        '/v3/places/search',
        params,
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': _foursquareKey,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (json['results'] as List).cast<Map<String, dynamic>>();
        return results.map((r) => PlaceModel.fromFoursquare(r)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Popular category IDs for Foursquare
  static const Map<String, String> categories = {
    'Attractions': '16000',
    'Food': '13000',
    'Hotels': '19014',
    'Shopping': '17000',
    'Outdoors': '16032',
    'Arts': '10000',
  };
}
