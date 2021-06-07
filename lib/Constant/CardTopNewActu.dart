import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;

import '../Pages/DetailsActu.dart';

class CardTopNewActu {
  var numberVue;
  String title;
  String authorName;
  String authorProfil;
  String id;
  String registerDate;
  String image;
  var content;
  var comment;
  bool favorie = false;

  CardTopNewActu(
      this.title,
      this.id,
      this.image,
      this.numberVue,
      this.registerDate,
      this.authorName,
      this.authorProfil,
      this.content,
      this.comment);

  Widget propotyping(context) {
    String afficheDate = (DateTime.now()
                .difference(DateTime(
                    int.parse(this.registerDate.substring(0, 4)),
                    int.parse(this.registerDate.substring(5, 7)),
                    int.parse(this.registerDate.substring(8, 10))))
                .inDays <
            4)
        ? "il y ' a " +
            DateTime.now()
                .difference(DateTime(
                    int.parse(this.registerDate.substring(0, 4)),
                    int.parse(this.registerDate.substring(5, 7)),
                    int.parse(this.registerDate.substring(8, 10))))
                .inDays
                .toString() +
            " jr"
        : this.registerDate.substring(0, 10);
    afficheDate = (DateTime.now()
                    .difference(DateTime(
                        int.parse(this.registerDate.substring(0, 4)),
                        int.parse(this.registerDate.substring(5, 7)),
                        int.parse(this.registerDate.substring(8, 10))))
                    .inDays <
                4 &&
            DateTime.now()
                    .difference(DateTime(
                        int.parse(this.registerDate.substring(0, 4)),
                        int.parse(this.registerDate.substring(5, 7)),
                        int.parse(this.registerDate.substring(8, 10))))
                    .inDays >
                1)
        ? '${afficheDate}s'
        : afficheDate;
    afficheDate = (DateTime.now()
                .difference(DateTime(
                    int.parse(this.registerDate.substring(0, 4)),
                    int.parse(this.registerDate.substring(5, 7)),
                    int.parse(this.registerDate.substring(8, 10))))
                .inDays <
            1)
        ? "Aujourd'hui"
        : afficheDate;

    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Container(
        width: 300,
        margin: EdgeInsets.only(right: 20.0),
        height: 290,
        decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(blurRadius: 5.0, color: tint, offset: Offset(0.0, 1.0))
            ]),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push((MaterialPageRoute(
                builder: (BuildContext context) =>
                    DetailsActu(title: this.title, id: this.id))));
          },
          child: Stack(
            children: <Widget>[
              Container(
                height: 170.0,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [backgroundColor, tint],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    )),
              ),
              Container(
                height: 180.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                )),
                child: Image.network(this.image, fit: BoxFit.cover),
              ),
              Positioned(
                top: 195.0,
                left: 10.0,
                right: 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(this.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Style.itemCustomFont()),
                    SizedBox(height: 5.0),
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                CircleAvatar(
                                    child: ClipOval(
                                        child: Image(
                                  width: 65,
                                  height: 65,
                                  image: NetworkImage(this.authorProfil),
                                  fit: BoxFit.contain,
                                ))),
                                SizedBox(width: 5.0),
                                Text(
                                  this.authorName,
                                  style: prefix0.Style.titleInSegment(),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  Icons.alarm,
                                  color: Colors.white,
                                  size: 15.0,
                                ),
                                SizedBox(width: 2.0),
                                Text(
                                  afficheDate,
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 2.0),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget propotypingOnBlock(context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push((MaterialPageRoute(
            builder: (BuildContext context) =>
                DetailsActu(title: this.title, id: this.id))));
      },
      child: Padding(
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
        child: Container(
          width: 350,
          height: 350,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                height: 270.0,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [backgroundColor, tint],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    )),
              ),
              Hero(
                tag: this.image,
                child: Container(
                  height: 270.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(this.image), fit: BoxFit.cover),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      )),
                ),
              ),
              Positioned(
                top: 285.0,
                left: 10.0,
                right: 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(this.title,
                        maxLines: 1, style: Style.itemCustomFont()),
                    SizedBox(height: 3.0),
                    Container(
                      width: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(this.numberVue.toString()),
                          SizedBox(width: 3.0),
                          Icon(Icons.remove_red_eye, color: Colors.grey)
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget propotypingScrol(context) {
    String afficheDate = dateFormatForTimesAgo(this.registerDate);
    return InkWell(
        onTap: () {
          Navigator.of(context).push((MaterialPageRoute(
              builder: (BuildContext context) => DetailsActu(
                  title: this.title,
                  id: this.id,
                  content: this.content,
                  autherName: this.authorName,
                  authorProfil: this.authorProfil,
                  imageCover: this.image,
                  comment: this.comment,
                  numberVue: this.numberVue))));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          color: Colors.transparent,
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                          image: NetworkImage(this.image), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Text(this.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: prefix0.Style.itemCustomFont()),
              SizedBox(height: 5.0),
              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          CircleAvatar(
                              child: ClipOval(
                                  child: Image(
                            width: 65,
                            height: 65,
                            image: NetworkImage(this.authorProfil),
                            fit: BoxFit.contain,
                          ))),
                          SizedBox(width: 5.0),
                          Text(
                            this.authorName,
                            style: prefix0.Style.titleInSegment(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            Icons.alarm,
                            color: Colors.white,
                            size: 15.0,
                          ),
                          SizedBox(width: 2.0),
                          Text(
                            afficheDate,
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 2.0),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  List<Widget> displayMinatureImageInNews(
      dynamic contents, double width, String imageCover) {
    List<String> parseContent = [];
    for (var i = 0; i < contents.length; i++) {
      final value = contents[i];
      if (value['isContentType'] == 'picture_text' ||
          value['isContentType'] == 'only_picture') {
        parseContent.add(value['inImage'].toString());
      }
    }
    print(imageCover);
    if (parseContent.length >= 2) {
      List<Widget> ListPicturePreview = [
        ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
          child: Image.network(imageCover,
              fit: BoxFit.cover, width: width, height: 250),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(topRight: Radius.circular(5.0)),
              child: Image.network(parseContent[0],
                  fit: BoxFit.cover, width: width, height: 120),
            ),
            SizedBox(height: 10.0),
            ClipRRect(
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(5.0)),
              child: Image.network(parseContent[1],
                  fit: BoxFit.cover, width: width, height: 120),
            ),
          ],
        )
      ];
      return ListPicturePreview;
    } else if (parseContent.length == 1) {
      List<Widget> ListPicturePreview = [
        ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
          child: Image.network(imageCover,
              fit: BoxFit.cover, width: width, height: 250),
        ),
        ClipRRect(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0)),
          child: Image.network(parseContent[0],
              fit: BoxFit.cover, width: width, height: 250),
        )
      ];
      return ListPicturePreview;
    } else {
      List<Widget> ListPicturePreview = [
        ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Image.network(imageCover, fit: BoxFit.cover, height: 250),
        )
      ];
      return ListPicturePreview;
    }
  }

  Widget propotypingProfil(context) {
    String afficheDate = dateFormatForTimesAgo(this.registerDate);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        elevation: 5.0,
        color: prefix0.backgroundColor,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7.0),
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(afficheDate, style: prefix0.Style.sousTitre(13.0)),
                  IconButton(
                    tooltip: "Retirer",
                    icon: Icon(Icons.favorite,
                        color: (this.favorie) ? Colors.redAccent : Colors.grey),
                    onPressed: () {
                      print(this.title);
                    },
                  )
                ],
              ),
              Text(this.title, style: prefix0.Style.titleDealsProduct()),
              new RichText(
                text: new TextSpan(
                    text:
                        "To run it, in a terminal cd into the folder. Then execute ulimit -S -n 2048 (ref). Then execute flutter run with a running emulator.",
                    style: prefix0.Style.sousTitre(10.0),
                    children: [
                      new TextSpan(
                        text: '...   ',
                        style: prefix0.Style.sousTitre(10.0),
                      ),
                      new TextSpan(
                        text: 'Voir plus',
                        style: prefix0.Style.priceDealsProduct(),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () => print('Tap Here onTap'),
                      )
                    ]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: displayMinatureImageInNews(this.content,
                    MediaQuery.of(context).size.width / 2.3, this.image),
              )
            ],
          ),
        ),
      ),
    );
  }
}
