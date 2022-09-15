import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Constant/widget_common.dart';

import '../Pages/DetailsActu.dart';

class CardTopNewActu {
  var numberVue;
  String title;
  String authorName;
  String authorProfil;
  String id;
  String registerDate;
  String image;
  String imageCover;
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
      this.comment,
      this.imageCover
      );


  Widget propotypingScrol(context) {
    String afficheDate = dateFormatForTimesAgo(this.registerDate);
    return InkWell(
        onTap: () {
          Navigator.of(context).push((MaterialPageRoute(
              builder: (BuildContext context) => DetailsActu(
                  comeBack: 0,
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
                  child: CachedNetworkImage(
                    imageUrl: this.image,
                    imageBuilder: (context, imageProvider) =>
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        Center(
                            child: CircularProgressIndicator(value: downloadProgress.progress)),
                    errorWidget: (context, url, error) => notSignal(),
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
                            fit: BoxFit.cover,
                          ))),
                          SizedBox(width: 5.0),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.37,
                            child: Text(
                              this.authorName,
                              style: prefix0.Style.titleInSegment(),
                            ),
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
      dynamic contents, double width, String imageCover, BuildContext context) {
    List<String> parseContent = [];
    for (var i = 0; i < contents.length; i++) {
      final value = contents[i];
      if (value['isContentType'] == 'picture_text' ||
          value['isContentType'] == 'only_picture') {
        parseContent.add(value['inImage'].toString());
      }
    }
    if (parseContent.length >= 2) {
      List<Widget> listPicturePreview = [
        CachedNetworkImage(
          imageUrl: imageCover,
          imageBuilder: (context, imageProvider) =>
              Container(
                width: width,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Center(
                  child: CircularProgressIndicator(value: downloadProgress.progress)),
          errorWidget: (context, url, error) => notSignal(),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: parseContent[0],
              imageBuilder: (context, imageProvider) =>
                  Container(
                    width: width,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(5.0)),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                      child: CircularProgressIndicator(value: downloadProgress.progress)),
              errorWidget: (context, url, error) => notSignal(),
            ),
            SizedBox(height: 10.0),
            CachedNetworkImage(
              imageUrl: parseContent[1],
              imageBuilder: (context, imageProvider) =>
                  Container(
                    width: width,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(5.0)),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                      child: CircularProgressIndicator(value: downloadProgress.progress)),
              errorWidget: (context, url, error) => notSignal(),
            ),

          ],
        )
      ];
      return listPicturePreview;
    } else if (parseContent.length == 1) {
      List<Widget> listPicturePreview = [
        CachedNetworkImage(
          imageUrl: imageCover,
          imageBuilder: (context, imageProvider) =>
              Container(
                width: width,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Center(
                  child: CircularProgressIndicator(value: downloadProgress.progress)),
          errorWidget: (context, url, error) => notSignal(),
        ),
        CachedNetworkImage(
          imageUrl: parseContent[0],
          imageBuilder: (context, imageProvider) =>
              Container(
                width: width,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Center(
                  child: CircularProgressIndicator(value: downloadProgress.progress)),
          errorWidget: (context, url, error) => notSignal(),
        ),
      ];
      return listPicturePreview;
    } else {
      List<Widget> listPicturePreview = [
        CachedNetworkImage(
          imageUrl: imageCover,
          imageBuilder: (context, imageProvider) =>
              Container(
                width: width*2,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Center(
                  child: CircularProgressIndicator(value: downloadProgress.progress)),
          errorWidget: (context, url, error) => notSignal(),
        ),
      ];
      return listPicturePreview;
    }
  }

  Widget propotypingProfil(context) {
    String afficheDate = dateFormatForTimesAgo(this.registerDate);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push((MaterialPageRoute(
              builder: (BuildContext context) =>
                  DetailsActu(title: this.title, id: this.id,comeBack: 0, autherName: this.authorName, comment: this.comment, numberVue: this.numberVue, authorProfil: this.authorProfil, content: this.content,imageCover: this.imageCover, ))));
        },
        child: Card(
          elevation: 5.0,
          color: prefix0.backgroundColor,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7.0),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(afficheDate, style: prefix0.Style.sousTitre(13.0)),

                  ],
                ),
                Text(this.title, style: prefix0.Style.titleDealsProduct()),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: displayMinatureImageInNews(this.content,
                      MediaQuery.of(context).size.width / 2.3, this.image, context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
