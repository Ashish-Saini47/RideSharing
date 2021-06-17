

import 'dart:convert';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geetaxi/datamodels/address.dart';
import 'package:geetaxi/datamodels/directiondetails.dart';
import 'package:geetaxi/datamodels/user.dart';
import 'package:geetaxi/dataprovider/appdata.dart';
import 'package:geetaxi/helpers/rewuesthelper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../globalvaribales.dart';

class HelperMethods{

  static void getCurrentUserInfo() async{
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    String userid = currentFirebaseUser.uid;
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('user/$userid');
    userRef.once().then((DataSnapshot snapshot){
      if(snapshot.value !=null){
        currentUserInfo = user.fromSnapshot(snapshot);
        print('my name is ${currentUserInfo.fullName}');

      }
    });


  }

  static Future<dynamic> findCordinateAddress(Position position,  context) async{
    String placeAddress = '';


    var connectivityResult= await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
      return placeAddress;
    }

   // Uri url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey');

    String url ='https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    if(response != 'failed'){
      placeAddress = response['results'][0]['formatted_address'];
      Address pickupAddress = new Address();


      pickupAddress.longitude= position.longitude;
      pickupAddress.latitude=position.latitude;
      pickupAddress.placeName=placeAddress;


      Provider.of<AppData>(context, listen: false).updatePickupAddress(pickupAddress);



    }
    return placeAddress;

  }
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

  static int estimateFares(DirectionDetails details){
    //double baseFare = 30;
    double distanceFare = (details.distanceValue/1000)*7;
    double timeFare = (details.durationValue/60)*8;

 //   double totalFare = baseFare+ distanceFare + timeFare ;
    double totalFare = distanceFare + timeFare;
    return totalFare.truncate();

  }


  static double generateRandomNumber(int max){
    var randomGenerator = Random();
    int radInt = randomGenerator.nextInt(max);

    return radInt.toDouble();

  }


  static sendNotification(String token, context, String ride_id) async{

    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

    
    Map<String, String> headerMap={
      'Content-Type': 'application/json',
      'Authorization': serverKey,
    };
    
    Map notificationMap ={
      'title': 'NEW TRIP REQUEST',
      'body': "Destination, ${destination.placeName}"
    };

    Map dataMap ={
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_id': ride_id,

    };

    Map bodyMap = {
      'notification':notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to':token,
    };
    String uri ='https://fcm.googleapis.com/fcm/send';
    Uri url =Uri.parse(uri);
    var response = await http.post(
      url,
      headers: headerMap,
      body: jsonEncode(bodyMap),

    );

    print(response.body);

  }


}