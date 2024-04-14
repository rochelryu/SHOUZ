import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

import '../Constant/event_item.dart';
import '../Models/User.dart';
import '../Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'VoteEventScreen.dart';
import 'choice_other_hobie_second.dart';
import 'choice_type_event_create.dart';

class EventInter extends StatefulWidget {
  @override
  _EventInterState createState() => _EventInterState();
}

class _EventInterState extends State<EventInter>  with SingleTickerProviderStateMixin {
  User? user;
  Map<String, dynamic>? eventFull;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  int currentTabIdex = 0;
  late TabController _controller;
  int level = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorEventKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorVoteKey = GlobalKey<RefreshIndicatorState>();
  bool loadingFull = true, isError = false;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this, initialIndex: currentTabIdex);
    getUser();
    loadEvents();
    getExplainEventMethod();
    //verifyIfUserHaveReadModalExplain();
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
      await modalForExplain("${ConsumeAPI.AssetPublicServer}Events.gif", "1/3 - Acheteur: 1️⃣ Participe à des évènements en achetant des tickets directement dans l'application par mobile money, crypto-monnaie ou carte bancaire, tu as la possibilité de partager tes tickets à tes amis ou de demander un rembourssement en cas d'indisponibilité de ta part.", context);
      await modalForExplain("${ConsumeAPI.AssetPublicServer}Events.gif", "2/3 - Promotteur: 2️⃣ Crée tes propres évènements nous générons tes tickets. Nous assurons la gestion et la vente des tickets, les statistiques de ventes, la sécurité des achats, la vérifications des tickets lors de l'évènement.", context);
      await modalForExplain("${ConsumeAPI.AssetPublicServer}Events.gif", "3/3 - Nous tenons à rappeler que nous affichons uniquement les évènements dans SHOUZ en fonction de vos préférences, alors si vous voulez plus de contenu vous pouvez allez compléter vos centres d'intérêts dans l'onglet Préférences.", context);
      await prefs.setBool('readEventModalExplain', true);
    }
  }

  getUser() async {
    User newClient = await DBProvider.db.getClient();
    if(newClient.numero != 'null') {
      setState(() {
        user = newClient;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
  Future loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted) {
      try {
        final events = await consumeAPI.getEvents();
        final votes = await consumeAPI.getVoteEvents();
        final data = {...events, ...votes};
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Container(
            height: 35,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: backgroundColorSec
            ),
            child: TabBar(
              dividerHeight: 0,
              controller: _controller,
              labelColor: Style.white,
              unselectedLabelColor: colorSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                  color: colorText,
                  borderRadius: BorderRadius.circular(20)
              ),
              tabs: [
                Tab(
                  text: "Events",
                ),
                Tab(
                  text: "Votes",
                ),
              ],
            ),
          ),
          Expanded(child: TabBarView(
            controller: _controller,
            children: [
              RefreshIndicator(
                key: _refreshIndicatorEventKey,
                onRefresh: loadEvents,
                child: LayoutBuilder(
                    builder: (context,contraints) {
                      if(loadingFull){
                        if(eventFull != null && eventFull?['listEventsWithFilter'].length > 0) {
                          var event = eventFull!;
                          return ListView.builder(
                              itemCount: event['listEventsWithFilter'].length,
                              itemBuilder: (context, index) {
                                final infoEvent = event['listEventsWithFilter'][index];
                                return EventItem(index:index, infoEvent:infoEvent, comeBack: 0, user: user);
                              });
                        }
                        return ListView.builder(
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return loadDataSkeletonOfEvent(context);
                          },
                        );

                      } else if(!loadingFull && isError && eventFull == null) {
                        return isErrorSubscribe(context);
                      } else {
                        var event = eventFull!;
                        if (event['listEventsWithFilter'].length == 0) {
                          return Column(
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
                              ]);
                        }
                        return ListView.builder(
                            itemCount: event['listEventsWithFilter'].length,
                            itemBuilder: (context, index) {
                              final infoEvent = event['listEventsWithFilter'][index];
                              return EventItem(index:index, infoEvent:infoEvent, comeBack: 0, user: user);
                            });
                      }}
                ),
              ),
              RefreshIndicator(
                key: _refreshIndicatorVoteKey,
                onRefresh: loadEvents,
                child: LayoutBuilder(
                    builder: (context,contraints) {
                      if(loadingFull){
                        if(eventFull != null && eventFull?['listVoteEvents'].length > 0) {
                          var event = eventFull!;
                          return VoteScreen(allVoteEvent: event['listVoteEvents']);
                        }
                        return ListView.builder(
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return loadDataSkeletonOfEvent(context);
                          },
                        );

                      } else if(!loadingFull && isError && eventFull == null) {
                        return isErrorSubscribe(context);
                      } else {
                        var event = eventFull!;
                        if (event['listVoteEvents'].length == 0) {
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "images/emptyevent.svg",
                                  semanticsLabel: 'Shouz event empty',
                                  height: MediaQuery.of(context).size.height * 0.35,
                                ),
                                Text(
                                    "Aucun Vôte disponible pour le moment selon vos centres d'intérêts",
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
                              ]);
                        }
                        return VoteScreen(allVoteEvent: event['listVoteEvents']);
                      }}
                ),
              ),


            ],
          )),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 20.0,
        shape: CircleBorder(),
        onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => ChoiceTypeEventCreate(
                        key: UniqueKey(),
                        isActivateForfait: user!= null && user!.isActivateForfait != 0,
                      level: level,
                    )
                )
            );

        },
        backgroundColor: colorText,
        child: Icon(Icons.add, color: Colors.white, size: 22.0),
      ),
    );
  }
}
