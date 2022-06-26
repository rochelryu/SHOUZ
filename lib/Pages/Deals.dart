import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/PopulaireDeals.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/VipDeals.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Constant/widget_common.dart';

import './CreateDeals.dart';
import 'ChoiceOtherHobie.dart';

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
  late TabController _controller;
  List<dynamic> dealsFull  = [];
  ConsumeAPI consumeAPI =new ConsumeAPI();
  ScrollController _scrollControllerVip = new ScrollController();
  ScrollController _scrollControllerRecent = new ScrollController();
  ScrollController _scrollControllerPopulaire = new ScrollController();
  List<PopupMenuItem<String>> pref = [];
  int numberItemVip = 10, numberItemRecent = 8, numberItemPopulaire = 8;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyVip = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyRecent = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyPopular = new GlobalKey<RefreshIndicatorState>();
  bool loadingFull = true, loadMinim =false, isError = false;


  @override
  void initState() {
    super.initState();
    _scrollControllerVip.addListener(() async {
      if(_scrollControllerVip.position.pixels >= _scrollControllerVip.position.maxScrollExtent && !loadMinim) {
        setState(() {
          loadMinim = true;
          numberItemVip += 10;
        });
        await loadProduct();
      }
    });
    _scrollControllerRecent.addListener(() async {
      if(_scrollControllerRecent.position.pixels >= _scrollControllerRecent.position.maxScrollExtent && !loadMinim) {
        setState(() {
          loadMinim = true;
          numberItemRecent += 8;
        });
        await loadProduct();
      }
    });
    _scrollControllerPopulaire.addListener(() async {
      if(_scrollControllerPopulaire.position.pixels >= _scrollControllerPopulaire.position.maxScrollExtent && !loadMinim) {
        setState(() {
          loadMinim = true;
          numberItemPopulaire += 8;
        });
        await loadProduct();
      }
    });
    _controller = new TabController(length: 3, vsync: this)
      ..addListener(() {
        if (_controller.indexIsChanging) {
          searchCtrl.clear();
          setState(() {
            choiceSearch = _controller.index;
            choiceItemSearch = 0;
            searchData = '';
          });
          changeMenuOptionButton();
        }
      });
    loadProduct();
    verifyIfUserHaveReadModalExplain();
  }

  loadProduct() async {
    final data = await consumeAPI.getDeals(numberItemVip,numberItemRecent, numberItemPopulaire);
    setState(() {
      dealsFull = data;
    });
    new Timer(const Duration(seconds: 1), changeMenuOptionButton);
    setState(() {
      loadMinim = false;
      loadingFull = false;
    });
  }

  Future loadProductForFuture() async {
    setState(() {
      loadingFull = true;
    });
    final data = await consumeAPI.getDeals(numberItemVip,numberItemRecent, numberItemPopulaire);
    setState(() {
      dealsFull = data;
    });
    new Timer(const Duration(seconds: 1), changeMenuOptionButton);
    setState(() {
      loadingFull = false;
    });
  }

  verifyIfUserHaveReadModalExplain() async {
    final prefs = await SharedPreferences.getInstance();
    final bool asRead = prefs.getBool('readDealsModalExplain') ?? false;
    if(!asRead) {
      await modalForExplain("images/ecommerce.gif", "1 - Acheteur: Achète tout ce qui t'intérèsse en discutant avec le vendeur afin de diminuer le prix et s'assurer de la qualité, en plus on te livre, c’est satisfait ou remboursé immédiatement et intégralement.\n2 - Vendeur: Vends tout article déplaçable sans frais et bénéficie d’une boutique spéciale à ton nom.\nLe tout uniquement en fonction de vos préférences, alors si vous voulez plus de contenue vous pouvez allez complêter vos centres d'intérêts dans l'onglet Préférences.", context);
      await prefs.setBool('readDealsModalExplain', true);
    }
  }

  changeMenuOptionButton() async {
    pref.clear();
    var deals = dealsFull;
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

    final buttonFilter = new PopupMenuButton(
        key: _menuKey,
        icon: Icon(Icons.filter_list, color: Colors.white),
        itemBuilder: (_) => pref,
        tooltip: "Filtrage par categorie",
        onSelected: (value) async {
          var deals = dealsFull;
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
                    child: Row(
                      children: [
                        Expanded(
                          flex:11,
                          child: Container(
                            height: 40.0,
                            width: double.infinity,
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
                                  width: MediaQuery.of(context).size.width / 1.55,
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
                                    onChanged: (String text) async {
                                      setState(() {
                                        searchData = text;
                                      });
                                      if(searchData.length == 0) {
                                        final data = await consumeAPI.getDeals(numberItemVip,numberItemRecent, numberItemPopulaire);
                                        setState(() {
                                          dealsFull = data;
                                        });

                                      }
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
                        ),
                        Expanded(
                            flex: 1,
                            child: buttonFilter),
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
                  height: MediaQuery.of(context).size.height - 230,
                  child: new TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _controller,
                    children: <Widget>[
                      RefreshIndicator(
                        key: _refreshIndicatorKeyVip,
                        onRefresh: loadProductForFuture,
                        child: LayoutBuilder( builder: (context,contraints) {
                          if(loadingFull){
                            return Column(children: <Widget>[
                                  Expanded(
                                    child: ListView.builder(
                                    itemCount: 2,
                                    itemBuilder: (context, index) {
                                      return loadDataSkeletonOfDeals(context);
                                      },
                                    ),
                                  )
                            ]);
                          } else if(!loadingFull && isError) {
                              return isErrorSubscribe(context);
                          } else {
                            var populaireActu = dealsFull;
                            if (populaireActu[0][choiceItemSearch]['body']
                                .length ==
                                0) {
                              return Center(
                                  child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: <Widget>[
                                        SvgPicture.asset(
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
                                  child: new ListView.builder(
                                    controller: _scrollControllerVip,
                                    itemCount: populaireActu[0]
                                    [choiceItemSearch]['body']
                                        .length,
                                    itemBuilder: (context, index) {
                                      return VipDeals(
                                          level: populaireActu[0]
                                          [choiceItemSearch]['body']
                                          [index]['level'],
                                          imageUrl: populaireActu[0]
                                          [choiceItemSearch]['body']
                                          [index]['images'],
                                          archive: populaireActu[0][choiceItemSearch]
                                          ['body'][index]['archive'],
                                          title: populaireActu[0][choiceItemSearch]
                                          ['body'][index]['name'],
                                          favorite: false,
                                          price: populaireActu[0][choiceItemSearch]
                                          ['body'][index]['price'].toString() + ' XOF',
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

                          }

                        )
                      ),
                      RefreshIndicator(
                          key: _refreshIndicatorKeyRecent,
                          onRefresh: loadProductForFuture,
                          child: LayoutBuilder( builder: (context,contraints) {
                            if(loadingFull){
                              return Column(children: <Widget>[
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: 2,
                                    itemBuilder: (context, index) {
                                      return loadDataSkeletonOfDeals(context);
                                    },
                                  ),
                                )
                              ]);
                            } else if(!loadingFull && isError) {
                              return isErrorSubscribe(context);
                            } else {
                              var populaireActu = dealsFull;
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
                                          child: MasonryGridView.count(
                                            controller: _scrollControllerRecent,
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            padding: EdgeInsets.all(10.0),
                                            itemCount: populaireActu[1]
                                            [choiceItemSearch]['body']
                                                .length,
                                            itemBuilder: (BuildContext context, int index) => PopulaireDeals(
                                                level: populaireActu[1]
                                                [choiceItemSearch]['body']
                                                [index]['level'],
                                                imageUrl: populaireActu[1]
                                                [choiceItemSearch]['body']
                                                [index]['images'],
                                                archive: populaireActu[1][choiceItemSearch]
                                                ['body'][index]['archive'],
                                                title: populaireActu[1][choiceItemSearch]
                                                ['body'][index]['name'],
                                                favorite: false,
                                                price: populaireActu[1][choiceItemSearch]
                                                ['body'][index]['price'].toString()+ ' XOF',
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

                                          ),
                                        ),
                                      ],
                                    );
                                }
                              })
                      ),
                      RefreshIndicator(
                          key: _refreshIndicatorKeyPopular,
                          onRefresh: loadProductForFuture,
                          child: LayoutBuilder( builder: (context,contraints) {
                            if(loadingFull){
                              return Column(children: <Widget>[
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: 2,
                                    itemBuilder: (context, index) {
                                      return loadDataSkeletonOfDeals(context);
                                    },
                                  ),
                                )
                              ]);
                            } else if(!loadingFull && isError) {
                              return isErrorSubscribe(context);
                            } else {
                              var populaireActu = dealsFull;
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
                                          child: MasonryGridView.count(
                                            controller: _scrollControllerPopulaire,
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            padding: EdgeInsets.all(10.0),
                                            itemCount: populaireActu[2]
                                            [choiceItemSearch]['body']
                                                .length,
                                            itemBuilder: (BuildContext context, int index) => PopulaireDeals(
                                                level: populaireActu[2]
                                                [choiceItemSearch]['body']
                                                [index]['level'],
                                                imageUrl: populaireActu[2]
                                                [choiceItemSearch]['body']
                                                [index]['images'],
                                                archive: populaireActu[2][choiceItemSearch]
                                                ['body'][index]['archive'],
                                                title: populaireActu[2][choiceItemSearch]
                                                ['body'][index]['name'],
                                                favorite: false,
                                                price: populaireActu[2][choiceItemSearch]
                                                ['body'][index]['price'].toString()+ ' XOF',
                                                numero: populaireActu[2][choiceItemSearch]
                                                ['body'][index]['numero'],
                                                autor: populaireActu[2][choiceItemSearch]
                                                ['body'][index]['author'],
                                                authorName: populaireActu[2][choiceItemSearch]['body'][index]['authorName'],
                                                id: populaireActu[2][choiceItemSearch]['body'][index]['_id'],
                                                profil: populaireActu[2][choiceItemSearch]['body'][index]['profil'],
                                                onLine: populaireActu[2][choiceItemSearch]['body'][index]['onLine'],
                                                describe: populaireActu[2][choiceItemSearch]['body'][index]['describe'],
                                                numberFavorite: populaireActu[2][choiceItemSearch]['body'][index]['numberFavorite'],
                                                lieu: populaireActu[2][choiceItemSearch]['body'][index]['lieu'],
                                                registerDate: populaireActu[2][choiceItemSearch]['body'][index]['registerDate'],
                                                quantity: populaireActu[2][choiceItemSearch]['body'][index]['quantity']),

                                          ),
                                        ),
                                      ],
                                    );
                                }
                              })
                      ),
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
    final List<dynamic> oldDealsNoFutur = dealsFull;
    final newPartialDealsFull = oldDealsNoFutur[_controller.index][choiceItemSearch]['body'].where((element) => element['name'].toString().toLowerCase().indexOf(text.toLowerCase()) != -1).toList();
    oldDealsNoFutur[_controller.index][choiceItemSearch]['body'] = newPartialDealsFull;
    setState(() {
      dealsFull = oldDealsNoFutur;
    });
  }



}
