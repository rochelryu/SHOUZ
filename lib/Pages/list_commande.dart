import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/helper.dart';

import '../Constant/Style.dart';
import '../Constant/widget_common.dart';
import '../Models/User.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import '../Utils/Database.dart';
import 'ChatDetails.dart';

class ListCommande extends StatefulWidget {
  final String productId;
  final int level;
  const ListCommande({required Key key, required this.productId, required this.level }) : super(key: key);

  @override
  _ListCommandeState createState() => _ListCommandeState();
}

class _ListCommandeState extends State<ListCommande> {
  bool loadingFull = true, isError = false;
  User? user;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  List<dynamic> allCommandes = [];

  @override
  void initState() {
    super.initState();
    getUser();
    loadCommandes();

  }
  getUser() async {
    User newClient = await DBProvider.db.getClient();
    setState(() {
      user = newClient;
    });
  }

  Future loadCommandes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final data = await consumeAPI.getAllCommandeProduct(widget.productId);
      setState(() {
        allCommandes = data;
        loadingFull = false;
      });
      await prefs.setString('allCommandes${widget.productId}', jsonEncode(data));
    } catch (e) {
      final allCommandesString = prefs.getString("allCommandes${widget.productId}");

      if(allCommandesString != null) {
        setState(() {
          allCommandes = jsonDecode(allCommandesString) as List<dynamic>;
        });
      }
      setState(() {
        isError = true;
        loadingFull = false;
      });
      await askedToLead(allCommandes.isNotEmpty ? "Aucune connection internet, donc nous vous affichons quelques commandes en mode hors ligne":"Aucune connection internet, veuillez vérifier vos données internet", false, context);
    }
  }
  @override
  Widget build(BuildContext context) {
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
        title: Text("Liste des commandes", style: Style.titleNews(),),
        centerTitle: true,
      ),
      body: LayoutBuilder(
          builder: (context,contraints) {
            if(loadingFull){
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(child: Container(
                  height: 70,
                  width: 70,
                  child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2),
                ),),
              );
            } else if(!loadingFull && isError && allCommandes.isEmpty) {
              return isErrorSubscribe(context);
            } else {
              if (allCommandes.isEmpty) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.asset(
                            "images/empty.svg",
                            semanticsLabel: 'Shouz empty',
                            height: MediaQuery.of(context).size.height * 0.35,
                          ),
                          Text(
                              "Aucune commande n'a été enrégistré",
                              textAlign: TextAlign.center,
                              style: Style.sousTitreEvent(15)),

                        ]));
              }
              return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: allCommandes.length,
                          itemBuilder: (context, index) {
                            final commande = allCommandes[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              color: backgroundColor,
                              elevation: 5,
                              child: Container(
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0)
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) => ChatDetails(
                                                newClient: user!,
                                                comeBack: 0,
                                                room: commande['room'],
                                                productId: widget.productId,
                                                name: commande["client"][0]["name"],
                                                onLine: commande["client"][0]["onLine"],
                                                profil: commande["client"][0]["images"],
                                                authorId: commande["client"][0]["_id"])));
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      CachedNetworkImage(
                                        imageUrl: "${ConsumeAPI.AssetProfilServer}${commande["client"][0]["images"]}",
                                        imageBuilder: (context, imageProvider) =>
                                            Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: commande["client"][0]["onLine"] ? Colors.green[300]!: Colors.yellow[300]! ),
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),

                                            ),
                                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                                            Center(
                                                child: CircularProgressIndicator(value: downloadProgress.progress)),
                                        errorWidget: (context, url, error) => notSignal(),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(child:
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(commande["client"][0]["name"], style: Style.secondTitre(13)),
                                            if(commande["lastMessage"][0]["image"].toString().indexOf(".m4a") != -1)Text(commande["lastMessage"][0]["ident"] == user?.ident ? "🗣 Vous avez envoyé une note vocale": "🗣 Vous a envoyé une note vocale", style: Style.simpleTextOnBoard(12, colorWelcome)),
                                            if(commande["lastMessage"][0]["image"].toString().indexOf(".m4a") == -1 && commande["lastMessage"][0]["image"] != "")Text(commande["lastMessage"][0]["ident"] == user?.ident ? "🖼️ Vous avez envoyé une image": "🖼️ Vous a envoyé une image", style: Style.simpleTextOnBoard(12, colorWelcome)),
                                            if(commande["lastMessage"][0]["image"] == "")Text(commande["lastMessage"][0]["ident"] == user?.ident ? "Vous: ${commande["lastMessage"][0]["content"]}": "${commande["lastMessage"][0]["content"]}", style: Style.simpleTextOnBoard(12, colorWelcome), maxLines: 2, overflow: TextOverflow.ellipsis),
                                            if(commande["etatCommunication"] != "Conversation between users") Text("Prix total: ${reformatNumberForDisplayOnPrice(commande["priceFinal"])} ${user?.currencies}. Qte Totale: ${commande["quantityProduct"].toString()}", style: Style.simpleTextOnBoard(12, colorWelcome), maxLines: 2, overflow: TextOverflow.ellipsis),
                                            statusLevelDelivery(commande["levelDelivery"]),
                                          ],
                                        )
                                      ),
                                      if(!commande["lastMessage"][0]['isReadByOtherUser'] && commande["lastMessage"][0]['ident'] != user?.ident) badges.Badge(

                                        badgeStyle: badges.BadgeStyle(badgeColor: colorText,padding: EdgeInsets.all(10),),
                                        badgeContent: Text("!", style: Style.titre(15),),
                                        child: SizedBox(
                                          height: double.infinity,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    )
                  ]);

            }
        }
      ),
    );
  }

  Widget statusLevelDelivery(int levelDelivery) {
    if(levelDelivery == 0) {
      return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)),
        color: colorWarning,
        child: Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0)
          ),
          child: Center(
            child: Text("Le client est intéréssé", style: Style.simpleTextInContainer(Colors.black),),
          ),
        ),
      );
    }
    if(levelDelivery == 1) {
      return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)),
        color: colorText,
        child: Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0)
          ),
          child: Center(
            child: Text("Le livreur vient chercher", style: Style.simpleTextInContainer()),
          ),
        ),
      );
    }
    if(levelDelivery == 2) {
      return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)),
        color: colorWarning,
        child: Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0)
          ),
          child: Center(
            child: Text("Article au siège", style: Style.simpleTextInContainer()),
          ),
        ),
      );
    }
    if(levelDelivery == 3) {
      return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)),
        color: colorPrimary,
        child: Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0)
          ),
          child: Center(
            child: Text("Article avec le client", style: Style.simpleTextInContainer(Colors.black),),
          ),
        ),
      );
    }
    if(levelDelivery == 4) {
      return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)),
        color: colorError,
        child: Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0)
          ),
          child: Center(
            child: Text("Client insatisfait", style: Style.simpleTextInContainer()),
          ),
        ),
      );
    }
    if(levelDelivery == 5) {
      return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)),
        color: colorSuccess,
        child: Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0)
          ),
          child: Center(
            child: Text("Client satisfait", style: Style.simpleTextInContainer()),
          ),
        ),
      );
    }
    if(levelDelivery == 6) {
      return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)),
        color: colorWarning,
        child: Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0)
          ),
          child: Center(
            child: Text("Delais client dépassé", style: Style.simpleTextInContainer()),
          ),
        ),
      );
    }
    if(levelDelivery == 7) {
      return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)),
        color: colorError,
        child: Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0)
          ),
          child: Center(
            child: Text("Delais client dépassé", style: Style.simpleTextInContainer()),
          ),
        ),
      );
    }
    else {
      return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
        color: colorError,
        child: Container(
          width: 200,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0)
          ),
          child: Center(
            child: Text("N/A"),
          ),
        ),

      );
    }
  }
}
