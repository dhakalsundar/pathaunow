import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapService {
  /// Fetch route (polyline) between [origin] and [destination] using
  /// Google Directions API. Provide a valid [apiKey].
  static Future<List<LatLng>> getRouteCoordinates({
    String? apiKey,
    required LatLng origin,
    required LatLng destination,
  }) async {
    final key = apiKey ?? dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (key.isEmpty) return [];

    final url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': key,
      'mode': 'driving',
    });

    final res = await http.get(url);
    if (res.statusCode != 200) return [];

    final data = json.decode(res.body) as Map<String, dynamic>;
    if ((data['routes'] as List).isEmpty) return [];

    final encoded = data['routes'][0]['overview_polyline']['points'] as String;
    final polylinePoints = PolylinePoints.decodePolyline(encoded);

    return polylinePoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);
  }
}
