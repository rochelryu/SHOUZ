import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shouz/Constant/PopulaireDeals.dart';
import 'package:shouz/Constant/RecentDeals.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/VipDeals.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:skeleton_text/skeleton_text.dart';

import './CreateDeals.dart';
import 'ChoiceHobie.dart';

class Deals extends StatefulWidget {
  @override
  _DealsState createState() => _DealsState();
}

class _DealsState extends State<Deals> with SingleTickerProviderStateMixin {
  TextEditingController searchCtrl = new TextEditingController();
  int choiceSearch = 0; // Index VIP or Recent Or Populaire
  int choiceItemSearch = 0; // Index Fall all Categorie or other categorie
  List<int> choiceItemSearchPositionOlder = [0, 0, 0];
  String searchData = "";
  final GlobalKey _menuKey = new GlobalKey();
  TabController _controller;
  Future<List<dynamic>> dealsFull;
  ScrollController _scrollController = new ScrollController();

  List<PopupMenuItem<String>> pref = [];

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 3, vsync: this)
      ..addListener(() {
        if (_controller.indexIsChanging) {
          searchCtrl.clear();
          setState(() {
            // choiceItemSearchPositionOlder[choiceSearch] = choiceItemSearch;
            choiceSearch = _controller.index;
            // choiceItemSearch = choiceItemSearchPositionOlder[choiceSearch];
            choiceItemSearch = 0;
            searchData = '';
          });
          changeMenuOptionButton();
        }
      });
    dealsFull = new ConsumeAPI().getDeals();
    new Timer(const Duration(seconds: 1), changeMenuOptionButton);
  }

  changeMenuOptionButton() async {
    pref.clear();
    var deals = await dealsFull;
    for (var i = 0; i < deals[choiceSearch].length; i++) {
      final item = new PopupMenuItem<String>(
        child: Text(
          deals[choiceSearch][i]['name'].toString(),
          style: TextStyle(color: backgroundColorSec),
        ),
        value: deals[choiceSearch][i]['name'].toString(),
      );
      setState(() {
        pref.add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Timer(Duration(milliseconds: 1000), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));

    final ButtonRyu = new PopupMenuButton(
        key: _menuKey,
        icon: Icon(Icons.filter_list, color: Colors.white),
        itemBuilder: (_) => pref,
        tooltip: "Filtrage par categorie",
        onSelected: (value) async {
          var deals = await dealsFull;
          for (var i = 0; i < deals[choiceSearch].length; i++) {
            if (deals[choiceSearch][i]['name'] == value) {
              setState(() {
                choiceItemSearch = i;
              });
            }
          }
        });

    return new GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      Container(
                        height: 40.0,
                        width: MediaQuery.of(context).size.width / 1.2,
                        decoration: BoxDecoration(
                            color: backgroundColorSec,
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10.0,
                                color: backgroundColor,
                                offset: Offset(0.0, 10.0),
                              )
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 17.0),
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width / 1.5,
                              color: Colors.transparent,
                              child: new TextField(
                                controller: searchCtrl,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                                cursorColor: colorText,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    hintText: "Entrer ce que vous chercher",
                                    hintStyle: TextStyle(color: colorPrimary),
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                    )),
                                onChanged: (String text) {
                                  setState(() {
                                    searchData = text;

                                    if(searchData.length == 0) {
                                      setState(() {
                                        dealsFull = new ConsumeAPI().getDeals();
                                      });

                                    }
                                  });
                                },
                                onSubmitted: (String text) {
                                  searchDataInContext(text);
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search, color: Colors.white),
                              onPressed: () {
                                searchDataInContext(searchData);
                              },
                            )
                          ],
                        ),
                      ),
                      ButtonRyu,
                    ],
                  )),
              SizedBox(height: 5.0),
              new Container(
                decoration: new BoxDecoration(color: Colors.transparent),
                child: new TabBar(
                  controller: _controller,
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: colorText,
                  tabs: [
                    new Tab(
                      //icon: const Icon(Icons.stars),
                      text: 'VIP',
                    ),
                    new Tab(
                      //icon: const Icon(Icons.shopping_cart),
                      text: 'RECENT',
                    ),
                    new Tab(
                      //icon: const Icon(Icons.star_half),
                      text: 'POPULAIRE',
                    ),
                  ],
                ),
              ),
              new Container(
                height: MediaQuery.of(context).size.height / 1.47,
                child: new TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _controller,
                  children: <Widget>[
                    FutureBuilder(
                        future: dealsFull,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
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
                                                      end: Alignment
                                                          .bottomRight),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10.0))),
                                              margin:
                                                  EdgeInsets.only(top: 45.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0, top: 8.0),
                                                    child: SkeletonAnimation(
                                                      child: Container(
                                                        height: 15,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
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
                                                                          .grey[
                                                                      300]),
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
                                                                          .grey[
                                                                      300]),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        SkeletonAnimation(
                                                          child: Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                    topLeft:
                                                        Radius.circular(10.0),
                                                    topRight:
                                                        Radius.circular(10.0),
                                                    bottomRight:
                                                        Radius.circular(10.0)),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0)),
                                                        color:
                                                            Colors.grey[200]),
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
                                                      end: Alignment
                                                          .bottomRight),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10.0))),
                                              margin:
                                                  EdgeInsets.only(top: 45.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0, top: 8.0),
                                                    child: SkeletonAnimation(
                                                      child: Container(
                                                        height: 15,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
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
                                                                          .grey[
                                                                      300]),
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
                                                                          .grey[
                                                                      300]),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        SkeletonAnimation(
                                                          child: Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                    topLeft:
                                                        Radius.circular(10.0),
                                                    topRight:
                                                        Radius.circular(10.0),
                                                    bottomRight:
                                                        Radius.circular(10.0)),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0)),
                                                        color:
                                                            Colors.grey[200]),
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
                                                  style: Style.sousTitreEvent(
                                                      15)))))
                                ]);
                              }
                              var populaireActu = snapshot.data;
                              if (populaireActu[0][choiceItemSearch]['body']
                                      .length ==
                                  0) {
                                return Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                      new SvgPicture.asset(
                                        "images/empty.svg",
                                        semanticsLabel: 'Shouz Pay',
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.39,
                                      ),
                                      Text(
                                          "Aucun Deals Vip pour le moment selon vos centres d'intérêts",
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
                              return Column(
                                children: <Widget>[
                                  Expanded(
                                    child: new ListView.builder(
                                      itemCount: populaireActu[0]
                                              [choiceItemSearch]['body']
                                          .length,
                                      itemBuilder: (context, index) {
                                        return VipDeals(
                                            imageUrl: populaireActu[0]
                                                    [choiceItemSearch]['body']
                                                [index]['images'],
                                            title: populaireActu[0][choiceItemSearch]
                                                ['body'][index]['name'],
                                            favorite: false,
                                            price: populaireActu[0][choiceItemSearch]
                                                ['body'][index]['price'],
                                            numero: populaireActu[0][choiceItemSearch]
                                                ['body'][index]['numero'],
                                            autor: populaireActu[0][choiceItemSearch]
                                                ['body'][index]['author'],
                                            authorName: populaireActu[0][choiceItemSearch]['body'][index]['authorName'],
                                            id: populaireActu[0][choiceItemSearch]
                                                ['body'][index]['_id'],
                                            profil: populaireActu[0][choiceItemSearch]['body'][index]['profil'],
                                            onLine: populaireActu[0][choiceItemSearch]['body'][index]['onLine'],
                                            describe: populaireActu[0][choiceItemSearch]['body'][index]['describe'],
                                            numberFavorite: populaireActu[0][choiceItemSearch]['body'][index]['numberFavorite'],
                                            lieu: populaireActu[0][choiceItemSearch]['body'][index]['lieu'],
                                            registerDate: populaireActu[0][choiceItemSearch]['body'][index]['registerDate'],
                                            quantity: populaireActu[0][choiceItemSearch]['body'][index]['quantity']);
                                      },
                                    ),
                                  )
                                ],
                              );
                          }
                        }),
                    FutureBuilder(
                        future: dealsFull,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                    new SvgPicture.asset(
                                      "images/notconnection.svg",
                                      semanticsLabel: 'Not Connexion',
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.39,
                                    ),
                                    Text(
                                        "Veuillez verifier votre connexion internet",
                                        textAlign: TextAlign.center,
                                        style: Style.sousTitreEvent(15))
                                  ]));

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
                                                      end: Alignment
                                                          .bottomRight),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10.0))),
                                              margin:
                                                  EdgeInsets.only(top: 45.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0, top: 8.0),
                                                    child: SkeletonAnimation(
                                                      child: Container(
                                                        height: 15,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
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
                                                                          .grey[
                                                                      300]),
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
                                                                          .grey[
                                                                      300]),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        SkeletonAnimation(
                                                          child: Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                    topLeft:
                                                        Radius.circular(10.0),
                                                    topRight:
                                                        Radius.circular(10.0),
                                                    bottomRight:
                                                        Radius.circular(10.0)),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0)),
                                                        color:
                                                            Colors.grey[200]),
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
                                                      end: Alignment
                                                          .bottomRight),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10.0))),
                                              margin:
                                                  EdgeInsets.only(top: 45.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0, top: 8.0),
                                                    child: SkeletonAnimation(
                                                      child: Container(
                                                        height: 15,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
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
                                                                          .grey[
                                                                      300]),
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
                                                                          .grey[
                                                                      300]),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        SkeletonAnimation(
                                                          child: Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                    topLeft:
                                                        Radius.circular(10.0),
                                                    topRight:
                                                        Radius.circular(10.0),
                                                    bottomRight:
                                                        Radius.circular(10.0)),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0)),
                                                        color:
                                                            Colors.grey[200]),
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
                                                  style: Style.sousTitreEvent(
                                                      15)))))
                                ]);
                              }
                              var populaireActu = snapshot.data;
                              if (populaireActu[1][choiceItemSearch]['body']
                                      .length ==
                                  0) {
                                return Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                      new SvgPicture.asset(
                                        "images/empty.svg",
                                        semanticsLabel: 'Shouz Pay',
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.39,
                                      ),
                                      Text(
                                          "Aucun Deals Récents pour le moment selon vos centres d'intérêts",
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
                              return Column(
                                children: <Widget>[
                                  Expanded(
                                    child: new StaggeredGridView.countBuilder(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      padding: EdgeInsets.all(10.0),
                                      itemCount: populaireActu[1]
                                              [choiceItemSearch]['body']
                                          .length,
                                      itemBuilder: (BuildContext context, int index) => PopulaireDeals(
                                          imageUrl: populaireActu[1]
                                                  [choiceItemSearch]['body']
                                              [index]['images'],
                                          title: populaireActu[1][choiceItemSearch]
                                              ['body'][index]['name'],
                                          favorite: false,
                                          price: populaireActu[1][choiceItemSearch]
                                              ['body'][index]['price'],
                                          numero: populaireActu[1][choiceItemSearch]
                                              ['body'][index]['numero'],
                                          autor: populaireActu[1][choiceItemSearch]
                                              ['body'][index]['author'],
                                          authorName: populaireActu[1][choiceItemSearch]['body'][index]['authorName'],
                                          id: populaireActu[1][choiceItemSearch]['body'][index]['_id'],
                                          profil: populaireActu[1][choiceItemSearch]['body'][index]['profil'],
                                          onLine: populaireActu[1][choiceItemSearch]['body'][index]['onLine'],
                                          describe: populaireActu[1][choiceItemSearch]['body'][index]['describe'],
                                          numberFavorite: populaireActu[1][choiceItemSearch]['body'][index]['numberFavorite'],
                                          lieu: populaireActu[1][choiceItemSearch]['body'][index]['lieu'],
                                          registerDate: populaireActu[1][choiceItemSearch]['body'][index]['registerDate'],
                                          quantity: populaireActu[1][choiceItemSearch]['body'][index]['quantity']),
                                      staggeredTileBuilder: (int index) =>
                                          new StaggeredTile.fit(2),
                                    ),
                                  ),
                                ],
                              );
                          }
                        }),
                    FutureBuilder(
                        future: dealsFull,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
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
                                                      end: Alignment
                                                          .bottomRight),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10.0))),
                                              margin:
                                                  EdgeInsets.only(top: 45.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0, top: 8.0),
                                                    child: SkeletonAnimation(
                                                      child: Container(
                                                        height: 15,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
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
                                                                          .grey[
                                                                      300]),
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
                                                                          .grey[
                                                                      300]),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        SkeletonAnimation(
                                                          child: Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                    topLeft:
                                                        Radius.circular(10.0),
                                                    topRight:
                                                        Radius.circular(10.0),
                                                    bottomRight:
                                                        Radius.circular(10.0)),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0)),
                                                        color:
                                                            Colors.grey[200]),
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
                                                      end: Alignment
                                                          .bottomRight),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10.0))),
                                              margin:
                                                  EdgeInsets.only(top: 45.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0, top: 8.0),
                                                    child: SkeletonAnimation(
                                                      child: Container(
                                                        height: 15,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
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
                                                                          .grey[
                                                                      300]),
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
                                                                          .grey[
                                                                      300]),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        SkeletonAnimation(
                                                          child: Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
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
                                                    topLeft:
                                                        Radius.circular(10.0),
                                                    topRight:
                                                        Radius.circular(10.0),
                                                    bottomRight:
                                                        Radius.circular(10.0)),
                                                child: SkeletonAnimation(
                                                  child: Container(
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0)),
                                                        color:
                                                            Colors.grey[200]),
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
                                                  style: Style.sousTitreEvent(
                                                      15)))))
                                ]);
                              }
                              var populaireActu = snapshot.data;
                              if (populaireActu[2][choiceItemSearch]['body']
                                      .length ==
                                  0) {
                                return Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                      new SvgPicture.asset(
                                        "images/empty.svg",
                                        semanticsLabel: 'Shouz Pay',
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.39,
                                      ),
                                      Text(
                                          "Aucun Deals Populaires pour le moment selon vos centres d'intérêts",
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
                              return Column(
                                children: <Widget>[
                                  Expanded(
                                    child: new ListView.builder(
                                      itemCount: populaireActu[2][choiceItemSearch]['body'].length,
                                      itemBuilder: (context, index) {
                                        return RecentDeals(
                                            imageUrl: populaireActu[2][choiceItemSearch]['body'][index]['images'],
                                            title: populaireActu[2][choiceItemSearch]['body'][index]['name'],
                                            favorite: false,
                                            price: populaireActu[2][choiceItemSearch]['body'][index]['price'],
                                            numero: populaireActu[2][choiceItemSearch]['body'][index]['numero'],
                                            autor: populaireActu[2][choiceItemSearch]['body'][index]['author'],
                                            authorName: populaireActu[2][choiceItemSearch]['body'][index]['authorName'],
                                            id: populaireActu[2][choiceItemSearch]['body'][index]['_id'],
                                            profil: populaireActu[2][choiceItemSearch]['body'][index]['profil'],
                                            onLine: populaireActu[2][choiceItemSearch]['body'][index]['onLine'],
                                            describe: populaireActu[2][choiceItemSearch]['body'][index]['describe'],
                                            numberFavorite: populaireActu[2][choiceItemSearch]['body'][index]['numberFavorite'],
                                            lieu: populaireActu[2][choiceItemSearch]['body'][index]['lieu'],
                                            registerDate: populaireActu[2][choiceItemSearch]['body'][index]['registerDate'],
                                            quantity: populaireActu[2][choiceItemSearch]['body'][index]['quantity']);
                                      },
                                    ),
                                  )
                                ],
                              );
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: _controller.index == 1 ? FloatingActionButton(
              elevation: 20.0,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (builder) => CreateDeals()),
                );
              },
              backgroundColor: colorText,
              child: Icon(Icons.add, color: Colors.white, size: 22.0),
            ): SizedBox(width: 1),
          )
        ],
      ),
    );
  }

  void searchDataInContext(String text) async {
    final List<dynamic> oldDealsNoFutur = await dealsFull;
    final newPartialDealsFull = oldDealsNoFutur[_controller.index][choiceItemSearch]['body'].where((element) => element['name'].toString().indexOf(text) != -1).toList();
    oldDealsNoFutur[_controller.index][choiceItemSearch]['body'] = newPartialDealsFull;
    setState(() {
      dealsFull = new ConsumeAPI().updateDealFullForFutur(oldDealsNoFutur);
    });
  }



}
