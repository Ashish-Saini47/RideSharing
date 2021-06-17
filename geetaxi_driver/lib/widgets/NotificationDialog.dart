import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geetaxi_driver/Screens/newtrippage.dart';
import 'package:geetaxi_driver/datamodels/tripdetails.dart';
import 'package:geetaxi_driver/globalvaribles.dart';
import 'package:geetaxi_driver/helpers/helpermethods.dart';
import 'package:geetaxi_driver/widgets/BrandDivider.dart';
import 'package:geetaxi_driver/widgets/ProgressDialog.dart';
import 'package:geetaxi_driver/widgets/TaxiButton.dart';
import 'package:geetaxi_driver/widgets/TaxiOutlineButton.dart';

class NotificationDialog extends StatelessWidget {


  final TripDetails tripDetails;
  NotificationDialog({
    this.tripDetails
});


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),


      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:   BorderRadius.circular(4),

        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30.0,),
            Image.asset('images/taxi.png', width: 100,),
            SizedBox(height: 16,),
            Text("New Trip Request", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            SizedBox(height: 30.0,),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('images/pickicon.png',height: 16,width: 16,),
                      SizedBox(width: 18,),
                      Expanded(child: Container(child: Text((tripDetails!=null)?tripDetails.pickupAddress:'', style: TextStyle(fontSize: 18),)))


                    ],

                  ),
                  SizedBox(height: 15,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('images/desticon.png',height: 16,width: 16,),
                      SizedBox(width: 18,),
                      Expanded(child: Container(child: Text((tripDetails!=null)?tripDetails.destinationAddress:'', style: TextStyle(fontSize: 18),)))


                    ],

                  ),

                ],
              ),
            ),
            BrandDivider(),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Container(
                        child: TaxiOutlineButton(
                          title: 'DECLINE',
                          color: Colors.grey,
                          onPressed:() async {
                            // assetsAudioPlayer.stop();
                            Navigator.pop(context);

                          },

                        ),

                  ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Container(
                      child: TaxiButton(
                        title: 'ACCEPT',
                        color: Colors.green,
                        onPressed:() async {

                          // assetsAudioPlayer.stop();

                          checkAvailablity(context);
                          Navigator.pop(context);

                        },

                      ),

                    ),
                  ),
                ],

              ),
            )
          ],
        ),
      ),
    );
  }

  void checkAvailablity(context){

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: "Accepting Request",),
    );
    DatabaseReference newRideRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newtrip');
    newRideRef.once().then((DataSnapshot snapshot){

      Navigator.pop(context);
      String thisRideId ="";
      if(snapshot != null){
        thisRideId = snapshot.value.toString();
      }
      else{
        print('ride not found');
      }

      if(thisRideId == tripDetails.rideId){
        newRideRef.set("accepted");
        HelperMethods.disableHomeTabLocationUpdate();
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewTripPage(tripDetails: tripDetails,)),
        );
        
      }
      else if(thisRideId == 'cancelled'){
        print('ride has been cancelled');
      }
      else if(thisRideId == 'timeout'){
        print('ride has been timeout');

      }
      else{
        print('ride not found');
      }
    });

  }
}
