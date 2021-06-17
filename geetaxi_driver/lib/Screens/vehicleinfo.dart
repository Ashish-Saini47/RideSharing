import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geetaxi_driver/Screens/MainScreen.dart';
import 'package:geetaxi_driver/globalvaribles.dart';
import 'package:geetaxi_driver/widgets/TaxiButton.dart';

class VehicleInfoPage extends StatelessWidget {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackBar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15), ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  static const String id = 'vehicleinfo';

  var carModelController = TextEditingController();
  var carColorController = TextEditingController();
  var vehicleNumberController = TextEditingController();

  void updateProfile(context){
    String id = currentFirebaseUser.uid;
    DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers/$id/vehicle_details');

    Map map = {
      'car_color':carColorController.text,
      'car_model':carModelController.text,
      'vehicle_number':vehicleNumberController.text,
    };

    driverRef.set(map);
    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Image.asset('images/logo.png', height: 110, width: 110,),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Text('Enter Vehicle Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                    SizedBox(height: 25,),

                    TextField(
                      controller: carModelController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Car Model',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 10,),



                    TextField(
                      controller: carColorController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Car color',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 10,),
                    TextField(
                      controller: vehicleNumberController,

                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Vehicle number',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 40,),
                    TaxiButton(
                      title: 'PROCEED',
                      color: Colors.green,
                      onPressed: (){

                        if(carModelController.text.length<3){
                          showSnackBar('Please provide a valid Car Model');
                          return;
                        }

                        if(carColorController.text.length<3){
                          showSnackBar('Please provide a valid Color Name');
                          return;
                        }

                        if(vehicleNumberController.text.length<3){
                          showSnackBar('Please provide a valid Vehicle Number');
                          return;
                        }
                        updateProfile(context);

                      },
                    )
                  ],
                ),
              ),
            ],

          ),
        ),
      ),
    );
  }
}
