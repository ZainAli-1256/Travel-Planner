// lib/models/weather_model.dart

class WeatherModel {
  final String cityName;
  final double tempC;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final DateTime dateTime;

  const WeatherModel({
    required this.cityName,
    required this.tempC,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.dateTime,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;

    return WeatherModel(
      cityName: json['name'] as String? ?? '',
      tempC: (main['temp'] as num).toDouble() - 273.15,
      tempMin: (main['temp_min'] as num).toDouble() - 273.15,
      tempMax: (main['temp_max'] as num).toDouble() - 273.15,
      description: weather['description'] as String,
      iconCode: weather['icon'] as String,
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      dateTime: DateTime.now(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  String get tempDisplay => '${tempC.round()}°C';
  String get tempRangeDisplay => '${tempMin.round()}° / ${tempMax.round()}°C';
}

class ForecastDay {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode;

  const ForecastDay({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      tempMin: (main['temp_min'] as num).toDouble() - 273.15,
      tempMax: (main['temp_max'] as num).toDouble() - 273.15,
      description: weather['description'] as String,
      iconCode: weather['icon'] as String,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}
