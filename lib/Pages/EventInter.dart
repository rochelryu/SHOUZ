import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/helper.dart';
import 'package:shouz/Pages/CreateEvent.dart';
import 'package:shouz/Pages/explication_event.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

import '../Models/User.dart';
import '../Utils/Database.dart';
import './EventDetails.dart';
import 'package:shouz/Constant/widget_common.dart';

import 'ExplainEvent.dart';
import 'choice_other_hobie_second.dart';

class EventInter extends StatefulWidget {
  @override
  _EventInterState createState() => _EventInterState();
}

class _EventInterState extends State<EventInter> {
  User? user;
  Map<String, dynamic>? eventFull;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  int level = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool loadingFull = true, isError = false;

  @override
  void initState() {
    super.initState();
    getUser();
    loadEvents();
    getExplainEventMethod();
    verifyIfUserHaveReadModalExplain();
  }

  Future getExplainEventMethod() async {
    try {
      int explainEvent = await getExplainEvent();
      setState(() {
        level = explainEvent;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  verifyIfUserHaveReadModalExplain() async {
    final prefs = await SharedPreferences.getInstance();
    final bool asRead = prefs.getBool('readEventModalExplain') ?? false;
    if(!asRead) {
      await modalForExplain("${ConsumeAPI.AssetPublicServer}Events.gif", "1/3 - Acheteur: Participe à des évènements en achetant des tickets directement dans l'application par mobile money, crypto-monnaie ou carte bancaire, tu as la possibilité de partager tes tickets à tes amis ou de demander un rembourssement en cas d'indisponibilité de ta part.", context);
      await modalForExplain("${ConsumeAPI.AssetPublicServer}Events.gif", "2/3 - Promotteur: Crée tes propres évènements nous générons tes tickets. Nous assurons la gestion et la vente des tickets, les statistiques de ventes, la sécurité des achats, la vérifications des tickets lors de l'évènement.", context);
      await modalForExplain("${ConsumeAPI.AssetPublicServer}Events.gif", "3/3 - Nous tenons à rappeler que nous affichons uniquement les évènements dans SHOUZ en fonction de vos préférences, alors si vous voulez plus de contenu vous pouvez allez compléter vos centres d'intérêts dans l'onglet Préférences.", context);
      await prefs.setBool('readEventModalExplain', true);
    }
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final data = await consumeAPI.getEvents();
      setState(() {
        eventFull = data;
        loadingFull = false;
      });
      await prefs.setString('eventFull', jsonEncode(data));
    } catch (e) {
      final eventFullString = prefs.getString("eventFull");

      if(eventFullString != null) {
        setState(() {
          eventFull = jsonDecode(eventFullString) as Map<String, dynamic>;
        });
      }
      setState(() {
        isError = true;
        loadingFull = false;
      });
      await askedToLead(eventFull != null && eventFull?["listEventsWithFilter"].length > 0 ? "Aucune connection internet, donc nous vous affichons quelques évènement en mode hors ligne":"Aucune connection internet, veuillez vérifier vos données internet", false, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: loadEvents,
        child: LayoutBuilder(
        builder: (context,contraints) {
        if(loadingFull){
          if(eventFull != null && eventFull?['listEventsWithFilter'].length > 0) {
            var event = eventFull!;
            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      itemCount: event['listEventsWithFilter'].length,
                      itemBuilder: (context, index) {
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
                                                  [index]['price'][0]['price'].toString().toUpperCase() == "GRATUIT" ? event['listEventsWithFilter'][index]['price'][0]['price'] : reformatNumberForDisplayOnPrice(event['listEventsWithFilter'][index]['price'][0]['price']),
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
          return Column(children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return loadDataSkeletonOfEvent(context);
                },
              ),
            )
          ]);

        } else if(!loadingFull && isError && eventFull == null) {
          return isErrorSubscribe(context);
        } else {
          var event = eventFull!;
          if (event['listEventsWithFilter'].length == 0) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        "images/emptyevent.svg",
                        semanticsLabel: 'Shouz event empty',
                        height: MediaQuery.of(context).size.height * 0.35,
                      ),
                      Text(
                          "Aucun Evenement Populaires pour le moment selon vos centres d'intérêts",
                          textAlign: TextAlign.center,
                          style: Style.sousTitreEvent(15)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push((MaterialPageRoute(
                              builder: (context) => ChoiceOtherHobieSecond(key: UniqueKey()))));
                        },
                        child: Text('Ajouter Préférence'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: colorPrimary, backgroundColor: colorText,
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
                                  child: CachedNetworkImage(
                                    imageUrl: "${ConsumeAPI.AssetEventServer}${event['listEventsWithFilter'][index]['imageCover']}",
                                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                                        Center(
                                            child: CircularProgressIndicator(value: downloadProgress.progress)),
                                    errorWidget: (context, url, error) => notSignal(),
                                    fit: BoxFit.cover,
                                  ),
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
        }}
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 20.0,
        onPressed: () {
          if(user!.isActivateForfait != 0) {
            Navigator.pushNamed(context, CreateEvent.rootName);
          } else {
            if(level == 0){
              setExplain(2, "event");
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) => ExplicationEvent(key: UniqueKey(), typeRedirect: 1)));
            } else {
              Navigator.pushNamed(context, ExplainEvent.rootName);
            }

          }

        },
        backgroundColor: colorText,
        child: Icon(Icons.add, color: Colors.white, size: 22.0),
      ),
    );
  }
}
