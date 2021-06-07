import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class EventItem extends StatefulWidget {
  final imageUrl;
  final title;
  final favorite;
  final price;
  final lieu;
  final numero;
  final autor;
  List<int> PriceList = [];
  EventItem({this.imageUrl, this.title, this.favorite,this.price, this.lieu, this.numero, this.PriceList, this.autor });
  @override
  _EventItemState createState() => _EventItemState();
}

class _EventItemState extends State<EventItem> {
  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}
