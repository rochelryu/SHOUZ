import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/PopulaireDeals.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/VipDeals.dart';
import 'package:shouz/Pages/search_advanced.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Constant/widget_common.dart';

import './CreateDeals.dart';
import 'choice_other_hobie_second.dart';

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
  bool loadingFull = true, loadMinim =false, isError = false, isEnd = false;


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
    _controller = TabController(length: 3, vsync: this)
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

  Future loadProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final data = await consumeAPI.getDeals(numberItemVip,numberItemRecent, numberItemPopulaire);
      setState(() {
        dealsFull = data;
      });
      Timer(const Duration(seconds: 1), changeMenuOptionButton);
      setState(() {
        loadMinim = false;
        loadingFull = false;
      });
      await prefs.setString('dealsFull', jsonEncode(data));
    }catch (e) {
      final dealsFullString = prefs.getString("dealsFull");
      if(dealsFullString != null) {
        setState(() {
          dealsFull = jsonDecode(dealsFullString) as List<dynamic>;
        });
        Timer(const Duration(seconds: 1), changeMenuOptionButton);
      }
      setState(() {
        isError = true;
        loadingFull = false;
      });
      await askedToLead(dealsFull.length > 0 ? "Aucune connection internet, donc nous vous affichons quelques articles en mode hors ligne":"Aucune connection internet, veuillez vérifier vos données internet", false, context);
    }
  }

  verifyIfUserHaveReadModalExplain() async {
    final prefs = await SharedPreferences.getInstance();
    final bool asRead = prefs.getBool('readDealsModalExplain') ?? false;
    if(!asRead) {
      await modalForExplain("images/ecommerce.gif", "1 - Acheteur: Achète tout ce qui t'intérèsse en discutant avec le vendeur afin de diminuer le prix et s'assurer de la qualité, en plus on te livre, c’est satisfait ou remboursé immédiatement et intégralement.\n2 - Vendeur: Vends tout article déplaçable sans frais et bénéficie d’une boutique spéciale à ton nom.\nLe tout uniquement en fonction de vos préférences, alors si vous voulez plus de contenu vous pouvez allez compléter vos centres d'intérêts dans l'onglet Préférences.", context);
      await prefs.setBool('readDealsModalExplain', true);
    }
  }
  changeMenuOptionButton() async {
    pref.clear();
    var deals = dealsFull;
    for (var i = 0; i < deals[choiceSearch].length; i++) {
      final item = PopupMenuItem<String>(
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Timer(Duration(milliseconds: 1000), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));

    final buttonFilter = PopupMenuButton(
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
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
                                  child: TextField(
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
                                      FocusScope.of(context).requestFocus(FocusNode());
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.search, color: Colors.white),
                                  onPressed: () {
                                    searchDataInContext(searchData);
                                    FocusScope.of(context).requestFocus(FocusNode());
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
                Container(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: TabBar(
                    controller: _controller,
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: colorText,
                    tabs: [
                      Tab(
                        //icon: const Icon(Icons.stars),
                        text: 'VIP',
                      ),
                      Tab(
                        //icon: const Icon(Icons.shopping_cart),
                        text: 'RECENT',
                      ),
                      Tab(
                        //icon: const Icon(Icons.star_half),
                        text: 'POPULAIRE',
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 230,
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _controller,
                    children: <Widget>[
                      RefreshIndicator(
                        key: _refreshIndicatorKeyVip,
                        onRefresh: loadProduct,
                        child: LayoutBuilder( builder: (context,contraints) {
                          if(loadingFull){
                            if(dealsFull.length > 0 && dealsFull[0][choiceItemSearch]['body'].length > 0) {
                              var populaireActu = dealsFull;
                              return Column(
                                children: <Widget>[
                                  Expanded(
                                    child: ListView.builder(
                                      controller: _scrollControllerVip,
                                      itemCount: populaireActu[0]
                                      [choiceItemSearch]['body']
                                          .length,
                                      itemBuilder: (context, index) {
                                        return VipDeals(
                                            level: populaireActu[0]
                                            [choiceItemSearch]['body']
                                            [index]['level'],
                                            video: populaireActu[0]
                                            [choiceItemSearch]['body']
                                            [index]['video'],
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
                                            categorieName: populaireActu[0][choiceItemSearch]['body'][index]['categorieName'],
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
                          } else if(!loadingFull && isError && dealsFull.length == 0) {
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
                                            searchData == "" ? "Aucun Deals Vip pour le moment selon vos centres d'intérêts": "Aucun resultat trouvé pour \"$searchData\" dans la recherche directe.\nVous pouvez lancer une recherche avancée",
                                            textAlign: TextAlign.center,
                                            style: Style.sousTitreEvent(15)),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            if(searchData == "") {
                                              Navigator.of(context).push((MaterialPageRoute(
                                                  builder: (context) => ChoiceOtherHobieSecond(key: UniqueKey()))));
                                            } else {
                                              if(!isError) {
                                                Navigator.of(context).push((MaterialPageRoute(
                                                    builder: (context) => SearchAdvanced(key: UniqueKey(), searchData: searchData))));
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: 'Aucune connexion internet, désolé',
                                                    toastLength: Toast.LENGTH_LONG,
                                                    gravity: ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: colorError,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0
                                                );
                                              }

                                            }

                                          },
                                          child: Text(searchData == "" ? 'Ajouter Préférence': 'Lancer la recherche avancée'),
                                          style: raisedButtonStyle,
                                        )
                                      ]));
                            }
                            return Column(
                              children: <Widget>[
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollControllerVip,
                                    itemCount: populaireActu[0]
                                    [choiceItemSearch]['body']
                                        .length,
                                    itemBuilder: (context, index) {
                                      return VipDeals(
                                          level: populaireActu[0]
                                          [choiceItemSearch]['body']
                                          [index]['level'],
                                          video: populaireActu[0]
                                          [choiceItemSearch]['body']
                                          [index]['video'],
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
                                          categorieName: populaireActu[0][choiceItemSearch]['body'][index]['categorieName'],
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
                          onRefresh: loadProduct,
                          child: LayoutBuilder( builder: (context,contraints) {
                            if(loadingFull){
                              if(dealsFull.length > 0 && dealsFull[1][choiceItemSearch]['body'].length > 0) {
                                var populaireActu = dealsFull;
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
                                          video: populaireActu[1]
                                          [choiceItemSearch]['body']
                                          [index]['video'],
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
                                          categorieName: populaireActu[1][choiceItemSearch]['body'][index]['categorieName'],
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
                            } else if(!loadingFull && isError && dealsFull.length == 0) {
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
                                                SvgPicture.asset(
                                                  "images/empty.svg",
                                                  semanticsLabel: 'Shouz Pay',
                                                  height:
                                                  MediaQuery.of(context).size.height *
                                                      0.39,
                                                ),
                                                Text(
                                                    searchData == "" ? "Aucun Deals Récents pour le moment selon vos centres d'intérêts": "Aucun resultat trouvé pour \"$searchData\" dans la recherche directe.\nVous pouvez lancer une recherche avancée",
                                                    textAlign: TextAlign.center,
                                                    style: Style.sousTitreEvent(15)),
                                                SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if(searchData == "") {
                                                      Navigator.of(context).push((MaterialPageRoute(
                                                          builder: (context) => ChoiceOtherHobieSecond(key: UniqueKey()))));
                                                    } else {
                                                      Navigator.of(context).push((MaterialPageRoute(
                                                          builder: (context) => SearchAdvanced(key: UniqueKey(), searchData: searchData))));

                                                    }

                                                  },
                                                  child: Text(searchData == "" ? 'Ajouter Préférence': 'Lancer la recherche avancée'),
                                                  style: raisedButtonStyle,
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
                                                video: populaireActu[1]
                                                [choiceItemSearch]['body']
                                                [index]['video'],
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
                                                categorieName: populaireActu[1][choiceItemSearch]['body'][index]['categorieName'],
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
                          onRefresh: loadProduct,
                          child: LayoutBuilder( builder: (context,contraints) {
                            if(loadingFull){
                              if(dealsFull.length > 0 && dealsFull[2][choiceItemSearch]['body'].length > 0) {
                                var populaireActu = dealsFull;
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
                                            video: populaireActu[2]
                                            [choiceItemSearch]['body']
                                            [index]['video'],
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
                                            categorieName: populaireActu[2][choiceItemSearch]['body'][index]['categorieName'],
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
                            } else if(!loadingFull && isError && dealsFull.length == 0) {
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
                                                SvgPicture.asset(
                                                  "images/empty.svg",
                                                  semanticsLabel: 'Shouz Pay',
                                                  height:
                                                  MediaQuery.of(context).size.height *
                                                      0.39,
                                                ),
                                                Text(
                                                    searchData == "" ? "Aucun Deals Populaire pour le moment selon vos centres d'intérêts": "Aucun resultat trouvé pour \"$searchData\" dans la recherche directe.\nVous pouvez lancer une recherche avancée",
                                                    textAlign: TextAlign.center,
                                                    style: Style.sousTitreEvent(15)),
                                                SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if(searchData == "") {
                                                      Navigator.of(context).push((MaterialPageRoute(
                                                          builder: (context) => ChoiceOtherHobieSecond(key: UniqueKey(),))));
                                                    } else {
                                                      Navigator.of(context).push((MaterialPageRoute(
                                                          builder: (context) => SearchAdvanced(key: UniqueKey(), searchData: searchData))));
                                                    }

                                                  },
                                                  child: Text(searchData == "" ? 'Ajouter Préférence': 'Lancer la recherche avancée'),
                                                  style: raisedButtonStyle,
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
                                                video: populaireActu[2]
                                                [choiceItemSearch]['body']
                                                [index]['video'],
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
                                                categorieName: populaireActu[2][choiceItemSearch]['body'][index]['categorieName'],
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
              child: FloatingActionButton(
                elevation: 20.0,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (builder) => CreateDeals()),
                  );
                },
                backgroundColor: colorText,
                child: Icon(Icons.add, color: Colors.white, size: 22.0),
              ),
            ),
            if(loadMinim) Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                    ),
                    child: LoadingIndicator(indicatorType: Indicator.ballRotateChase,colors: [colorText], strokeWidth: 2),
                  ),
                ))
          ],
        ),
    );
  }

  void searchDataInContext(String text) async {
    final List<dynamic> oldDealsNoFutur = dealsFull;
    final List<dynamic> newPartialDealsFull = oldDealsNoFutur[_controller.index][choiceItemSearch]['body'].where((element) => element['name'].toString().toLowerCase().indexOf(text.toLowerCase()) != -1).toList();
    oldDealsNoFutur[_controller.index][choiceItemSearch]['body'] = newPartialDealsFull;
    setState(() {
      dealsFull = oldDealsNoFutur;
    });
  }



}
