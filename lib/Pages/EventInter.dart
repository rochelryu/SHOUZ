import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/CreateEvent.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:skeleton_text/skeleton_text.dart';

import '../Models/User.dart';
import '../Utils/Database.dart';
import './EventDetails.dart';
import 'ChoiceOtherHobie.dart';
import 'ExplainEvent.dart';

class EventInter extends StatefulWidget {
  @override
  _EventInterState createState() => _EventInterState();
}

class _EventInterState extends State<EventInter> {
  Location location = new Location();
  late LocationData locationData;
  User? user;
  late StreamSubscription<LocationData> stream;
  late Future<Map<String, dynamic>> eventFull;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  @override
  void initState() {
    super.initState();
    getUser();
    eventFull = consumeAPI.getEvents();
    listenOnMove();
  }

  getUser() async {
    User newClient = await DBProvider.db.getClient();
    setState(() {
      user = newClient;
    });
  }
  Streamer() async {
    try {
      var test = await location.getLocation();
      setState(() {
        locationData = test;
      });
      print(locationData.latitude);
    } catch (e) {
      print("nous avons une erreur $e");
    }
  }

  listenOnMove() {
    stream = location.onLocationChanged.listen((newPosition) {
      setState(() {
        locationData = newPosition;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose

    stream.cancel();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder(
          future: eventFull,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Column(
                  children: <Widget>[
                    Expanded(
                        child: Center(
                      child: Text("Erreur de connexion",
                          style: Style.titreEvent(18)),
                    )),
                  ],
                );
              case ConnectionState.waiting:
                return Column(children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 10.0, bottom: 5.0),
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [backgroundColor, tint],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0))),
                                margin: EdgeInsets.only(top: 45.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 15.0, top: 8.0),
                                      child: SkeletonAnimation(
                                        child: Container(
                                          height: 15,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.grey[300]),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(left: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SkeletonAnimation(
                                              child: Container(
                                                height: 5,
                                                width: 15,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.grey[300]),
                                              ),
                                            ),
                                            SizedBox(width: 5.0),
                                            SkeletonAnimation(
                                              child: Container(
                                                height: 5,
                                                width: 15,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.grey[300]),
                                              ),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SkeletonAnimation(
                                            child: Container(
                                              height: 5,
                                              width: 45,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: Colors.grey[300]),
                                            ),
                                          ),
                                          SizedBox(width: 15.0),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SkeletonAnimation(
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5.0),
                                          SkeletonAnimation(
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5.0),
                                          SkeletonAnimation(
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SkeletonAnimation(
                                      child: Container(
                                        height: 40,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(10.0))),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                bottom: 0,
                                width: MediaQuery.of(context).size.width / 2.3,
                                child: Material(
                                  elevation: 30.0,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0)),
                                  child: SkeletonAnimation(
                                    child: Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                              bottomRight:
                                                  Radius.circular(10.0)),
                                          color: Colors.grey[200]),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ]);

              case ConnectionState.active:
                return Column(children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 10.0, bottom: 5.0),
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [backgroundColor, tint],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0))),
                                margin: EdgeInsets.only(top: 45.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 15.0, top: 8.0),
                                      child: SkeletonAnimation(
                                        child: Container(
                                          height: 15,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.grey[300]),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(left: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SkeletonAnimation(
                                              child: Container(
                                                height: 5,
                                                width: 15,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.grey[300]),
                                              ),
                                            ),
                                            SizedBox(width: 5.0),
                                            SkeletonAnimation(
                                              child: Container(
                                                height: 5,
                                                width: 15,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.grey[300]),
                                              ),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SkeletonAnimation(
                                            child: Container(
                                              height: 5,
                                              width: 45,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: Colors.grey[300]),
                                            ),
                                          ),
                                          SizedBox(width: 15.0),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SkeletonAnimation(
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5.0),
                                          SkeletonAnimation(
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5.0),
                                          SkeletonAnimation(
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SkeletonAnimation(
                                      child: Container(
                                        height: 40,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(10.0))),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                bottom: 0,
                                width: MediaQuery.of(context).size.width / 2.3,
                                child: Material(
                                  elevation: 30.0,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0)),
                                  child: SkeletonAnimation(
                                    child: Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                              bottomRight:
                                                  Radius.circular(10.0)),
                                          color: Colors.grey[200]),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ]);

              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Column(children: <Widget>[
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(
                                child: Text("${snapshot.error}",
                                    style: Style.sousTitreEvent(15)))))
                  ]);
                }
                var event = snapshot.data;
                if (event['listEventsWithFilter'].length == 0) {
                  return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        new SvgPicture.asset(
                          "images/emptyevent.svg",
                          semanticsLabel: 'Shouz Pay',
                          height: MediaQuery.of(context).size.height * 0.39,
                        ),
                        Text(
                            "Aucun Evenement Populaires pour le moment selon vos centres d'intérêts",
                            textAlign: TextAlign.center,
                            style: Style.sousTitreEvent(15)),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push((MaterialPageRoute(
                                    builder: (context) => ChoiceOtherHobie())));
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

                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: event['listEventsWithFilter'].length,
                          itemBuilder: (context, index) {
                            final positionRecently =
                                event['listEventsWithFilter'][index]
                                    ['positionRecently'];
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (builder) => EventDetails(
                                        event['listEventsWithFilter'][index]
                                            ['imageCover'],
                                        index,
                                        event['listEventsWithFilter'][index]
                                            ['price'],
                                        event['listEventsWithFilter'][index]
                                            ['numberFavorite'],
                                        event['listEventsWithFilter'][index]
                                            ['authorName'],
                                        event['listEventsWithFilter'][index]
                                            ['describe'],
                                        event['listEventsWithFilter'][index]
                                            ['_id'],
                                        event['listEventsWithFilter'][index]
                                            ['numberTicket'],
                                        event['listEventsWithFilter'][index]
                                            ['position'],
                                        event['listEventsWithFilter'][index]
                                            ['enventDate'],
                                        event['listEventsWithFilter'][index]
                                            ['title'],
                                        event['listEventsWithFilter'][index]
                                            ['positionRecently'],
                                        event['listEventsWithFilter'][index]
                                            ['state'],
                                        event['listEventsWithFilter'][index]
                                            ['videoPub'],
                                      event['listEventsWithFilter'][index]
                                      ['allTicket'],
                                      event['listEventsWithFilter'][index]
                                      ['authorId'],
                                      event['listEventsWithFilter'][index]
                                      ['cumulGain'],
                                      event['listEventsWithFilter'][index]
                                      ['authorId'] == user!.ident,
                                      event['listEventsWithFilter'][index]
                                      ['state'],
                                      event['listEventsWithFilter'][index]
                                      ['favorie'],
                                    )));
                              },
                              child: Container(
                                width: double.infinity,
                                height: 235,
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      child: Hero(
                                        tag: index,
                                        child: Image.network(
                                            "${ConsumeAPI.AssetEventServer}${event['listEventsWithFilter'][index]['imageCover']}",
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      height: 235,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: [
                                              const Color(0x00000000),
                                              const Color(0x99111100),
                                            ],
                                                begin:
                                                    FractionalOffset(0.0, 0.0),
                                                end: FractionalOffset(
                                                    0.0, 1.0))),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                                event['listEventsWithFilter']
                                                        [index]['title']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: Style.titreEvent(20),
                                                textAlign: TextAlign.center),
                                            SizedBox(height: 10.0),
                                            Text(
                                                event['listEventsWithFilter']
                                                    [index]['position'],
                                                style: Style.sousTitreEvent(15),
                                                maxLines: 2,
                                                textAlign: TextAlign.center),
                                            SizedBox(height: 25.0),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    SizedBox(width: 10.0),
                                                    Icon(Icons.favorite,
                                                        color: Colors.redAccent,
                                                        size: 22.0),
                                                    Text(
                                                      event['listEventsWithFilter']
                                                                  [index]
                                                              ['numberFavorite']
                                                          .toString(),
                                                      style: Style
                                                          .titleInSegment(),
                                                    ),
                                                    SizedBox(width: 20.0),
                                                    Icon(
                                                        Icons
                                                            .account_balance_wallet,
                                                        color: Colors.white,
                                                        size: 22.0),
                                                    SizedBox(width: 5.0),
                                                    Text(
                                                      event['listEventsWithFilter']
                                                          [index]['price'][0]['price'],
                                                      style: Style
                                                          .titleInSegment(),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                        Icons.person_pin_circle,
                                                        color: Colors.white,
                                                        size: 22.0),
                                                    Text(
                                                        (positionRecently[
                                                                    'longitude'] ==
                                                                0)
                                                            ? 'N/A'
                                                            : '2.2 Km',
                                                        style: Style
                                                            .titleInSegment()),
                                                    SizedBox(width: 10.0)
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15.0),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                );
            }
          }),
      floatingActionButton: FloatingActionButton(
        elevation: 20.0,
        onPressed: () {
          Navigator.pushNamed(context, user!.isActivateForfait == 0 ? ExplainEvent.rootName: CreateEvent.rootName);
        },
        backgroundColor: colorText,
        child: Icon(Icons.add, color: Colors.white, size: 22.0),
      ),
    );
  }
}
