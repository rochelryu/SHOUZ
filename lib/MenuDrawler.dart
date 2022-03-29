import 'dart:io';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/ChoiceOtherHobie.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

import './Constant/my_flutter_app_second_icons.dart' as prefix1;
import './Pages/Actualite.dart';
import './Pages/Covoiturage.dart';
import './Pages/Deals.dart';
import './Pages/EventInter.dart';
import './Pages/Notifications.dart';
import './Pages/Profil.dart';
import './Pages/Setting.dart';
import './Pages/WidgetPage.dart';
import 'Provider/AppState.dart';

class MenuDrawler extends StatefulWidget {
  static String rootName = '/menuDrawler';

  @override
  _MenuDrawlerState createState() => _MenuDrawlerState();
}

class _MenuDrawlerState extends State<MenuDrawler>
    with SingleTickerProviderStateMixin {
  late AppState appState;
  bool isCollasped = false;
  bool showBadge = true;
  String id = '';
  late double screenWidth, screenHeight;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  User? newClient;
  late String statusPermission;
  List<Widget> menus = [Actualite(), Deals(), EventInter(), Covoiturage()];

  int numberConnected = 0;

  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    super.initState();
    loadInfo();
    _controller =
        AnimationController(vsync: this, duration: prefix0.transitionMedium);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  loadInfo() async {
    User user = await DBProvider.db.getClient();
    setState(() {
      newClient = user;
      id = newClient!.ident;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context, listen: true);
    final numberNotif = appState.getNumberNotif;
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return Scaffold(
      backgroundColor: prefix0.backgroundColor,
      body: Stack(
        children: <Widget>[
          menu(context, numberNotif),
          dashboard(context, numberNotif),
        ],
      ),
    );
  }

  Widget menu(context, int numberNotif) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            newClient != null ? Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.00),
                      image: DecorationImage(
                        image: NetworkImage("${ConsumeAPI.AssetProfilServer}${newClient!.images}"),
                        fit: BoxFit.cover,
                      )),
                ) : Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.00),
                        image: DecorationImage(
                            image: AssetImage("images/logos.png"),
                        fit: BoxFit.cover,
                      )),
                ),
                SizedBox(height: 10),
                Container(
                  width: 150,
                  child: Text(newClient != null ? newClient!.name : '',
                      style: prefix0.Style.titre(21), maxLines: 1),
                ),
                SizedBox(height: 5),
                Container(
                  width: 150,
                  child: Text((newClient != null) ? newClient!.position : '',
                      style: prefix0.Style.sousTitre(13)),
                ),
                SizedBox(height: 40),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () {
                    Navigator.of(context).push(
                        (MaterialPageRoute(builder: (context) => Profil())));
                  },
                  leading: Icon(Icons.account_circle, color: Colors.white),
                  title:
                      Text("Profil", style: prefix0.Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () {
                    Navigator.of(context).push((MaterialPageRoute(
                        builder: (context) => ChoiceOtherHobie())));
                  },
                  leading: Icon(Icons.favorite, color: Colors.white),
                  title: Text("Préférences",
                      style: prefix0.Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () async {
                    appState.setNumberNotif(0);
                    Navigator.of(context).push((MaterialPageRoute(
                        builder: (context) => Notifications())));
                  },
                  leading: Stack(children: <Widget>[
                    Icon(Icons.notifications, color: Colors.white),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: numberNotif != 0
                          ? Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                color: prefix0.colorText,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: Text(
                                numberNotif.toString(),
                                style: TextStyle(color: Colors.white),
                              )),
                            )
                          : Container(),
                    ),
                  ]),
                  title: Text("Notifications",
                      style: prefix0.Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () {
                    Navigator.of(context).push((MaterialPageRoute(
                        builder: (context) => WidgetPage())));
                  },
                  leading: Icon(Icons.widgets, color: Colors.white),
                  title:
                      Text("Outils", style: prefix0.Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () {
                    Navigator.of(context).push(
                        (MaterialPageRoute(builder: (context) => Setting())));
                  },
                  leading: Icon(Icons.settings, color: Colors.white),
                  title: Text("Paramettre",
                      style: prefix0.Style.menuStyleItem(16.0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dashboard(context, int numberNotif) {
    bool isIos = Platform.isIOS;
    if (numberConnected <= 2) {
      final appState = Provider.of<AppState>(context);
      try {
        appState.setJoinConnected(id);
          numberConnected++;
      } catch (e) {
        print(e);
      }
    }
    return AnimatedPositioned(
      top: isCollasped ? 0.15 * screenHeight : 0,
      left: isCollasped ? 0.5 * screenWidth : 0,
      right: isCollasped ? -0.4 * screenWidth : 0,
      bottom: isCollasped ? 0.15 * screenWidth : 0,
      duration: prefix0.transitionMedium,
      child: Material(
        animationDuration: prefix0.transitionMedium,
        borderRadius: BorderRadius.circular(10.0),
        elevation: 8,
        color: prefix0.backgroundColor,
        child: Scaffold(
          backgroundColor: prefix0.backgroundColor,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: prefix0.backgroundColor,
            leading: Stack(children: <Widget>[
              IconButton(
                icon: Icon(prefix0.Style.menu, color: Colors.white),
                onPressed: () {
                  setState(() {
                    showBadge = !showBadge;
                    if (isCollasped) {
                      _controller.reverse();
                    } else {
                      _controller.forward();
                    }
                    isCollasped = !isCollasped;
                  });
                },
              ),
              Positioned(
                top: 2,
                right: 2,
                child: showBadge && numberNotif != 0
                    ? Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          color: prefix0.colorText,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(numberNotif.toString()),
                        ),
                      )
                    : Container(),
              ),
            ]),
          ),
          body: menus[appState.getIndexBottomBar],
          bottomNavigationBar: (!isCollasped)
              ? CurvedNavigationBar(
                  index: appState.getIndexBottomBar,
                  onTap: (index) {
                    appState.setIndexBottomBar(index);
                  },
                  height: isIos ? 65.0 : 50.0,
                  color: prefix0.tint,
                  buttonBackgroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  //animationCurve: Curves.linearToEaseOut,
                  animationDuration: Duration(milliseconds: 700),
                  items: <Widget>[
                    /*
              Badge(
                badgeContent: Text('3'),
                child: Icon(Icons.fiber_new, size: 30, color: (appState.getIndexBottomBar == 0)? Colors.white : Colors.grey),
              ),
              Badge(
                badgeContent: Text('3'),
                child: Icon(Icons.store_mall_directory, size: 30, color: (appState.getIndexBottomBar == 1)? Colors.white : Colors.grey),
              ),
              Badge(
                badgeContent: Text('3'),
                child: Icon(Icons.event_available, size: 30, color: (appState.getIndexBottomBar == 2)? Colors.white : Colors.grey),
              ),
              Badge(
                badgeContent: Text('3'),
                child: Icon(Icons.directions_car, size: 30, color: (appState.getIndexBottomBar == 3)? Colors.white : Colors.grey),
              ),
               */
                    Icon(prefix1.MyFlutterAppSecond.newspaper,
                        size: 30,
                        color: (appState.getIndexBottomBar == 0) ? prefix0.tint : Colors.white),
                    Icon(prefix1.MyFlutterAppSecond.shop,
                        size: 30,
                        color: (appState.getIndexBottomBar == 1) ? prefix0.tint : Colors.white),
                    Icon(prefix1.MyFlutterAppSecond.calendar,
                        size: 30,
                        color: (appState.getIndexBottomBar == 2) ? prefix0.tint : Colors.white),
                    Icon(prefix1.MyFlutterAppSecond.destination,
                        size: 30,
                        color: (appState.getIndexBottomBar == 3) ? prefix0.tint : Colors.white),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
