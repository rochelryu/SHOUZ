import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/DetailsDeals.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:url_launcher/url_launcher.dart';


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
  String id;
  List<String> PersonneLike = [];
  RecentDeals({this.imageUrl, this.title, this.favorite,this.price, this.numero, this.autor, required this.id, this.profil, required this.onLine, this.describe, this.numberFavorite, this.lieu, this.registerDate, this.quantity, this.authorName });
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
    return Padding(padding: EdgeInsets.all(0),
      child: Stack(
        children: <Widget>[
          Container(
            height: 320,
            width: MediaQuery.of(context).size.width,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 280,
                      height: 250,
                      child: InkWell(
                        onTap: (){
                          Navigator.of(context)
                              .push((MaterialPageRoute(builder: (context) {
                            DealsSkeletonData item = new DealsSkeletonData(
                                quantity: widget.quantity,
                                numberFavorite: widget.numberFavorite,
                                lieu: widget.lieu,
                                id: widget.id,
                                registerDate: widget.registerDate,
                                profil: widget.profil,
                                imageUrl: widget.imageUrl,
                                title: widget.title,
                                favorite: widget.favorite,
                                price: widget.price,
                                autor: widget.autor,
                                numero: widget.numero,
                                describe: widget.describe,
                                onLine: widget.onLine,
                                authorName: widget.authorName,
                            );
                            return DetailsDeals(dealsDetailsSkeleton: item);
                          })));
                        },
                        child: Image.network("${ConsumeAPI.AssetProductServer}${widget.imageUrl[0]}"),
                      ),
                    ),
                    Text(widget.title, style: Style.titleDealsProduct()),
                    Text("${widget.price.toString()} ETH", style: Style.priceDealsProduct()),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(icon: (Icon(Icons.favorite, color: widget.favorite ? Colors.redAccent : Colors.grey, size: 22.0)), onPressed: (){
                          setState(() {
                            widget.favorite = !widget.favorite;
                          });
                        }),
                        Text(widget.numberFavorite.toString(), style: Style.numberOfLike()),
                      ],
                    ),

                    SizedBox(height: 15.0),
                    IconButton(icon: Icon(Style.chatting, color: Colors.yellow), onPressed: (){
                      setState(() {
                        widget.favorite = !widget.favorite;
                      });
                      launch("sms:${widget.numero}");
                    }),
                    SizedBox(height: 15.0),
                    IconButton(icon: Icon(Icons.share, color: Colors.white), onPressed: (){
                      setState(() {
                        widget.favorite = !widget.favorite;
                      });
                      launch("https:${widget.numero}");
                    }),
                  ],
                ),
                SizedBox(width: 10.0),
              ],
            ),
          ),
          Positioned(
            top:230,
            left: 15,
            child: Material(
              elevation: 15.0,
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                height: 50,
                width: 50,
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
