import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/DetailsDeals.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';


class RecentDeals extends StatefulWidget {
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
  String id;
  List<String> PersonneLike = [];
  RecentDeals({this.imageUrl, this.title,this.level, this.favorite,this.price, this.numero, this.autor, required this.id, this.profil, required this.onLine, this.describe, this.numberFavorite, this.lieu, this.registerDate, this.quantity, this.authorName, this.archive, this.categorieName, this.video });
  @override
  _RecentDeals createState() => _RecentDeals();
}

class _RecentDeals extends State<RecentDeals> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    final color = widget.onLine ? Colors.green[300] : Colors.yellow[300];
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
                            image: NetworkImage("${ConsumeAPI.AssetProductServer}${widget.imageUrl[0]}"),
                            fit: BoxFit.cover
                        )
                    ),

                  ),
                  Text("${widget.title}", style: Style.titleDealsProduct(11.0), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,),
                  Text("${widget.price.toString()} XOF", style: Style.priceDealsProduct(), textAlign: TextAlign.center,),
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
                          "${ConsumeAPI.AssetProfilServer}${widget.profil}"),
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
