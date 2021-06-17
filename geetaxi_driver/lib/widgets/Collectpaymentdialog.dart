import 'package:flutter/material.dart';
import 'package:geetaxi_driver/helpers/helpermethods.dart';
import 'package:geetaxi_driver/widgets/BrandDivider.dart';
import 'package:geetaxi_driver/widgets/TaxiButton.dart';

class CollectPayment extends StatelessWidget {

  final String paymentMethod;
  final int fares;
  CollectPayment({
    this.fares,
    this.paymentMethod,
});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
          ),

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
                SizedBox(height: 20,),
                Text("Cash Payment"),
                SizedBox(height: 20,),

                BrandDivider(),
                SizedBox(height: 16,),
                Text('RS:-$fares', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Amount above is the total to be charged to the rider",textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30,),
                Container(
                  width: 230,
                  child: TaxiButton(
                    title: "COLLECT CASH",
                    color: Colors.green,
                    onPressed: (){
                       Navigator.pop(context);
                       Navigator.pop(context);

                       HelperMethods.enableHomeTabLocationUpdate();



                    },
                  ),
                ),
                SizedBox(height: 40,),
              ],
            ),
          ),
          );
  }
}
