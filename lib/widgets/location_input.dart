import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:newplaces/screens/map.dart';

import '../models/place.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});
  final void Function(PlaceLocation placeLocation) onSelectLocation;
  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String get locationImage {
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyCSvRdptkNiDfOEMoepzoRPVVLQDjysIr8';
  }

  PlaceLocation? _pickedLocation;
  var isGettingLocation = false;
  void getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      isGettingLocation = true;
    });
    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    if (lat == null || lng == null) {
      return;
    }
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyCSvRdptkNiDfOEMoepzoRPVVLQDjysIr8');
    final response = await http.get(url);
    final resData = jsonDecode(response.body);
    final address = resData['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation =
          PlaceLocation(latitude: lat, longitude: lng, address: address);
      isGettingLocation = false;
    });
    print(locationData.latitude);
    print(locationData.longitude);
    widget.onSelectLocation(
      _pickedLocation!,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Text(
      'No location chosen!',
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onBackground),
    );
    if (_pickedLocation != null) {
      content = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (isGettingLocation) {
      content = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: content,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: getLocation,
              icon: const Icon(Icons.location_pin),
              label: const Text('Get current location'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapScreen(
                              location: _pickedLocation!,
                              isSelecting: true,
                            )));
              },
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            )
          ],
        )
      ],
    );
  }
}
