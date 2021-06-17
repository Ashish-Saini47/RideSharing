import 'package:flutter/material.dart';
import 'package:geetaxi_driver/widgets/TaxiOutlineButton.dart';

import 'TaxiButton.dart';

class ConfirmSheet extends StatelessWidget {

  final String title;
  final String subtitle;
  final Function onPressed;

  ConfirmSheet({this.title, this.subtitle,this.onPressed});


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
       // borderRadius: BorderRadius.circular(20),
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
      height: 220,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          children: [
            SizedBox(height: 10,),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20,),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24,),

            Row(
              children: [
                Expanded(

                  child: Container(
                    child: TaxiOutlineButton(
                      title: 'Back',
                      color: Colors.grey,
                      onPressed: (){
                        Navigator.pop(context);

                      },
                    ),
                  ),
                ),
                SizedBox(width: 16,),
                Expanded(

                  child: Container(
                    child: TaxiButton(
                      title: 'Confirm',
                      color: (title == 'Go Online') ? Colors.green :Colors.red,

                      onPressed: onPressed,
                    ),
                  ),
                ),


              ],
            )

          ],
        ),
      ),
    );
  }
}
