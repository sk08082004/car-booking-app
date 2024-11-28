import 'package:flutter/cupertino.dart';
import 'package:user_app/models/directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, UserDropOffLocation;
  int countTotalTrips = 0;

  void updatePickkUpLocationAddress(Directions userPickUpAddress){
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions userDropOffAddress){
    UserDropOffLocation = userDropOffAddress;
    notifyListeners();
  }
}
