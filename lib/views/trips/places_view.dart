import 'package:flutter/material.dart';
import '../../../models/trip_model.dart';
import '../../../models/place_model.dart';
import '../../../services/places_service.dart';
import '../../../core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PlacesView extends StatefulWidget {
  final TripModel trip;

  const PlacesView({super.key, required this.trip});

  @override
  State<PlacesView> createState() => _PlacesViewState();
}

class _PlacesViewState extends State<PlacesView> {
  final _placesService = PlacesService();
  List<PlaceModel> _places = [];
  final Map<String, String> _addressOverrides = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);
    _addressOverrides.clear();
    final city = widget.trip.destination.split(',').first;
    final categoryFilters = _selectedCategory == 'All'
        ? null
        : PlacesService.categories[_selectedCategory];

    // First, find the city lat/lng
    try {
      final cities = await _placesService.searchCities(city);
      List<PlaceModel> places = [];

      if (cities.isNotEmpty) {
        final cityGeo = cities.first;
        places = await _placesService.searchPlaces(
          latitude: cityGeo.latitude,
          longitude: cityGeo.longitude,
          query: _searchQuery,
          categories: categoryFilters,
        );
      } else {
        if (mounted) {
          setState(() {
            _places = [];
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('City not found. Try a nearby larger city.'),
            ),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _places = places;
          _isLoading = false;
        });
        _resolveAddresses(places);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _places = [];
          _isLoading = false;
        });
        final message = e is PlacesApiException
            ? e.toString()
            : 'Places API error. Check your keys.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  Future<void> _resolveAddresses(List<PlaceModel> places) async {
    for (final place in places) {
      if (!mounted) return;
      if (_addressOverrides.containsKey(place.id)) continue;
      if (place.address != null && place.address!.trim().isNotEmpty) continue;
      final lat = place.latitude;
      final lon = place.longitude;
      if (lat == null || lon == null) continue;

      final address =
          await _placesService.reverseGeocode(latitude: lat, longitude: lon);
      if (!mounted) return;
      if (address != null && address.isNotEmpty) {
        setState(() => _addressOverrides[place.id] = address);
      }

      await Future.delayed(const Duration(milliseconds: 1100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Search places, food, attractions...',
              hintStyle: const TextStyle(color: AppColors.slate400),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.amber),
              filled: true,
              fillColor: AppColors.glassBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (val) {
              _searchQuery = val;
              _loadPlaces();
            },
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _CategoryChip(
                label: 'All',
                isSelected: _selectedCategory == 'All',
                onTap: () {
                  setState(() => _selectedCategory = 'All');
                  _loadPlaces();
                },
              ),
              ...PlacesService.categories.keys.map((label) {
                return _CategoryChip(
                  label: label,
                  isSelected: _selectedCategory == label,
                  onTap: () {
                    setState(() => _selectedCategory = label);
                    _loadPlaces();
                  },
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.amber))
              : _places.isEmpty
                  ? Center(
                      child: Text('No places found',
                          style: GoogleFonts.inter(color: AppColors.slate400)),
                    )
                  : RefreshIndicator(
                      color: AppColors.amber,
                      onRefresh: _loadPlaces,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _places.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final place = _places[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.glassBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      place.name,
                                      style: GoogleFonts.inter(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (place.rating != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.navyDeep,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star_rounded,
                                              color: AppColors.amber, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            place.rating!.toStringAsFixed(1),
                                            style: GoogleFonts.inter(
                                                color: AppColors.white,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(place.category ?? 'General',
                                      style: GoogleFonts.inter(
                                          color: AppColors.amber,
                                          fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatPlaceAddress(place),
                                    style: GoogleFonts.inter(
                                        color: AppColors.slate400,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  String _formatPlaceAddress(PlaceModel place) {
    final override = _addressOverrides[place.id];
    if (override != null && override.trim().isNotEmpty) {
      return override;
    }
    if (place.address != null && place.address!.trim().isNotEmpty) {
      return place.address!;
    }
    final lat = place.latitude;
    final lon = place.longitude;
    if (lat != null && lon != null) {
      final latStr = lat.toStringAsFixed(4);
      final lonStr = lon.toStringAsFixed(4);
      return 'Lat $latStr, Lon $lonStr';
    }
    return 'No address';
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.amber : AppColors.glassBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? AppColors.navyDeep : AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
