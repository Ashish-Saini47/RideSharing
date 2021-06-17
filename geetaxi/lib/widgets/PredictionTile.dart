import 'package:flutter/material.dart';
import 'package:geetaxi/datamodels/address.dart';
import 'package:geetaxi/datamodels/predication.dart';
import 'package:geetaxi/dataprovider/appdata.dart';
import 'package:geetaxi/globalvaribales.dart';
import 'package:geetaxi/helpers/rewuesthelper.dart';
import 'package:geetaxi/widgets/ProgressDialog.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';


class PredictionTile extends StatelessWidget {


  final Prediction prediction;
  PredictionTile({
   this.prediction
});

  void getPlaceDetails(String placeId, context) async{

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>ProgressDialog(status:'Please wait...',)
    );


    String url ="https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var response = await RequestHelper.getRequest(url);
    Navigator.pop(context);
    if(response == 'failed'){
      return ;
    }
    if(response['status']== 'OK'){
      Address thisPlace = Address();
      thisPlace.placeName= response['result']['name'];
      thisPlace.placeId=placeId;
      thisPlace.latitude= response['result']['geometry']['location']['lat'];
      thisPlace.longitude=response['result']['geometry']['location']['lng'];
      Provider.of<AppData>(context, listen: false).updateDestinationAddress(thisPlace);
      print(thisPlace.placeName);

      Navigator.pop(context,'getDirection');
    }

  }


  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        getPlaceDetails(prediction.placeId, context);

      },
      padding: EdgeInsets.all(0),
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 8,),
            Row(
              children: [
                Icon(OMIcons.locationOn, color: Colors.grey,),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prediction.mainText, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 16),),
                      SizedBox(height: 2,),
                      Text(prediction.secondaryText, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 12, color: Colors.grey),),

                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}