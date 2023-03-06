import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/DetailsDeals.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:url_launcher/url_launcher.dart';


class SearchAdvancedDeals extends StatefulWidget {
  var imageUrl;
  var title;
  var favorite;
  var price;
  var numero;
  var autor;
  var profil;
  var onLine;
  var describe;
  var numberFavorite;
  var lieu;
  var registerDate;
  var quantity;
  var level;
  var authorName;
  var archive;
  var categorieName;
  var video;
  String id;
  bool displayProfilAuthor;
  var approved;
  var comments;
  var numberVue;
  List<String> PersonneLike = [];
  SearchAdvancedDeals({this.imageUrl,this.comments, this.numberVue , this.title, this.favorite,this.price, this.numero, this.autor, required this.id, this.profil, this.onLine,this.level, this.describe, this.numberFavorite, this.lieu, this.registerDate, this.quantity, this.authorName, this.archive, this.categorieName, required this.displayProfilAuthor, this.video, this.approved});
  @override
  _SearchAdvancedDealsState createState() => _SearchAdvancedDealsState();
}

class _SearchAdvancedDealsState extends State<SearchAdvancedDeals> {

  @override
  Widget build(BuildContext context) {
    final register = DateTime.parse(widget.registerDate); //.toString();
    String afficheDate = (DateTime.now().difference(DateTime(register.year,register.month,register.day)).inDays < 1) ?  "Auj. à ${register.hour.toString()}h ${register.minute.toString()}"  : "${register.day.toString()}/${register.month.toString()}/${register.year.toString()} à ${register.hour.toString()}h ${register.minute.toString()}";
    afficheDate = (DateTime.now().difference(DateTime(register.year,register.month,register.day)).inDays == 1) ? "Hier à ${register.hour.toString()}h ${register.minute.toString()}"  : afficheDate;
    if(widget.level == 3) {
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Material(
              elevation: 30.0,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0)),
              child: Container(
                height: 155,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0)),
                  image: DecorationImage(
                      image: NetworkImage(
                          "${ConsumeAPI.AssetProductServer}${widget.imageUrl[0]}"),
                      fit: BoxFit.cover),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push((MaterialPageRoute(builder: (context) {
                      DealsSkeletonData item = DealsSkeletonData(
                          comments: widget.comments,
                          numberVue:widget.numberVue,
                        level: widget.level,
                        video: widget.video,
                        quantity: widget.quantity,
                        numberFavorite: widget.numberFavorite,
                        lieu: widget.lieu,
                        id: widget.id,
                        registerDate: widget.registerDate,
                        profil: widget.profil,
                        imageUrl: widget.imageUrl,
                        title: widget.title,
                        price: widget.price,
                        autor: widget.autor,
                        numero: widget.numero,
                        describe: widget.describe,
                        onLine: widget.onLine,
                        authorName: widget.authorName,
                        archive: widget.archive,
                        categorieName: widget.categorieName,
                        approved: widget.approved
                      );
                      return DetailsDeals(dealsDetailsSkeleton: item, comeBack: 0);
                    })));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      if(widget.displayProfilAuthor) Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(10.0),
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2.0,
                                  color: widget.onLine
                                      ? Colors.green[300]!
                                      : Colors.yellow[300]!),
                              borderRadius: BorderRadius.circular(50.0),
                              image: DecorationImage(
                                  image: NetworkImage(
                                      "${ConsumeAPI.AssetProfilServer}${widget.profil}"),
                                  fit: BoxFit.cover),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 155,
              width: MediaQuery.of(context).size.width * 0.53,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [backgroundColor, tint],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0))),
              child: InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push((MaterialPageRoute(builder: (context) {
                    DealsSkeletonData item = DealsSkeletonData(
                        comments: widget.comments,
                        numberVue:widget.numberVue,
                      level: widget.level,
                      video: widget.video,
                      quantity: widget.quantity,
                      numberFavorite: widget.numberFavorite,
                      lieu: widget.lieu,
                      id: widget.id,
                      registerDate: widget.registerDate,
                      profil: widget.profil,
                      imageUrl: widget.imageUrl,
                      title: widget.title,
                      price: widget.price,
                      autor: widget.autor,
                      numero: widget.numero,
                      describe: widget.describe,
                      onLine: widget.onLine,
                      authorName: widget.authorName,
                      archive: widget.archive,
                      categorieName: widget.categorieName,
                      approved: widget.approved
                    );
                    return DetailsDeals(dealsDetailsSkeleton: item, comeBack: 0);
                  })));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 5.0, top: 8.0, right: 3.0),
                        child:Text(widget.title, style: Style.titleDealsProduct(), maxLines: 4, overflow: TextOverflow.ellipsis,)),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text("${widget.price.toString()}",
                          style: Style.priceDealsProduct()),
                    ),
                    Spacer(),
                    Container(
                      height: 40,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(afficheDate, style: Style.numberOfLike()),
                              ],
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(widget.numberFavorite.toString(),
                                      style: Style.numberOfLike()),
                                  SizedBox(width: 5.0),
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.redAccent,
                                    size: 13.0,
                                  ),
                                  SizedBox(width: 5.0),
                                ],
                              )),
                          /*IconButton(
                      icon: Icon(Icons.call, color: Colors.green),
                      onPressed: () async {
                        await launchUrlString("tel:${widget.numero}");
                      }),*/


                          /*IconButton(
                      icon: Icon(Style.social_normal, color: tint),
                      onPressed: () {
                        Share.share("${ConsumeAPI.ProductLink}${widget.id}");
                      }),*/
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                          colors: [backgroundColor, tint],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.call, color: Colors.green),
                      onPressed: () async {
                        await launchUrl(Uri(scheme: "tel", path: widget.numero));
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                          colors: [backgroundColor, tint],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                    ),
                    child: IconButton(
                      icon: Icon(Style.social_normal, color: Style.yellow),
                      onPressed: () {
                        Share.share("${ConsumeAPI.ProductLink}${widget.id}");
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Material(
              elevation: 30.0,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0)),
              child: Container(
                height: 155,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0)),
                  image: DecorationImage(
                      image: NetworkImage(
                          "${ConsumeAPI.AssetProductServer}${widget.imageUrl[0]}"),
                      fit: BoxFit.cover),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push((MaterialPageRoute(builder: (context) {
                      DealsSkeletonData item = DealsSkeletonData(
                          comments: widget.comments,
                          numberVue: widget.numberVue,
                        level: widget.level,
                        video: widget.video,
                        quantity: widget.quantity,
                        numberFavorite: widget.numberFavorite,
                        lieu: widget.lieu,
                        id: widget.id,
                        registerDate: widget.registerDate,
                        profil: widget.profil,
                        imageUrl: widget.imageUrl,
                        title: widget.title,
                        price: widget.price,
                        autor: widget.autor,
                        numero: widget.numero,
                        describe: widget.describe,
                        onLine: widget.onLine,
                        authorName: widget.authorName,
                        archive: widget.archive,
                        categorieName: widget.categorieName,approved: widget.approved
                      );
                      return DetailsDeals(dealsDetailsSkeleton: item, comeBack: 0);
                    })));
                  },

                ),
              ),
            ),
            Container(
              height: 155,
              width: MediaQuery.of(context).size.width * 0.63,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [backgroundColor, tint],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0))),
              child: InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push((MaterialPageRoute(builder: (context) {
                    DealsSkeletonData item = DealsSkeletonData(
                        comments: widget.comments,
                        numberVue: widget.numberVue,
                      level: widget.level,
                      video: widget.video,
                      quantity: widget.quantity,
                      numberFavorite: widget.numberFavorite,
                      lieu: widget.lieu,
                      id: widget.id,
                      registerDate: widget.registerDate,
                      profil: widget.profil,
                      imageUrl: widget.imageUrl,
                      title: widget.title,
                      price: widget.price,
                      autor: widget.autor,
                      numero: widget.numero,
                      describe: widget.describe,
                      onLine: widget.onLine,
                      authorName: widget.authorName,
                      archive: widget.archive,
                      categorieName: widget.categorieName, approved: widget.approved
                    );
                    return DetailsDeals(dealsDetailsSkeleton: item, comeBack: 0);
                  })));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 5.0, top: 8.0),
                        child:
                        Text(widget.title, style: Style.titleDealsProduct(), maxLines: 4, overflow: TextOverflow.ellipsis)),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text("${widget.price.toString()}",
                          style: Style.priceDealsProduct()),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                            height: 40,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(afficheDate, style: Style.numberOfLike()),
                                    ],
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(left: 5.0),
                                    width: 60,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(widget.numberFavorite.toString(),
                                            style: Style.numberOfLike()),
                                        SizedBox(width: 5.0),
                                        Icon(
                                          Icons.favorite,
                                          color: Colors.redAccent,
                                          size: 17.0,
                                        )
                                      ],
                                    )),
                                /*IconButton(
                                icon: Icon(Icons.call, color: Colors.green),
                                onPressed: () async {
                                  await launchUrlString("tel:${widget.numero}");
                                }),*/


                                /*IconButton(
                                icon: Icon(Style.social_normal, color: tint),
                                onPressed: () {
                                  Share.share("${ConsumeAPI.ProductLink}${widget.id}");
                                }),*/
                              ],
                            ),
                          ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

          ],
        ),
      );
    }
  }
}