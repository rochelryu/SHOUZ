import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/CardTopNewActu.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/helper.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:skeleton_text/skeleton_text.dart';
import '../Constant/my_flutter_app_second_icons.dart' as prefix1;
import 'CovoiturageChoicePlace.dart';
import 'DetailsDeals.dart';
import 'EventDetails.dart';
import 'package:shouz/Constant/widget_common.dart';

class Profil extends StatefulWidget {
  static String rootName = '/profil';
  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> with TickerProviderStateMixin {
  User? newClient;
  Map<dynamic, dynamic>? info;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  bool loadingFull = true, error = false;
  late TabController _controllerDeals;
  late TabController _controllerEvents;
  late TabController _controllerTravels;

  @override
  void initState() {
    super.initState();
    _controllerDeals = TabController(length: 2, vsync: this);
    _controllerEvents = TabController(length: 2, vsync: this);
    _controllerTravels = TabController(length: 2, vsync: this);
    LoadInfo();
  }

  LoadInfo() async {
    User user = await DBProvider.db.getClient();
    setState(() {
      newClient = user;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final data = await consumeAPI.getProfil();
      setState(() {
        info = data;
      });
      setState(() {
        loadingFull = false;
      });
      await prefs.setString('profilFull', jsonEncode(data));
    } catch (e) {
      final profilFullString = prefs.getString("profilFull");
      if (profilFullString != null) {
        setState(() {
          info = jsonDecode(profilFullString) as Map<dynamic, dynamic>;
        });
      }
      setState(() {
        error = true;
        loadingFull = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        body: DefaultTabController(
          length: 4,
          initialIndex: 1,
          child: NestedScrollView(
            scrollDirection: Axis.vertical,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  floating: true,
                  elevation: 10.0,
                  leading: SizedBox(width: 6),
                  expandedHeight: 200.0,
                  backgroundColor: backgroundColor,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: (newClient != null)
                            ? "${ConsumeAPI.AssetProfilServer}${newClient!.images}"
                            : '',
                        imageBuilder: (context, imageProvider) => Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 2.0, sigmaY: 2.0),
                                    child: Container(
                                      decoration: BoxDecoration(
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
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  )),
                                            ),
                                            SizedBox(height: 10.0),
                                            Text(
                                              (newClient != null)
                                                  ? newClient!.name
                                                  : '',
                                              maxLines: 1,
                                              style: Style.titre(20.0),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress)),
                        errorWidget: (context, url, error) => notSignal(),
                      ),
                      Positioned(
                          top: 50,
                          left: 16,
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.black26),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.close,
                                      color: Colors.white, size: 22.0),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              )))
                    ],
                  )),
                  bottom: TabBar(
                    labelColor: colorText,
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: Colors.white.withOpacity(0.85),
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
            body: TabBarView(
              children: <Widget>[
                LayoutBuilder(builder: (context, contraints) {
                  if (loadingFull) {
                    return Column(children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return loadDataSkeletonOfActuality(context);
                          },
                        ),
                      )
                    ]);
                  } else if (!loadingFull && error && info == null) {
                    return isErrorSubscribe(context);
                  } else {
                    var infoUser = info!;
                    if (infoUser['favoriteActualite'].length == 0) {
                      return Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                            SvgPicture.asset(
                              "images/empty.svg",
                              semanticsLabel: 'Shouz Pay',
                              height: MediaQuery.of(context).size.height * 0.39,
                            ),
                            Text("Aucune actualité n'a été ajouté en favorie",
                                textAlign: TextAlign.center,
                                style: Style.sousTitreEvent(15))
                          ]));
                    } else {
                      return Column(
                        children: <Widget>[
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(0),
                              itemCount: infoUser['favoriteActualite'].length,
                              itemBuilder: (context, index) {
                                return CardTopNewActu(
                                  infoUser['favoriteActualite'][index]['title'],
                                  infoUser['favoriteActualite'][index]['_id'],
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
                                      ['comment'],
                                  infoUser['favoriteActualite'][index]
                                      ['imageCover'],
                                ).propotypingProfil(context);
                              },
                            ),
                          )
                        ],
                      );
                    }
                  }
                }),
                LayoutBuilder(builder: (context, contraints) {
                  if (loadingFull) {
                    return Column(children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
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
                                    width:
                                        MediaQuery.of(context).size.width / 2,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 15.0, top: 8.0),
                                          child: SkeletonAnimation(
                                            child: Container(
                                              height: 15,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: Colors.grey[300]),
                                            ),
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
                                                    height: 5,
                                                    width: 15,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color:
                                                            Colors.grey[300]),
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
                                                                .circular(10.0),
                                                        color:
                                                            Colors.grey[300]),
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
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30)),
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
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30)),
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
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
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
                                    width:
                                        MediaQuery.of(context).size.width / 2.3,
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
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  topRight:
                                                      Radius.circular(10.0),
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
                  } else if (!loadingFull && error && info == null) {
                    return isErrorSubscribe(context);
                  } else {
                    var infoUser = info!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: TabBar(
                            controller: _controllerDeals,
                            indicatorSize: TabBarIndicatorSize.label,
                            dividerHeight: 0,
                            labelColor: Style.white,
                            unselectedLabelColor: colorSecondary,
                            indicatorColor: colorText,
                            tabs: [
                              Tab(
                                text:
                                'Mes Favories (${infoUser['favoriteDeals'].length})',
                              ),
                              Tab(
                                text:
                                    'Mes Produits (${infoUser['myDeals'].length})',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _controllerDeals,
                            children: <Widget>[
                              GridView.builder(
                                  padding: EdgeInsets.all(0),
                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                                  itemCount: infoUser['favoriteDeals'].length,
                                  itemBuilder: (context, index) {
                                    final item =
                                    infoUser['favoriteDeals'][index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            (MaterialPageRoute(
                                                builder: (context) {
                                                  DealsSkeletonData element =
                                                  DealsSkeletonData(
                                                      comments: item['comments'],
                                                      numberVue: item['numberVue'],
                                                      video: item['video'],
                                                      quantity: item['quantity'],
                                                      archive: item['archive'],
                                                      level: item['level'],
                                                      numberFavorite:
                                                      item['numberFavorite'],
                                                      lieu: item['lieu'],
                                                      id: item['_id'],
                                                      registerDate:
                                                      item['registerDate'],
                                                      profil: item['profil'],
                                                      imageUrl: item['images'],
                                                      title: item['name'],
                                                      price:
                                                      item['price'].toString() +
                                                          ' XOF',
                                                      autor: item['author'],
                                                      numero: item['numero'],
                                                      describe: item['describe'],
                                                      onLine: item['onLine'],
                                                      authorName:
                                                      item['authorName'],
                                                      categorieName:
                                                      item['categorieName'],
                                                      approved: item['approved']);
                                                  return DetailsDeals(
                                                      dealsDetailsSkeleton: element,
                                                      comeBack: 0);
                                                })));
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl:
                                        "${ConsumeAPI.AssetProductServer}${item['images'][0]}",
                                        progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                            Center(
                                                child:
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress)),
                                        errorWidget: (context, url, error) =>
                                            notSignal(),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }),
                              GridView.builder(
                                padding: EdgeInsets.all(0),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2),
                                  itemCount: infoUser['myDeals'].length,
                                  itemBuilder: (context, index) {
                                    final item = infoUser['myDeals'][index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            (MaterialPageRoute(
                                                builder: (context) {
                                          DealsSkeletonData element =
                                              DealsSkeletonData(
                                                  comments: item['comments'],
                                                  numberVue: item['numberVue'],
                                                  quantity: item['quantity'],
                                                  video: item['video'],
                                                  level: item['level'],
                                                  numberFavorite:
                                                      item['numberFavorite'],
                                                  lieu: item['lieu'],
                                                  id: item['_id'],
                                                  registerDate:
                                                      item['registerDate'],
                                                  profil: item['profil'],
                                                  imageUrl: item['images'],
                                                  title: item['name'],
                                                  price:
                                                      item['price'].toString() +
                                                          ' XOF',
                                                  autor: item['author'],
                                                  numero: item['numero'],
                                                  describe: item['describe'],
                                                  onLine: item['onLine'],
                                                  authorName:
                                                      item['authorName'],
                                                  categorieName:
                                                      item['categorieName'],
                                                  archive: item['archive'],
                                                  approved: item['approved']);
                                          return DetailsDeals(
                                              dealsDetailsSkeleton: element,
                                              comeBack: 0);
                                        })));
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "${ConsumeAPI.AssetProductServer}${item['images'][0]}",
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        value: downloadProgress
                                                            .progress)),
                                        errorWidget: (context, url, error) =>
                                            notSignal(),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }),

                            ],
                          ),
                        )
                      ],
                    );
                  }
                }),
                LayoutBuilder(builder: (context, contraints) {
                  if (loadingFull) {
                    return Column(children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return loadDataSkeletonOfEvent(context);
                          },
                        ),
                      )
                    ]);
                  } else if (!loadingFull && error && info == null) {
                    return isErrorSubscribe(context);
                  } else {
                    var infoUser = info!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: TabBar(
                            controller: _controllerEvents,
                            indicatorSize: TabBarIndicatorSize.label,
                            dividerHeight: 0,
                            labelColor: Style.white,
                            unselectedLabelColor: colorSecondary,
                            indicatorColor: colorText,
                            tabs: [
                              Tab(
                                text:
                                    'Mes Evenements (${infoUser['myEvents'].length})',
                              ),
                              Tab(
                                text:
                                    'Mes Favories (${infoUser['favoriteEvents'].length})',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _controllerEvents,
                            children: <Widget>[
                              ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  itemCount: infoUser['myEvents'].length,
                                  itemBuilder: (context, index) {
                                    final item = infoUser['myEvents'][index];
                                    final indexHero = index + 50000;
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    EventDetails(
                                                      0,
                                                      item['imageCover'],
                                                      indexHero,
                                                      item['price'],
                                                      item['numberFavorite'],
                                                      item['authorName'],
                                                      item['describe'],
                                                      item['_id'],
                                                      item['numberTicket'],
                                                      item['position'],
                                                      item['eventDate'],
                                                      item['title'],
                                                      item['positionRecently'],
                                                      item['videoPub'],
                                                      item['allTicket'],
                                                      item['authorId'],
                                                      item['cumulGain'],
                                                      item['authorId'] ==
                                                          newClient!.ident,
                                                      item['state'],
                                                      item['favorie'],
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
                                                tag: indexHero,
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      "${ConsumeAPI.AssetEventServer}${item['imageCover']}",
                                                  progressIndicatorBuilder: (context,
                                                          url,
                                                          downloadProgress) =>
                                                      Center(
                                                          child: CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress)),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          notSignal(),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              height: 200,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        colors: [
                                                      const Color(0x00000000),
                                                      const Color(0x99111111),
                                                    ],
                                                        begin: FractionalOffset(
                                                            0.0, 0.0),
                                                        end: FractionalOffset(
                                                            0.0, 1.0))),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Text(
                                                        item['title']
                                                            .toString()
                                                            .toUpperCase(),
                                                        style: Style.titreEvent(
                                                            20),
                                                        textAlign:
                                                            TextAlign.center),
                                                    SizedBox(height: 10.0),
                                                    Text(item['position'],
                                                        style: Style
                                                            .sousTitreEvent(15),
                                                        maxLines: 2,
                                                        textAlign:
                                                            TextAlign.center),
                                                    SizedBox(height: 25.0),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            SizedBox(
                                                                width: 10.0),
                                                            Icon(Icons.favorite,
                                                                color: Colors
                                                                    .redAccent,
                                                                size: 22.0),
                                                            Text(
                                                              item['numberFavorite']
                                                                  .toString(),
                                                              style: Style
                                                                  .titleInSegment(),
                                                            ),
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
                              ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  itemCount: infoUser['favoriteEvents'].length,
                                  itemBuilder: (context, index) {
                                    final indexHero = index + 10000;
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    EventDetails(
                                                      0,
                                                      infoUser['favoriteEvents']
                                                          [index]['imageCover'],
                                                      indexHero,
                                                      infoUser['favoriteEvents']
                                                          [index]['price'],
                                                      infoUser['favoriteEvents']
                                                              [index]
                                                          ['numberFavorite'],
                                                      infoUser['favoriteEvents']
                                                          [index]['authorName'],
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
                                                          [index]['eventDate'],
                                                      infoUser['favoriteEvents']
                                                          [index]['title'],
                                                      infoUser['favoriteEvents']
                                                              [index]
                                                          ['positionRecently'],
                                                      infoUser['favoriteEvents']
                                                          [index]['videoPub'],
                                                      infoUser['favoriteEvents']
                                                          [index]['allTicket'],
                                                      infoUser['favoriteEvents']
                                                          [index]['authorId'],
                                                      infoUser['favoriteEvents']
                                                          [index]['cumulGain'],
                                                      infoUser['favoriteEvents']
                                                                  [index]
                                                              ['authorId'] ==
                                                          newClient!.ident,
                                                      infoUser['favoriteEvents']
                                                          [index]['state'],
                                                      infoUser['favoriteEvents']
                                                          [index]['favorie'],
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
                                                tag: indexHero,
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      "${ConsumeAPI.AssetEventServer}${infoUser['favoriteEvents'][index]['imageCover']}",
                                                  progressIndicatorBuilder: (context,
                                                          url,
                                                          downloadProgress) =>
                                                      Center(
                                                          child: CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress)),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          notSignal(),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              height: 200,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        colors: [
                                                      const Color(0x00000000),
                                                      const Color(0x99111111),
                                                    ],
                                                        begin: FractionalOffset(
                                                            0.0, 0.0),
                                                        end: FractionalOffset(
                                                            0.0, 1.0))),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Text(
                                                        infoUser['favoriteEvents']
                                                                [index]['title']
                                                            .toString()
                                                            .toUpperCase(),
                                                        style: Style.titreEvent(
                                                            20),
                                                        textAlign:
                                                            TextAlign.center),
                                                    SizedBox(height: 10.0),
                                                    Text(
                                                        infoUser[
                                                                'favoriteEvents']
                                                            [index]['position'],
                                                        style: Style
                                                            .sousTitreEvent(15),
                                                        maxLines: 2,
                                                        textAlign:
                                                            TextAlign.center),
                                                    SizedBox(height: 25.0),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            SizedBox(
                                                                width: 10.0),
                                                            Icon(Icons.favorite,
                                                                color: Colors
                                                                    .redAccent,
                                                                size: 22.0),
                                                            Text(
                                                              infoUser['favoriteEvents']
                                                                          [
                                                                          index]
                                                                      [
                                                                      'numberFavorite']
                                                                  .toString(),
                                                              style: Style
                                                                  .titleInSegment(),
                                                            ),
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
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                }),
                LayoutBuilder(builder: (context, contraints) {
                  if (loadingFull) {
                    return Column(children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return loadDataSkeletonOfEvent(context);
                          },
                        ),
                      )
                    ]);
                  } else if (!loadingFull && error && info == null) {
                    return isErrorSubscribe(context);
                  } else {
                    var infoUser = info!;
                    if (infoUser['buyTravel'].length == 0 &&
                        infoUser['myTravels'].length == 0) {
                      return Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                            SvgPicture.asset(
                              "images/notdepart.svg",
                              semanticsLabel: 'Not Voyage',
                              height: MediaQuery.of(context).size.height * 0.39,
                            ),
                            Text("Vous avez fait aucun voyage jusqu'a present",
                                textAlign: TextAlign.center,
                                style: Style.sousTitreEvent(15))
                          ]));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        (infoUser['myTravels'].length != 0)
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                child: Text(
                                    "Mes Voyages crées (${infoUser['myTravels'].length})",
                                    style: Style.titleDealsProduct()),
                              )
                            : SizedBox(height: 20),
                        (infoUser['myTravels'].length != 0)
                            ? Container(
                                height: 100,
                                child: ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: infoUser['myTravels'].length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return SizedBox(width: 35);
                                    } else {
                                      final item =
                                          infoUser['myTravels'][index - 1];
                                      return Padding(
                                        padding: EdgeInsets.only(right: 30.0),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                (MaterialPageRoute(
                                                    builder: (builder) =>
                                                        CovoiturageChoicePlace(
                                                          item['id'],
                                                          0,
                                                          item['beginCity'],
                                                          item['endCity'],
                                                          item['lieuRencontre'],
                                                          item['price'],
                                                          item['travelDate'],
                                                          item['authorId'],
                                                          item['placePosition'],
                                                          item['userPayCheck'],
                                                          item['infoAuthor'],
                                                          item[
                                                              'commentPayCheck'],
                                                          newClient != null &&
                                                              item['authorId'] ==
                                                                  newClient!
                                                                      .ident,
                                                          item['state'],
                                                        ))));
                                          },
                                          child: Card(
                                            color: Colors.transparent,
                                            elevation: 2.0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)),
                                            child: Container(
                                              width: 300,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                gradient: LinearGradient(
                                                    colors: gradient[4],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          item['beginCity']
                                                              .toString()
                                                              .toUpperCase(),
                                                          style: Style
                                                              .simpleTextOnNews()),
                                                      Icon(
                                                        Icons.arrow_circle_down,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                          item['endCity']
                                                              .toString()
                                                              .toUpperCase(),
                                                          style: Style
                                                              .simpleTextOnNews()),
                                                    ],
                                                  )),
                                                  Expanded(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .account_balance_wallet,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                          SizedBox(width: 3),
                                                          Text(
                                                              reformatNumberForDisplayOnPrice(
                                                                  item[
                                                                      'price']),
                                                              style: Style
                                                                  .simpleTextOnNews()),
                                                          SizedBox(width: 1),
                                                          Text(
                                                              newClient != null
                                                                  ? newClient!
                                                                      .currencies
                                                                  : '',
                                                              style: Style
                                                                  .simpleTextOnNews()),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.people_alt,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                          SizedBox(width: 3),
                                                          Text(
                                                              item['userPayCheck']
                                                                  .length
                                                                  .toString(),
                                                              style: Style
                                                                  .simpleTextOnNews()),
                                                        ],
                                                      ),
                                                    ],
                                                  ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )
                            : SizedBox(width: 10),
                        SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                              "Mes Voyages effectués  (${infoUser['buyTravel'].length})",
                              style: Style.titleDealsProduct()),
                        ),
                        (infoUser['buyTravel'].length != 0)
                            ? Expanded(
                                child: GridView.builder(
                                    padding: EdgeInsets.all(0),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2),
                                    itemCount: infoUser['buyTravel'].length,
                                    itemBuilder: (context, index) {
                                      final item = infoUser['buyTravel'][index];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              (MaterialPageRoute(
                                                  builder: (builder) =>
                                                      CovoiturageChoicePlace(
                                                        item['id'],
                                                        0,
                                                        item['beginCity'],
                                                        item['endCity'],
                                                        item['lieuRencontre'],
                                                        item['price'],
                                                        item['travelDate'],
                                                        item['authorId'],
                                                        item['placePosition'],
                                                        item['userPayCheck'],
                                                        item['infoAuthor'],
                                                        item['commentPayCheck'],
                                                        newClient != null &&
                                                            item['authorId'] ==
                                                                newClient!
                                                                    .ident,
                                                        item['state'],
                                                      ))));
                                        },
                                        child: Card(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                height: 100,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            "images/secondvoyage.png"),
                                                        fit: BoxFit.contain)),
                                              ),
                                              Container(
                                                height: 20,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                            item['beginCity']
                                                                .toString()
                                                                .toUpperCase(),
                                                            style: Style
                                                                .textBeginCity(
                                                                    11)),
                                                        SizedBox(width: 3),
                                                        Expanded(
                                                            child: Divider()),
                                                        SizedBox(width: 3),
                                                        Text(
                                                            item['endCity']
                                                                .toString()
                                                                .toUpperCase(),
                                                            style: Style
                                                                .textEndCity(
                                                                    11))
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                  height: 20,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 13),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.directions_car,
                                                        size: 19,
                                                        color: item['state'] ==
                                                                1
                                                            ? Colors.redAccent
                                                            : colorText,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        DateTime.parse(item[
                                                                    'travelDate'])
                                                                .day
                                                                .toString() +
                                                            '/' +
                                                            DateTime.parse(item[
                                                                    'travelDate'])
                                                                .month
                                                                .toString() +
                                                            '/' +
                                                            DateTime.parse(item[
                                                                    'travelDate'])
                                                                .year
                                                                .toString() +
                                                            ' à ' +
                                                            DateTime.parse(item[
                                                                    'travelDate'])
                                                                .hour
                                                                .toString() +
                                                            'h ' +
                                                            DateTime.parse(item[
                                                                    'travelDate'])
                                                                .minute
                                                                .toString(),
                                                        style: Style
                                                            .simpleTextOnBoard(
                                                                13),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                    SvgPicture.asset(
                                      "images/notdepart.svg",
                                      semanticsLabel: 'Shouz Pay',
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                    ),
                                    Text(
                                        "Vous n'avez pas encore acheté un ticket de voyage",
                                        textAlign: TextAlign.center,
                                        style: Style.sousTitreEvent(15))
                                  ])),
                      ],
                    );
                  }
                }),
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
