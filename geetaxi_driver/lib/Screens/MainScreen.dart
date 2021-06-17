import 'dart:io';

// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geetaxi_driver/datamodels/driver.dart';
import 'package:geetaxi_driver/datamodels/tripdetails.dart';
import 'package:geetaxi_driver/helpers/pushnotificationservice.dart';
import 'package:geetaxi_driver/tabs/ProfileTab.dart';
import 'package:geetaxi_driver/tabs/earningtab.dart';
import 'package:geetaxi_driver/tabs/hometab.dart';
import 'package:geetaxi_driver/tabs/rattingtab.dart';
import 'package:geetaxi_driver/widgets/NotificationDialog.dart';
import 'package:geetaxi_driver/widgets/ProgressDialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../globalvaribles.dart';

class MainPage extends StatefulWidget {
  static const String id = "mainpage";
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{
  TabController tabController;
  int selectedIndex = 0;

  void onItemClicked(int index){
    setState(() {
      selectedIndex = index;
      tabController.index= selectedIndex;
    });
  }

  //for firebase messaging
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
      playSound: true);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);




    //Firebase messaging
    getDriverInfo(context);


  }

  void dispose(){
    tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTab(),
          EarningTab(),
          RatingTab(),
          ProfileTab(),


        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon:Icon(Icons.home),
            title: Text('Home')
          ),
          BottomNavigationBarItem(
              icon:Icon(Icons.credit_card),
              title: Text('Earnings')
          ),
          BottomNavigationBarItem(
              icon:Icon(Icons.star),
              title: Text('Ratings')
          ),
          BottomNavigationBarItem(
              icon:Icon(Icons.person),
              title: Text('Profile')
          ),

        ],
        currentIndex: selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.orange,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12),

        type: BottomNavigationBarType.fixed,
        onTap: onItemClicked,
      ),


    );
  }

  //show notification
  void showNotification() {
    var text;
    setState(() {
      text = 12;
    });

    flutterLocalNotificationsPlugin.show(
        0,
        "Testing $text",
        "How you doin ?",
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name, channel.description,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }
   void  getDriverInfo(context) async{
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}');
    driverRef.once().then((DataSnapshot snapshot){
      if(snapshot.value != null){

        currentDriverInfo = Driver.fromSnapshot(snapshot);


      }
    });
    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      RemoteNotification notification = message.notification;

      fetchRideInfo(getId(message), context);

      AndroidNotification android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));

        // showDialog(
        //
        //     builder: (_) {
        //       return AlertDialog(
        //         title: Text(notification.title),
        //         content: SingleChildScrollView(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [Text(notification.body),
        //             ],
        //           ),
        //         ),
        //       );
        //     });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      fetchRideInfo(getId(message), context);

      RemoteNotification notification = message.notification;
      // Map<String, String> data =message['data'] ?? message;
      print("this is message ${message.data}");



      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        // showDialog(
        //
        //     builder: (_) {
        //       return AlertDialog(
        //         title: Text(notification.title),
        //         content: SingleChildScrollView(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [Text(notification.body),
        //             ],
        //           ),
        //         ),
        //       );
        //     });
      }
    });

  }
  String getId(RemoteMessage message){
    String rideId;
    if(Platform.isAndroid){
      rideId = message.data['ride_id'];


    }
    return rideId;
  }

  void fetchRideInfo(String rideId, context){

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: "Fetching details",),
    );

    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('ride request/$rideId');
    rideRef.once().then((DataSnapshot snapshot){

      Navigator.pop(context);

      if(snapshot.value != null){


        // assetsAudioPlayer.open(
        //   Audio('sounds/alert.mp3'),
        // );
        // assetsAudioPlayer.play();

        double pickupLat = double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng = double.parse(snapshot.value['location']['longitude'].toString());
        String pickupAddress = snapshot.value['pickup_address'].toString();

        double destinationLat =double.parse(snapshot.value['destination']['latitude'].toString());
        double destinationLng =double.parse(snapshot.value['destination']['longitude'].toString());
        String destinationAddress = snapshot.value['destination_address'].toString();
        String paymentMethod = snapshot.value['payment_methods'];
        String riderName = snapshot.value['rider_name'];

        String riderPhone=snapshot.value['rider_phone'];
        print('pickup address :$pickupAddress');

        TripDetails tripDetails = TripDetails();
        tripDetails.rideId=rideId;
        tripDetails.pickupAddress=pickupAddress;
        tripDetails.destinationAddress=destinationAddress;
        tripDetails.pickup=LatLng(pickupLat, pickupLng);
        tripDetails.destination=LatLng(destinationLat, destinationLng);
        tripDetails.paymentMethod=paymentMethod;
        tripDetails.riderName=riderName;
        tripDetails.riderPhone=riderPhone;

        showDialog(

            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => NotificationDialog(tripDetails: tripDetails,));
      }
    });
  }
}
