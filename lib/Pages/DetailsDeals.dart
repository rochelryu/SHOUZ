import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shouz/Constant/PageIndicator.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

import './ChatDetails.dart';

class DetailsDeals extends StatefulWidget {
  final DealsSkeletonData dealsDetailsSkeleton;
  DetailsDeals({@required this.dealsDetailsSkeleton});
  @override
  _DetailsDealsState createState() => _DetailsDealsState();
}

class _DetailsDealsState extends State<DetailsDeals> {
  int _currentItem = 0;
  String id = '';
  bool isMe = true;

  @override
  void initState() {
    getUser();
  }

  getUser() async {
    User newClient = await DBProvider.db.getClient();
    setState(() {
      id = newClient.ident;
      isMe = (widget.dealsDetailsSkeleton.autor != id) ? false : true;
    });
  }

  Future archivateProduct(String productId) async {
    /*final data = await ConsumeAPI().deleteContrat(widget.newClient.recovery, contratid);
    if(data['etat']) {
      Navigator.pushNamed(context, HomeScreen.routeName);
    } else {
      //print(data);
    }*/
    print('$id et produit $productId');

  }

  Widget build(BuildContext context) {
    bool isIos = Platform.isIOS;
    final register =
        DateTime.parse(widget.dealsDetailsSkeleton.registerDate); //.toString();
    String afficheDate = (DateTime.now()
                .difference(
                    DateTime(register.year, register.month, register.day))
                .inDays <
            1)
        ? "Aujourd'hui à ${register.hour.toString()}h ${register.minute.toString()}"
        : "Le ${register.day.toString()}/${register.month.toString()}/${register.year.toString()} à ${register.hour.toString()}h ${register.minute.toString()}";
    afficheDate = (DateTime.now()
                .difference(
                    DateTime(register.year, register.month, register.day))
                .inDays ==
            1)
        ? "Hier à ${register.hour.toString()}h ${register.minute.toString()}"
        : afficheDate;
    return new Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 1.9,
                  child: PageView.builder(
                    onPageChanged: (value) {
                      setState(() {
                        _currentItem = value;
                      });
                    },
                    itemCount: widget.dealsDetailsSkeleton.imageUrl.length,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (builder) => ViewerProduct(
                                  index: "Hero#" + index.toString(),
                                  imgUrl: widget.dealsDetailsSkeleton
                                      .imageUrl[_currentItem])),
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        child: Hero(
                          transitionOnUserGestures: true,
                          tag: "Hero#" + index.toString(),
                          child: Image.network(
                              "${ConsumeAPI.AssetProductServer}${widget.dealsDetailsSkeleton.imageUrl[_currentItem]}",
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ),
                (isIos)
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 32.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        color: Colors.black26),
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(Icons.close,
                                            color: Colors.white, size: 22.0),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    )),
                              ],
                            )
                          ],
                        ),
                      )
                    : Positioned(
                        top: 30,
                        left: 10,
                        child: SizedBox(width: 5.0),
                      ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2.7,
                  bottom: 45.0,
                  child: Container(
                    width: 100.0,
                    child: PageIndicator(_currentItem,
                        widget.dealsDetailsSkeleton.imageUrl.length),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.4,
              transform: Matrix4.translationValues(0.0, -40, 0.0),
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Padding(
                padding: EdgeInsets.only(left: 25.0, top: 20.0, right: 25.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Text(widget.dealsDetailsSkeleton.title,
                                style: Style.titre(20.0)),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Text(afficheDate,
                                    textAlign: TextAlign.center,
                                    style: Style.titre(10.0)),
                                isMe
                                    ? SizedBox(height: 30)
                                    : IconButton(
                                        icon: Icon(Icons.favorite,
                                            color: (widget.dealsDetailsSkeleton
                                                    .favorite)
                                                ? Colors.redAccent
                                                : Colors.grey,
                                            size: 22.0),
                                        onPressed: () {
                                          setState(() {
                                            widget.dealsDetailsSkeleton
                                                    .favorite =
                                                !widget.dealsDetailsSkeleton
                                                    .favorite;
                                          });
                                        },
                                      )
                              ],
                            ),
                          )
                        ],
                      ),
                      Text(
                        widget.dealsDetailsSkeleton.describe,
                        style: Style.sousTitre(14.0),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Row(
                          //   children: Accumulation(widget.dealsDetailsSkeleton.PersonneLike),
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.call, color: colorText),
                              SizedBox(width: 10),
                              Text(widget.dealsDetailsSkeleton.numero,
                                  style: Style.priceOldDealsProductBiggest())
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.local_mall, color: colorText),
                              SizedBox(width: 5),
                              Text("${widget.dealsDetailsSkeleton.quantity} disponible${widget.dealsDetailsSkeleton.quantity > 1 ? 's':''}",
                                  style: Style.priceOldDealsProductBiggest())
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: Container(
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          height: 70,
          decoration: BoxDecoration(
              color: backgroundColorSec,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.dealsDetailsSkeleton.price.toString() + " XOF",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold)),
                  Text(widget.dealsDetailsSkeleton.lieu,
                      style: TextStyle(color: Colors.white, fontSize: 13.5)),
                ],
              ),
              isMe
                  ? Row(
                children: [
                  IconButton(

                      icon: Icon(Icons.archive_rounded, color: colorText),
                      onPressed: (){
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                DialogCustomForValidateAction('ARCHIVER PRODUIT', 'Êtes vous sûr de vouloir archiver ce produit', 'Oui', () => archivateProduct(widget.dealsDetailsSkeleton.id), context),
                            barrierDismissible: false);
                        print("delete product with id : ${widget.dealsDetailsSkeleton.id}");
                      },
                      tooltip: 'Archiver cet article ?',
                      ),
                  IconButton(

                    icon: Icon(Icons.edit_outlined, color: colorText),
                    onPressed: (){
                      print("edit product with id : ${widget.dealsDetailsSkeleton.id}");
                    },
                    tooltip: 'Supprimer cet article ?',
                  ),
                ],
              )
                  : widget.dealsDetailsSkeleton.quantity > 0 ? FlatButton(
                      color: colorText,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Text("Discuter", style: Style.titre(18)),
                      onPressed: () {
                        print('${widget.dealsDetailsSkeleton.id}, ${widget.dealsDetailsSkeleton.authorName}, ${widget.dealsDetailsSkeleton.onLine}, ${widget.dealsDetailsSkeleton.profil}, ${widget.dealsDetailsSkeleton.autor}');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => ChatDetails(
                                    room: '',
                                    productId: widget.dealsDetailsSkeleton.id,
                                    name: widget.dealsDetailsSkeleton.authorName,
                                    onLine: widget.dealsDetailsSkeleton.onLine,
                                    profil: widget.dealsDetailsSkeleton.profil,
                                    authorId: widget.dealsDetailsSkeleton.autor)));
                      },
                    ) : SizedBox(width: 20)
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> Accumulation(List<String> otherClient) {
    List<Widget> entass = [];

    for (var i = 0; i < otherClient.length; i++) {
      if (i > 2) {
        var item = Container(
          margin: EdgeInsets.only(right: 10.0),
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: backgroundColorSec),
          child: Center(
            child: Text((otherClient.length - i).toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
        );
        entass.add(item);
        break;
      } else {
        var item = Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              image: DecorationImage(
                  image: AssetImage(otherClient[i]), fit: BoxFit.cover)),
        );
        entass.add(item);
      }
    }
    return entass;
  }
}

class ViewerProduct extends StatefulWidget {
  final String index;
  final String imgUrl;

  ViewerProduct({this.index, this.imgUrl});
  @override
  _ViewerProductState createState() => _ViewerProductState();
}

class _ViewerProductState extends State<ViewerProduct> {
  bool isSave = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              tooltip: "Sauvergarder l'image",
              icon: isSave
                  ? Icon(Icons.save_alt, color: colorText)
                  : Icon(Icons.save, color: Colors.white),
              onPressed: () {
                if (!isSave) {
                  setState(() {
                    isSave = true;
                  });
                } else {
                  print('already save');
                }
              }),
        ],
      ),
      body: Center(
        child: Hero(
          transitionOnUserGestures: true,
          tag: widget.index,
          child: Image.network(
              "${ConsumeAPI.AssetProductServer}${widget.imgUrl}",
              fit: BoxFit.contain),
        ),
      ),
    );
  }
}
