

import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geetaxi_driver/datamodels/directiondetails.dart';
import 'package:geetaxi_driver/globalvaribles.dart';
import 'package:geetaxi_driver/helpers/rewuesthelper.dart';
import 'package:geetaxi_driver/widgets/ProgressDialog.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HelperMethods{



  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async{
    String url ="https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&key=$mapKey";
    var response = await RequestHelper.getRequest(url);

    if(response == 'failed'){
      return null;
    }

    DirectionDetails directionDetails= DirectionDetails();
    directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];
    directionDetails.distanceText=response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue=response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints=response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }

  static int estimateFares(DirectionDetails details, int durationValue){
    //double baseFare = 30;
    double distanceFare = (details.distanceValue/1000)*7;
    double timeFare = (durationValue/60)*0.2;

   double totalFare = distanceFare + timeFare ;
 //    double totalFare = distanceFare + timeFare;
    return totalFare.truncate();

  }


  static double generateRandomNumber(int max){
    var randomGenerator = Random();
    int radInt = randomGenerator.nextInt(max);

    return radInt.toDouble();

  }

  static void disableHomeTabLocationUpdate(){
    homeTabPositionStream.pause();
    Geofire.removeLocation(currentFirebaseUser.uid);


  }

  static void enableHomeTabLocationUpdate(){

    homeTabPositionStream.resume();
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

  }

  static void showProgressDialog(context){
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: "Please wait",));
  }



}