import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_app/infoHandler/app_info.dart';
import 'package:user_app/methods/common_methods.dart';
import 'package:user_app/models/directions.dart';

class PrecisePickUpScreen extends StatefulWidget {
  const PrecisePickUpScreen({super.key});

  @override
  State<PrecisePickUpScreen> createState() => _PrecisePickUpScreenState();
}

class _PrecisePickUpScreenState extends State<PrecisePickUpScreen> {
  final Completer<GoogleMapController> _controllerGoogleMaps = Completer();
  GoogleMapController? newGoogleMapController;

  Position? userCurrentPosition;
  LatLng? pickLocation;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> locateUserPosition() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userCurrentPosition = currentPosition;
      pickLocation = LatLng(
        userCurrentPosition!.latitude,
        userCurrentPosition!.longitude,
      );
    });
    newGoogleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: pickLocation!,
          zoom: 15,
        ),
      ),
    );
    String address = await CommonMethods()
        .searchAddressForGeographicCoordinates(currentPosition, context);
    Directions userPickUpAddress = Directions(
      locationLatitude: pickLocation!.latitude,
      locationLongitude: pickLocation!.longitude,
      locationName: address,
    );
    Provider.of<AppInfo>(context, listen: false)
        .updatePickkUpLocationAddress(userPickUpAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(top: 30, bottom: 50),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMaps.complete(controller);
              newGoogleMapController = controller;
              locateUserPosition();
            },
            onCameraMove: (CameraPosition position) {
              pickLocation = position.target;
            },
            onCameraIdle: () async {
              if (pickLocation != null) {
                String address = await CommonMethods()
                    .getAddressFromCoordinates(
                        pickLocation!.latitude, pickLocation!.longitude);
                setState(() {
                  Directions userPickUpAddress = Directions(
                    locationLatitude: pickLocation!.latitude,
                    locationLongitude: pickLocation!.longitude,
                    locationName: address,
                  );
                  Provider.of<AppInfo>(context, listen: false)
                      .updatePickkUpLocationAddress(userPickUpAddress);
                });
              }
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Image.asset(
                "assets/images/initial.png",
                height: 45,
                width: 45,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(12),
              child: Consumer<AppInfo>(
                builder: (context, appInfo, child) {
                  String address = appInfo.userPickUpLocation?.locationName ??
                      "Fetching address...";
                  return Text(
                    address.length > 24
                        ? "${address.substring(0, 24)}..."
                        : address,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("Confirm Pickup Location"),
            ),
          ),
        ],
      ),
    );
  }
}
