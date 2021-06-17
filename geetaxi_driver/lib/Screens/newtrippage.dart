import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geetaxi_driver/datamodels/tripdetails.dart';
import 'package:geetaxi_driver/globalvaribles.dart';
import 'package:geetaxi_driver/helpers/helpermethods.dart';
import 'package:geetaxi_driver/helpers/mapkithelper.dart';
import 'package:geetaxi_driver/widgets/Collectpaymentdialog.dart';
import 'package:geetaxi_driver/widgets/ProgressDialog.dart';
import 'package:geetaxi_driver/widgets/TaxiButton.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTripPage extends StatefulWidget {


  final TripDetails tripDetails;
  NewTripPage({this.tripDetails});


  @override
  _NewTripPageState createState() => _NewTripPageState();
}


class _NewTripPageState extends State<NewTripPage> {

  GoogleMapController rideMapController;
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _marker = Set<Marker>();
  Set<Circle> _circle = Set<Circle>();
  Set<Polyline> _polyline = Set<Polyline>();



  List<LatLng> polylineCoordinate = [];
  PolylinePoints polylinePoints = PolylinePoints();

  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor movingMarkerIcon;

  Position myPosition;

  String status = 'accepted';
  String durationString = '';

  bool isRequestingDirection =false;
  String buttonTitle = "ARRIVED";
  Color buttonColor = Colors.black;

  Timer timer;
  int durationCounter = 0;





  void createMarker(){
    if(movingMarkerIcon == null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context , size:Size(2,2));

      BitmapDescriptor.fromAssetImage( imageConfiguration, 'images/car_android.png').then((icon){
        movingMarkerIcon = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acceptTrip();
  }



  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
     body: Stack(
       children: [
         GoogleMap(
           padding: EdgeInsets.only(bottom: 260),
           myLocationEnabled: true,
           myLocationButtonEnabled: true,
           // trafficEnabled: true,

           zoomGesturesEnabled: true,
           zoomControlsEnabled: true,
           mapType: MapType.normal,
           circles: _circle,
           markers: _marker,
           polylines: _polyline,
           initialCameraPosition: googlePlex,
           onMapCreated: (GoogleMapController controller)async{
             _controller.complete(controller);
             rideMapController= controller;

             var currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
             var pickupLatLng = widget.tripDetails.pickup;

             await getDirection(currentLatLng, pickupLatLng);

             getLocationUpdate();



             // getCurrentPosition();
           },
         ),

         Positioned(
           left: 0,
           right: 0,
           bottom: 0,
           child: Container(
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
               boxShadow: [
                 BoxShadow(
                   color: Colors.black26,
                   blurRadius: 15.0,
                   spreadRadius: 0.5,
                   offset: Offset(
                     0.7,
                     0.7,
                   ),
                 ),
               ],
             ),
             height: Platform.isIOS ?280 : 253,
             child: Padding(
               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     durationString,
                     style: TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.bold,
                       color: Colors.deepPurpleAccent,

                     ),
                   ),

                   SizedBox(height: 5,),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Expanded(
                         child: Container(
                           child: Text(
                             (widget.tripDetails !=null)? widget.tripDetails.riderName :'',
                             // 'User Name',
                             style: TextStyle(
                               fontSize: 22,
                               fontWeight: FontWeight.bold,
                             ),


                           ),
                         ),
                       ),
                       Padding(
                         padding: EdgeInsets.only(right: 10),
                         child: Icon(Icons.call),

                       )

                     ],
                   ),

                   SizedBox(height: 25,),

                   Row(
                     children: [
                       Image.asset('images/pickicon.png', height: 16, width: 16,),
                       SizedBox(width: 18,),

                       Expanded(
                         child: Container(
                           child: Text(
                             (widget.tripDetails !=null)? widget.tripDetails.pickupAddress :'',
                             // "pickup Address",
                             style: TextStyle(fontSize: 18),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                       ),
                     ],
                   ),

                   SizedBox(height: 15,),
                   Row(
                     children: [
                       Image.asset('images/desticon.png', height: 16, width: 16,),
                       SizedBox(width: 18,),

                       Expanded(
                         child: Container(
                           child: Text(
                             (widget.tripDetails !=null)? widget.tripDetails.destinationAddress :'',
                             style: TextStyle(fontSize: 18),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                       ),
                     ],
                   ),
                   SizedBox(height: 25,),
                   TaxiButton(
                     title: buttonTitle,
                     color: buttonColor,
                     onPressed: () async{

                       if(status == 'accepted'){
                         status ='arrived';
                         rideRef.child('status').set('arrived');
                         setState(() {
                           buttonTitle = "Start Trip";
                           buttonColor = Colors.green;

                         });

                         HelperMethods.showProgressDialog(context);
                         await getDirection(widget.tripDetails.pickup,  widget.tripDetails.destination);

                         Navigator.pop(context);


                       }
                       else if (status == 'arrived'){
                         status = 'ontrip';
                         rideRef.child('status').set('ontrip');
                         setState(() {
                           buttonTitle = "End RIDE";
                           buttonColor = Colors.red;
                         });
                         startTimer();


                       }
                       else if(status == 'ontrip'){
                         endTrip();
                       }

                     },
                   ),

                 ],
               ),
             ),

           ),
         ),
       ],
     ),
    );
  }

  void acceptTrip(){
    String rideId = widget.tripDetails.rideId;

    rideRef = FirebaseDatabase.instance.reference().child('ride request/$rideId');
    rideRef.child('status').set('accepted');
    rideRef.child('driver_name').set(currentDriverInfo.fullName);
    rideRef.child('car_details').set('${currentDriverInfo.carColor} - ${currentDriverInfo.carModel}');
    rideRef.child('driver_phone').set(currentDriverInfo.phone);
    rideRef.child('driver_id').set(currentDriverInfo.id);

    Map locationMap = {
      'latitude':currentPosition.latitude.toString(),
      'longitude':currentPosition.longitude.toString(),

    };
    
    rideRef.child("driver_location").set(locationMap);

    DatabaseReference historyRef =FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/history/$rideId');

    historyRef.set(true);



  }

  void getLocationUpdate(){

    LatLng oldPosition = LatLng(0, 0);
    

    ridePositionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation).listen((Position position){

      myPosition = position;
      currentPosition = position;
      LatLng pos = LatLng(position.latitude, position.longitude);
      
      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude, oldPosition.longitude, pos.latitude, pos.longitude);


      Marker movingMarker = Marker(
        markerId: MarkerId('moving'),
        position: pos,
        icon: movingMarkerIcon,
        rotation: rotation,
        infoWindow: InfoWindow(title: 'currentLocation')
      );

      setState(() {
        CameraPosition cp = new CameraPosition(target: pos, zoom:17);
        rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));

        _marker.removeWhere((marker) => marker.markerId.value == 'moving');
        _marker.add(movingMarker);

      });

      oldPosition =pos;
      updateTripDetails();

      Map locationMap = {
        'latitude':myPosition.latitude.toString(),
        'longitude': myPosition.longitude.toString(),
      };
      
      rideRef.child('driver_location').set(locationMap);

    });

  }

  void updateTripDetails() async {

    if(!isRequestingDirection){

      isRequestingDirection = true;
      if(myPosition == null){
        return ;
      }

      var positionLatLng= LatLng(myPosition.latitude, myPosition.longitude);

      LatLng destinationLatLng ;
      if(status == 'accepted'){
        destinationLatLng = widget.tripDetails.pickup;
      }
      else{
        destinationLatLng= widget.tripDetails.destination;
      }

      var directionDetails = await HelperMethods.getDirectionDetails(positionLatLng, destinationLatLng);

      if(directionDetails != null){
        setState(() {
          durationString = directionDetails.durationText;
        });
      }

      isRequestingDirection = false;

    }



  }

  Future getDirection(LatLng pickLatLng, LatLng destinationLatLng)async{

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext)=> ProgressDialog(status: 'Please Wait...',)
    );

    var thisDetails =await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);

    Navigator.pop(context);



    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =polylinePoints.decodePolyline(thisDetails.encodedPoints);


    polylineCoordinate.clear();
    if(results.isNotEmpty){

      results.forEach((PointLatLng point){
        polylineCoordinate.add(LatLng(point.latitude, point.longitude));



      });
    }

   _polyline.clear();
    setState(() {
      print(polylineCoordinate);
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),


        color: Colors.blue,
        points: polylineCoordinate,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,

      );
      _polyline.add(polyline);

    });

    LatLngBounds bounds;

    if(pickLatLng.latitude>destinationLatLng.latitude && pickLatLng.longitude>destinationLatLng.longitude){
      bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);

    }
    else if(pickLatLng.longitude>destinationLatLng.longitude){
      bounds = LatLngBounds(southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude,pickLatLng.longitude));

    }
    else if(pickLatLng.latitude > destinationLatLng.latitude){
      bounds = LatLngBounds(southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude,destinationLatLng.longitude));

    }
    else{
      bounds= LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }

    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));


    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),


    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),



    );
    setState(() {
      _marker.add(pickupMarker);
      _marker.add(destinationMarker);

    });


    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: Colors.lightGreen,


    );
    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: Colors.purpleAccent,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: Colors.purpleAccent,


    );

    setState(() {

      _circle.add(pickupCircle);
      _circle.add(destinationCircle);
    });
  }
void startTimer(){
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter++;
    });

}

void endTrip() async{
    timer.cancel();
    HelperMethods.showProgressDialog(context);

    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);

    var directionDetails = await HelperMethods.getDirectionDetails(widget.tripDetails.pickup, currentLatLng);

    Navigator.pop(context);

    int fares = HelperMethods.estimateFares(directionDetails, durationCounter);

    rideRef.child('fares').set(fares.toString());
    
    rideRef.child('status').set('ended');

    ridePositionStream.cancel();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)=> CollectPayment(
          paymentMethod: widget.tripDetails.paymentMethod,
          fares:fares,
        ));
    topUpEarning(fares);

}


void topUpEarning(int fares){
    
    DatabaseReference earningRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/earning');
    earningRef.once().then((DataSnapshot snapshot){
      if(snapshot.value !=null){
        double oldEarning =double.parse(snapshot.value.toString());
        double adjustedEarning = (fares.toDouble()*0.85)+oldEarning;
        earningRef.set(adjustedEarning.toStringAsFixed(2));

      }
      else{
        double adjustedEarning = (fares.toDouble()*0.85);
        earningRef.set(adjustedEarning.toStringAsFixed(2));
      }
    });
}
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GoogleMapController>('mapController', rideMapController));
  }
}
