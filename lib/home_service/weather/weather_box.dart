import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:http/http.dart' as http;

import 'weather_forecast_screen.dart';
import 'package:provider/provider.dart';
import 'package:refill/providers/weather_provider.dart';

class WeatherBox extends StatefulWidget {
  const WeatherBox({super.key});

  @override
  State<WeatherBox> createState() => _WeatherBoxState();
}

class _WeatherBoxState extends State<WeatherBox> {
  String weather = '로딩 중...';
  String temperature = '';
  String humidity = '';
  IconData weatherIcon = Icons.wb_sunny;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      final double lat = 35.1595;
      final double lon = 126.8526;

      final data = await _fetchWeather(lat, lon);
      final weatherMain = data['weather'][0]['main']; // 예: 'Clear', 'Rain', etc.
      final temp = data['main']['temp'];
      final humid = data['main']['humidity'];
      print('현재 습도: $humid');

      Provider.of<WeatherProvider>(context, listen: false).updateWeather(weatherMain);

      setState(() {
        weather = _translateWeather(weatherMain);
        temperature = '${temp.toStringAsFixed(1)}°C';
        humidity = '습도 $humid%';
        weatherIcon = _getWeatherIcon(weatherMain);
      });
    } catch (e) {
      print("날씨 로딩 실패: $e");
      setState(() {
        weather = '불러오기 실패';
        temperature = '';
        humidity = '';
        weatherIcon = Icons.error;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchWeather(double lat, double lon) async {
    const apiKey = '3a7bc2dc7a3b4025ce04a27e31923af7';
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&lang=kr&appid=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('날씨 데이터 오류');
    }
  }

  IconData _getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'drizzle':
        return Icons.grain;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  String _translateWeather(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return '맑음';
      case 'clouds':
        return '흐림';
      case 'rain':
        return '비';
      case 'drizzle':
        return '이슬비';
      case 'snow':
        return '눈';
      case 'thunderstorm':
        return '천둥번개';
      case 'mist':
      case 'fog':
        return '안개';
      default:
        return '알 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WeatherForecastScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(weatherIcon, size: 30, color: AppColors.primary),
            Text(
              weather,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              temperature,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              humidity,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
