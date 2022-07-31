import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Constant/SearchAdvancedDeals.dart';
import '../Constant/Style.dart';
import '../Constant/widget_common.dart';
import '../ServicesWorker/ConsumeAPI.dart';

class SearchAdvanced extends StatefulWidget {
  String searchData;
  SearchAdvanced({required Key key, required this.searchData}) : super(key: key);

  @override
  _SearchAdvancedState createState() => _SearchAdvancedState();
}

class _SearchAdvancedState extends State<SearchAdvanced> {
  TextEditingController searchCtrl = new TextEditingController();
  ConsumeAPI consumeAPI = new ConsumeAPI();
  bool loadingFull = true, loadMinim =false, isError = false;
  List<dynamic> dealsFull  = [];

  @override
  void initState() {
    super.initState();
    searchCtrl.text = widget.searchData;
    loadProduct();
  }

  loadProduct() async {
    if(searchCtrl.text.length > 2) {
      setState(() {
        loadingFull = true;
      });
      final data = await consumeAPI.getSearchAdvancedProduct(searchCtrl.text);
      setState(() {
        dealsFull = data;
        loadMinim = false;
        loadingFull = false;
      });
    } else {
      Fluttertoast.showToast(
          msg: 'Mot recherché trop court',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: colorError,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0.0,
        title: Text("Recherche avancée"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
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

                        onSubmitted: (String text) async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          await loadProduct();
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        await loadProduct();
                      },
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height - 165,
              width: double.infinity,
              child: LayoutBuilder( builder: (context,contraints) {
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
                  if (dealsFull.length == 0) {
                    return Center(
                    child: Column(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset("images/empty.svg",semanticsLabel: 'Shouz Empty Product',height:MediaQuery.of(context).size.height *0.39),
                      Text("Aucun resultat trouvé pour \"${searchCtrl.text}\" dans la recherche avancée",
                          textAlign: TextAlign.center,style: Style.sousTitreEvent(15)),
                    ]));
                  }
                  return ListView.builder(
                  itemCount: dealsFull.length,
                  itemBuilder: (context, index) {
                    return SearchAdvancedDeals(
                        displayProfilAuthor: true,
                        level: dealsFull[index]['level'],
                        imageUrl: dealsFull[index]['images'],
                        archive: dealsFull[index]['archive'],
                        title: dealsFull[index]['name'],
                        favorite: false,
                        price: dealsFull[index]['price'].toString() + ' XOF',
                        numero: dealsFull[index]['numero'],
                        autor: dealsFull[index]['author'],
                        authorName: dealsFull[index]['authorName'],
                        id: dealsFull[index]['_id'],
                        profil: dealsFull[index]['profil'],
                        categorieName: dealsFull[index]['categorieName'],
                        onLine: dealsFull[index]['onLine'],
                        describe: dealsFull[index]['describe'],
                        numberFavorite: dealsFull[index]['numberFavorite'],
                        lieu: dealsFull[index]['lieu'],
                        registerDate: dealsFull[index]['registerDate'],
                        quantity: dealsFull[index]['quantity']);
                  });
                }
              }
            )
            ),
          ],
        ),
      ),
    );
  }
}
