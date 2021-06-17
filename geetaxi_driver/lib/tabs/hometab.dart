import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geetaxi_driver/globalvaribles.dart';
import 'package:geetaxi_driver/widgets/AvailabilityButton.dart';
import 'package:geetaxi_driver/widgets/ConfirmSheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();



  var geolocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  String availabilityTitle= 'Go Online';
  Color availabilityColor = Colors.green;
  bool isAvailable = false;








  void getCurrentPosition()async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition= position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 18);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 135),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,

          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
            mapController= controller;

            getCurrentPosition();
          },
        ),
        Container(
          height: 135,
          width: double.infinity,
          color: Colors.black,
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: (){
                  showModalBottomSheet(
                      isDismissible: false,
                      context: context,
                      builder: (BuildContext context)=> ConfirmSheet(
                        title: (!isAvailable) ? 'Go Online' : 'Go Offline',
                        subtitle: (!isAvailable) ? 'You are about to become available to receive trip requests' : 'You will stop receiving new trip requests',
                        onPressed: (){
                          if(!isAvailable){
                            GoOnline();
                            getLocationUpdates();
                            Navigator.pop(context);

                            setState(() {
                              availabilityColor = Colors.red;
                              availabilityTitle = 'Go Offline';
                              isAvailable= true;


                            });

                          }
                          else{
                            GoOffline();
                            Navigator.pop(context);
                            setState(() {
                              availabilityColor = Colors.green;
                              availabilityTitle = 'Go Online';
                              isAvailable= false;


                            });



                          }
                        },
                      ));

                 // GoOnline();
                  //getLocationUpdates();
                },

              ),
            ],
          ),
        ),
      ],
    );
  }

  void GoOnline(){
    Geofire.initialize('driverAvailable');
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

    tripRequestRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newtrip');
    tripRequestRef.set('waiting');
    tripRequestRef.onValue.listen((event) {


    });

  }

  void GoOffline(){
    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;
  }
  void getLocationUpdates(){


    homeTabPositionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4).listen((event) async {

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);

      currentPosition = position;
      Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cp = new CameraPosition(target: pos, zoom: 18);
      mapController.animateCamera(CameraUpdate.newCameraPosition(cp));



    });

  }


}
