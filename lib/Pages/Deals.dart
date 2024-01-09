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
import 'package:shouz/Constant/helper.dart';
import 'package:shouz/Pages/search_advanced.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Constant/widget_common.dart';

import 'choice_other_hobie_second.dart';

class Deals extends StatefulWidget {
  String categorie;
  String categorieName;
  int? indexTabs;
  Deals({ required Key key, required this.categorie, required this.categorieName, this.indexTabs }) : super(key: key);
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
  int numberTotalVip = 0, numberTotalPopulaire = 0, numberTotalRecent = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyVip = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyRecent = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyPopular = new GlobalKey<RefreshIndicatorState>();
  bool loadingFull = true, loadMinim =false, isError = false, isEnd = false, readyForLaunchSearchAdvanced =false;


  @override
  void initState() {
    super.initState();
    _scrollControllerVip.addListener(() async {
      if(_scrollControllerVip.position.pixels >= _scrollControllerVip.position.maxScrollExtent && !loadMinim) {
        setState(() {
          loadMinim = true;
          numberItemVip += 17;
        });
        await loadProduct();
      }
    });
    _scrollControllerRecent.addListener(() async {
      if(_scrollControllerRecent.position.pixels >= _scrollControllerRecent.position.maxScrollExtent && !loadMinim) {
        setState(() {
          loadMinim = true;
          numberItemRecent += 17;
        });
        await loadProduct();
      }
    });
    _scrollControllerPopulaire.addListener(() async {
      if(_scrollControllerPopulaire.position.pixels >= _scrollControllerPopulaire.position.maxScrollExtent && !loadMinim) {
        setState(() {
          loadMinim = true;
          numberItemPopulaire += 17;
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
    _controller = TabController(length: 3, vsync: this, initialIndex: widget.indexTabs ?? 1)
      ..addListener(() {
        if (_controller.indexIsChanging) {
          if(searchData != '') {
            loadProduct();
          }
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
    //verifyIfUserHaveReadModalExplain();
  }

  Future loadProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {

      final data = await consumeAPI.getDeals(numberItemVip,numberItemRecent, numberItemPopulaire,searchData, widget.categorie);
      if(dealsFull.length > 0){

        if(
        data[0][0]['body'].length != dealsFull[0][0]['body'].length
            || data[1][0]['body'].length != dealsFull[1][0]['body'].length
            || data[2][0]['body'].length != dealsFull[2][0]['body'].length
        ){
          setState(() {
            dealsFull = data;
            numberTotalVip = data[3];
            numberTotalRecent = data[4];
            numberTotalPopulaire = data[5];
          });
        }
      } else {
        setState(() {
          dealsFull = data;
          numberTotalVip = data[3];
          numberTotalRecent = data[4];
          numberTotalPopulaire = data[5];
        });
      }
      Timer(const Duration(seconds: 1), changeMenuOptionButton);
      setState(() {
        loadMinim = false;
        loadingFull = false;
      });
      await prefs.setString('dealsFull${widget.categorie}', jsonEncode(data));
    }catch (e) {
      print(e);
      final dealsFullString = prefs.getString("dealsFull${widget.categorie}");
      if(dealsFullString != null) {
        if(mounted) {
          setState(() {
            dealsFull = jsonDecode(dealsFullString) as List<dynamic>;
          });
        }
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
      await modalForExplain("${ConsumeAPI.AssetPublicServer}ecommerce.gif", "1/3 - Acheteur: 🤳🏽 Discute avec le vendeur dans l'application, marchande le prix 📉, demande lui les infos sur la qualité 💁🏽‍♂️️. Paye l'article depuis l'application par mobile money, crypto-monnaie ou carte bancaire pour une garantie sécurité. Shouz te livre, c’est satisfait ou remboursé immédiatement et intégralement.", context);
      await modalForExplain("${ConsumeAPI.AssetPublicServer}ecommerce.gif", "2/3 - Vendeur: Vends tout article déplaçable sans frais et bénéficie d’une boutique spéciale à ton nom, des livraisons gratuites, des clients intéressés, des liens de partages, des propositions sur les articles les plus achetés, des discusssions directes avec les clients, une gestion & trésorie optimale de tes ventes.\n", context);
      await modalForExplain("${ConsumeAPI.AssetPublicServer}ecommerce.gif", "3/3 - Nous tenons à rappeler que nous affichons uniquement les articles dans SHOUZ en fonction de vos préférences, alors si vous voulez plus de contenu vous pouvez allez compléter vos centres d'intérêts dans l'onglet Préférences.", context);
      await prefs.setBool('readDealsModalExplain', true);
    }
  }
  changeMenuOptionButton() async {
    pref.clear();

    if(dealsFull.length > 0) {
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Style.white,)
        ),
        title: Text(widget.categorieName, style: Style.titleNews(),),
        centerTitle: true,
      ),
      body: GestureDetector(
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
                                        hintText: "Entrez ce que vous cherchez",
                                        hintStyle: TextStyle(color: colorPrimary),
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                        )),
                                    onChanged: (String text) async {
                                      setState(() {
                                        searchData = text;
                                      });

                                    },
                                    onSubmitted: (String text) async {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      Navigator.of(context).push((MaterialPageRoute(
                                          builder: (context) => SearchAdvanced(key: UniqueKey(), searchData: searchData))));
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.search, color: Colors.white),
                                  onPressed: () async {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    Navigator.of(context).push((MaterialPageRoute(
                                        builder: (context) => SearchAdvanced(key: UniqueKey(), searchData: searchData))));
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
                    dividerHeight: 0,
                    labelColor: Style.white,
                    unselectedLabelColor: colorSecondary,
                    controller: _controller,
                    padding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: colorText,
                    tabs: [
                      Tab(
                        child: Text('VIP (${numberTotalVip.toString()})', style: TextStyle(fontSize: 12),),
                      ),
                      Tab(
                        child: Text('News (${numberTotalRecent.toString()})', style: TextStyle(fontSize: 12),),
                      ),
                      Tab(
                        child: Text('Tendances (${numberTotalPopulaire.toString()})', style: TextStyle(fontSize: 12),),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 190,
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
                                              comments: populaireActu[0]
                                              [choiceItemSearch]['body']
                                              [index]['comments'],
                                              numberVue: populaireActu[0]
                                              [choiceItemSearch]['body']
                                              [index]['numberVue'],
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
                                              price: reformatNumberForDisplayOnPrice(populaireActu[0][choiceItemSearch]
                                              ['body'][index]['price']) + ' XOF',
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
                                              approved: populaireActu[0][choiceItemSearch]['body'][index]['approved'],
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
                                            comments: populaireActu[0]
                                            [choiceItemSearch]['body']
                                            [index]['comments'],
                                            numberVue: populaireActu[0]
                                            [choiceItemSearch]['body']
                                            [index]['numberVue'],
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
                                            price: reformatNumberForDisplayOnPrice(populaireActu[0][choiceItemSearch]
                                            ['body'][index]['price']) + ' XOF',
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
                                            approved: populaireActu[0][choiceItemSearch]['body'][index]['approved'],
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
                                            comments: populaireActu[1]
                                            [choiceItemSearch]['body']
                                            [index]['comments'],
                                            numberVue: populaireActu[1]
                                            [choiceItemSearch]['body']
                                            [index]['numberVue'],
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
                                            price: reformatNumberForDisplayOnPrice(populaireActu[1][choiceItemSearch]
                                            ['body'][index]['price']) + ' XOF',
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
                                            approved: populaireActu[1][choiceItemSearch]['body'][index]['approved'],
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
                                          comments: populaireActu[1]
                                          [choiceItemSearch]['body']
                                          [index]['comments'],
                                          numberVue: populaireActu[1]
                                          [choiceItemSearch]['body']
                                          [index]['numberVue'],
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
                                          price: reformatNumberForDisplayOnPrice(populaireActu[1][choiceItemSearch]
                                          ['body'][index]['price']) + ' XOF',
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
                                          approved: populaireActu[1][choiceItemSearch]['body'][index]['approved'],
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
                                            comments: populaireActu[2]
                                            [choiceItemSearch]['body']
                                            [index]['comments'],
                                            numberVue: populaireActu[2]
                                            [choiceItemSearch]['body']
                                            [index]['numberVue'],
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
                                            price: reformatNumberForDisplayOnPrice(populaireActu[2][choiceItemSearch]
                                            ['body'][index]['price']) + ' XOF',
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
                                            approved: populaireActu[2][choiceItemSearch]['body'][index]['approved'],
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
                                          comments: populaireActu[2]
                                          [choiceItemSearch]['body']
                                          [index]['comments'],
                                          numberVue: populaireActu[2]
                                          [choiceItemSearch]['body']
                                          [index]['numberVue'],
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
                                          price: reformatNumberForDisplayOnPrice(populaireActu[2][choiceItemSearch]
                                          ['body'][index]['price']) + ' XOF',
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
                                          approved: populaireActu[2][choiceItemSearch]['body'][index]['approved'],
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
      ),
    );
  }



}
