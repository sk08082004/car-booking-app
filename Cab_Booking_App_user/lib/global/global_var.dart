import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_app/methods/direction_details_info.dart';
import 'package:user_app/models/user_model.dart';

/// Global Variables
String userName = "";
String googleMapsKey = "Api Key";
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

/// Current User Information
UserModel? userModelCurrentInfo;

DirectionDetailsInfo? tripDirectionDetailsinfo;

/// Drop-off Address
String userDropOffAddress = "";
