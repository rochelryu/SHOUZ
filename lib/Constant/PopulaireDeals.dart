import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:shouz/Pages/DetailsDeals.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';


class PopulaireDeals extends StatelessWidget {
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
  var approved;
  var comments;
  var numberVue;
  List<String> PersonneLike = [];
  PopulaireDeals({this.imageUrl,this.comments, this.numberVue, this.title, this.favorite,this.price, this.numero, this.autor, required this.id, this.profil, this.onLine,this.level, this.describe, this.numberFavorite, this.lieu, this.registerDate, this.quantity, this.authorName, this.archive, this.categorieName, this.video,required this.approved});
  @override
  Widget build(BuildContext context) {
    final register = DateTime.parse(registerDate); //.toString();
    String afficheDate = (DateTime.now().difference(DateTime(register.year,register.month,register.day)).inDays < 1) ?  "Auj. à ${register.hour.toString()}h ${register.minute.toString()}"  : "${register.day.toString()}/${register.month.toString()}/${register.year.toString()} à ${register.hour.toString()}h ${register.minute.toString()}";
    afficheDate = (DateTime.now().difference(DateTime(register.year,register.month,register.day)).inDays == 1) ? "Hier à ${register.hour.toString()}h ${register.minute.toString()}"  : afficheDate;
    return Padding(padding: EdgeInsets.all(0.0),
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push((
              MaterialPageRoute(
                  builder: (context){
                    DealsSkeletonData item = DealsSkeletonData(comments: comments,numberVue:numberVue,approved: approved,level: level,video: video,quantity: quantity,numberFavorite: numberFavorite, lieu: lieu, id:id, registerDate:  registerDate, profil: profil, imageUrl: imageUrl, title: title, price:price, autor: autor, numero: numero, describe:describe, onLine: onLine,authorName: authorName,archive: archive, categorieName: categorieName );
                    return DetailsDeals(dealsDetailsSkeleton:item, comeBack: 0);
                  }
              )));
        },
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Material(
                  elevation: 25.0,
                  borderRadius: BorderRadius.circular(5.0),
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),

                  child: CachedNetworkImage(
                    imageUrl: "${ConsumeAPI.AssetProductServer}${imageUrl[0]}",
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        Center(
                            child: CircularProgressIndicator(value: downloadProgress.progress)),
                    errorWidget: (context, url, error) => notSignal(),
                  )),
                ),
                SizedBox(height: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Style.titleDealsProduct(), maxLines: 4, overflow: TextOverflow.ellipsis,),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("${price.toString()}", style: Style.priceDealsProduct()),
                        Row(
                          children: <Widget>[
                            Text(numberFavorite.toString(), style: Style.numberOfLike()),
                            SizedBox(width: 5.0),
                            Icon(Icons.favorite, color: Colors.redAccent, size: 16.0),
                          ]
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Text(afficheDate, style: Style.sousTitre(12)),
                    SizedBox(height: 20.0),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

