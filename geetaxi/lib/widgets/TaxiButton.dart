import 'package:flutter/material.dart';

class TaxiButton extends StatelessWidget {
  final String title;

  final Function onPressed;
  TaxiButton({this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(25),
      ),
      color:Colors.green,
      textColor: Colors.white,
      child: Container(
        height: 50,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 18,),
          ),
        ),
      ),

    );
  }
}