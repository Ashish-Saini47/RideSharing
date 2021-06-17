import 'dart:async';

// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'datamodels/driver.dart';

User currentFirebaseUser;
final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

String mapKey="AIzaSyCkpbq0fagejjnBSr7n-mdMx7FmnMombxU";

DatabaseReference tripRequestRef;

StreamSubscription<Position> homeTabPositionStream;

StreamSubscription<Position> ridePositionStream;



Position currentPosition;
DatabaseReference rideRef;

Driver currentDriverInfo;



// final assetsAudioPlayer = AssetsAudioPlayer();