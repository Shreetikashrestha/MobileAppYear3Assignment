import 'package:dio/dio.dart';

/// Weather Service using OpenWeatherMap API (3rd Party API)
/// Free API: https://openweathermap.org/api
class WeatherService {
  final Dio _dio = Dio();
  
  // Free API key for demo (replace with your own)
  static const String _apiKey = 'demo_key'; // User should get their own key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Get current weather by coordinates
  Future<WeatherData?> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric', // Celsius
        },
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  /// Get current weather by city name
  Future<WeatherData?> getWeatherByCity(String cityName) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'q': cityName,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  /// Get 5-day weather forecast
  Future<List<WeatherData>> getWeatherForecast(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['list'];
        return list.map((json) => WeatherData.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching forecast: $e');
      return [];
    }
  }
}

/// Weather Data Model
class WeatherData {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final String cityName;
  final DateTime? dateTime;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.cityName,
    this.dateTime,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final weather = (json['weather'] as List?)?.first ?? {};
    final wind = json['wind'] ?? {};

    return WeatherData(
      temperature: (main['temp'] ?? 0).toDouble(),
      feelsLike: (main['feels_like'] ?? 0).toDouble(),
      humidity: main['humidity'] ?? 0,
      windSpeed: (wind['speed'] ?? 0).toDouble(),
      description: weather['description'] ?? 'Unknown',
      icon: weather['icon'] ?? '01d',
      cityName: json['name'] ?? 'Unknown',
      dateTime: json['dt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000)
          : null,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  String get temperatureDisplay => '${temperature.toStringAsFixed(1)}°C';

  String get descriptionCapitalized =>
      description.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
}
