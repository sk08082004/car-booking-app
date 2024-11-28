import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_app/infoHandler/app_info.dart';
import 'package:user_app/methods/common_methods.dart';
import 'package:user_app/methods/direction_details_info.dart';
import 'package:user_app/models/directions.dart';
import 'package:user_app/pages/drawer_screen.dart';
import 'package:user_app/pages/search_places.dart';
import 'package:user_app/widgets/progress_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controllerGoogleMaps = Completer();
  GoogleMapController? newGoogleMapController;

  Position? userCurrentPosition;
  LatLng? pickLocation;
  String? _address;
  String? _destinationAddress;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Set<Polyline> polylineSet = {};
  Timer? _debounce;

  String? selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndLocateUser();
  }

  Future<void> _checkLocationPermissionAndLocateUser() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission is required")),
      );
      return;
    }
    locateUserPosition();
  }

  Future<void> locateUserPosition() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ProgressDialog(message: "Locating you..."),
      );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userCurrentPosition = position;
      LatLng latLng = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 15);
      newGoogleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );

      String address = await CommonMethods()
          .searchAddressForGeographicCoordinates(position, context);

      setState(() {
        _address = address;
      });
    } catch (e) {
      print("Error locating user: $e");
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).UserDropOffLocation;

    if (originPosition == null || destinationPosition == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProgressDialog(message: "Finding route..."),
    );

    try {
      DirectionDetailsInfo? directionDetails = await CommonMethods()
          .obtainOriginToDirectionDetails(originPosition, destinationPosition);

      if (directionDetails != null) {
        setState(() {
          polylineSet.clear();
          polylineSet.add(
            Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.blue,
              points: directionDetails.ePoints
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList(),
            ),
          );
        });
      }
    } catch (e) {
      print("Error fetching route: $e");
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldState,
        drawer: const DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.terrain,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              polylines: polylineSet,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (controller) {
                _controllerGoogleMaps.complete(controller);
                newGoogleMapController = controller;
                locateUserPosition();
              },
            ),
            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () => _scaffoldState.currentState?.openDrawer(),
                child: CircleAvatar(
                  backgroundColor:
                      darkTheme ? Colors.amber.shade400 : Colors.grey.shade200,
                  child: Icon(
                    Icons.menu,
                    color: darkTheme ? Colors.black : Colors.blue,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Location Display
                    TextField(
                      controller: TextEditingController(text: _address),
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "From: Your current location",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon:
                            const Icon(Icons.location_on, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Destination Selection
                    GestureDetector(
                      onTap: () async {
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchPlacesScreen(),
                          ),
                        );
                        if (result != null && result is Directions) {
                          setState(() {
                            _destinationAddress = result.locationName;
                          });
                          Provider.of<AppInfo>(context, listen: false)
                              .updateDropOffLocationAddress(result);
                          await drawPolyLineFromOriginToDestination();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.blue),
                            const SizedBox(width: 10),
                            Text(
                              _destinationAddress ?? "To: Enter your destination",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Payment Method Selection
                    Text(
                      "Payment Method:",
                      style: TextStyle(
                        fontSize: 16,
                        color: darkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PaymentMethodOption(
                          label: "Cash",
                          isSelected: selectedPaymentMethod == "Cash",
                          onTap: () {
                            setState(() {
                              selectedPaymentMethod = "Cash";
                            });
                          },
                        ),
                        PaymentMethodOption(
                          label: "Card",
                          isSelected: selectedPaymentMethod == "Card",
                          onTap: () {
                            setState(() {
                              selectedPaymentMethod = "Card";
                            });
                          },
                        ),
                        PaymentMethodOption(
                          label: "AutoPay",
                          isSelected: selectedPaymentMethod == "AutoPay",
                          onTap: () {
                            setState(() {
                              selectedPaymentMethod = "AutoPay";
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Find Driver Button
                    ElevatedButton(
                      onPressed: () async {
                        if (_destinationAddress == null ||
                            _destinationAddress!.isEmpty) {
                          CommonMethods().displaySnackBar(
                              "Please enter a destination", context);
                          return;
                        }
                        if (selectedPaymentMethod == null ||
                            selectedPaymentMethod!.isEmpty) {
                          CommonMethods().displaySnackBar(
                              "Please select a payment method", context);
                          return;
                        }
                        CommonMethods().showLoadingDialog(
                            "Finding Nearby Driver...", context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "Find Driver",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
