import 'dart:async';
import 'dart:typed_data';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hike_app/model/direction_model.dart';
import 'package:hike_app/screens/planhike_page.dart';
import 'package:hike_app/service/direction_map.dart';
import 'package:intl/intl.dart';

class map_page extends StatefulWidget {
  final int? hike_id;
  final bool? is_edit;

  map_page({super.key, this.hike_id, this.is_edit});

  @override
  State<map_page> createState() => _map_pageState();
}

class _map_pageState extends State<map_page> {
  late GoogleMapController _controller;

  LatLng? _currentPosition;
  bool _isLoading = true;
  bool is_mark = false;

  Marker? origin;
  Marker? destination;
  Directions? direct;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  void _addMarker(LatLng pos) async {
    if (origin == null || (origin != null && destination != null)) {
      setState(() {
        origin = Marker(
            markerId: MarkerId('origin'),
            infoWindow: InfoWindow(title: 'Start location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos);
        destination = null;
        direct = null;
        is_mark = true;
      });
    } else {
      setState(() {
        destination = Marker(
            markerId: MarkerId('destination'),
            infoWindow: InfoWindow(title: 'Finish location'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: pos);
      });

      // Get directions
      final directions = await DirectionsRepository().getDirections(
        origin: origin!.position,
        destination: pos,
      );
      setState(() => direct = directions);

      double midlat =
          (origin!.position.latitude + destination!.position.latitude) / 2;
      double midlong =
          (origin!.position.longitude + destination!.position.longitude) / 2;

      LatLng midlatlng = LatLng(midlat, midlong);

      _controller.animateCamera(CameraUpdate.newLatLngZoom(midlatlng, 9));
    }
  }

  void plan_hike() async {
    if (origin != null && destination != null && direct != null) {
      if (widget.is_edit == true) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => planhike_page(
                is_edit: widget.is_edit,
                hike_id: widget.hike_id,
                start_hike: direct!.start,
                end_hike: direct!.end,
                length_hike: (direct!.dis_num / 1000).toStringAsFixed(2),
                duration_hike: ((direct!.dur_num / 60) / 60).toStringAsFixed(2),
              ),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => planhike_page(
                start_hike: direct!.start,
                end_hike: direct!.end,
                length_hike: (direct!.dis_num / 1000).toStringAsFixed(2),
                duration_hike: ((direct!.dur_num / 60) / 60).toStringAsFixed(2),
              ),
            ));
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Please point origin and destination mark"),
      action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }),
    ));
  }

  getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    setState(() {
      _currentPosition = location;
      _isLoading = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(alignment: Alignment.center, children: [
        _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition:
                    CameraPosition(target: _currentPosition!, zoom: 5),
                compassEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: _onMapCreated,
                onLongPress: _addMarker,
                markers: {
                  if (origin != null) origin!,
                  if (destination != null) destination!
                },
                polylines: {
                  if (direct != null)
                    Polyline(
                      polylineId: const PolylineId('overview_polyline'),
                      color: Colors.blue,
                      width: 5,
                      points: direct!.polylinePoints
                          .map((e) => LatLng(e.latitude, e.longitude))
                          .toList(),
                    )
                },
              ),
        if (direct != null)
          Positioned(
            top: 65.0,
            child: Column(
              children: [
                Container(
                  width: 400,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'From: ',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${direct!.start}',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            'To: ',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${direct!.end}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: Text(
                    '${direct!.totalDistance}, ${direct!.totalDuration}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          bottom: 85,
          right: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  if (_controller != null) {
                    _controller.animateCamera(
                      CameraUpdate.zoomIn(), // Zoom in
                    );
                  }
                },
                child: Icon(Icons.add),
              ),
              SizedBox(height: 16.0),
              FloatingActionButton(
                onPressed: () {
                  if (_controller != null) {
                    _controller.animateCamera(
                      CameraUpdate.zoomOut(), // Zoom out
                    );
                  }
                },
                child: Icon(Icons.remove),
              ),
            ],
          ),
        ),
        if (is_mark == false)
          Positioned(
              top: 350,
              child: Container(
                width: 216,
                height: 35,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(20)),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText('Hold to mark a point',
                          textStyle: TextStyle(color: Colors.black)),
                    ],
                    repeatForever: true,
                  ),
                ),
              )),
        Positioned(
            bottom: 10,
            left: 10,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                setState(() {
                  direct = null;
                  origin = null;
                  destination = null;
                });
              },
              backgroundColor: Colors.red,
              child: Text('Clear'),
            )),
        Positioned(
            bottom: 15,
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  plan_hike();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.black,
                    ),
                    Text(
                      'Plan hike',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    )
                  ],
                ),
              ),
            ))
      ]),
    );
  }
}
