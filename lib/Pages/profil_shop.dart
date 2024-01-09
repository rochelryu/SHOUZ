import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Constant/SearchAdvancedDeals.dart';
import '../Constant/Style.dart';
import '../Constant/widget_common.dart';
import '../MenuDrawler.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import 'DetailsDeals.dart';

class ProfilShop extends StatefulWidget {
  var authorName;
  var onLine;
  var autor;
  var profil;
  int comeBack;
  ProfilShop({required Key key, required this.authorName, required this.autor, required this.onLine, required this.profil, required this.comeBack}) : super(key: key);

  @override
  _ProfilShopState createState() => _ProfilShopState();
}

class _ProfilShopState extends State<ProfilShop> with SingleTickerProviderStateMixin {
  late TabController _controller;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  bool loadingFull = true, loadMinim =false, isError = false;
  Map<dynamic,dynamic> dealsFull  = {"arrayProductUnAvailable": [], "arrayProductAvailable": []};

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
    loadProduct();
  }

  loadProduct() async {
    final data = await consumeAPI.getOtherClientForDisplayShop(widget.autor);
    setState(() {
      dealsFull = data;
      loadMinim = false;
      loadingFull = false;
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: (){
          if(widget.comeBack == 0) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamed(context, MenuDrawler.rootName);
          }
        }, icon: Icon(Icons.arrow_back, color: Style.white,)),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
            height: 180,
            width: double.infinity,
            child: Row(
              children: [
                Material(
                  elevation: 30.0,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: Container(
                    width: 140,
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      border: Border.all(
                          width: 2.0,
                          color: widget.onLine
                              ? Colors.green[300]!
                              : Colors.yellow[300]!),
                      image: DecorationImage(
                          image: NetworkImage(
                              "${ConsumeAPI.AssetProfilServer}${widget.profil}"),
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            "Salut à vous et bienvenue dans mon magasin.\nJe suis ${widget.authorName}",
                            textStyle: Style.titre(17),
                            speed: const Duration(milliseconds: 100)
                          ),
                        ],
                        totalRepeatCount: 1,
                        pause: const Duration(milliseconds: 1500),
                        displayFullTextOnTap: false,
                        stopPauseOnTap: true,
                      )
                    ],
                  ),
                ))
              ],
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            decoration: BoxDecoration(color: Colors.transparent),
            child: TabBar(
              controller: _controller,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Style.white,
              unselectedLabelColor: colorSecondary,
              indicatorColor: colorText,
              tabs: [
                Tab(
                  //icon: const Icon(Icons.stars),
                  text: 'EN STOCK',
                ),
                Tab(
                  //icon: const Icon(Icons.shopping_cart),
                  text: 'STOCK ÉPUISÉ',
                ),
              ],
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height - 310,
              child: TabBarView(
                  controller: _controller,
                  children: <Widget>[
                    LayoutBuilder( builder: (context,contraints) {
                      if(loadingFull) {
                        return Column(
                            children: <Widget>[
                              Expanded(
                                child: ListView.builder(
                                    itemCount: 2,
                                    itemBuilder: (context, index) {
                                      return loadDataSkeletonOfDeals(context);
                                    }
                                ),
                              )
                            ]);
                      } else if(!loadingFull && isError) {
                        return isErrorSubscribe(context);
                      } else {
                        if (dealsFull["arrayProductAvailable"].length == 0) {
                          return Center(
                              child: Column(
                                  mainAxisAlignment:MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset("images/empty.svg",semanticsLabel: 'Shouz Empty Product',height:MediaQuery.of(context).size.height *0.39),
                                    Text("Aucun article VIP en stock",
                                        textAlign: TextAlign.center,style: Style.sousTitreEvent(15)),
                                  ]));
                        }
                        return ListView.builder(
                            itemCount: dealsFull["arrayProductAvailable"].length,
                            itemBuilder: (context, index) {
                              return SearchAdvancedDeals(
                                  displayProfilAuthor: false,
                                  comments: dealsFull["arrayProductAvailable"][index]['comments'],
                                  numberVue: dealsFull["arrayProductAvailable"][index]['numberVue'],
                                  level: dealsFull["arrayProductAvailable"][index]['level'],
                                  video: dealsFull["arrayProductAvailable"][index]['video'],
                                  imageUrl: dealsFull["arrayProductAvailable"][index]['images'],
                                  archive: dealsFull["arrayProductAvailable"][index]['archive'],
                                  title: dealsFull["arrayProductAvailable"][index]['name'],
                                  favorite: false,
                                  approved: dealsFull["arrayProductAvailable"][index]['approved'],
                                  price: dealsFull["arrayProductAvailable"][index]['price'].toString() + ' XOF',
                                  numero: dealsFull["arrayProductAvailable"][index]['numero'],
                                  autor: dealsFull["arrayProductAvailable"][index]['author'],
                                  authorName: dealsFull["arrayProductAvailable"][index]['authorName'],
                                  id: dealsFull["arrayProductAvailable"][index]['_id'],
                                  profil: dealsFull["arrayProductAvailable"][index]['profil'],
                                  categorieName: dealsFull["arrayProductAvailable"][index]['categorieName'],
                                  onLine: dealsFull["arrayProductAvailable"][index]['onLine'],
                                  describe: dealsFull["arrayProductAvailable"][index]['describe'],
                                  numberFavorite: dealsFull["arrayProductAvailable"][index]['numberFavorite'],
                                  lieu: dealsFull["arrayProductAvailable"][index]['lieu'],
                                  registerDate: dealsFull["arrayProductAvailable"][index]['registerDate'],
                                  quantity: dealsFull["arrayProductAvailable"][index]['quantity']);
                            });
                      }
                    }
                    ),
                    LayoutBuilder( builder: (context,contraints) {
                      if(loadingFull) {
                        return Column(
                            children: <Widget>[
                              Expanded(
                                child: ListView.builder(
                                    itemCount: 2,
                                    itemBuilder: (context, index) {
                                      return loadDataSkeletonOfDeals(context);
                                    }
                                ),
                              )
                            ]);
                      } else if(!loadingFull && isError) {
                        return isErrorSubscribe(context);
                      } else {
                        if (dealsFull["arrayProductUnAvailable"].length == 0) {
                          return Center(
                              child: Column(
                                  mainAxisAlignment:MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset("images/empty.svg",semanticsLabel: 'Shouz Empty Product',height:MediaQuery.of(context).size.height *0.39),
                                    Text("Aucun article VIP n'a été vendu jusqu'à présent",
                                        textAlign: TextAlign.center,style: Style.sousTitreEvent(15)),
                                  ]));
                        }
                        return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                            itemCount: dealsFull["arrayProductUnAvailable"].length,
                            itemBuilder: (context, index) {
                              final item = dealsFull["arrayProductUnAvailable"][index];
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .push((MaterialPageRoute(builder: (context) {
                                    DealsSkeletonData element = DealsSkeletonData(
                                      comments: item['comments'],
                                      numberVue: item['numberVue'],
                                      quantity: item['quantity'],
                                      video: item['video'],
                                      archive: item['archive'],
                                      level: item['level'],
                                      numberFavorite: item['numberFavorite'],
                                      lieu: item['lieu'],
                                      id: item['_id'],
                                      registerDate: item['registerDate'],
                                      profil: item['profil'],
                                      imageUrl: item['images'],
                                      title: item['name'],
                                      price: item['price'],
                                      autor: item['author'],
                                      numero: item['numero'],
                                      describe: item['describe'],
                                      onLine: item['onLine'],
                                      authorName: item['authorName'],
                                      categorieName: item['categorieName'],
                                      approved: item['approved'],
                                    );
                                    return DetailsDeals(dealsDetailsSkeleton: element, comeBack: 0);
                                  })));
                                },
                                child: Image.network(
                                    "${ConsumeAPI.AssetProductServer}${item['images'][0]}",
                                    fit: BoxFit.cover),
                              );
                            });
                      }
                    }
                    ),
                  ]
              )
          )
        ],
      ),

    );
  }
}
