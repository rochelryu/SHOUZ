import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';



class CovoiturageChoicePlace extends StatefulWidget {
  VoyageModel voyage;
  List<LatLng> global = [];
  CovoiturageChoicePlace(this.voyage, this.global);
  @override
  _CovoiturageChoicePlaceState createState() => _CovoiturageChoicePlaceState();
}

class _CovoiturageChoicePlaceState extends State<CovoiturageChoicePlace> {
  List<dynamic> choice = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    choice = widget.voyage.placeDisponible;
  }

  @override
  Widget build(BuildContext context) {
    final hobbies = widget.voyage.hobiesCovoiturage.map((value) {
      return Chip(
                  label: Text(value),
                  labelStyle: prefix0.Style.titleInSegment(),
                  backgroundColor: prefix0.colorText,

                );
    }).toList();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: backgroundColor,
        title: Text("${widget.voyage.price.toString()} F cfa"),
        actions: <Widget>[
          IconButton(icon: Icon(Style.social_normal, color: Colors.white, size: 22.0), onPressed: (){
            print("Share on Social Media");
          })
        ],
      ),
      body:new ListView(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height/3,
            width: double.infinity,
            child: new FlutterMap(
                options: new MapOptions(
                  center: new LatLng(widget.global[1].latitude, widget.global[1].longitude),
                  minZoom: 6.0,
                  zoom: 7.0,
                ),
                layers: [
                  new TileLayerOptions(
                      urlTemplate:
                      "https://api.mapbox.com/styles/v1/rochelryu/ck1piq46n2i5y1cpdlmq6e8e2/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoicm9jaGVscnl1IiwiYSI6ImNrMTkwbWkxMjAwM2UzZG9ka3hmejEybW0ifQ.9BIwdEGZfCz6MLIg8V6SIg",
                      additionalOptions: {
                        'accessToken': 'pk.eyJ1Ijoicm9jaGVscnl1IiwiYSI6ImNrMTkwbWkxMjAwM2UzZG9ka3hmejEybW0ifQ.9BIwdEGZfCz6MLIg8V6SIg',
                        'id': 'mapbox.mapbox-streets-v8'
                      }),
                  new MarkerLayerOptions(markers: [
                    new Marker(
                        width: 20.0,
                        height: 20.0,
                        point: new LatLng(widget.global[0].latitude, widget.global[0].longitude),
                        builder: (context) => new Container(
                          child: Icon(MyFlutterAppSecond.pin, color: colorText, size: 20.0),
                        )),
                    new Marker(
                        width: 20.0,
                        height: 20.0,
                        point: new LatLng(widget.global[1].latitude, widget.global[1].longitude),
                        builder: (context) => new Container(
                          child: Icon(MyFlutterAppSecond.pin, color: Colors.redAccent, size: 20.0),
                        )),
                  ]),

                  new PolylineLayerOptions(
                      polylines: [
                        new Polyline(
                          points: widget.global,
                          strokeWidth: 2.0,
                          isDotted: true,
                          color: colorText,
                        )
                      ]
                  )
                ]
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        image: DecorationImage(
                          image: NetworkImage("${ConsumeAPI.AssetProfilServer}${widget.voyage.chauffeur}"),
                          fit: BoxFit.cover
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            right: 0,
                            child: iconLevel(widget.voyage.numberTravel),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.voyage.chauffeurName, style: prefix0.Style.titre(14)),
                          Text("Niveau : ${widget.voyage.levelName}", style: prefix0.Style.sousTitre(12)),
                          LinearProgressIndicator(
                            backgroundColor: backgroundColorSec,
                            valueColor: AlwaysStoppedAnimation<Color>(prefix0.colorText),
                            value: widget.voyage.numberTravel / widget.voyage.nextLevel,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 120,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              //direction: Axis.vertical,
              alignment: WrapAlignment.spaceEvenly,
              runSpacing: 1.0,
              spacing: 2.0,
              children: hobbies,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2.0,left: 10.0, bottom: 5.0),
            child: Text("Veillez choisir votre place pour le voyage", style: prefix0.Style.sousTitre(12)),
          ),
          Container(
            height: ((widget.voyage.placeTotal - 1) % 3 == 0) ? 300:400,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 5.0,mainAxisSpacing: 5.0),
                itemCount: widget.voyage.placeTotal + 2,
                itemBuilder: (context, index){
                  if(index == 0){
                    return new Container(
                      height: double.infinity,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 15.0),
                      decoration: BoxDecoration(
                        color: prefix0.backgroundColorSec,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          /*Container(
                            height: 30,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Icon(Icons.blur_circular,size: 30, color: Colors.grey)
                              ],
                            ),
                          ),*/
                          Padding(
                            padding: EdgeInsets.only(left: 10.0,bottom: 10.0),
                              child: Icon(MyFlutterAppSecond.driver, size: 40, color: Colors.white)
                          ),
                          Text('Conducteur', style: prefix0.Style.titre(12))
                        ],
                      ),
                    );
                  }
                  else if(index == 1 || (index == 4 && (widget.voyage.placeTotal - 1) % 3 != 0)){
                    return new Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                    );
                  }
                  else{
                    return (choice[index - 2] == 0 || choice[index - 2] == 2) ?
                    new InkWell(
                      onTap: (){
                        setState(() {
                          choice[index - 2] = (choice[index - 2] == 0) ? 2 : 0;
                        });
                      },
                      child: new Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
/*
                        (widget.voyage.placeDisponible[index - 2] == 0)
*/
                          color: prefix0.backgroundColorSec,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 30,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  (choice[index - 2] == 0) ? Icon(Icons.blur_circular,size: 30, color: Colors.grey): Icon(Icons.check_circle,size: 30, color: Colors.green)
                                ],
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 10.0,bottom: 10.0),
                                child: Icon(MyFlutterAppSecond.car_seat_with_seatbelt, size: 40, color: Colors.white)),
                            Text('  Place Libre', style: prefix0.Style.titre(12))
                          ],
                        ),
                      ),
                    ): new Container(
                      height: double.infinity,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 15.0),
                      decoration: BoxDecoration(
/*
                        (widget.voyage.placeDisponible[index - 2] == 0)
*/
                        color: prefix0.backgroundColorSec,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 10.0,bottom: 10.0),
                              child: Icon(MyFlutterAppSecond.passenger, size: 40, color: Colors.white)),
                          Text('Place occupée', style: prefix0.Style.titre(12))
                        ],
                      ),
                    );
                  }
                }),
          ),

        ],
      ),
      floatingActionButton: choice.contains(2) ? FloatingActionButton(
        onPressed: (){
          print('montre');
        },
        backgroundColor: prefix0.colorText,
        child: Icon(Icons.payment, color: Colors.white),
      ):SizedBox(width: 10.0),
    );
  }

  Widget iconLevel(dynamic numberTravel) {
    if (numberTravel >= 40) {
      return Icon(Icons.stars, size: 22.0, color: Colors.redAccent);
    }
    else if (numberTravel >= 20 && numberTravel < 40) {
      return Icon(Icons.star, size: 22.0, color: Colors.yellowAccent);
    }
    else if (numberTravel >= 13 && numberTravel < 20) {
      return Icon(Icons.star_half, size: 22.0, color: Colors.yellowAccent);
    }
    else if (numberTravel >= 5 && numberTravel < 13) {
      return Icon(Icons.star_border, size: 22.0, color: Colors.yellowAccent);
    }
    else {
      return Icon(Icons.star_border, size: 22.0, color: Colors.tealAccent);
    }
  }
}
