import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geetaxi_driver/widgets/ProgressDialog.dart';
import 'package:geetaxi_driver/widgets/TaxiButton.dart';


import 'MainScreen.dart';
import 'Registration.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth =FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackBar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15), ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void login()async{

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: "Logging you in",),
    );

    final User user= (await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text).catchError((ex){
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);
    })).user;
    if(user != null){
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('drivers/${user.uid}');
      userRef.once().then((DataSnapshot snapshot){
        if(snapshot.value !=null){
          Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);

        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height:70,),
                Image(
                  alignment: Alignment.center,
                  height: 100.0,
                  width: 100.0,
                  image:
                  AssetImage('images/logo.png'),
                ),
                SizedBox(height: 40,),
                Text("Sign In As Driver",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          ),


                        ),

                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10,),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          ),


                        ),

                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 40,),

                      TaxiButton(
                        title:'LOGIN',
                        color: Colors.green,
                        onPressed: ()async{
                          var connectivityResult= await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar("No internet Connection");
                          }

                          if(!emailController.text.contains("@") ){
                            showSnackBar("Pls provide a valid email Address");
                            return;
                          }
                          if(passwordController.text.length<8 ){
                            showSnackBar("Pls provide a Eight digit password");
                            return;
                          }
                          login();

                        },
                      ),
                    ],
                  ),
                ),

                FlatButton(
                    onPressed: (){
                      Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);

                    },
                    child: Text('Don\'t have an account, sign up here')
                ),



              ],
            ),
          ),
        ),
      ),
    );
  }
}


