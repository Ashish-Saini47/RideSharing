import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geetaxi_driver/Screens/LoginPage.dart';
import 'package:geetaxi_driver/Screens/MainScreen.dart';
import 'package:geetaxi_driver/Screens/Registration.dart';
import 'package:geetaxi_driver/Screens/vehicleinfo.dart';


import 'globalvaribles.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'db2',
    options: Platform.isIOS || Platform.isMacOS
        ? const FirebaseOptions(
      appId: '1:297855924061:ios:c6de2b69b03a5be8',
      apiKey: 'AIzaSyCkpbq0fagejjnBSr7n-mdMx7FmnMombxU',
      projectId: 'flutter-firebase-plugins',
      messagingSenderId: '297855924061',
      databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
    )
        : const FirebaseOptions(
      appId: '1:113910703201:android:9f8fd8abdfa52debde3620',
      apiKey: 'AIzaSyCkpbq0fagejjnBSr7n-mdMx7FmnMombxU',
      messagingSenderId: '113910703201',
      projectId: 'geetaxi-7c517',
      databaseURL: 'https://geetaxi-7c517-default-rtdb.firebaseio.com/',
    ),
  );
  currentFirebaseUser = await FirebaseAuth.instance.currentUser;


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      initialRoute: (currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
      routes: {
        MainPage.id: (context)=> MainPage(),
        RegistrationPage.id: (context)=> RegistrationPage(),
        VehicleInfoPage.id: (context)=> VehicleInfoPage(),
        LoginPage.id: (context)=> LoginPage(),

      },
    );
  }
}

