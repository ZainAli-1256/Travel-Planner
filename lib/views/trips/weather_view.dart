import 'package:flutter/material.dart';
import '../../../models/trip_model.dart';
import '../../../models/weather_model.dart';
import '../../../services/weather_service.dart';
import '../../../core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherView extends StatefulWidget {
  final TripModel trip;

  const WeatherView({super.key, required this.trip});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final _weatherService = WeatherService();
  WeatherModel? _currentWeather;
  List<ForecastDay> _forecast = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final city = widget.trip.destination.split(',').first;
    final current = await _weatherService.getCurrentWeather(city);
    final forecast = await _weatherService.getForecast(city);

    if (mounted) {
      setState(() {
        _currentWeather = current;
        _forecast = forecast;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.amber));
    }

    if (_currentWeather == null) {
      return Center(
        child: Text(
          'Could not load weather for ${widget.trip.destination}',
          style: GoogleFonts.inter(color: AppColors.slate400),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(
              'Trip Dates: ${widget.trip.startDate.day}/${widget.trip.startDate.month} - ${widget.trip.endDate.day}/${widget.trip.endDate.month}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _currentWeather!.cityName,
            style: GoogleFonts.sora(
                fontSize: 28,
                color: AppColors.white,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _currentWeather!.description.toUpperCase(),
            style: GoogleFonts.inter(
                color: AppColors.slate400, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(_currentWeather!.iconUrl, width: 80, height: 80),
              const SizedBox(width: 16),
              Text(
                _currentWeather!.tempDisplay,
                style: GoogleFonts.sora(
                    fontSize: 56,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _WeatherInfo(
                  icon: Icons.water_drop_rounded,
                  value: '${_currentWeather!.humidity}%',
                  label: 'Humidity'),
              const SizedBox(width: 32),
              _WeatherInfo(
                  icon: Icons.air_rounded,
                  value: '${_currentWeather!.windSpeed} m/s',
                  label: 'Wind'),
            ],
          ),
          const SizedBox(height: 48),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('5-Day Forecast',
                style: GoogleFonts.sora(
                    fontSize: 20,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          if (_forecast.isEmpty)
            Text('Forecast data not available.',
                style: GoogleFonts.inter(color: AppColors.slate400))
          else
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _forecast.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final day = _forecast[index];
                  final isToday = day.date.day == DateTime.now().day &&
                      day.date.month == DateTime.now().month;
                  final inTripRange = !day.date.isBefore(
                        DateTime(
                            widget.trip.startDate.year,
                            widget.trip.startDate.month,
                            widget.trip.startDate.day),
                      ) &&
                      !day.date.isAfter(
                        DateTime(widget.trip.endDate.year,
                            widget.trip.endDate.month, widget.trip.endDate.day),
                      );

                  return Container(
                    width: 110,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: inTripRange ? AppColors.amber : AppColors.glassBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: inTripRange
                              ? Colors.transparent
                              : AppColors.glassBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday
                              ? 'Today'
                              : '${day.date.day}/${day.date.month}',
                          style: GoogleFonts.inter(
                            color: inTripRange
                                ? AppColors.navyDeep
                                : AppColors.white,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.network(day.iconUrl, width: 40, height: 40),
                        const SizedBox(height: 8),
                        Text(
                          '${day.tempMax.round()}°',
                          style: GoogleFonts.sora(
                            color: inTripRange
                                ? AppColors.navyDeep
                                : AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _WeatherInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherInfo(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.amber, size: 28),
        const SizedBox(height: 8),
        Text(value,
            style: GoogleFonts.inter(
                color: AppColors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 12)),
      ],
    );
  }
}
