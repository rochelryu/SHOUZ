import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/helper.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Pages/DetailsDeals.dart';

class VipDeals extends StatelessWidget {
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
  var approved;
  String id;
  var comments;
  var numberVue;
  List<String> personneLike = [];
  VipDeals(
      {this.imageUrl,
      this.title,
      this.comments,
      this.numberVue,
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
      this.authorName,
      this.categorieName,
      this.video,
      required this.approved});
  @override
  Widget build(BuildContext context) {
    final register = DateTime.parse(registerDate); //.toString();
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
              Navigator.of(context).push((MaterialPageRoute(builder: (context) {
                DealsSkeletonData item = DealsSkeletonData(
                    comments: comments,
                    numberVue: numberVue,
                    level: level,
                    quantity: quantity,
                    numberFavorite: numberFavorite,
                    lieu: lieu,
                    id: id,
                    registerDate: registerDate,
                    profil: profil,
                    imageUrl: imageUrl,
                    title: title,
                    price: price,
                    autor: autor,
                    numero: numero,
                    describe: describe,
                    onLine: onLine,
                    authorName: authorName,
                    archive: archive,
                    categorieName: categorieName,
                    video: video,
                    approved: approved);
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
                      padding:
                          EdgeInsets.only(left: 12.0, top: 8.0, right: 6.0),
                      child: Text(
                        title,
                        style: Style.titleDealsProduct(),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )),
                  Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(numberFavorite.toString(),
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
                    padding: EdgeInsets.only(left: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${price.toString()}",
                            style: Style.priceDealsProduct()),
                        SizedBox(width: 15.0),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12.0),
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
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () async {
                              await launchUrl(
                                  Uri(scheme: 'tel', path: "+$serviceCall"));
                            }),
                        SizedBox(width: 7.0),
                        IconButton(
                            icon: Icon(Style.social_normal, color: tint),
                            onPressed: () {
                              Share.share(
                                  "$title à $price\n 🙂 Shouz Avantage:\n   - 🤩 Achète à ton prix.\n   - 🤩 Paye par mobile money ou à la livraison.\n   - 🤩 Livraison gratuite pour tes 2 premiers achats.\n   - 🤩 Et si l'article n'est pas ce que tu as vu en ligne, Shouz te rembourse tout ton argent.\n Clique ici pour voir l'article que je te partage ${ConsumeAPI.ProductLink}${title.toString().replaceAll(' ', '-').replaceAll('/', '_')}/$id");
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
                  imageUrl:
                      "${ConsumeAPI.AssetProductServer}${imageUrl[0]}",
                  imageBuilder: (context, imageProvider) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0)),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push((MaterialPageRoute(builder: (context) {
                          DealsSkeletonData item = DealsSkeletonData(
                              comments: comments,
                              numberVue: numberVue,
                              level: level,
                              quantity: quantity,
                              numberFavorite: numberFavorite,
                              lieu: lieu,
                              id: id,
                              registerDate: registerDate,
                              profil: profil,
                              imageUrl: imageUrl,
                              title: title,
                              price: price,
                              autor: autor,
                              numero: numero,
                              describe: describe,
                              onLine: onLine,
                              authorName: authorName,
                              archive: archive,
                              categorieName: categorieName,
                              video: video,
                              approved: approved);
                          return DetailsDeals(
                              dealsDetailsSkeleton: item, comeBack: 0);
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
                                      color: onLine
                                          ? Colors.green[300]!
                                          : Colors.yellow[300]!),
                                  borderRadius: BorderRadius.circular(50.0),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "${ConsumeAPI.AssetProfilServer}$profil"),
                                      fit: BoxFit.cover),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress)),
                  errorWidget: (context, url, error) => notSignal(),
                )),
          )
        ],
      ),
    );
  }
}
