import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


import '../globalvaribles.dart';

class PushNotificationService{
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('A bg message just showed up :  ${message.messageId}');
  }


  Future<void>  getToken() async{
    String token = await FirebaseMessaging.instance.getToken();
    print('token is ${token}');

    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/token');
    tokenRef.set(token);

   await FirebaseMessaging.instance.subscribeToTopic('alldrivers');
    await FirebaseMessaging.instance.subscribeToTopic('allusers');

  }
}