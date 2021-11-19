import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shouz/Constant/CardTopNewActu.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:skeleton_text/skeleton_text.dart';

import '../Constant/my_flutter_app_second_icons.dart' as prefix1;
import 'EventDetails.dart';

class Profil extends StatefulWidget {
  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  User newClient;
  String id;
  Future<Map<dynamic, dynamic>> info;

  @override
  void initState() {
    super.initState();
    LoadInfo();
    info = new ConsumeAPI().getProfil();
  }

  LoadInfo() async {
    User user = await DBProvider.db.getClient();
    setState(() {
      newClient = user;
      id = newClient.ident;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        body: DefaultTabController(
          length: 4,
          child: new NestedScrollView(
            scrollDirection: Axis.vertical,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  floating: true,
                  elevation: 10.0,
                  expandedHeight: 200.0,
                  backgroundColor: backgroundColor,
                  pinned: true,
                  flexibleSpace: new FlexibleSpaceBar(
                      background: Stack(
                    children: <Widget>[
                      Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: NetworkImage((newClient != null)
                                  ? "${ConsumeAPI.AssetProfilServer}${newClient.images}"
                                  : ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: new BackdropFilter(
                                  filter: new ImageFilter.blur(
                                      sigmaX: 2.0, sigmaY: 2.0),
                                  child: new Container(
                                    decoration: new BoxDecoration(
                                        color: Colors.white.withOpacity(0.0)),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: backgroundColor,
                                                    width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                image: DecorationImage(
                                                  image: NetworkImage((newClient !=
                                                          null)
                                                      ? "${ConsumeAPI.AssetProfilServer}${newClient.images}"
                                                      : ''),
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                          SizedBox(height: 10.0),
                                          Text(
                                            newClient.name,
                                            maxLines: 1,
                                            style: Style.titre(20.0),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 65,
                                right: 10,
                                child: Text(
                                  '${newClient.wallet} F cfa',
                                  style: Style.titleInSegment(),
                                ),
                              )
                            ],
                          ))
                    ],
                  )),
                  bottom: TabBar(
                    labelColor: colorText,
                    unselectedLabelColor: Colors.blueAccent.withOpacity(0.25),
                    labelPadding: EdgeInsets.all(5.0),
                    indicatorColor: colorText,
                    tabs: <Widget>[
                      Icon(prefix1.MyFlutterAppSecond.newspaper, size: 30),
                      Icon(prefix1.MyFlutterAppSecond.shop, size: 30),
                      Icon(prefix1.MyFlutterAppSecond.calendar, size: 30),
                      Icon(prefix1.MyFlutterAppSecond.destination, size: 30),
                    ],
                  ),
                ),
              ];
            },
            body: new TabBarView(
              children: <Widget>[
                FutureBuilder(
                    future: info,
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
                                        left: 15.0,
                                        right: 15.0,
                                        top: 10.0,
                                        bottom: 5.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 200,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    backgroundColor,
                                                    tint
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight),
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  bottomLeft:
                                                      Radius.circular(10.0))),
                                          margin: EdgeInsets.only(top: 45.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 15.0, top: 8.0),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 15,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color:
                                                            Colors.grey[300]),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              color: Colors
                                                                  .grey[300]),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
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
                                                  )),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15.0),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
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
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10.0))),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.3,
                                          child: Material(
                                            elevation: 30.0,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0)),
                                            child: SkeletonAnimation(
                                              child: Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    10.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10.0)),
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
                                        left: 15.0,
                                        right: 15.0,
                                        top: 10.0,
                                        bottom: 5.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 200,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    backgroundColor,
                                                    tint
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight),
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  bottomLeft:
                                                      Radius.circular(10.0))),
                                          margin: EdgeInsets.only(top: 45.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 15.0, top: 8.0),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 15,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color:
                                                            Colors.grey[300]),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              color: Colors
                                                                  .grey[300]),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
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
                                                  )),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15.0),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
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
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10.0))),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.3,
                                          child: Material(
                                            elevation: 30.0,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0)),
                                            child: SkeletonAnimation(
                                              child: Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    10.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10.0)),
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
                                              style:
                                                  Style.sousTitreEvent(15)))))
                            ]);
                          } else {
                            var infoUser = snapshot.data;
                            if (infoUser['favoriteActualite'].length == 0) {
                              return Center(
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        new SvgPicture.asset(
                                          "images/empty.svg",
                                          semanticsLabel: 'Shouz Pay',
                                          height: MediaQuery.of(context).size.height *
                                              0.39,
                                        ),
                                        Text(
                                            "Aucun Deals Vip pour le moment selon vos centres d'intérêts",
                                            textAlign: TextAlign.center,
                                            style: Style.sousTitreEvent(15))
                                      ]));
                            } else {
                              return Column(
                                children: <Widget>[
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount:
                                      infoUser['favoriteActualite'].length,
                                      itemBuilder: (context, index) {
                                        return CardTopNewActu(
                                            infoUser['favoriteActualite'][index]
                                            ['title'],
                                            infoUser['favoriteActualite'][index]
                                            ['_id'],
                                            infoUser['favoriteActualite'][index]
                                            ['imageCover'],
                                            infoUser['favoriteActualite'][index]
                                            ['numberVue'],
                                            infoUser['favoriteActualite'][index]
                                            ['registerDate'],
                                            infoUser['favoriteActualite'][index]
                                            ['autherName'],
                                            infoUser['favoriteActualite'][index]
                                            ['authorProfil'],
                                            infoUser['favoriteActualite'][index]
                                            ['content'],
                                            infoUser['favoriteActualite'][index]
                                            ['comment'])
                                            .propotypingProfil(context);
                                      },
                                    ),
                                  )
                                ],
                              );
                            }
                          }

                      }
                    }),
                FutureBuilder(
                    future: info,
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
                                        left: 15.0,
                                        right: 15.0,
                                        top: 10.0,
                                        bottom: 5.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 200,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    backgroundColor,
                                                    tint
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight),
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  bottomLeft:
                                                      Radius.circular(10.0))),
                                          margin: EdgeInsets.only(top: 45.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 15.0, top: 8.0),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 15,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color:
                                                            Colors.grey[300]),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              color: Colors
                                                                  .grey[300]),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
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
                                                  )),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15.0),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
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
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10.0))),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.3,
                                          child: Material(
                                            elevation: 30.0,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0)),
                                            child: SkeletonAnimation(
                                              child: Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    10.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10.0)),
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
                                        left: 15.0,
                                        right: 15.0,
                                        top: 10.0,
                                        bottom: 5.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 200,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    backgroundColor,
                                                    tint
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight),
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  bottomLeft:
                                                      Radius.circular(10.0))),
                                          margin: EdgeInsets.only(top: 45.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 15.0, top: 8.0),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 15,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color:
                                                            Colors.grey[300]),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              color: Colors
                                                                  .grey[300]),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
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
                                                  )),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15.0),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
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
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10.0))),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.3,
                                          child: Material(
                                            elevation: 30.0,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0)),
                                            child: SkeletonAnimation(
                                              child: Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    10.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10.0)),
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
                                              style:
                                                  Style.sousTitreEvent(15)))))
                            ]);
                          }
                          var infoUser = snapshot.data;
                          if (infoUser['favoriteDeals'].length == 0 &&
                              infoUser['myDeals'].length == 0) {
                            return Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                  new SvgPicture.asset(
                                    "images/empty.svg",
                                    semanticsLabel: 'Shouz Pay',
                                    height: MediaQuery.of(context).size.height *
                                        0.39,
                                  ),
                                  Text(
                                      "Vous avez fait aucun deals jusqu'a present",
                                      textAlign: TextAlign.center,
                                      style: Style.sousTitreEvent(15))
                                ]));
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              (infoUser['myDeals'].length != 0)
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 10.0),
                                      child: Text(
                                          "Mes Produits (${infoUser['myDeals'].length})",
                                          style: Style.titleDealsProduct()),
                                    )
                                  : SizedBox(width: 10),
                              (infoUser['myDeals'].length != 0)
                                  ? Container(
                                      height: 200,
                                      child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            infoUser['myDeals'].length + 1,
                                        itemBuilder: (context, index) {
                                          if (index == 0) {
                                            return SizedBox(width: 35);
                                          } else {
                                            final item =
                                                infoUser['myDeals'][index - 1];
                                            return new Padding(
                                              padding:
                                                  EdgeInsets.only(right: 30.0),
                                              child: InkWell(
                                                onTap: () {
                                                  print(index);
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Card(
                                                      elevation: 10.0,
                                                      child: Container(
                                                        height: 100,
                                                        width: 200,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.0),
                                                            image: DecorationImage(
                                                                image: NetworkImage(
                                                                    "${ConsumeAPI.AssetProductServer}${item['images'][0]}"),
                                                                fit: BoxFit
                                                                    .cover)),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Container(
                                                      height: 80,
                                                      width: 200,
                                                      child: Column(
                                                        children: <Widget>[
                                                          Text(item['name'],
                                                              maxLines: 3,
                                                              style: Style
                                                                  .titleDealsProduct()),
                                                          SizedBox(height: 5.0),
                                                          Text(
                                                              '${item['price'].toString()} Fcfa',
                                                              style: Style
                                                                  .priceDealsProduct()),
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
                                    )
                                  : SizedBox(width: 10),
                              (infoUser['favoriteDeals'].length != 0)
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Text(
                                          "Mes Favories (${infoUser['favoriteDeals'].length})",
                                          style: Style.titleDealsProduct()),
                                    )
                                  : SizedBox(width: 10),
                              (infoUser['favoriteDeals'].length != 0)
                                  ? Expanded(
                                      child: GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2),
                                          itemCount:
                                              infoUser['favoriteDeals'].length,
                                          itemBuilder: (context, index) {
                                            return new InkWell(
                                              onTap: () {
                                                print(index);
                                              },
                                              child: Image.network(
                                                  "${ConsumeAPI.AssetProductServer}${infoUser['favoriteDeals'][index]['images'][0]}",
                                                  fit: BoxFit.cover),
                                            );
                                          }),
                                    )
                                  : Center(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                          new SvgPicture.asset(
                                            "images/empty.svg",
                                            semanticsLabel: 'Shouz Pay',
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.25,
                                          ),
                                          Text(
                                              "Vous n'etes pas interesse par un deals externes",
                                              textAlign: TextAlign.center,
                                              style: Style.sousTitreEvent(15))
                                        ])),
                            ],
                          );
                      }
                    }),
                FutureBuilder(
                    future: info,
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
                                        left: 15.0,
                                        right: 15.0,
                                        top: 10.0,
                                        bottom: 5.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 200,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    backgroundColor,
                                                    tint
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight),
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  bottomLeft:
                                                      Radius.circular(10.0))),
                                          margin: EdgeInsets.only(top: 45.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 15.0, top: 8.0),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 15,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color:
                                                            Colors.grey[300]),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              color: Colors
                                                                  .grey[300]),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
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
                                                  )),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15.0),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
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
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10.0))),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.3,
                                          child: Material(
                                            elevation: 30.0,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0)),
                                            child: SkeletonAnimation(
                                              child: Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    10.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10.0)),
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
                                        left: 15.0,
                                        right: 15.0,
                                        top: 10.0,
                                        bottom: 5.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 200,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    backgroundColor,
                                                    tint
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight),
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  bottomLeft:
                                                      Radius.circular(10.0))),
                                          margin: EdgeInsets.only(top: 45.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 15.0, top: 8.0),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 15,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color:
                                                            Colors.grey[300]),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              color: Colors
                                                                  .grey[300]),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      SkeletonAnimation(
                                                        child: Container(
                                                          height: 5,
                                                          width: 15,
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
                                                  )),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15.0),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    SkeletonAnimation(
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
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
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10.0))),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.3,
                                          child: Material(
                                            elevation: 30.0,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0)),
                                            child: SkeletonAnimation(
                                              child: Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    10.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10.0)),
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
                                              style:
                                                  Style.sousTitreEvent(15)))))
                            ]);
                          }
                          var infoUser = snapshot.data;
                          if (infoUser['favoriteEvents'].length == 0 &&
                              infoUser['myEvents'].length == 0) {
                            return Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                  new SvgPicture.asset(
                                    "images/empty.svg",
                                    semanticsLabel: 'Shouz Pay',
                                    height: MediaQuery.of(context).size.height *
                                        0.39,
                                  ),
                                  Text(
                                      "Aucun Evenement ne vous a interesse jusqu'a present",
                                      textAlign: TextAlign.center,
                                      style: Style.sousTitreEvent(15))
                                ]));
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              (infoUser['myEvents'].length != 0)
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 10.0),
                                      child: Text(
                                          "Mes Evenements (${infoUser['myEvents'].length})",
                                          style: Style.titleDealsProduct()),
                                    )
                                  : SizedBox(width: 10),
                              (infoUser['myEvents'].length != 0)
                                  ? Container(
                                      height: 200,
                                      child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            infoUser['myEvents'].length + 1,
                                        itemBuilder: (context, index) {
                                          if (index == 0) {
                                            return SizedBox(width: 35);
                                          } else {
                                            final item =
                                                infoUser['myEvents'][index - 1];
                                            return new Padding(
                                              padding:
                                                  EdgeInsets.only(right: 30.0),
                                              child: InkWell(
                                                onTap: () {
                                                  print(index);
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Card(
                                                      elevation: 10.0,
                                                      /*shape: CircleBorder(),
                                      clipBehavior: Clip.antiAlias,*/
                                                      child: Container(
                                                        height: 100,
                                                        width: 200,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.0),
                                                            image: DecorationImage(
                                                                image: NetworkImage(
                                                                    "${ConsumeAPI.AssetEventServer}${item['imageCover']}"),
                                                                fit: BoxFit
                                                                    .cover)),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Container(
                                                      height: 80,
                                                      width: 200,
                                                      child: Column(
                                                        children: <Widget>[
                                                          Text(item['title'],
                                                              maxLines: 3,
                                                              style: Style
                                                                  .titleDealsProduct()),
                                                          SizedBox(height: 5.0),
                                                          Text(
                                                              (item['price']
                                                                          [0] ==
                                                                      'GRATUIT')
                                                                  ? 'GRATUIT'
                                                                  : '${item['price'][0]} Fcfa',
                                                              style: Style
                                                                  .priceDealsProduct()),
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
                                    )
                                  : SizedBox(width: 10),
                              (infoUser['favoriteEvents'].length != 0)
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Text(
                                          "Mes Favories (${infoUser['favoriteEvents'].length})",
                                          style: Style.titleDealsProduct()),
                                    )
                                  : SizedBox(width: 10),
                              (infoUser['favoriteEvents'].length != 0)
                                  ? Expanded(
                                      child: ListView.builder(
                                          itemCount:
                                              infoUser['favoriteEvents'].length,
                                          itemBuilder: (context, index) {
                                            final positionRecently =
                                                infoUser['favoriteEvents']
                                                    [index]['positionRecently'];
                                            return InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(MaterialPageRoute(
                                                    builder: (builder) => EventDetails(
                                                        infoUser['favoriteEvents'][index]
                                                            ['imageCover'],
                                                        index,
                                                        infoUser['favoriteEvents']
                                                            [index]['price'],
                                                        infoUser['favoriteEvents']
                                                                [index]
                                                            ['numberFavorite'],
                                                        infoUser['favoriteEvents']
                                                                [index]
                                                            ['authorName'],
                                                        infoUser['favoriteEvents']
                                                            [index]['describe'],
                                                        infoUser['favoriteEvents']
                                                            [index]['_id'],
                                                        infoUser['favoriteEvents']
                                                                [index]
                                                            ['numberTicket'],
                                                        infoUser['favoriteEvents']
                                                            [index]['position'],
                                                        infoUser['favoriteEvents']
                                                                [index]
                                                            ['enventDate'],
                                                        infoUser['favoriteEvents']
                                                            [index]['title'],
                                                        infoUser['favoriteEvents']
                                                                [index]
                                                            ['positionRecently'],
                                                        infoUser['favoriteEvents'][index]['state'],
                                                        infoUser['favoriteEvents'][index]['videoPub'])));
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
                                                            "${ConsumeAPI.AssetEventServer}${infoUser['favoriteEvents'][index]['imageCover']}",
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      left: 0,
                                                      right: 0,
                                                      height: 200,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                              const Color(
                                                                  0x00000000),
                                                              const Color(
                                                                  0x99111111),
                                                            ],
                                                                    begin:
                                                                        FractionalOffset(
                                                                            0.0,
                                                                            0.0),
                                                                    end: FractionalOffset(
                                                                        0.0,
                                                                        1.0))),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            Text(
                                                                infoUser['favoriteEvents']
                                                                            [
                                                                            index]
                                                                        [
                                                                        'title']
                                                                    .toString()
                                                                    .toUpperCase(),
                                                                style: Style
                                                                    .titreEvent(
                                                                        20),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                            SizedBox(
                                                                height: 10.0),
                                                            Text(
                                                                infoUser['favoriteEvents']
                                                                        [index][
                                                                    'position'],
                                                                style: Style
                                                                    .sousTitreEvent(
                                                                        15),
                                                                maxLines: 2,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                            SizedBox(
                                                                height: 25.0),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    SizedBox(
                                                                        width:
                                                                            10.0),
                                                                    Icon(
                                                                        Icons
                                                                            .favorite,
                                                                        color: Colors
                                                                            .redAccent,
                                                                        size:
                                                                            22.0),
                                                                    Text(
                                                                      infoUser['favoriteEvents'][index]
                                                                              [
                                                                              'numberFavorite']
                                                                          .toString(),
                                                                      style: Style
                                                                          .titleInSegment(),
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            20.0),
                                                                    Icon(
                                                                        Icons
                                                                            .account_balance_wallet,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            22.0),
                                                                    SizedBox(
                                                                        width:
                                                                            5.0),
                                                                    Text(
                                                                      infoUser['favoriteEvents']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'price'][0],
                                                                      style: Style
                                                                          .titleInSegment(),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                        Icons
                                                                            .person_pin_circle,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            22.0),
                                                                    Text(
                                                                        (positionRecently['longitude'] ==
                                                                                0)
                                                                            ? 'N/A'
                                                                            : '2.2 Km',
                                                                        style: Style
                                                                            .titleInSegment()),
                                                                    SizedBox(
                                                                        width:
                                                                            10.0)
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 15.0),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                    )
                                  : Center(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                          new SvgPicture.asset(
                                            "images/empty.svg",
                                            semanticsLabel: 'Shouz Pay',
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.25,
                                          ),
                                          Text(
                                              "Vous n'etes pas interesse par un Evenement externes",
                                              textAlign: TextAlign.center,
                                              style: Style.sousTitreEvent(15))
                                        ])),
                            ],
                          );
                      }
                    }),
                ListView(
                  children: <Widget>[
                    // SizedBox(height: 20.0),
                    // new CardTopNewActu("Didier Drogba pour la présidence", "Nous savons maintenant pourquoi jusqu'à présent notre joueur étais tapis dans l'ombre.", "images/me.jpg", 18, "25 Août 2019", "Rochel","Rochel").propotypingProfil(context),
                    // SizedBox(height: 20.0),
                    // new CardTopNewActu("Didier Drogba pour la présidence", "Nous savons maintenant pourquoi jusqu'à présent notre joueur étais tapis dans l'ombre.", "images/me.jpg", 18, "25 Août 2019", "Rochel","Rochel").propotypingProfil(context),
                    // SizedBox(height: 20.0),
                    // new CardTopNewActu("Didier Drogba pour la présidence", "Nous savons maintenant pourquoi jusqu'à présent notre joueur étais tapis dans l'ombre.", "images/me.jpg", 18, "25 Août 2019", "Rochel","Rochel").propotypingProfil(context),
                    // SizedBox(height: 20.0),
                    // new CardTopNewActu("Didier Drogba pour la présidence", "Nous savons maintenant pourquoi jusqu'à présent notre joueur étais tapis dans l'ombre.", "images/me.jpg", 18, "25 Août 2019", "Rochel","Rochel").propotypingProfil(context),
                    // SizedBox(height: 20.0),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  List<Widget> displayContent(
      dynamic contentMyAction, dynamic contentMyFavorite) {
    List<Widget> listWidget = [];
    return listWidget;
  }
}
