import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constant/SearchAdvancedDeals.dart';
import '../Constant/Style.dart';
import '../Constant/helper.dart';
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
          msg: "Le nom de l'article que vous recherchez est trop court. Veuillez donnez plus d'information",
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
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
              },
            icon: Icon(Icons.arrow_back, color: Style.white,)
        ),
        title: Text("Recherche avancée", style: Style.titleNews(),),
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
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 17.0),
                        height: MediaQuery.of(context).size.height,
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
                            FocusScope.of(context).requestFocus(FocusNode());
                            await loadProduct();
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
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
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  return loadDataSkeletonOfEvent(context, 175);
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
                      Text("Aucun resultat trouvé.\nMais vous pouvez nous demander de recherchez \"${searchCtrl.text}\" pour vous en cliquant sur le bouton ci-dessous",
                          textAlign: TextAlign.center,style: Style.sousTitreEvent(15)),
                      SizedBox(height: 5,),
                      ElevatedButton(
                        style: raisedButtonStyle,
                        onPressed: () async {
                          await launchUrl(
                              Uri.parse(
                                  "https://wa.me/$serviceCall?text=Salut je recherche ${searchCtrl.text} mais je n'ai aucun resultat, pouvez vous m'aider rapidement. #rechercheAvancé"),
                              mode: LaunchMode.externalApplication);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.support_agent),
                              Text(
                                "Recherchez pour moi",
                                style: Style.simpleTextOnBoard(14, colorPrimary),
                              ),
                            ],
                          ),
                        ),
                      )
                    ]));
                  }
                  return ListView.builder(
                  itemCount: dealsFull.length,
                  itemBuilder: (context, index) {
                    return SearchAdvancedDeals(
                        displayProfilAuthor: true,
                        level: dealsFull[index]['level'],
                        video: dealsFull[index]['video'],
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
                        approved: dealsFull[index]['approved'],
                        categorieName: dealsFull[index]['categorieName'],
                        onLine: dealsFull[index]['onLine'],
                        describe: dealsFull[index]['describe'],
                        numberFavorite: dealsFull[index]['numberFavorite'],
                        lieu: dealsFull[index]['lieu'],
                        registerDate: dealsFull[index]['registerDate'],
                        comments: dealsFull[index]['comments'],
                        numberVue: dealsFull[index]['numberVue'],
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
