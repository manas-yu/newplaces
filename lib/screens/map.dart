// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:newplaces/models/place.dart';

class MapScreen extends StatefulWidget {
  MapScreen({Key? key, required this.location, required this.isSelecting})
      : super(key: key);
  PlaceLocation location =
      PlaceLocation(latitude: 37, longitude: 122, address: '');
  bool isSelecting = true;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

LatLng? pickedPlace;

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'Select Your Location' : 'Your Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.location.latitude,
            widget.location.longitude,
          ),
        ),
        markers: {
          Marker(
            markerId: MarkerId('m1'),
            position: LatLng(
              widget.location.latitude,
              widget.location.longitude,
            ),
          ),
        },
      ),
    );
  }
}
