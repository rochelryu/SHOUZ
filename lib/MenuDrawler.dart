import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:url_launcher/url_launcher.dart';

import './Constant/my_flutter_app_second_icons.dart' as prefix1;
import './Pages/Actualite.dart';
import './Pages/Covoiturage.dart';
import './Pages/Deals.dart';
import './Pages/EventInter.dart';
import './Pages/Notifications.dart';
import './Pages/Profil.dart';
import './Pages/Setting.dart';
import './Pages/WidgetPage.dart';
import 'Constant/helper.dart';
import 'Constant/my_flutter_app_second_icons.dart';
import 'Pages/choice_other_hobie_second.dart';
import 'Pages/wallet_page.dart';
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
  List<String> titleDomain = ['Actualité', 'E-commerce', 'Événementiel', 'Covoiturage'];

  int numberConnected = 0;
  ConsumeAPI consumeAPI =new ConsumeAPI();

  @override
  void initState() {
    super.initState();
    loadInfo();
    getTokenForNotificationProvider();
    _controller =
        AnimationController(vsync: this, duration: transitionMedium);
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
    try {
      final getLatestVersionApp = await consumeAPI.getLatestVersionApp();
      if(getLatestVersionApp['playstore'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final versionning = prefs.getString("versionning");
        if(versionning != null) {
          final versionInApp = jsonDecode(versionning) as dynamic;
          if(Platform.isAndroid) {
            if(await isHms()) {
              if(versionInApp['appGallery'] != getLatestVersionApp['appGallery']) {
                await prefs.setString('versionning', jsonEncode(getLatestVersionApp));
                await modalForExplain("images/updateApp.png", "Une nouvelle version de l'application est disponible, pensez à mettre à jour l'application pour garantir la sécurité de tous vos contenus.", context);
                await launchUrl(Uri.parse(linkAppGalleryForShouz), mode: LaunchMode.externalApplication);
              }
            } else {
              if(versionInApp['playstore'] != getLatestVersionApp['playstore']) {
                await prefs.setString('versionning', jsonEncode(getLatestVersionApp));
                await modalForExplain("images/updateApp.png", "Une nouvelle version de l'application est disponible, pensez à mettre à jour l'application pour garantir la sécurité de tous vos contenus.", context);
                await launchUrl(Uri.parse(linkPlayStoreForShouz), mode: LaunchMode.externalApplication);
              }
            }
          } else {
            if(versionInApp["appleStore"] != getLatestVersionApp['appleStore']){
              await prefs.setString('versionning', jsonEncode(getLatestVersionApp));
              await modalForExplain("images/updateApp.png", "Une nouvelle version de l'application est disponible, pensez à mettre à jour l'application pour garantir la sécurité de tous vos contenus.", context);
              await launchUrl(Uri.parse(linkAppleStoreForShouz), mode: LaunchMode.externalApplication);
            }
          }
        }
        else {
          if(Platform.isAndroid) {
            if(await isHms()) {
              if("1.0.5" != getLatestVersionApp['appGallery']) {
                await prefs.setString('versionning', jsonEncode(getLatestVersionApp));
                await modalForExplain("images/updateApp.png", "Une nouvelle version de l'application est disponible, pensez à mettre à jour l'application pour garantir la sécurité de tous vos contenus.", context);
                await launchUrl(Uri.parse(linkAppGalleryForShouz), mode: LaunchMode.externalApplication);
              }
            } else {
              if("1.0.5" != getLatestVersionApp['playstore']) {
                await prefs.setString('versionning', jsonEncode(getLatestVersionApp));
                await modalForExplain("images/updateApp.png", "Une nouvelle version de l'application est disponible, pensez à mettre à jour l'application pour garantir la sécurité de tous vos contenus.", context);
                await launchUrl(Uri.parse(linkPlayStoreForShouz), mode: LaunchMode.externalApplication);
              }
            }
          } else {
            if("1.0.5" != getLatestVersionApp['appleStore']){
              await prefs.setString('versionning', jsonEncode(getLatestVersionApp));
              await modalForExplain("images/updateApp.png", "Une nouvelle version de l'application est disponible, pensez à mettre à jour l'application pour garantir la sécurité de tous vos contenus.", context);
              await launchUrl(Uri.parse(linkAppleStoreForShouz), mode: LaunchMode.externalApplication);
            }
          }
        }
      }

    } catch(e) {

    }
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
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: <Widget>[
            menu(context, numberNotif),
            dashboard(context, numberNotif),
          ],
        ),
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
                      style: Style.titre(21), maxLines: 1),
                ),
                SizedBox(height: 5),
                Container(
                  width: 150,
                  child: Text((newClient != null) ? newClient!.position : '',
                      style: Style.sousTitre(13)),
                ),
                SizedBox(height: 40),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () {
                    Navigator.of(context).push(
                        (MaterialPageRoute(builder: (context) => Profil())));
                  },
                  leading: Icon(Icons.account_circle_outlined, color: Colors.white),
                  title:
                      Text("Profil", style: Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () {
                    Navigator.pushNamed(context, WalletPage.rootName);
                  },
                  leading: Icon(MyFlutterAppSecond.credit_card, color: Colors.white),
                  title: Text("Portefeuille",
                      style: Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () {
                    Navigator.of(context).push((MaterialPageRoute(
                        builder: (context) => ChoiceOtherHobieSecond(key: UniqueKey(),))));
                  },
                  leading: Icon(Icons.favorite_outline, color: Colors.white),
                  title: Text("Préférences",
                      style: Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () {
                    Navigator.of(context).push((MaterialPageRoute(
                        builder: (context) => WidgetPage())));
                  },
                  leading: Icon(Icons.widgets_outlined, color: Colors.white),
                  title:
                      Text("Outils", style: Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () {
                    Navigator.of(context).push(
                        (MaterialPageRoute(builder: (context) => Setting())));
                  },
                  leading: Icon(Icons.settings_outlined, color: Colors.white),
                  title: Text("Paramètres",
                      style: Style.menuStyleItem(16.0)),
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
      duration: transitionMedium,
      child: Material(
        animationDuration: transitionMedium,
        borderRadius: BorderRadius.circular(10.0),
        elevation: 8,
        color: backgroundColor,
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: backgroundColor,
            leading: InkWell(
              child: Icon(Style.menu, color: Colors.white),
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  if (isCollasped) {
                    _controller.reverse();
                  } else {
                    _controller.forward();
                  }
                  isCollasped = !isCollasped;
                });
              },
            ),
            title: Text(titleDomain[appState.getIndexBottomBar]),
            centerTitle: true,
            actions: [
              Badge(
                  position: BadgePosition(top: 0, start: 0),
                  badgeColor: colorText,
                  badgeContent: Text(numberNotif.toString(),style: TextStyle(color: Colors.white),),
                  showBadge: numberNotif != 0,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push((MaterialPageRoute(
                          builder: (context) => Notifications())));
                    },
                    icon: Icon(numberNotif > 0 ? Icons.notifications_active :Icons.notifications_none, color: Colors.white)
                  )
              ),
            ],
          ),
          body: menus[appState.getIndexBottomBar],
          bottomNavigationBar: (!isCollasped)
              ? CurvedNavigationBar(
                  index: appState.getIndexBottomBar,
                  onTap: (index) {
                    appState.setIndexBottomBar(index);
                  },
                  height: isIos ? 65.0 : 50.0,
                  color: tint,
                  buttonBackgroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  //animationCurve: Curves.linearToEaseOut,
                  animationDuration: Duration(milliseconds: 700),
                  items: <Widget>[
                    Icon(prefix1.MyFlutterAppSecond.newspaper,
                        size: 30,
                        color: (appState.getIndexBottomBar == 0) ? tint : Colors.white),
                    Icon(prefix1.MyFlutterAppSecond.shop,
                        size: 30,
                        color: (appState.getIndexBottomBar == 1) ? tint : Colors.white),
                    Icon(prefix1.MyFlutterAppSecond.calendar,
                        size: 30,
                        color: (appState.getIndexBottomBar == 2) ? tint : Colors.white),
                    Icon(prefix1.MyFlutterAppSecond.destination,
                        size: 30,
                        color: (appState.getIndexBottomBar == 3) ? tint : Colors.white),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
