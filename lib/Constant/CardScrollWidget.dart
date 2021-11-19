import 'dart:math';

import 'package:flutter/material.dart';

import './Style.dart';

class CardScrollWidget extends StatefulWidget {
  var _currentPage;
  final double padding = 20.0;
  final double verticalInset = 20.0;
  CardScrollWidget(this._currentPage);
  @override
  _CardScrollWidgetState createState() => _CardScrollWidgetState();
}

var cardAspectRatio = 12.0 / 16.0;
var widgetAspectRatio = cardAspectRatio * 1.2;

class _CardScrollWidgetState extends State<CardScrollWidget> {
  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(
        builder: (context, contraints) {
          var width = contraints.maxWidth;
          var height = contraints.maxHeight;

          var safeWidth = width - 2 * widget.padding;
          var safeHeight = height - 2 * widget.padding;

          var heightOfPrimaryCard = safeHeight;
          var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;
          var primaryCardLeft = safeWidth - widthOfPrimaryCard;
          var horizontalInset = primaryCardLeft / 2;

          List<Widget> cardList = [];

          for (var i = 0; i < dealsList.length; i++) {
            var delta = i - widget._currentPage;
            bool isOnRight = delta > 0;

            var start = widget.padding +
                max(
                    primaryCardLeft -
                        horizontalInset * -delta * (isOnRight ? 15 : 1),
                    0.0);

            var cardItem = Positioned.directional(
                textDirection: TextDirection.rtl,
                top: widget.padding + widget.verticalInset * max(-delta, 0.0),
                bottom:
                    widget.padding + widget.verticalInset * max(-delta, 0.0),
                start: start,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: InkWell(
                    onTap: () {
                      print(dealsList[i]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10.0,
                                offset: Offset(3.0, 6.0),
                                color: Colors.black12)
                          ]),
                      child: AspectRatio(
                        aspectRatio: cardAspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Image.asset(dealsList[i].imageUrl,
                                fit: BoxFit.cover),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: 100,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                      colors: [
                                        const Color(0x00000000),
                                        const Color(0xD9111111)
                                      ],
                                      begin: FractionalOffset(0.0, 0.0),
                                      end: FractionalOffset(0.0, 1.0),
                                    )),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 16.0,
                                              left: 8.0,
                                              right: 8.0,
                                              bottom: 3.0),
                                          child: Text(
                                            dealsList[i].title,
                                            style: Style.titleDealsProduct(),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            child: RaisedButton(
                                              onPressed: () {
                                                print(dealsList[i]);
                                              },
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12.0,
                                                  horizontal: 50.0),
                                              color: colorText,
                                              textColor: Colors.white,
                                              child: Text(
                                                "Voir",
                                                style: Style.itemNote(),
                                              ),
                                            ),
                                          ),
                                        ),
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
                  ),
                ));
            cardList.add(cardItem);
          }
          return Stack(
            children: cardList,
          );
        },
      ),
    );
  }
}
