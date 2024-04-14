import 'dart:io';
import 'package:badges/badges.dart' as badges;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
//import 'package:shouz/Pages/Covoiturage.dart';
import 'package:shouz/Pages/Login.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:url_launcher/url_launcher.dart';

import './Constant/my_flutter_app_second_icons.dart' as prefix1;
import './Pages/Actualite.dart';

import './Pages/EventInter.dart';
import './Pages/Notifications.dart';
import './Pages/Profil.dart';
import './Pages/Setting.dart';
import './Pages/WidgetPage.dart';
import 'Constant/helper.dart';
import 'Constant/my_flutter_app_second_icons.dart';
import 'Pages/Covoiturage.dart';
import 'Pages/all_categorie_deals_choice.dart';
import 'Pages/choice_other_hobie_second.dart';
import 'Pages/not_available.dart';
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
  bool isCollasped = false, update = false;
  bool showBadge = true;
  String id = '';
  late double screenWidth, screenHeight;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  User? newClient;
  int logged = 0;
  late String statusPermission;
  List<Widget> menus = [
    Actualite(),
    AllCategorieDealsChoice(
      key: UniqueKey(),
    ),
    EventInter(),
    Covoiturage(),
    // NotAvailable(
    //   key: UniqueKey(),
    // ),
  ];
  List<String> titleDomain = [
    'Actualité',
    'E-commerce',
    'Événementiel',
    'Covoiturage & VTC'
  ];

  int numberConnected = 0;
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    super.initState();
    loadInfo();

    _controller = AnimationController(vsync: this, duration: transitionMedium);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    //WidgetsBinding.instance.addPostFrameCallback((timeStamp) {(_) => showOverLayDealsBasic();});
  }

  loadInfo() async {
    try {
      User user = await DBProvider.db.getClient();
      setState(() {
        newClient = user;
        id = newClient!.ident;
      });
      if (user.tokenNotification == "ONE_SIGNAL" || user.tokenNotification == "") {
        try {
          await getTokenForNotificationProvider(true);
        } catch (e) {
          print("Token  non mis à jour au backend");
        }
      }
      if (user.numero == '' || user.numero == 'null') {
        setState(() {
          logged = -1;
        });
      }
      final getLatestVersionApp = await consumeAPI.getLatestVersionApp();
      if (getLatestVersionApp['playstore'] != null) {
        if (Platform.isAndroid) {
          if (await isHms()) {
            if (versionApp != getLatestVersionApp['appGallery']) {
              setState(() {
                update = true;
              });
            } else {
              final notificationCenter =
                  await consumeAPI.getLatestInfoNotificationInApp();
              if (notificationCenter['etat'] == "found") {
                final result = notificationCenter['result'];
                await displayNotificationCenter(
                  result['imgUrl'],
                  result['title'],
                  result['body'],
                  result['data'],
                  context,
                );
              }
            }
          } else {
            if (versionApp != getLatestVersionApp['playstore']) {
              setState(() {
                update = true;
              });
            } else {
              final notificationCenter =
                  await consumeAPI.getLatestInfoNotificationInApp();
              if (notificationCenter['etat'] == "found") {
                final result = notificationCenter['result'];
                await displayNotificationCenter(
                  result['imgUrl'],
                  result['title'],
                  result['body'],
                  result['data'],
                  context,
                );
              }
            }
          }
        } else {
          if (versionApp != getLatestVersionApp['appleStore']) {
            setState(() {
              update = true;
            });
          } else {
            final notificationCenter =
                await consumeAPI.getLatestInfoNotificationInApp();
            if (notificationCenter['etat'] == "found") {
              final result = notificationCenter['result'];
              await displayNotificationCenter(
                result['imgUrl'],
                result['title'],
                result['body'],
                result['data'],
                context,
              );
            }
          }
        }
      }

    } catch (e) {
      print("Erreur de get vervion");
      if(e.toString().contains('User')) {
        logout();
      }
      print(e.toString());

    }
  }

  Future logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await DBProvider.db.delProfil();
    final result = await consumeAPI.createUserToAvoidInfo();
    await DBProvider.db.delClient();
    await DBProvider.db.newClient(result["user"]);
    await loadInfo();
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
        onTap: () {
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
                newClient != null && newClient!.images != ''
                    ? Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.00),
                            image: DecorationImage(
                              image: NetworkImage(
                                  "${ConsumeAPI.AssetProfilServer}${newClient!.images}"),
                              fit: BoxFit.cover,
                            )),
                      )
                    : Container(
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
                  onTap: () async {
                    if (newClient != null && newClient?.numero.length == 10) {
                      Navigator.of(context).push(
                          (MaterialPageRoute(builder: (context) => Profil())));
                    } else {
                      await modalForExplain(
                          "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                          "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
                          context,
                          true);
                      Navigator.pushNamed(context, Login.rootName);
                    }
                  },
                  leading:
                      Icon(Icons.account_circle_outlined, color: Colors.white),
                  title: Text("Profil", style: Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () async {
                    if (newClient != null && newClient?.numero.length == 10) {
                      Navigator.pushNamed(context, WalletPage.rootName);
                    } else {
                      await modalForExplain(
                          "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                          "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
                          context,
                          true);
                      Navigator.pushNamed(context, Login.rootName);
                    }
                  },
                  leading:
                      Icon(MyFlutterAppSecond.credit_card, color: Colors.white),
                  title: Text("Portefeuille", style: Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () async {
                    if (newClient != null && newClient?.numero.length == 10) {
                      Navigator.of(context).push((MaterialPageRoute(
                          builder: (context) => ChoiceOtherHobieSecond(
                                key: UniqueKey(),
                              ))));
                    } else {
                      await modalForExplain(
                          "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                          "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
                          context,
                          true);
                      Navigator.pushNamed(context, Login.rootName);
                    }
                  },
                  leading: Icon(Icons.favorite_outline, color: Colors.white),
                  title: Text("Préférences", style: Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () async {
                    if (newClient != null && newClient?.numero.length == 10) {
                      Navigator.of(context).push((MaterialPageRoute(
                          builder: (context) => WidgetPage())));
                    } else {
                      await modalForExplain(
                          "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                          "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
                          context,
                          true);
                      Navigator.pushNamed(context, Login.rootName);
                    }
                  },
                  leading: Icon(Icons.widgets_outlined, color: Colors.white),
                  title: Text("Outils", style: Style.menuStyleItem(16.0)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  onTap: () async {
                    if (newClient != null && newClient?.numero.length == 10) {
                      Navigator.of(context).push(
                          (MaterialPageRoute(builder: (context) => Setting())));
                    } else {
                      await modalForExplain(
                          "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                          "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
                          context,
                          true);
                      Navigator.pushNamed(context, Login.rootName);
                    }
                  },
                  leading: Icon(Icons.settings_outlined, color: Colors.white),
                  title: Text("Paramètres", style: Style.menuStyleItem(16.0)),
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
        if (id != "" && id != 'ident' && newClient?.numero != '') {
          appState.setJoinConnected(id);
        }
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
            title: update
                ? TextButton(
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        if (await isHms()) {
                          await launchUrl(Uri.parse(linkAppGalleryForShouz),
                              mode: LaunchMode.externalApplication);
                        } else {
                          await launchUrl(Uri.parse(linkPlayStoreForShouz),
                              mode: LaunchMode.externalApplication);
                        }
                      } else {
                        await launchUrl(Uri.parse(linkAppleStoreForShouz),
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -8, end: -20),
                      badgeStyle: badges.BadgeStyle(
                          badgeColor: colorError,
                          shape: badges.BadgeShape.twitter),
                      badgeContent: Text(
                        ' ! ',
                        style: TextStyle(color: Colors.white),
                      ),
                      child: Text(
                        'Mettre à jour Shouz',
                        style: Style.titleNews(15),
                      ),
                    )
            )
                : Text(titleDomain[appState.getIndexBottomBar], style: Style.titleNews(),),
            centerTitle: true,
            actions: [
              if (newClient != null && newClient!.numero != 'null'  && newClient!.numero != '')
                badges.Badge(
                    position: badges.BadgePosition.topStart(top: 0, start: 0),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: colorText,
                    ),
                    badgeContent: Text(
                      numberNotif.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    showBadge: numberNotif != 0,
                    child: IconButton(
                        onPressed: () async {
                          Navigator.of(context).push((MaterialPageRoute(
                              builder: (context) => Notifications())));
                        },
                        icon: Icon(
                          numberNotif > 0
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                          color: Style.white,
                          size: 35,
                        )
                    )
                ),
              if (logged == -1)
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: badges.Badge(
                      position: badges.BadgePosition.topStart(top: 0, start: 0),
                      badgeStyle: badges.BadgeStyle(
                          badgeColor: colorError,
                          shape: badges.BadgeShape.twitter,
                        padding: EdgeInsets.all(3)
                      ),
                      badgeContent: Text(
                        ' ! ',
                        style: TextStyle(color: Style.white),
                      ),
                      child: IconButton(
                          onPressed: () async {
                            await modalForExplain(
                                "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                                "Nous allons créer votre compte ensemble et vous allez commencer à avoir accès à tous les avantages de SHOUZ.",
                                context,
                                true);
                            Navigator.pushNamed(context, Login.rootName);
                          },
                          icon: Icon(Icons.account_circle_outlined, size: 35,color: Style.white,))),
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
                        color: (appState.getIndexBottomBar == 0)
                            ? tint
                            : Colors.white),
                    Icon(prefix1.MyFlutterAppSecond.shop,
                        size: 30,
                        color: (appState.getIndexBottomBar == 1)
                            ? tint
                            : Colors.white),
                    Icon(prefix1.MyFlutterAppSecond.calendar,
                        size: 30,
                        color: (appState.getIndexBottomBar == 2)
                            ? tint
                            : Colors.white),
                    Icon(prefix1.MyFlutterAppSecond.destination,
                        size: 30,
                        color: (appState.getIndexBottomBar == 3)
                            ? tint
                            : Colors.white),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
