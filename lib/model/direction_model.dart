import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;
  final String start;
  final String end;
  final int dis_num;
  final int dur_num;

  const Directions(
      {required this.bounds,
      required this.polylinePoints,
      required this.totalDistance,
      required this.totalDuration,
      required this.start,
      required this.end,
      required this.dis_num,
      required this.dur_num});

  factory Directions.fromMap(Map<String, dynamic> map) {
    // Check if route is not available
    if ((map['routes'] as List).isEmpty) ;

    // Get route information
    final data = Map<String, dynamic>.from(map['routes'][0]);

    // Bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    String distance = '';
    String duration = '';
    String start = '';
    String end = '';
    int dur_num = 0;
    int dis_num = 0;

    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
      start = leg['start_address'];
      end = leg['end_address'];
      dis_num = leg['distance']['value'];
      dur_num = leg['duration']['value'];
    }

    return Directions(
        bounds: bounds,
        polylinePoints: PolylinePoints()
            .decodePolyline(data['overview_polyline']['points']),
        totalDistance: distance,
        totalDuration: duration,
        start: start,
        end: end,
        dis_num: dis_num ,
        dur_num: dur_num);
  }
}
