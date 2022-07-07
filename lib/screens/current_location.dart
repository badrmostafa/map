import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({Key? key}) : super(key: key);

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  late GoogleMapController mapController;
  static const initialCameraPposition =
      CameraPosition(target: LatLng(30.0444, 31.2357), zoom: 14);

  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.amber.shade500),
          backgroundColor: Colors.white24,
          title: Text('User Current Location',
              style: TextStyle(color: Colors.amber.shade500))),
      body: Container(
        padding: const EdgeInsets.only(bottom: 70),
        decoration: const BoxDecoration(),
        child: GoogleMap(
          initialCameraPosition: initialCameraPposition,
          markers: markers,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
          onMapCreated: (controller) {
            mapController = controller;
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.white30,
          onPressed: () async {
            Position position = await determinePosition();
            mapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 14)));
            markers.clear();
            markers.add(Marker(
                markerId: const MarkerId('currentLocation'),
                position: LatLng(position.latitude, position.longitude)));

            setState(() {});
          },
          label: Text('Current User Location',
              style: TextStyle(color: Colors.amber.shade500)),
          icon: Icon(Icons.location_history, color: Colors.amber.shade500)),
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled == false) {
      return Future.error('Location Services are Disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission Denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location Permission Permennant Denied');
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
