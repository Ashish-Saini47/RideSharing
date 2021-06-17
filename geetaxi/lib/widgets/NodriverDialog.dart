import 'package:flutter/material.dart';
import 'package:geetaxi/widgets/BrandDivider.dart';
import 'package:geetaxi/widgets/TaxiOutlineButton.dart';

class NoDriverDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),

      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:   BorderRadius.circular(4),

        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10,),
                Text("No Driver Found", style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),),
                SizedBox(height: 25,),

                // BrandDivider(),
                // SizedBox(height: 16,),
                // Text('RS:-$fares', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),),
                // SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "No available driver closed by you, we suggest you to try again shortly ",textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 25,),
                Container(
                  width: 200,
                  child: TaxiOutlineButton(
                    title: 'CLOSE',
                    color: Colors.grey,
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ),
    );;
  }
}
