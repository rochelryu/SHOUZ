import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Pages/DetailsDeals.dart';

class VipDeals extends StatefulWidget {
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
  var authorName;
  var archive;
  var level;
  var categorieName;
  var video;
  String id;
  List<String> personneLike = [];
  VipDeals(
      {this.imageUrl,
      this.title,
      this.favorite,
      this.price,
      this.level,
      this.numero,
      this.autor,
      required this.id,
      this.profil,
      this.onLine,
      this.describe,
      this.numberFavorite,
      this.lieu,
      this.registerDate,
      this.quantity,
      this.archive,
      this.authorName, this.categorieName, this.video});
  @override
  _VipDealsState createState() => _VipDealsState();
}

class _VipDealsState extends State<VipDeals> {
  @override
  Widget build(BuildContext context) {
    final register = DateTime.parse(widget.registerDate); //.toString();
    String afficheDate = (DateTime.now()
                .difference(
                    DateTime(register.year, register.month, register.day))
                .inDays <
            1)
        ? "Auj. à ${register.hour.toString()}h ${register.minute.toString()}"
        : "Le ${register.day.toString()}/${register.month.toString()}/${register.year.toString()} à ${register.hour.toString()}h ${register.minute.toString()}";
    afficheDate = (DateTime.now()
                .difference(
                    DateTime(register.year, register.month, register.day))
                .inDays ==
            1)
        ? "Hier à ${register.hour.toString()}h ${register.minute.toString()}"
        : afficheDate;
    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 18.0),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push((MaterialPageRoute(builder: (context) {
                DealsSkeletonData item = DealsSkeletonData(
                  level: widget.level,
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
                  video: widget.video,
                );
                return DetailsDeals(dealsDetailsSkeleton: item, comeBack: 0);
              })));
            },
            child: Container(
              height: 200,
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [backgroundColor, tint],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0))),
              margin: EdgeInsets.only(top: 45.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 8.0),
                      child:
                          Text(widget.title, style: Style.titleDealsProduct())),
                  Padding(
                      padding: EdgeInsets.only(left: 15.0),
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
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${widget.price.toString()}",
                            style: Style.priceDealsProduct()),
                        SizedBox(width: 15.0),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(afficheDate, style: Style.numberOfLike()),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(10.0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () async {
                              await launchUrl(Uri(scheme: 'tel', path: widget.numero));
                            }),

                        SizedBox(width: 7.0),
                        IconButton(
                            icon: Icon(Style.social_normal, color: tint),
                            onPressed: () {
                              Share.share("${ConsumeAPI.ProductLink}${widget.id}");
                            }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width / 2.3,
            child: Material(
              elevation: 30.0,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
              child: CachedNetworkImage(
                imageUrl: "${ConsumeAPI.AssetProductServer}${widget.imageUrl[0]}",
                imageBuilder: (context, imageProvider) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0)),
                    image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push((MaterialPageRoute(builder: (context) {
                        DealsSkeletonData item = DealsSkeletonData(
                            level: widget.level,
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
                          video: widget.video,
                        );
                        return DetailsDeals(dealsDetailsSkeleton: item, comeBack: 0);
                      })));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
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
                  ),),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                        child: CircularProgressIndicator(value: downloadProgress.progress)),
                errorWidget: (context, url, error) => notSignal(),
              )
            ),
          )
        ],
      ),
    );
  }
}
