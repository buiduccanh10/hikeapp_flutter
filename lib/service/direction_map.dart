import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hike_app/service/google_api.dart';

import '../model/direction_model.dart';

class DirectionsRepository {
  static const String base_Url =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio dio;

  DirectionsRepository({Dio? dio}) : dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await dio.get(
      base_Url,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': google_api_key,
      },
    );
    print(response.data);
    // Check if response is successful
    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return null;
  }
}
