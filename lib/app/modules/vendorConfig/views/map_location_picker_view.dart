import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/utils/app_theme_system.dart';

class MapLocationPickerView extends StatefulWidget {
  final LatLng? initialPosition;
  final String? initialAddress;

  const MapLocationPickerView({
    super.key,
    this.initialPosition,
    this.initialAddress,
  });

  @override
  State<MapLocationPickerView> createState() => _MapLocationPickerViewState();
}

class _MapLocationPickerViewState extends State<MapLocationPickerView> {
  late MapController mapController;
  late LatLng selectedPosition;
  String selectedAddress = '';
  bool isLoading = false;

  // Recherche
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    // Position initiale : soit celle passée en paramètre, soit Douala par défaut
    selectedPosition = widget.initialPosition ?? const LatLng(4.0511, 9.7679);
    selectedAddress = widget.initialAddress ?? '';

    // Si on a une position initiale, obtenir son adresse
    if (selectedAddress.isEmpty && widget.initialPosition != null) {
      _reverseGeocode(selectedPosition);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    mapController.dispose();
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      selectedPosition = position;
      selectedAddress = 'Chargement de l\'adresse...';
      searchResults = []; // Fermer les résultats de recherche
    });

    // Obtenir l'adresse via géocodage inverse
    _reverseGeocode(position);
  }

  /// Géocodage inverse : obtenir l'adresse depuis les coordonnées
  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'format=json&'
        'lat=${position.latitude}&'
        'lon=${position.longitude}&'
        'zoom=18&'
        'addressdetails=1'
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'AssoApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            selectedAddress = data['display_name'] ??
              'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            selectedAddress = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          selectedAddress = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  /// Rechercher une adresse
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          searchResults = [];
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        isSearching = true;
      });
    }

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'format=json&'
        'q=$query&'
        'limit=5&'
        'addressdetails=1'
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'AssoApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            searchResults = data.map((item) => {
              'display_name': item['display_name'],
              'lat': double.parse(item['lat']),
              'lon': double.parse(item['lon']),
            }).toList();
            isSearching = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            searchResults = [];
            isSearching = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          searchResults = [];
          isSearching = false;
        });
      }

      Get.snackbar(
        'Erreur',
        'Impossible de rechercher l\'adresse',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppThemeSystem.errorColor,
        colorText: Colors.white,
      );
    }
  }

  /// Sélectionner un résultat de recherche
  void _selectSearchResult(Map<String, dynamic> result) {
    final position = LatLng(result['lat'], result['lon']);

    setState(() {
      selectedPosition = position;
      selectedAddress = result['display_name'];
      searchResults = [];
      searchController.clear();
    });

    // Animer vers la position
    mapController.move(position, 16.0);
  }

  void _confirmLocation() {
    Get.back(result: {
      'latitude': selectedPosition.latitude,
      'longitude': selectedPosition.longitude,
      'address': selectedAddress.isEmpty
          ? 'Position: ${selectedPosition.latitude.toStringAsFixed(4)}, ${selectedPosition.longitude.toStringAsFixed(4)}'
          : selectedAddress,
    });
  }

  void _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Mettre à jour la position sélectionnée
      final newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        selectedPosition = newPosition;
        selectedAddress = 'Chargement de l\'adresse...';
        isLoading = false;
        searchResults = [];
      });

      // Animer vers la position
      mapController.move(selectedPosition, 16.0);

      // Obtenir l'adresse
      _reverseGeocode(newPosition);

      Get.snackbar(
        'Position trouvée',
        'Votre position actuelle a été détectée',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppThemeSystem.successColor.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        'Erreur',
        'Impossible de récupérer votre position actuelle',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppThemeSystem.errorColor,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.primaryTextColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Sélectionner la position',
          style: context.h5.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.my_location,
              color: AppThemeSystem.primaryColor,
            ),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte OpenStreetMap
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: selectedPosition,
              initialZoom: 15.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.asso',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: selectedPosition,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Barre de recherche en haut
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Champ de recherche
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une adresse...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: AppThemeSystem.primaryColor),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  searchResults = [];
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      _searchLocation(value);
                    },
                    onSubmitted: (value) {
                      _searchLocation(value);
                    },
                  ),

                  // Résultats de recherche
                  if (isSearching)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppThemeSystem.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (searchResults.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final result = searchResults[index];
                          return ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: AppThemeSystem.primaryColor,
                            ),
                            title: Text(
                              result['display_name'],
                              style: const TextStyle(fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSearchResult(result),
                            dense: true,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Indicateur de chargement
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppThemeSystem.primaryColor,
                  ),
                ),
              ),
            ),

          // Panneau d'information en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(context.horizontalPadding),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      'Position sélectionnée',
                      style: context.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.elementSpacing * 0.5),

                    // Adresse ou coordonnées
                    Container(
                      padding: EdgeInsets.all(context.horizontalPadding * 0.75),
                      decoration: BoxDecoration(
                        color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                        borderRadius: context.borderRadius(BorderRadiusType.medium),
                        border: Border.all(
                          color: AppThemeSystem.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppThemeSystem.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedAddress.isEmpty
                                  ? 'Appuyez sur la carte pour sélectionner'
                                  : selectedAddress,
                              style: context.body2.copyWith(
                                color: context.primaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.elementSpacing),

                    // Bouton de confirmation
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedAddress.isEmpty ? null : _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeSystem.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: context.verticalPadding * 0.75,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: context.borderRadius(BorderRadiusType.medium),
                          ),
                        ),
                        child: Text(
                          'Confirmer cette position',
                          style: context.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
