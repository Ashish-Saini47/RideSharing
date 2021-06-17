import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'datamodels/user.dart';

String serverKey = 'key=AAAAGoWbZGE:APA91bH1wLDBji5KdI9troueJQmhhlTGTRUSaI32yhbM9oiYHANZ4OOJGAcdqdZ0mH9WGkqjlFLvELYgYFyTa7NFvflHWdTRGaAAXiN5BewFhpANGo3WXS7njR9pU-qlnAIksPaYbIAe';


String mapKey="AIzaSyCkpbq0fagejjnBSr7n-mdMx7FmnMombxU";

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

User currentFirebaseUser;

user currentUserInfo;