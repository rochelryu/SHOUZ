import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart';
import 'package:shouz/Constant/CardTopNewActu.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:skeleton_text/skeleton_text.dart';

import 'ChoiceHobie.dart';

class Actualite extends StatefulWidget {
  @override
  _ActualiteState createState() => _ActualiteState();
}

class _ActualiteState extends State<Actualite> {
  String destination;
  String firstTextMeteo = "";
  String secondTextMeteo = "";
  Location location ;
  LocationData locationData;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  Future<Map<String, dynamic>> topActualite;
  Future<Map<String, dynamic>> contentActulite;


  getPositionCurrent() async {
    try {
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        } else {
          _serviceEnabled = await location.serviceEnabled();
          if (!_serviceEnabled) {
            _serviceEnabled = await location.requestService();
            if (!_serviceEnabled) {
              return;
            }
          }
          var test = await location.getLocation();
          setState(() {
            locationData = test;
          });
        }
      } else {
        _serviceEnabled = await location.serviceEnabled();
        if (!_serviceEnabled) {
          _serviceEnabled = await location.requestService();
          if (!_serviceEnabled) {
            return;
          }
        }
        var test = await location.getLocation();
        setState(() {
          locationData = test;
        });
      }

    } catch (e) {
      print("nous avons une erreur $e");
    }
  }

  cityFromCoord() async {

    final addresses =
        await geocoding.placemarkFromCoordinates(locationData.latitude, locationData.longitude);
    geocoding.Placemark first = addresses.first;

    String finalPosition;
    if (first.locality != null) {
      finalPosition =
          first.locality + ' ' + first.name + ', ' + first.isoCountryCode;
    } else {
      finalPosition = first.name + first.country;
    }
    finalPosition = finalPosition.trim();
    //print('geocoding name ${first.name} locality ${first.locality} country ${first.country} street ${first.street} isoCountryCode ${first.isoCountryCode} administrativeArea ${first.administrativeArea} postalCode ${first.postalCode} subAdministrativeArea${first.subAdministrativeArea} subLocality ${first.subLocality} subThoroughfare ${first.subThoroughfare} thoroughfare ${first.thoroughfare}');
    /*
    geocoding name District Autonome d'Abidjan
    locality Abidjan
    country Côte d'Ivoire
    street Unnamed Road
    isoCountryCode CI
    administrativeArea District Autonome d'Abidjan
    postalCode
    subAdministrativeArea Abidjan
    subLocality Cocody
    subThoroughfare
    thoroughfare
     */
    final meteo = await new ConsumeAPI()
        .getMeteo(locationData.latitude, locationData.longitude);
    final user = await new ConsumeAPI().updatePosition(
        finalPosition,
        locationData.latitude,
        locationData.longitude,
        locationData.speedAccuracy);
    if (meteo['etat'] == 'found') {
      setState(() {
        firstTextMeteo = "Il fait ${meteo['result'].toString()}ºC";
        secondTextMeteo = (first.locality != null)
            ? "à ${first.locality} actuellement"
            : "à ${first.street} actuellement";
      });
    }
    if (user['etat'] == 'found') {
      await DBProvider.db.delClient();
      await DBProvider.db.newClient(user['user']);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location = new Location();
    getPositionCurrent();
    topActualite = new ConsumeAPI().getActualite();
    contentActulite = topActualite;

    new Timer(const Duration(seconds: 5), cityFromCoord);
  }

  Widget listItemCustom(BuildContext context, String categorieName,
      String categorieId, List<dynamic> bodyItem) {
    List<Widget> itemOfList = bodyItem
        .map((value) => new CardTopNewActu(
                value['title'],
                value['_id'],
                value['imageCover'],
                value['numberVue'],
                value['registerDate'],
                value['autherName'],
                value['authorProfil'],
                value['content'],
                value['comment'])
            .propotypingScrol(context))
        .toList();
    return new Container(
      height: 310,
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15.0, top: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(categorieName, style: Style.titre(25.0)),
                Text("Voir plus", style: Style.moreViews()),
              ],
            ),
          ),
          SizedBox(height: 7.0),
          Container(
            height: 250,
            child: PageView(
              controller: PageController(viewportFraction: 0.8),
              scrollDirection: Axis.horizontal,
              pageSnapping: true,
              children: itemOfList,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: Container(
        child: new Column(
          children: <Widget>[
            SizedBox(height: 10),
            FutureBuilder(
                future: contentActulite,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Center(
                          child: Text(
                        "Erreur de connection, veuillez verifier votre connection et reesayer",
                        style: Style.sousTitreEvent(15),
                      ));
                    case ConnectionState.waiting:
                      return Container(
                        height: 300.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return new SizedBox(width: 20.0);
                            } else {
                              return Padding(
                                padding:
                                    EdgeInsets.only(top: 10.0, bottom: 10.0),
                                child: Container(
                                  width: 300,
                                  margin: EdgeInsets.only(right: 20.0),
                                  height: 290,
                                  decoration: BoxDecoration(
                                      color: tint,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 5.0,
                                            color: tint,
                                            offset: Offset(0.0, 1.0))
                                      ]),
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        height: 170.0,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: [backgroundColor, tint],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                            )),
                                      ),
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 180.0,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.circular(10.0),
                                          )),
                                        ),
                                      ),
                                      Positioned(
                                        top: 195.0,
                                        left: 10.0,
                                        right: 1.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SkeletonAnimation(
                                              child: Container(
                                                height: 15,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.grey[300]),
                                              ),
                                            ),
                                            SizedBox(height: 5.0),
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Container(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: <Widget>[
                                                        SkeletonAnimation(
                                                          child: Container(
                                                            height: 65,
                                                            width: 65,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100.0),
                                                                color: Colors
                                                                    .grey[300]),
                                                          ),
                                                        ),
                                                        SizedBox(width: 5.0),
                                                        SkeletonAnimation(
                                                          child: Container(
                                                            width: 60,
                                                            height: 13,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Colors
                                                                    .grey[300]),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );

                    case ConnectionState.active:
                      return Container(
                        height: 300.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return new SizedBox(width: 20.0);
                            } else {
                              return Padding(
                                padding:
                                    EdgeInsets.only(top: 10.0, bottom: 10.0),
                                child: Container(
                                  width: 300,
                                  margin: EdgeInsets.only(right: 20.0),
                                  height: 290,
                                  decoration: BoxDecoration(
                                      color: tint,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 5.0,
                                            color: tint,
                                            offset: Offset(0.0, 1.0))
                                      ]),
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        height: 170.0,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: [backgroundColor, tint],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                            )),
                                      ),
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 180.0,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.circular(10.0),
                                          )),
                                        ),
                                      ),
                                      Positioned(
                                        top: 195.0,
                                        left: 10.0,
                                        right: 1.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SkeletonAnimation(
                                              child: Container(
                                                height: 15,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.grey[300]),
                                              ),
                                            ),
                                            SizedBox(height: 5.0),
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Container(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: <Widget>[
                                                        SkeletonAnimation(
                                                          child: Container(
                                                            height: 65,
                                                            width: 65,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100.0),
                                                                color: Colors
                                                                    .grey[300]),
                                                          ),
                                                        ),
                                                        SizedBox(width: 5.0),
                                                        SkeletonAnimation(
                                                          child: Container(
                                                            width: 60,
                                                            height: 13,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Colors
                                                                    .grey[300]),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );

                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Center(
                            child: Text(
                          "${snapshot.error}",
                          style: Style.sousTitreEvent(15),
                        ));
                      }
                      var actualiteOther = snapshot.data;
                      if (actualiteOther['otherActualite'].length <= 1) {
                        return Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Padding(
                                    padding: EdgeInsets.only(
                                        left: 15.0,
                                        right: 15.0,
                                        bottom: 10.0,
                                        top: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(firstTextMeteo,
                                            style: Style.grandTitre(18.0)),
                                        SizedBox(height: 2.0),
                                        Text(secondTextMeteo,
                                            style: Style.grandTitre(14.0)),
                                        SizedBox(height: 20.0),
                                      ],
                                    ),
                                  ),
                                  new SvgPicture.asset(
                                    "images/not actu.svg",
                                    semanticsLabel: 'Shouz Pay',
                                    height: MediaQuery.of(context).size.height * 0.39,
                                  ),
                                  Text(
                                      "Aucune Actualité pour vos differentes préferences. Nous vous recommandons d'ajouter au moins une préference populaire afin d'avoir le minimum d'information d'actualité ",
                                      textAlign: TextAlign.center,
                                      style: Style.sousTitreEvent(15)),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push((MaterialPageRoute(
                                          builder: (context) => ChoiceHobie())));
                                    },
                                    child: Text('Ajouter Préférence'),
                                    style: ElevatedButton.styleFrom(
                                      onPrimary: colorPrimary,
                                      primary: colorText,
                                      minimumSize: Size(88, 36),
                                      elevation: 4.0,
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                                    ),
                                  )
                                ]));
                      }
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.95,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount:
                                actualiteOther['otherActualite'].length + 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return new Padding(
                                  padding: EdgeInsets.only(
                                      left: 15.0,
                                      right: 15.0,
                                      bottom: 10.0,
                                      top: 5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(firstTextMeteo,
                                          style: Style.grandTitre(18.0)),
                                      SizedBox(height: 2.0),
                                      Text(secondTextMeteo,
                                          style: Style.grandTitre(14.0)),
                                      SizedBox(height: 20.0),
                                    ],
                                  ),
                                );
                              } else if (index <=
                                  actualiteOther['otherActualite'].length) {
                                return listItemCustom(
                                    context,
                                    actualiteOther['otherActualite'][index - 1]
                                        ['name'],
                                    actualiteOther['otherActualite'][index - 1]
                                        ['block'],
                                    actualiteOther['otherActualite'][index - 1]
                                        ['body']);
                              } else {
                                return SizedBox(height: 150);
                              }
                            }),
                      );

                    // return new CardTopNewActu()
                  }
                }),
          ],
        ),
      ),
    );
  }
}
