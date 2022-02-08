import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/DetailsDeals.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';


class PopulaireDeals extends StatefulWidget {
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
  String id;
  List<String> PersonneLike = [];
  PopulaireDeals({this.imageUrl, this.title, this.favorite,this.price, this.numero, this.autor, required this.id, this.profil, this.onLine, this.describe, this.numberFavorite, this.lieu, this.registerDate, this.quantity, this.authorName });
  @override
  _PopulaireDealsState createState() => _PopulaireDealsState();
}

class _PopulaireDealsState extends State<PopulaireDeals> {
  
  @override
  Widget build(BuildContext context) {
    final register = DateTime.parse(widget.registerDate); //.toString();
    String afficheDate = (DateTime.now().difference(DateTime(register.year,register.month,register.day)).inDays < 1) ?  "Aujourd'hui à ${register.hour.toString()}h ${register.minute.toString()}"  : "Depuis le ${register.day.toString()}/${register.month.toString()}/${register.year.toString()} à ${register.hour.toString()}h ${register.minute.toString()}";
    afficheDate = (DateTime.now().difference(DateTime(register.year,register.month,register.day)).inDays == 1) ? "Hier à ${register.hour.toString()}h ${register.minute.toString()}"  : afficheDate;
    return Padding(padding: EdgeInsets.all(0.0),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Material(
                elevation: 25.0,
                borderRadius: BorderRadius.circular(5.0),
                child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).push((
                          MaterialPageRoute(
                              builder: (context){
                                DealsSkeletonData item = new DealsSkeletonData(quantity: widget.quantity,numberFavorite: widget.numberFavorite, lieu: widget.lieu, id:widget.id, registerDate:  widget.registerDate, profil: widget.profil, imageUrl: widget.imageUrl, title: widget.title, favorite: widget.favorite, price:widget.price, autor: widget.autor, numero: widget.numero, describe:widget.describe, onLine: widget.onLine,authorName: widget.authorName );
                                return DetailsDeals(dealsDetailsSkeleton:item);
                              }
                          )
                      ));
                      },
                      child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.network("${ConsumeAPI.AssetProductServer}${widget.imageUrl[0]}")),
                ),
              ),
              SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.title, style: Style.titleDealsProduct()),
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("${widget.price.toString()}", style: Style.priceDealsProduct()),
                      Row(
                        children: <Widget>[
                          Text(widget.numberFavorite.toString(), style: Style.numberOfLike()),
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
    );
  }
}
