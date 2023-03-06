import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/Deals.dart';
import 'package:shouz/Pages/search_advanced.dart';

import '../Constant/PageTransition.dart';
import '../Constant/helper.dart';
import '../Constant/widget_common.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import 'CreateDeals.dart';

class AllCategorieDealsChoice extends StatefulWidget {
  const AllCategorieDealsChoice({required Key key}) : super(key: key);

  @override
  _AllCategorieDealsChoiceState createState() =>
      _AllCategorieDealsChoiceState();
}

class _AllCategorieDealsChoiceState extends State<AllCategorieDealsChoice> {
  TextEditingController searchCtrl = new TextEditingController();
  String searchData = "";
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    loadProduct();
    verifyIfUserHaveReadModalExplain();
  }

  Future loadProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final items = await consumeAPI.getCategoriesAndNumbersItemsDeals();


      setState(() {
        data = items;
      });

      await prefs.setString('listCategorieInDeals', jsonEncode(data));
    }catch (e) {
      final listCategorieInDealsString = prefs.getString("listCategorieInDeals");
      if(listCategorieInDealsString != null) {
        if(mounted) {
          setState(() {
            data = jsonDecode(listCategorieInDealsString) as List<dynamic>;
          });
        }
      }

    }
  }

  verifyIfUserHaveReadModalExplain() async {
    final prefs = await SharedPreferences.getInstance();
    final bool asRead = prefs.getBool('readFreeDeliveryModalExplain') ?? false;
    if(!asRead) {
      await modalForExplain("${ConsumeAPI.AssetPublicServer}free_delivery.svg", "Cher client, Shouz vous offre un bonus 🤩 Nouveau membre. Bénéficiez de livraison gratuite sur vos 2 premiers achats d'articles.", context, true);

      await prefs.setBool('readFreeDeliveryModalExplain', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 10.0),
              margin: EdgeInsets.symmetric(horizontal: 20),
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
              ),),
            SizedBox(height: 5.0),
            Expanded(
              child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                      itemCount: data.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if(index == 0) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text('Nos catégories d\'articles', style: Style.titre(23),),
                          );
                        } else {
                          return InkWell(
                            onTap: () {
                              Navigator.push(context, ScaleRoute(widget: Deals(key: UniqueKey(), categorie: data[index - 1]["_id"], categorieName: data[index - 1]["name"].toString().toUpperCase())));
                            },
                            child: Material(
                              elevation: 25.0,
                              borderRadius: BorderRadius.circular(5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: CachedNetworkImage(
                                  imageUrl: "${ConsumeAPI.AssetPublicServer}${data[index - 1]["picture"]}",
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        width: 100,
                                        height: 300,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                top: 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            const Color(0x00000000),
                                                            const Color(0x99111100),
                                                          ],
                                                          begin:
                                                          FractionalOffset(0.0, 0.0),
                                                          end: FractionalOffset(
                                                              0.0, 1.0))),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                          data[index - 1]["name"].toString()
                                                              .toUpperCase(),
                                                          style: Style.titreEvent(15),
                                                          textAlign: TextAlign.center),
                                                      SizedBox(height: 10.0),
                                                      Text("${data[index - 1]["nbreArticle"].toString()} Article${data[index - 1]["nbreArticle"]>1? 's':''}",
                                                        style: Style
                                                            .titleInSegment(),
                                                      ),
                                                      SizedBox(height: 10.0),
                                                    ],
                                                  ),
                                                )
                                            )],
                                        ),
                                      ),
                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                                      Center(
                                          child: CircularProgressIndicator(value: downloadProgress.progress)),
                                  errorWidget: (context, url, error) => notSignal(),
                                ),
                              ),
                            ),
                          );
                        }
                      })),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 20.0,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (builder) => CreateDeals()),
          );
        },
        backgroundColor: colorText,
        child: Icon(Icons.add, color: Colors.white, size: 22.0),
      ),
    );
  }
}
