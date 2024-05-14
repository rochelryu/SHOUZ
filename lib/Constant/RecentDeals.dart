import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/DetailsDeals.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';


class RecentDeals extends StatelessWidget {
  var imageUrl;
  var title;
  var favorite;
  var price;
  var numero;
  var autor;
  var profil;
  bool onLine;
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
  var comments;
  var numberVue;
  String id;
  List<String> PersonneLike = [];
  RecentDeals({this.imageUrl,this.comments, this.numberVue, this.title,this.level, this.favorite,this.price, this.numero, this.autor, required this.id, this.profil, required this.onLine, this.describe, this.numberFavorite, this.lieu, this.registerDate, this.quantity, this.authorName, this.archive, this.categorieName, this.video,required this.approved });
  @override
  Widget build(BuildContext context) {
    final color = onLine ? Colors.green[300] : Colors.yellow[300];
    return Padding(padding: EdgeInsets.all(10),
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: InkWell(
              onTap: (){
                Navigator.of(context)
                    .push((MaterialPageRoute(builder: (context) {
                  DealsSkeletonData item = DealsSkeletonData(
                      comments: comments,
                      numberVue:numberVue,
                    level: level,
                    video: video,
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
                    categorieName: categorieName, approved: approved
                  );
                  return DetailsDeals(dealsDetailsSkeleton: item, comeBack: 0);
                })));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 145,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                            image: NetworkImage("${ConsumeAPI.AssetProductServer}${imageUrl[0]}"),
                            fit: BoxFit.cover
                        )
                    ),

                  ),
                  Text("$title", style: Style.titleDealsProduct(11.0), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,),
                  Text("${price.toString()} XOF", style: Style.priceDealsProduct(), textAlign: TextAlign.center,),
                ],
              ),
            )

          ),
          Positioned(
            bottom:30,
            left: 15,
            child: Material(
              elevation: 15.0,
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(

                  border: Border.all(width: 2.0, color: color!),
                  borderRadius: BorderRadius.circular(50.0),
                  image: DecorationImage(
                      image: NetworkImage(
                          "${ConsumeAPI.AssetProfilServer}$profil"),
                      fit: BoxFit.cover
                  ),
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}
