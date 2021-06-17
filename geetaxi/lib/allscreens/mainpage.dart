import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geetaxi/allscreens/searchpage.dart';
import 'package:geetaxi/datamodels/directiondetails.dart';
import 'package:geetaxi/datamodels/driver.dart';
import 'package:geetaxi/datamodels/nearbydriver.dart';
import 'package:geetaxi/dataprovider/appdata.dart';
import 'package:geetaxi/helpers/firehelper.dart';
import 'package:geetaxi/helpers/helpermethods.dart';
import 'package:geetaxi/ridevariable.dart';
import 'package:geetaxi/styles/styles.dart';
import 'package:geetaxi/widgets/BrandDivider.dart';
import 'package:geetaxi/widgets/CollectPaymentDialog.dart';
import 'package:geetaxi/widgets/NodriverDialog.dart';
import 'package:geetaxi/widgets/ProgressDialog.dart';
import 'package:geetaxi/widgets/TaxiButton.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import '../globalvaribales.dart';

class mainpage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _mainpageState createState() => _mainpageState();
}

class _mainpageState extends State<mainpage> with TickerProviderStateMixin{

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();


  double searchSheetHeight = (Platform.isIOS) ? 300 : 270;
  double rideDetailsSheetHeight = 0;
  double requestSheetHeight = 0;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;
  double tripSheetHeight = 0;

  List<LatLng> polylineCoordinate = [];
  Set<Polyline> _polylines={};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles= {};

  BitmapDescriptor nearbyIcon;




  var geoLocator = Geolocator();
  Position currentPosition;

  String appState = 'NORMAL';

  DirectionDetails tripDirectionDetails;

  bool drawerCanOpen = true;

  DatabaseReference rideRef;

  StreamSubscription<Event> rideSubScription;
  List<NearbyDriver> availableDrivers;

  bool nearbyDriverKeysLoaded = false;
  bool isRequestingLocationDetails = false;


  void setupPositionLocator()async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition= position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 16);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    String address = await HelperMethods.findCordinateAddress(position, context);
    print(address);
   startGeofireListener();

  }

  void showTripSheet(){
    setState(() {
      requestSheetHeight = 0;
      tripSheetHeight = (Platform.isAndroid) ? 270 :300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 310;

    });
  }


  void showDetailsSheet()async {

    await getDirection();
    setState(() {
      searchSheetHeight=0;
      rideDetailsSheetHeight=230;
      mapBottomPadding = (Platform.isAndroid) ? 240:230;
      drawerCanOpen=false;
    });
  }

  void showRequestSheet() async{
    setState(() {
      searchSheetHeight=0;
      rideDetailsSheetHeight=0;
      requestSheetHeight=(Platform.isAndroid) ? 190 : 220;
      drawerCanOpen = true;
      mapBottomPadding=(Platform.isAndroid) ? 195:190;
    });

    createRideRequest();
  }

  void createMarker(){
    if(nearbyIcon == null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context , size:Size(2,2));

      BitmapDescriptor.fromAssetImage( imageConfiguration, 'images/car_android.png').then((icon){
        nearbyIcon = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HelperMethods.getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();

    return Scaffold(
      key: scaffoldKey,
      drawer:Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    
                  ),
                  child: Row(
                    children: [
                      Image.asset('images/user_icon.png', height: 60, width: 60,),
                      SizedBox(width: 15,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('User Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          SizedBox(height: 5,),
                          Text('View profile'),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
              BrandDivider(),

              SizedBox(height: 10,),
              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text('Free Ride', style: kDrawerItemStyle,),
              ),
              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text('Payment', style: kDrawerItemStyle,),
              ),
              ListTile(
                leading: Icon(OMIcons.history),
                title: Text('Ride History', style: kDrawerItemStyle,),
              ),
              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text('Support', style: kDrawerItemStyle,),
              ),
              ListTile(
                leading: Icon(OMIcons.info),
                title: Text('About', style: kDrawerItemStyle,),
              ),


            ],
          ),
        ),
      ),

     body: Stack(
       children: [
         GoogleMap(
           padding: EdgeInsets.only(bottom: mapBottomPadding),
           mapType: MapType.normal,
           myLocationButtonEnabled: true,
           initialCameraPosition: googlePlex,

           myLocationEnabled: true,
           zoomGesturesEnabled: true,
           zoomControlsEnabled: true,
           polylines: _polylines,
           markers: _Markers,
           circles: _Circles,
           onMapCreated: (GoogleMapController controller){
             _controller.complete(controller);
             mapController = controller;
             setState(() {
               mapBottomPadding = (Platform.isAndroid) ? 270 : 280;
             });

             setupPositionLocator();
           },
         ),
         Positioned(
           top: 44,
           left:20,
           child: GestureDetector(
             onTap: (){
               if(drawerCanOpen){
                 scaffoldKey.currentState.openDrawer();

               }
               else{
                 resetApp();
               }
             },
             child: Container(
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black26,
                     blurRadius: 5.0,
                     spreadRadius: 0.5,
                     offset: Offset(
                       0.7,
                       0.7,
                     ),
                   )
                 ],

               ),
               child: CircleAvatar(
                 backgroundColor: Colors.white,
                 radius: 20,
                 child: Icon((drawerCanOpen) ? Icons.menu : Icons.arrow_back, color: Colors.black87,),
               ),
             ),
           ),
         ),
//Search Sheet
         Positioned(
           left: 0,
           right: 0,
           bottom: 0,
           child: AnimatedSize(
             vsync: this,
             duration: new Duration(milliseconds: 150),
             curve: Curves.easeIn,
             child: Container(
               // height: 0,
               height: searchSheetHeight,
               decoration: BoxDecoration(

                 color: Colors.white,
                 borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black,
                     blurRadius: 15.0,
                     spreadRadius: 0.5,
                     offset: Offset(
                       0.7,
                       0.7,
                     )
                   )
                 ]
               ),
               child:Padding(
                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     SizedBox(height: 5,),
                     Text("Nice to See You!", style: TextStyle(fontSize: 10),),
                     Text("Where are you going?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                     SizedBox(height: 20,),
                     GestureDetector(
                       onTap: () async {
                         var response = await Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchPage()));


                         if(response == 'getDirection'){
                           showDetailsSheet();
                         }
                       },
                       child: Container(
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(4),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.black12,
                               blurRadius: 5.0,
                               spreadRadius: 0.5,
                               offset: Offset(
                                 0.7,
                                 0.7,
                               )
                             ),


                           ]
                         ),
                         child: Padding(
                           padding: EdgeInsets.all(12.0),
                           child: Row(
                             children: [
                               Icon(Icons.search, color: Colors.greenAccent,),
                               SizedBox(width:10,),
                               Text('Search Destination'),
                             ],
                           ),
                         ),
                       ),
                     ),

                     SizedBox(height: 22,),
                     Row(
                       children: [
                         Icon(OMIcons.home, color: Colors.greenAccent,),
                         SizedBox(width: 12,),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Add Home'),
                             SizedBox(height: 3,),
                             Text('Your residential address', style: TextStyle(fontSize: 11, color: Colors.grey,),),

                           ],
                         ),



                       ],
                     ),
                     SizedBox(height: 10,),
                     BrandDivider(),
                     SizedBox(height: 16,),
                     Row(
                       children: [
                         Icon(OMIcons.workOutline, color: Colors.greenAccent,),
                         SizedBox(width: 12,),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Add Work Place'),
                             SizedBox(height: 3,),
                             Text('Your Office address', style: TextStyle(fontSize: 11, color: Colors.grey,),),

                           ],
                         ),



                       ],
                     ),
                   ],
                 ),
               ),
             ),
           ),
         ),


         //Rider details

         Positioned(
           left: 0,
           right: 0,
           bottom: 0,
           child: AnimatedSize(
             vsync: this,
             duration: new Duration(milliseconds: 150),

             child: Container(
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),

                 boxShadow: [
                   BoxShadow(
                     color: Colors.black26,
                     blurRadius: 15.0,
                     spreadRadius: 0.5,
                     offset: Offset(
                       0.7,
                       0.7,
                     ),
                   )
                 ],

               ),
               height: rideDetailsSheetHeight,
               child: Padding(
                 padding: EdgeInsets.symmetric(vertical: 18),
                 child: Column(
                   children: [
                     Container(
                       width:double.infinity,
                       color: Colors.green[100],
                       child: Padding(
                         padding:EdgeInsets.symmetric(horizontal: 16),
                         child: Row(
                           children: [
                             Image.asset('images/taxi.png', height: 70, width:70,),
                             SizedBox(width: 16,),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('Taxi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                 Text((tripDirectionDetails != null) ? tripDirectionDetails.distanceText : '',  style: TextStyle(fontSize: 16, color: Colors.grey),),

                               ],
                             ),
                             Expanded(child: Container()),
                             Text((tripDirectionDetails != null) ? 'RS:-${HelperMethods.estimateFares(tripDirectionDetails)}' : '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),

                           ],
                         ),
                       ),
                     ),
                     SizedBox(height: 22,),
                     Padding(
                       padding: EdgeInsets.symmetric(horizontal: 16),
                       child: Row(children: [

                         Icon(FontAwesomeIcons.moneyBillAlt,size: 18, color: Colors.grey,),
                         SizedBox(width: 16,),
                         Text("Cash"),

                       ],),
                     ),

                     SizedBox(height: 22,),
                     Padding(
                       padding: EdgeInsets.symmetric(horizontal: 16),
                       child: TaxiButton(
                         title: 'REQUEST CAB',
                         onPressed: (){
                           setState(() {
                             appState="REQUESTING";
                           });
                           showRequestSheet();
                           availableDrivers = FireHelper.nearbyDriverList;
                           findDriver();



                         },

                       ),
                     ),
                   ],
                 ),
               ),

             ),
           ),
         ),

         Positioned(
           left: 0,
           right: 0,
           bottom: 0,
           child: AnimatedSize(
             vsync: this,
             duration: new Duration(milliseconds: 150),
             curve: Curves.easeIn,
             child: Container(
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),

                 boxShadow: [
                   BoxShadow(
                     color: Colors.black26,
                     blurRadius: 15.0,
                     spreadRadius: 0.5,
                     offset: Offset(
                       0.7,
                       0.7,
                     ),
                   )
                 ],

               ),

               height: requestSheetHeight,
               child: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.center,

                   children: [
                     SizedBox(height: 10,),
                     SizedBox(
                      width: double.infinity,
                      
                      child: TextLiquidFill(
                        text: 'Requesting a Ride...',
                        waveColor: Colors.grey,
                        boxBackgroundColor: Colors.white,
                        textStyle: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,

                        ),
                        boxHeight: 40,

                      ),

                     ),

                     SizedBox(height: 20,),
                     GestureDetector(
                       onTap: (){
                         cancelRequest();
                         resetApp();
                       },
                       child: Container(
                         height: 50,
                         width: 50,
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(25),
                           border: Border.all(width: 1.0, color: Colors.grey[600]),

                         ),
                         child: Icon(Icons.close, size: 25, color: Colors.grey[600],),

                       ),
                     ),
                     SizedBox(height: 10,),
                     Container(
                       width: double.infinity,
                       child: Text(
                         'Cancel ride',
                         textAlign: TextAlign.center,
                         style: TextStyle(fontSize: 12),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
         ),

         Positioned(
           left: 0,
           right: 0,
           bottom: 0,
           child: AnimatedSize(
             vsync: this,
             duration: new Duration(milliseconds: 150),

             child: Container(
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),

                 boxShadow: [
                   BoxShadow(
                     color: Colors.black26,
                     blurRadius: 15.0,
                     spreadRadius: 0.5,
                     offset: Offset(
                       0.7,
                       0.7,
                     ),
                   )
                 ],

               ),
               height: tripSheetHeight,
               child: Padding(
                 padding: EdgeInsets.symmetric(vertical: 18),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     SizedBox(height: 5,),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text( tripStatusDisplay,
                         textAlign: TextAlign.center,
                         style: TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                         ),
                         ),
                         
                       ],
                     ),
                     SizedBox(height: 20,),
                     BrandDivider(),
                     SizedBox(height: 20,),
                     Text( driverCarDetails, style: TextStyle(color: Colors.grey),),
                     Text(driverFullName, style: TextStyle(fontSize: 20),),
                     SizedBox(height: 20,),
                     BrandDivider(),
                     SizedBox(height: 20,),

                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Container(
                               height: 50,
                               width: 50,
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.all(Radius.circular(25)),
                                 border: Border.all(width: 1, color: Colors.grey),
                               ),
                               child: Icon(Icons.call),
                               
                             ),
                             SizedBox(height:10,),
                             Text('Call'),
                             

                           ],
                         ),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Container(
                               height: 50,
                               width: 50,
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.all(Radius.circular(25)),
                                 border: Border.all(width: 1, color: Colors.grey),
                               ),
                               child: Icon(Icons.list),

                             ),
                             SizedBox(height:10,),
                             Text('Details'),


                           ],
                         ),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Container(
                               height: 50,
                               width: 50,
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.all(Radius.circular(25)),
                                 border: Border.all(width: 1, color: Colors.grey),
                               ),
                               child: Icon(OMIcons.clear),

                             ),
                             SizedBox(height:10,),
                             Text('Cancel'),


                           ],
                         ),
                       ],

                     ),
                    ]
                 ),
               ),

             ),
           ),
         ),


       ],
     ),
    );
  }

  Future getDirection()async{
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (BuildContext)=> ProgressDialog(status: 'Please Wait...',)
    );

    var thisDetails =await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetails = thisDetails;
    });
    Navigator.pop(context);



    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =polylinePoints.decodePolyline(thisDetails.encodedPoints);


    polylineCoordinate.clear();
    if(results.isNotEmpty){

      results.forEach((PointLatLng point){
        polylineCoordinate.add(LatLng(point.latitude, point.longitude));



      });
    }

    _polylines.clear();
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
      _polylines.add(polyline);

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

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));


    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName,snippet: 'My Location'),

    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: destination.placeName,snippet: 'Destination'),


    );
    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);

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

      _Circles.add(pickupCircle);
      _Circles.add(destinationCircle);
    });
  }

  void startGeofireListener() {
    
    Geofire.initialize('driverAvailable');
    Geofire.queryAtLocation(currentPosition.latitude, currentPosition.longitude, 5).listen((map) {
      print(map);



      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude= map['latitude'];
            nearbyDriver.longitude=map['longitude'];
            FireHelper.nearbyDriverList.add(nearbyDriver);
            if(nearbyDriverKeysLoaded){
              updateDriverOnMap();
            }

            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriverOnMap();

            break;

          case Geofire.onKeyMoved:
          // Update your key's location
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude= map['latitude'];
            nearbyDriver.longitude=map['longitude'];
            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriverOnMap();
            break;

          case Geofire.onGeoQueryReady:

            nearbyDriverKeysLoaded = true;
            updateDriverOnMap();

            break;
        }
      }
    });
  }

  void updateDriverOnMap(){
    setState(() {
      _Markers.clear();
    });
    Set<Marker> tempMarker = Set<Marker>();
    for (NearbyDriver driver in FireHelper.nearbyDriverList){
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
      Marker thisMarker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearbyIcon,
        rotation:HelperMethods.generateRandomNumber(360),
      );
      tempMarker.add(thisMarker);
    }

    setState(() {
      _Markers = tempMarker;
    });
  }

  void createRideRequest(){
    rideRef = FirebaseDatabase.instance.reference().child('ride request').push();

    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

    Map pickupMap={
      'latitude':pickup.latitude.toString(),
      'longitude':pickup.longitude.toString(),
    };

    Map destinationMap = {
      'latitude':destination.latitude.toString(),
      'longitude':destination.longitude.toString(),
    };

    Map rideMap = {
      'created_at':DateTime.now().toString(),
      'rider_name':currentUserInfo.fullName,
      'rider_phone':currentUserInfo.phone,
      'pickup_address':pickup.placeName,
      'destination_address':destination.placeName,
      'location':pickupMap,
      'destination':destinationMap,
      'payment_method':'cash',
      'driver_id':'waiting',

    };

    rideRef.set(rideMap);
    rideSubScription = rideRef.onValue.listen((event) async{
      if (event.snapshot == null){
       return;
      }

      if(event.snapshot.value['car_details'] != null){

        setState(() {
          driverCarDetails = event.snapshot.value["car_details"].toString();
        });
      }

      if(event.snapshot.value['driver_name'] != null){

        setState(() {
          driverFullName = event.snapshot.value["driver_name"].toString();
        });
      }
      if(event.snapshot.value['driver_phone'] != null){

        setState(() {
          driverPhone = event.snapshot.value["driver_phone"].toString();
        });
      }

      if(event.snapshot.value['driver_location'] !=null){
        double driverLat = double.parse(event.snapshot.value['driver_location']['latitude'].toString());
        double driverLng = double.parse(event.snapshot.value['driver_location']['longitude'].toString());
        LatLng driverLocation =LatLng(driverLat, driverLng);

        if(status== 'accepted'){
          updateToPickup(driverLocation);

        }
        else if (status == 'ontrip'){

        updateToDestination(driverLocation);
      }
      else if(status == 'arrived'){
        setState(() {
          tripStatusDisplay = 'Driver has arrived';
        });
      }

      }

      if(event.snapshot.value['status'] != null){
        status = event.snapshot.value['status'].toString();

      }
      if(status == 'accepted'){
        showTripSheet();
        Geofire.stopListener();
        removeGeofireMarkers();
      }

      if(status == "ended"){
        if(event.snapshot.value['fares'] !=null){
          int fares = int.parse(event.snapshot.value['fares'].toString());

          var response = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext)=> CollectPayment(fares: fares,paymentMethod: 'cash',));

          if (response == 'close'){
            rideRef.onDisconnect();
            rideRef = null;
            rideSubScription.cancel();
            rideSubScription = null;
            resetApp();
          }
        }
      }


    });

  }

  void cancelRequest(){
    rideRef.remove();
    setState(() {
      appState='NORMAL';
    });


  }

  void NoDriverFound(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)=> NoDriverDialog());
  }
  void findDriver(){
    if(availableDrivers.length ==0){
      cancelRequest();
      resetApp();

      NoDriverFound();



      return;
    }
    var driver = availableDrivers[0];

    notifyDriver(driver);

    availableDrivers.removeAt(0);
    print(driver.key);
  }
  resetApp(){
setState(() {
  polylineCoordinate.clear();
  _polylines.clear();
  _Markers.clear();
  _Circles.clear();

  rideDetailsSheetHeight= 0;
  requestSheetHeight=0;
  searchSheetHeight = (Platform.isAndroid) ? 270:300;
  mapBottomPadding = (Platform.isAndroid) ? 280:270;
  tripSheetHeight=0;
  drawerCanOpen= true;
  status ='';
  driverFullName ='';
  driverPhone = '';
  driverCarDetails = '';
  tripStatusDisplay ='Driver is Arriving';

});
  }

  void removeGeofireMarkers(){
    setState(() {
      _Markers.removeWhere((m) => m.markerId.value.contains('driver'));
    });
  }

  void updateToPickup(LatLng driverLocation) async {

    if(!isRequestingLocationDetails){

      isRequestingLocationDetails = true;

      var positionLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

      var thisDetails = await HelperMethods.getDirectionDetails(driverLocation, positionLatLng);

      if(thisDetails == null){
        return;
      }

      setState(() {
        tripStatusDisplay = 'Driver is Arriving - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;

    }


  }

  void updateToDestination(LatLng driverLocation) async {

    if(!isRequestingLocationDetails){

      isRequestingLocationDetails = true;

      var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

      var destinationLatLng = LatLng(destination.latitude, destination.longitude);

      var thisDetails = await HelperMethods.getDirectionDetails(driverLocation, destinationLatLng);

      if(thisDetails == null){
        return;
      }

      setState(() {
        tripStatusDisplay = 'Driving to Destination - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;

    }


  }

  void notifyDriver(NearbyDriver driver){
    DatabaseReference driverTripRef = FirebaseDatabase.instance.reference().child('drivers/${driver.key}/newtrip');
    driverTripRef.set(rideRef.key);
    
    
    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('drivers/${driver.key}/token');
    tokenRef.once().then((DataSnapshot snapshot){
      if(snapshot.value != null){
        String token= snapshot.value.toString();
        HelperMethods.sendNotification(token, context, rideRef.key);

      }
      else{
        return;
      }
      const oneSecTick = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecTick, (timer) {
        
        if(appState != 'REQUESTING'){
          driverTripRef.set('cancelled');
          driverTripRef.onDisconnect();
          timer.cancel();
          driverRequestTimeout = 30;
        }

        driverRequestTimeout --;
        driverTripRef.onValue.listen((event) {
          if(event.snapshot.value.toString()== 'accepted'){
            driverTripRef.onDisconnect();
            timer.cancel();
            driverRequestTimeout =30;

          }
        });

        if (driverRequestTimeout == 0){
          driverTripRef.set('timeout');
          driverTripRef.onDisconnect();
          driverRequestTimeout = 30;
          timer.cancel();

          findDriver();
        }
      });
    });
    
  }

}
