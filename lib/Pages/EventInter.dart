import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/CreateEvent.dart';
import 'package:shouz/Pages/explication_event.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

import '../Models/User.dart';
import '../Utils/Database.dart';
import './EventDetails.dart';
import 'ChoiceOtherHobie.dart';
import 'package:shouz/Constant/widget_common.dart';

class EventInter extends StatefulWidget {
  @override
  _EventInterState createState() => _EventInterState();
}

class _EventInterState extends State<EventInter> {
  User? user;
  late Future<Map<String, dynamic>> eventFull;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    getUser();
    eventFull = consumeAPI.getEvents();
  }

  getUser() async {
    User newClient = await DBProvider.db.getClient();
    setState(() {
      user = newClient;
    });
  }

  @override
  void dispose() {

    super.dispose();

  }
  Future loadEvents() async {
    setState(() {
      eventFull = consumeAPI.getEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: loadEvents,
        child: FutureBuilder(
            future: eventFull,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return isErrorSubscribe(context);
                case ConnectionState.waiting:
                  return Column(children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return loadDataSkeletonOfEvent(context);
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
                          return loadDataSkeletonOfEvent(context);
                        },
                      ),
                    )
                  ]);

                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return isErrorSubscribe(context);
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
                                          0,
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
                                                          Icons.alarm,
                                                          color: Colors.white,
                                                          size: 22.0),
                                                      Text(DateTime.parse(event['listEventsWithFilter']
                                                      [index]['enventDate']).day.toString() +
                                                          '/' +
                                                          DateTime.parse(event['listEventsWithFilter']
                                                          [index]['enventDate'])
                                                              .month
                                                              .toString() +
                                                          '/' +
                                                          DateTime.parse(event['listEventsWithFilter']
                                                          [index]['enventDate'])
                                                              .year
                                                              .toString()+
                                                          ' à ' +
                                                          DateTime.parse(event['listEventsWithFilter']
                                                          [index]['enventDate'])
                                                              .hour
                                                              .toString() +
                                                          'h:' +
                                                          DateTime.parse(event['listEventsWithFilter']
                                                          [index]['enventDate'])
                                                              .minute
                                                              .toString(),
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
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 20.0,
        onPressed: () {
          if(user!.isActivateForfait != 0) {
            Navigator.pushNamed(context, CreateEvent.rootName);
          } else {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) => ExplicationEvent(key: UniqueKey(), typeRedirect: 1)));
          }

        },
        backgroundColor: colorText,
        child: Icon(Icons.add, color: Colors.white, size: 22.0),
      ),
    );
  }
}
