import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/place_model.dart';
import '../../services/places_service.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final _placesService = PlacesService();
  final _searchCtrl = TextEditingController();
  List<CityModel> _results = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _placesService.searchCities(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to search cities. Check your GeoDB key.';
          _results = [];
          _isLoading = false;
        });
      }
    }
  }

  void _selectCity(CityModel city) {
    final label = '${city.name}, ${city.country}';
    Navigator.pop(context, label);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: Text('City Search',
            style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: GoogleFonts.inter(color: AppColors.white),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        hintText: 'Search cities (e.g., Lahore)',
                        hintStyle: GoogleFonts.inter(color: AppColors.slate400),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.amber),
                        filled: true,
                        fillColor: AppColors.glassBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: AppColors.navyDeep,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _error!,
                  style: GoogleFonts.inter(color: AppColors.error),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.amber))
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            'No cities yet. Search above.',
                            style: GoogleFonts.inter(color: AppColors.slate400),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final city = _results[index];
                            return GestureDetector(
                              onTap: () => _selectCity(city),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.glassBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: AppColors.glassBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_city_rounded,
                                        color: AppColors.amber),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${city.name}, ${city.country}',
                                            style: GoogleFonts.inter(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            city.population == null
                                                ? 'Population not available'
                                                : 'Population: ${city.population}',
                                            style: GoogleFonts.inter(
                                              color: AppColors.slate400,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded,
                                        color: AppColors.slate400),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
