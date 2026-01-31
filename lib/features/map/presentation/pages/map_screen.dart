import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/map_service.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map';
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Example coordinates; in real use these should come from parcel data
  final LatLng _origin = const LatLng(27.7172, 85.3240); // Kathmandu
  LatLng? _destination = const LatLng(27.6720, 85.3219);

  // API key is read from .env (GOOGLE_MAPS_API_KEY). Create .env at project root.

  @override
  void initState() {
    super.initState();
    _setInitialMarkers();
  }

  void _setInitialMarkers() {
    _markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: _origin,
        infoWindow: const InfoWindow(title: 'Pickup'),
      ),
    );
    if (_destination != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination!,
          infoWindow: const InfoWindow(title: 'Dropoff'),
        ),
      );
    }
  }

  Future<void> _drawRoute() async {
    if (_destination == null) return;
    final coords = await MapService.getRouteCoordinates(
      origin: _origin,
      destination: _destination!,
    );

    if (coords.isEmpty) return;

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      width: 5,
      points: coords,
    );

    setState(() {
      _polylines.clear();
      _polylines.add(polyline);
    });

    final controller = await _controller.future;
    final bounds = _boundsFromLatLngList(coords);
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (final latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialCamera = CameraPosition(
      target: _origin ?? const LatLng(0, 0),
      zoom: 12,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Map / Route')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCamera,
            myLocationEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onLongPress: (pos) {
              // Toggle setting destination on long press
              setState(() {
                _destination = pos;
                _markers.removeWhere((m) => m.markerId.value == 'destination');
                _markers.add(
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: pos,
                    infoWindow: const InfoWindow(title: 'Dropoff'),
                  ),
                );
              });
            },
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'route',
                  onPressed: _drawRoute,
                  child: const Icon(Icons.alt_route),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'clear',
                  onPressed: () {
                    setState(() {
                      _polylines.clear();
                    });
                  },
                  child: const Icon(Icons.clear),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
