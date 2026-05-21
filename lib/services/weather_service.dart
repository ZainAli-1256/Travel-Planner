import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../core/constants/api_keys.dart';

class WeatherService {
  static const String _apiKey = ApiKeys.openWeather;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel?> getCurrentWeather(String city) async {
    try {
      final url =
          Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherModel.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<ForecastDay>> getForecast(String city) async {
    try {
      final url =
          Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final list = json['list'] as List;

        final Map<String, ForecastDay> dailyForecasts = {};
        for (var item in list) {
          final forecast = ForecastDay.fromJson(item);
          final dateKey =
              '${forecast.date.year}-${forecast.date.month}-${forecast.date.day}';
          if (!dailyForecasts.containsKey(dateKey)) {
            dailyForecasts[dateKey] = forecast;
          }
        }

        return dailyForecasts.values.toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
