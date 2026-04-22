import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:takash/shared/widgets/takash_icon.dart';
import '../data/location_service.dart';
import '../../listings/presentation/listings_controller.dart';
import '../../listings/domain/listing_model.dart';
import '../../listings/presentation/widgets/listing_card.dart';
import 'package:takash/shared/widgets/loading_indicator.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  mapbox.MapboxMap? _mapboxMap;
  mapbox.CircleAnnotationManager? _circleAnnotationManager;
  List<ListingModel> _currentListings = [];
  final Map<String, String> _markerToListing = {};

  @override
  void dispose() {
    _mapboxMap = null;
    _circleAnnotationManager = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(userLocationProvider);

    ref.listen(nearbyListingsProvider, (previous, next) {
      if (next is AsyncData && _circleAnnotationManager != null) {
        _currentListings = next.value!;
        _updateMarkers(_currentListings);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yakınımdakiler'),
        actions: [
          IconButton(
            icon: const TakashIcon(assetName: TakashIcon.myLocation),
            onPressed: () => _centerOnUser(),
          ),
        ],
      ),
      body: locationAsync.when(
        data: (position) {
          if (position == null) {
            return _buildPermissionDenied();
          }
          return mapbox.MapWidget(
            key: ValueKey('mapbox_widget_${GoRouterState.of(context).uri}'),
            styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
            onMapCreated: (mapboxMap) {
              _mapboxMap = mapboxMap;
            },
            onStyleLoadedListener: (styleLoadedEvent) async {
              _circleAnnotationManager =
                  await _mapboxMap?.annotations.createCircleAnnotationManager();

              _circleAnnotationManager?.addOnCircleAnnotationClickListener(
                _MarkerClickListener(
                  onMarkerTap: (listingId) => _showListingSummary(listingId),
                  markerMap: _markerToListing,
                ),
              );

              try {
                await _mapboxMap?.location.updateSettings(
                  mapbox.LocationComponentSettings(
                      enabled: true, pulsingEnabled: true),
                );
              } catch (_) {}

              _centerOnUser();

              final listings = ref.read(nearbyListingsProvider).value;
              if (listings != null) {
                _currentListings = listings;
                _updateMarkers(listings);
              }
            },
            cameraOptions: mapbox.CameraOptions(
              center: mapbox.Point(
                  coordinates:
                      mapbox.Position(position.longitude, position.latitude)),
              zoom: 11.0,
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Konum alınıyor...'),
        error: (err, stack) {
          debugPrint('Konum hatası: $err');
          return _buildPermissionDenied();
        },
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TakashIcon(
                assetName: TakashIcon.locationOff,
                size: 64,
                color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Konum izni gerekli',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Yakınızdaki ilanları görmek için konum servisini açın ve izin verin.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  bool serviceEnabled =
                      await Geolocator.isLocationServiceEnabled();
                  if (!serviceEnabled) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Konum servisi kapalı. Lütfen konumu açın.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                    await Geolocator.openLocationSettings();
                    return;
                  }

                  LocationPermission permission =
                      await Geolocator.checkPermission();

                  if (permission == LocationPermission.deniedForever) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Konum izni için Ayarlar → Takaş → İzinler'),
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                    await Geolocator.openAppSettings();
                    return;
                  }

                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                  }

                  if (permission == LocationPermission.whileInUse ||
                      permission == LocationPermission.always) {
                    if (mounted) {
                      ref.invalidate(userLocationProvider);
                      ref.invalidate(nearbyListingsProvider);
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Konumu Aç'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // İzin olmadan tüm ilanları göster
                ref.invalidate(userLocationProvider);
              },
              child: const Text('İzinsiz devam et'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateMarkers(List<ListingModel> listings) async {
    if (_circleAnnotationManager == null || !mounted) return;

    try {
      await _circleAnnotationManager?.deleteAll();
      _markerToListing.clear();

      final List<mapbox.CircleAnnotationOptions> options = [];

      for (final listing in listings) {
        if (listing.location != null) {
          options.add(
            mapbox.CircleAnnotationOptions(
              geometry: mapbox.Point(
                coordinates: mapbox.Position(
                    listing.location!.longitude, listing.location!.latitude),
              ),
              circleColor: const Color(0xFF2E7D32).value, // Takash Yeşili
              circleRadius: 10.0,
              circleStrokeColor: Colors.white.value,
              circleStrokeWidth: 3.0,
            ),
          );
        }
      }

      if (options.isNotEmpty) {
        final annotations =
            await _circleAnnotationManager?.createMulti(options);
        if (annotations != null) {
          for (int i = 0; i < annotations.length; i++) {
            if (annotations[i] != null) {
              _markerToListing[annotations[i]!.id] = listings[i].id;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('📍 [MapScreen] Marker hatası: $e');
    }
  }

  void _showListingSummary(String listingId) {
    try {
      final listing = _currentListings.firstWhere((l) => l.id == listingId);
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2))),
              ListingCard(
                  listing: listing,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/listing/${listing.id}');
                  }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    } catch (_) {}
  }

  void _centerOnUser() {
    final position = ref.read(userLocationProvider).value;
    if (position != null && _mapboxMap != null) {
      _mapboxMap?.setCamera(mapbox.CameraOptions(
          center: mapbox.Point(
              coordinates:
                  mapbox.Position(position.longitude, position.latitude)),
          zoom: 12.0));
    }
  }
}

class _MarkerClickListener extends mapbox.OnCircleAnnotationClickListener {
  final Function(String) onMarkerTap;
  final Map<String, String> markerMap;
  _MarkerClickListener({required this.onMarkerTap, required this.markerMap});
  @override
  bool onCircleAnnotationClick(mapbox.CircleAnnotation annotation) {
    final listingId = markerMap[annotation.id];
    if (listingId != null) onMarkerTap(listingId);
    return true;
  }
}
