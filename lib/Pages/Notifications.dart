import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/VerifyUser.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Pages/wallet_page.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:badges/badges.dart' as badges;
import '../MenuDrawler.dart';
import '../Models/User.dart';
import '../Provider/AppState.dart';
import '../Provider/Notifications.dart';
import '../Utils/Database.dart';
import 'ChatDetails.dart';
import 'LoadHide.dart';
import 'Login.dart';
import 'choice_categorie_scan.dart';
import 'create_travel.dart';

class Notifications extends StatefulWidget {
  static String rootName = '/Notifications';
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>  with SingleTickerProviderStateMixin{
  late TabController _controller;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  int numberNotifDeals = 0, numberNotifEvent = 0, numberNotifCovoiturage = 0, numberNotifShouzPay = 0, type = 0;
  bool isToDelete = false;
  List<String> listNotificationDelete = [];

  late Future<Map<dynamic, dynamic>> notificationsFull;
  User? newClient;


  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
    getInfo();
    notificationsFull = consumeAPI.getAllNotif();
  }


  Future removeManyNotification(List<String> notificationsId, int type) async {
    final remove = await consumeAPI.removeManyNotification(notificationsId, type.toString());

    if (remove == "notFound") {
      showDialog(
          context: context,
          builder: (BuildContext context) => dialogCustomError(
              'Plusieurs connexions à ce compte',
              "Pour une question de sécurité nous allons devoir vous déconnecter.",
              context),
          barrierDismissible: false);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (builder) => Login()));
    } else {
      setState(() {
        isToDelete = false;
        listNotificationDelete = [];
        type = 0;
      });
      await getInfo();
      final allNotif = consumeAPI.getAllNotif();
      setState(() {
        notificationsFull = allNotif;
      });
    }

  }

  Future getInfo() async {
    User user = await DBProvider.db.getClient();
    try {
      setState(() {
        newClient = user;
      });
      final getAllNumberNotifByCategorie = await consumeAPI.getAllNumberNotifByCategorie();
      if(getAllNumberNotifByCategorie['etat'] != 'found') {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialogCustomError('Plusieurs connexions à ce compte', "Pour une question de sécurité nous allons devoir vous déconnecter.", context),
            barrierDismissible: false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => Login()));
      } else {
        setState(() {
          numberNotifDeals = getAllNumberNotifByCategorie['result']['numberNotifDeals'];
          numberNotifEvent = getAllNumberNotifByCategorie['result']['numberNotifEvent'];
          numberNotifCovoiturage = getAllNumberNotifByCategorie['result']['numberNotifCovoiturage'];
          numberNotifShouzPay = getAllNumberNotifByCategorie['result']['numberNotifShouzPay'];
        });
        await cancelAllAwesomeNotification();
      }

    } catch (e) {
      print("Erreur $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Style.white),
          onPressed: ()async {
            await Navigator.pushNamedAndRemoveUntil(context,MenuDrawler.rootName, (route) => route.isFirst);
          },
        ),
        title: Text('Notifications', style: Style.titleNews(),),
        centerTitle: true,
        backgroundColor: backgroundColor,

        actions: [
          if(isToDelete) badges.Badge(
              position: badges.BadgePosition.topStart(top: 0, start: 0),
              badgeStyle: badges.BadgeStyle(
                badgeColor: Style.white,
              ),
              badgeContent: Text(
                listNotificationDelete.length.toString(),
                style: TextStyle(color: colorError.withOpacity(0.75), fontSize: 12),
              ),
              showBadge: listNotificationDelete.length != 0,
              child: IconButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            dialogCustomForValidateAction(
                                'SUPPRIMER NOTIFICATION',
                                'Êtes vous sûr de vouloir supprimer ${listNotificationDelete.length > 1 ? 'ces' :'cette'} notification${listNotificationDelete.length > 1 ? 's' :''} ?',
                                'Oui',
                                    () async => await removeManyNotification(listNotificationDelete, type),
                                context),
                        barrierDismissible: false);
                  },
                  icon: Icon(
                    Icons.delete_outline_outlined,
                    color: colorError,
                    size: 35,
                  )
              )
          ),
        ],
        bottom: TabBar(
          controller: _controller,
          unselectedLabelColor: colorSecondary,
          labelColor: colorText,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          indicatorColor: colorText,
          physics: isToDelete ? NeverScrollableScrollPhysics() : const BouncingScrollPhysics() ,
          tabs: [
            Tab(
              child: badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -20, end: -20),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: colorText,
                  ),
                  badgeContent: Text(
                    numberNotifDeals.toString(),
                    style: TextStyle(color: Style.white),
                  ),
                  showBadge: numberNotifDeals != 0,
                  child: Text('Deals', maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            Tab(
              //icon: const Icon(Icons.shopping_cart),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -20, end: -20),
                badgeStyle: badges.BadgeStyle(
                  badgeColor: colorText,
                ),
                badgeContent: Text(
                  numberNotifEvent.toString(),
                  style: TextStyle(color: Style.white),
                ),
                showBadge: numberNotifEvent != 0,
                child: Text('Events', maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            Tab(
              //icon: const Icon(Icons.shopping_cart),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -20, end: -20),
                badgeStyle: badges.BadgeStyle(
                  badgeColor: colorText,
                ),
                badgeContent: Text(
                  numberNotifCovoiturage.toString(),
                  style: TextStyle(color: Style.white),
                ),
                showBadge: numberNotifCovoiturage != 0,
                child: Text('Voyages', maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            Tab(
              //icon: const Icon(Icons.shopping_cart),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -20, end: -20),
                badgeStyle: badges.BadgeStyle(
                  badgeColor: colorText,
                ),
                badgeContent: Text(
                  numberNotifShouzPay.toString(),
                  style: TextStyle(color: Style.white),
                ),
                showBadge: numberNotifShouzPay != 0,
                child: Text('ShouzPay', maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
      body:Container(
        height: MediaQuery.of(context).size.height,
        child: TabBarView(
          controller: _controller,
          children: <Widget>[
            FutureBuilder(
                future: notificationsFull,
                builder:
                    (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return isErrorSubscribe(context);
                    case ConnectionState.waiting:
                      return Column(children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 10.0,
                                    bottom: 5.0),
                                child: Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          backgroundColor,
                                          tint
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment
                                            .bottomRight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10.0),
                                              color: Colors
                                                  .grey[300]),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15.0),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: 100,
                                                  decoration: BoxDecoration(

                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 40,
                                          width: 40,
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
                              );
                            },
                          ),
                        )
                      ]);

                    case ConnectionState.active:
                      return Column(children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 10.0,
                                    bottom: 5.0),
                                child: Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          backgroundColor,
                                          tint
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment
                                            .bottomRight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10.0),
                                              color: Colors
                                                  .grey[300]),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15.0),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: 100,
                                                  decoration: BoxDecoration(

                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 40,
                                          width: 40,
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
                              );
                            },
                          ),
                        )
                      ]);

                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return isErrorSubscribe(context);
                      }
                      var notificationsDeals = snapshot.data;
                      if (notificationsDeals['result']['deals'].length == 0) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Center(
                              child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      "images/not_notification.svg",
                                      semanticsLabel: 'NotNotificationDeals',
                                      height:
                                      MediaQuery.of(context).size.height *
                                          0.39,
                                    ),
                                    Text(
                                        "Vous n'avez aucune notification de deals pour le moment",
                                        textAlign: TextAlign.center,
                                        style: Style.sousTitreEvent(15)),
                                    SizedBox(height: 20),

                                  ])),
                        );
                      }
                      return Column(
                        children: <Widget>[
                          Expanded(
                            child: displayNotifDeals(notificationsDeals['result']['deals']),
                          ),
                        ],
                      );
                  }
                }),
            FutureBuilder(
                future: notificationsFull,
                builder:
                    (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return isErrorSubscribe(context);
                    case ConnectionState.waiting:
                      return Column(children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 10.0,
                                    bottom: 5.0),
                                child: Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          backgroundColor,
                                          tint
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment
                                            .bottomRight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10.0),
                                              color: Colors
                                                  .grey[300]),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15.0),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: 100,
                                                  decoration: BoxDecoration(

                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 40,
                                          width: 40,
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
                              );
                            },
                          ),
                        )
                      ]);

                    case ConnectionState.active:
                      return Column(children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 10.0,
                                    bottom: 5.0),
                                child: Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          backgroundColor,
                                          tint
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment
                                            .bottomRight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10.0),
                                              color: Colors
                                                  .grey[300]),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15.0),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: 100,
                                                  decoration: BoxDecoration(

                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 40,
                                          width: 40,
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
                              );
                            },
                          ),
                        )
                      ]);

                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return isErrorSubscribe(context);
                      }
                      var notificationsEvents = snapshot.data;
                      if (notificationsEvents['result']['allEventNotif'].length == 0) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Center(
                              child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      "images/event_search.svg",
                                      semanticsLabel: 'NotNotificationEvent',
                                      height:
                                      MediaQuery.of(context).size.height *
                                          0.39,
                                    ),
                                    Text(
                                        "Vous n'avez aucune notification d'évènement pour le moment",
                                        textAlign: TextAlign.center,
                                        style: Style.sousTitreEvent(15)),
                                    SizedBox(height: 20),

                                  ])),
                        );
                      }
                      return Column(
                        children: <Widget>[
                          Expanded(
                            child: displayNotifEvents(notificationsEvents['result']['allEventNotif']),
                          ),
                        ],
                      );
                  }
                }),
            FutureBuilder(
                future: notificationsFull,
                builder:
                    (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return isErrorSubscribe(context);
                    case ConnectionState.waiting:
                      return Column(children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 10.0,
                                    bottom: 5.0),
                                child: Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          backgroundColor,
                                          tint
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment
                                            .bottomRight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10.0),
                                              color: Colors
                                                  .grey[300]),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15.0),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: 100,
                                                  decoration: BoxDecoration(

                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 40,
                                          width: 40,
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
                              );
                            },
                          ),
                        )
                      ]);

                    case ConnectionState.active:
                      return Column(children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 10.0,
                                    bottom: 5.0),
                                child: Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          backgroundColor,
                                          tint
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment
                                            .bottomRight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10.0),
                                              color: Colors
                                                  .grey[300]),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15.0),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: 100,
                                                  decoration: BoxDecoration(

                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 40,
                                          width: 40,
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
                              );
                            },
                          ),
                        )
                      ]);

                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return isErrorSubscribe(context);
                      }
                      var notificationsDeals = snapshot.data;
                      if (notificationsDeals['result']['travels'].length == 0) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Center(
                              child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      "images/wait_vehicule_second.svg",
                                      semanticsLabel: 'NotNotificationTravel',
                                      height:
                                      MediaQuery.of(context).size.height *
                                          0.39,
                                    ),
                                    Text(
                                        "Vous n'avez aucune notification de voyage pour le moment",
                                        textAlign: TextAlign.center,
                                        style: Style.sousTitreEvent(15)),
                                    SizedBox(height: 20),

                                  ])),
                        );
                      }
                      return Column(
                        children: <Widget>[
                          Expanded(
                            child: displayNotifTravels(notificationsDeals['result']['travels']),
                          ),
                        ],
                      );
                  }
                }),
            FutureBuilder(
                future: notificationsFull,
                builder:
                    (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return isErrorSubscribe(context);
                    case ConnectionState.waiting:
                      return Column(children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 10.0,
                                    bottom: 5.0),
                                child: Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          backgroundColor,
                                          tint
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment
                                            .bottomRight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10.0),
                                              color: Colors
                                                  .grey[300]),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15.0),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: 100,
                                                  decoration: BoxDecoration(

                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 40,
                                          width: 40,
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
                              );
                            },
                          ),
                        )
                      ]);

                    case ConnectionState.active:
                      return Column(children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 10.0,
                                    bottom: 5.0),
                                child: Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          backgroundColor,
                                          tint
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment
                                            .bottomRight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10.0),
                                              color: Colors
                                                  .grey[300]),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15.0),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  height: 5,
                                                  width: 100,
                                                  decoration: BoxDecoration(

                                                      color: Colors
                                                          .grey[
                                                      300]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 40,
                                          width: 40,
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
                              );
                            },
                          ),
                        )
                      ]);

                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return isErrorSubscribe(context);
                      }
                      var notificationsDeals = snapshot.data;
                      if (notificationsDeals['result']['transactions'].length == 0) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Center(
                              child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      "images/recherche.svg",
                                      semanticsLabel: 'NotNotificationTransaction',
                                      height:
                                      MediaQuery.of(context).size.height *
                                          0.39,
                                    ),
                                    Text(
                                        "Vous n'avez aucune notification de rechargement ou retrait pour le moment",
                                        textAlign: TextAlign.center,
                                        style: Style.sousTitreEvent(15)),
                                    SizedBox(height: 20),

                                  ])),
                        );
                      }
                      return Column(
                        children: <Widget>[
                          Expanded(
                            child: displayNotifTransactions(notificationsDeals['result']['transactions']),
                          ),
                        ],
                      );
                  }
                })
          ],
        ),
      ),
    );
  }

  Widget displayNotifDeals(List<dynamic> atMoment){
    var item;
    if(atMoment.length != 0){
      item = ListView.builder(
        shrinkWrap: true,
          itemCount: atMoment.length,
          itemBuilder: (context, index){
          final isCampagne = atMoment[index]['room'].toString().split('_').length != 3;
            return InkWell(
              onLongPress: () {
                setState(() {
                  isToDelete = true;
                });
                setState(() {
                  if(!listNotificationDelete.contains(atMoment[index]['notificationId'])) {
                    listNotificationDelete.add(atMoment[index]['notificationId']);
                    type = 1;
                  } else {
                    listNotificationDelete.remove(atMoment[index]['notificationId']);
                    if(listNotificationDelete.isEmpty) {
                      setState(() {
                        isToDelete = false;
                      });
                    }
                  }
                });

              },
              onTap: () async {
                if(!isToDelete) {
                  if(!atMoment[index]['isAlreadyRead']) {
                    final appState = Provider.of<AppState>(context, listen: false);
                    final numberNotif = appState.getNumberNotif - 1;
                    appState.setNumberNotif(numberNotif > 0 ? numberNotif: 0);
                    setState(() {
                      numberNotifDeals = (numberNotifDeals - 1) >0 ? numberNotifDeals - 1: 0;
                    });
                    await consumeAPI.viewNotif(atMoment[index]['notificationId'], "DEALS");
                  }
                  if(isCampagne){
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (context) => LoadProduct(key: UniqueKey(), productId: atMoment[index]['productId'] ?? '', doubleComeBack: 1,)), (route) => route.isFirst);
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => ChatDetails(
                                newClient:newClient!,
                                comeBack: 0,
                                room: atMoment[index]['room'],
                                productId: atMoment[index]['productId'],
                                name: atMoment[index]['name'],
                                onLine: atMoment[index]['onLine'],
                                profil: atMoment[index]['imageOtherUser'],
                                //authorId prend la valeur de idOtherUser
                                authorId: atMoment[index]['idOtherUser'])));
                  }
                } else {
                  setState(() {
                    if(!listNotificationDelete.contains(atMoment[index]['notificationId'])) {
                      listNotificationDelete.add(atMoment[index]['notificationId']);
                      type = 1;
                    } else {
                      listNotificationDelete.remove(atMoment[index]['notificationId']);
                      if(listNotificationDelete.isEmpty) {
                        setState(() {
                          isToDelete = false;
                        });
                      }
                    }
                  });
                }


              },
              child: Container(
                color:listNotificationDelete.contains(atMoment[index]['notificationId']) ? colorError : atMoment[index]['isAlreadyRead'] ? Colors.transparent: colorText.withOpacity(0.05),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: listNotificationDelete.contains(atMoment[index]['notificationId']) ? colorError : colorText, width: 1.0),
                          borderRadius: BorderRadius.circular(50.0),
                          image: DecorationImage(
                            image: isCampagne ? NetworkImage("${ConsumeAPI.AssetPublicServer}campagne.jpeg") : NetworkImage("${ConsumeAPI.AssetProfilServer}${atMoment[index]['imageOtherUser']}"),
                            fit: BoxFit.cover,
                          )
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(atMoment[index]['content'], style: Style.simpleTextInContainer(listNotificationDelete.contains(atMoment[index]['notificationId']) ? colorBlack: colorPrimary), maxLines: 3,)
                        ],
                      ),),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          image: DecorationImage(
                              image: NetworkImage("${ConsumeAPI.AssetProductServer}${atMoment[index]['nameImage']}"),
                              fit: BoxFit.cover
                          )
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    }
    else item = const SizedBox(height: 10.0);

    return item;
  }

  Widget displayNotifTravels(List<dynamic> atMoment){
    var item;
    if(atMoment.length != 0){
      item = ListView.builder(
          shrinkWrap: true,
          itemCount: atMoment.length,
          itemBuilder: (context, index){
            return InkWell(
              onLongPress: () {
                setState(() {
                  isToDelete = true;
                });
                setState(() {
                  if(!listNotificationDelete.contains(atMoment[index]['_id'])) {
                    listNotificationDelete.add(atMoment[index]['_id']);
                    type = 3;
                  } else {
                    listNotificationDelete.remove(atMoment[index]['_id']);
                    if(listNotificationDelete.isEmpty) {
                      setState(() {
                        isToDelete = false;
                      });
                    }
                  }
                });

              },
              onTap: () async {
                if(!isToDelete) {
                  if (!atMoment[index]['isAlreadyRead']) {
                    final appState =
                        Provider.of<AppState>(context, listen: false);
                    final numberNotif = appState.getNumberNotif - 1;
                    appState.setNumberNotif(numberNotif > 0 ? numberNotif : 0);
                    setState(() {
                      numberNotifCovoiturage = (numberNotifCovoiturage - 1) > 0
                          ? numberNotifCovoiturage - 1
                          : 0;
                    });
                    await consumeAPI.viewNotif(
                        atMoment[index]['_id'], "TRAVELS");
                  }
                  if (atMoment[index]['typeTravel'] == 'DEMANDE_TRAVELER') {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => VerifyUser(
                              redirect: CreateTravel.rootName,
                              key: UniqueKey(),
                            )));
                  }
                }
                else {
                  setState(() {
                    if(!listNotificationDelete.contains(atMoment[index]['_id'])) {
                      listNotificationDelete.add(atMoment[index]['_id']);
                      type = 3;
                    } else {
                      listNotificationDelete.remove(atMoment[index]['_id']);
                      if(listNotificationDelete.isEmpty) {
                        setState(() {
                          isToDelete = false;
                        });
                      }
                    }
                  });
                }
              },
              child: Container(
                color: listNotificationDelete.contains(atMoment[index]['notificationId']) ? colorError : atMoment[index]['isAlreadyRead'] ? Colors.transparent: colorText.withOpacity(0.05),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: atMoment[index]['typeTravel'] == 'SHOUZ_ATTRIBUT_LIVRAISON' ? Colors.green[200]: Colors.brown[300],
                      ),

                      child: Icon(atMoment[index]['typeTravel'] == 'SHOUZ_ATTRIBUT_LIVRAISON' ? MyFlutterAppSecond.passenger: MyFlutterAppSecond.driver,
                          color: atMoment[index]['typeTravel'] == 'SHOUZ_ATTRIBUT_LIVRAISON' ? Colors.green[900]: Colors.brown[700], size: 22.0),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(atMoment[index]['content'], style: Style.contextNotif(11), maxLines: 3,)
                          ],
                        ),),
                    ),

                  ],
                ),
              ),
            );
          });
    }
    else item = SizedBox(height: 10.0);

    return item;
  }

  Widget displayNotifTransactions(List<dynamic> atMoment){
    var item;
    if(atMoment.length != 0){
      item = ListView.builder(
          shrinkWrap: true,
          itemCount: atMoment.length,
          itemBuilder: (context, index){
            return InkWell(
              onLongPress: () {
                setState(() {
                  isToDelete = true;
                });
                setState(() {
                  if(!listNotificationDelete.contains(atMoment[index]['_id'])) {
                    listNotificationDelete.add(atMoment[index]['_id']);
                    type = 4;
                  } else {
                    listNotificationDelete.remove(atMoment[index]['_id']);
                    if(listNotificationDelete.isEmpty) {
                      setState(() {
                        isToDelete = false;
                      });
                    }
                  }
                });
              },
              onTap: () async {
                if(!isToDelete) {
                  if (!atMoment[index]['isAlreadyRead']) {
                    final appState =
                        Provider.of<AppState>(context, listen: false);
                    final numberNotif = appState.getNumberNotif - 1;
                    appState.setNumberNotif(numberNotif > 0 ? numberNotif : 0);
                    setState(() {
                      numberNotifShouzPay = (numberNotifShouzPay - 1) > 0
                          ? numberNotifShouzPay - 1
                          : 0;
                    });
                    await consumeAPI.viewNotif(
                        atMoment[index]['_id'], "SHOUZPAY");
                  }
                  Navigator.pushNamed(context, WalletPage.rootName);
                }
                else {
                  setState(() {
                    if(!listNotificationDelete.contains(atMoment[index]['_id'])) {
                      listNotificationDelete.add(atMoment[index]['_id']);
                      type = 4;
                    } else {
                      listNotificationDelete.remove(atMoment[index]['_id']);
                      if(listNotificationDelete.isEmpty) {
                        setState(() {
                          isToDelete = false;
                        });
                      }
                    }
                  });
                }
              },
              child: Container(
                color: listNotificationDelete.contains(atMoment[index]['_id']) ? colorError : atMoment[index]['isAlreadyRead'] ? Colors.transparent: colorText.withOpacity(0.05),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: atMoment[index]['stateForProcessus'] == 0 ? Colors.green[200]: Colors.orange[300],
                      ),

                      child: Icon(atMoment[index]['stateForProcessus'] == 0 ? iconForRechargeOrRetrait(atMoment[index]['typeTransaction']): Icons.donut_large_outlined,
                          color: atMoment[index]['stateForProcessus'] == 0  ? Colors.green[900]: Colors.orange[700], size: 22.0),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(atMoment[index]['content'], style: Style.contextNotif(11), maxLines: 3,)
                          ],
                        ),),
                    ),

                  ],
                ),
              ),
            );
          });
    }
    else item = const SizedBox(height: 10.0);

    return item;
  }



  Widget displayNotifEvents(List<dynamic> atMoment){
    var item;
    if(atMoment.length != 0){
      item = ListView.builder(
          shrinkWrap: true,
          itemCount: atMoment.length,
          itemBuilder: (context, index){
            return InkWell(
              onLongPress: () {
                setState(() {
                  isToDelete = true;
                });
                setState(() {
                  if(!listNotificationDelete.contains(atMoment[index]['_id'])) {
                    listNotificationDelete.add(atMoment[index]['_id']);
                    type = 2;
                  } else {
                    listNotificationDelete.remove(atMoment[index]['_id']);
                    if(listNotificationDelete.isEmpty) {
                      setState(() {
                        isToDelete = false;
                      });
                    }
                  }
                });

              },
                onTap: () async {
                  if(!isToDelete) {
                  if (!atMoment[index]['isAlreadyRead']) {
                    final appState =
                        Provider.of<AppState>(context, listen: false);
                    final numberNotif = appState.getNumberNotif - 1;
                    appState.setNumberNotif(numberNotif > 0 ? numberNotif : 0);
                    setState(() {
                      numberNotifEvent =
                          (numberNotifEvent - 1) > 0 ? numberNotifEvent - 1 : 0;
                    });
                    await consumeAPI.viewNotif(
                        atMoment[index]['_id'], "EVENTS");
                  }
                  if (atMoment[index]['typeEvent'] == "ATTRIBUTION_DECODAGE") {
                    Navigator.of(context).push((MaterialPageRoute(
                        builder: (context) => ChoiceCategorieScan())));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => LoadEvent(
                                key: UniqueKey(),
                                eventId: atMoment[index]['idEvent'])));
                  }
                }
                  else {
                    setState(() {
                      if(!listNotificationDelete.contains(atMoment[index]['_id'])) {
                        listNotificationDelete.add(atMoment[index]['_id']);
                        type = 2;
                      } else {
                        listNotificationDelete.remove(atMoment[index]['_id']);
                        if(listNotificationDelete.isEmpty) {
                          setState(() {
                            isToDelete = false;
                          });
                        }
                      }
                    });
                  }
              },
              child: Container(
                color: listNotificationDelete.contains(atMoment[index]['_id']) ? colorError : atMoment[index]['isAlreadyRead'] ? Colors.transparent: colorText.withOpacity(0.05),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: atMoment[index]['typeEvent'] == 'ATTRIBUTION_DECODAGE' ? Colors.yellow[300] : Colors.green[200],
                      ),

                      child: Icon(atMoment[index]['typeEvent'] == 'ATTRIBUTION_DECODAGE' ? Icons.qr_code_scanner: Icons.account_balance_wallet_outlined,
                          color: atMoment[index]['typeEvent'] == 'ATTRIBUTION_DECODAGE' ? Colors.yellow[700] : Colors.green[900], size: 22.0),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(atMoment[index]['content'], style: Style.contextNotif(11), maxLines: 3,)
                          ],
                        ),),
                    ),

                  ],
                ),
              ),
            );
          });
    }
    else item = const SizedBox(height: 10.0);

    return item;
  }

  IconData iconForRechargeOrRetrait(String typeTransaction) {
    if(typeTransaction.indexOf("RETRAIT") != -1) {
      return Icons.upload_outlined;
    } else {
      return Icons.download_outlined;
    }
  }
}

