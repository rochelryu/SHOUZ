import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';


class Publicite extends StatefulWidget {
  @override
  _PubliciteState createState() => _PubliciteState();
}


var cardAspectRatio = 12.0/16.0;
var widgetAspectRatio = cardAspectRatio * 1.2;
class _PubliciteState extends State<Publicite> {

  var currentPage = mesUsers.length - 1.0;
  @override
  Widget build(BuildContext context) {

    PageController controller = PageController(initialPage: mesUsers.length - 1);
    controller.addListener((){
      setState(() {
        currentPage = controller.page;
      });
    });
    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
        children: <Widget>[
          Center(
            child: Stack(
              children: <Widget>[
                CardScrollWidget(currentPage),
                Positioned.fill(
                  child: PageView.builder(
                      itemCount: mesUsers.length,
                      controller: controller,
                      reverse: true,
                      itemBuilder: (context, index){
                        return Container();
                      }),
                ),

              ],
            ),
          ),
          Container()
        ],
      ),
    );
  }
}

class CardScrollWidget extends StatelessWidget {
  var currentPage;
  var padding = 20.0;
  var verticalInset = 20.0;
  CardScrollWidget(this.currentPage);
  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(
        builder: (context, contraints){
          var width = contraints.maxWidth;
          var height = contraints.maxHeight;

          var safeWidth = width - 2 * padding;
          var safeHeight = height - 2 * padding;
          var heigthOfPrimaryCard = safeHeight;
          var widthOfPrimaryCard = heigthOfPrimaryCard * cardAspectRatio;

          var primaryCardLeft = safeWidth - widthOfPrimaryCard;
          var horizontalInset = primaryCardLeft / 2;
          List<Widget> cardList = [];

          for (var i = 0; i < mesUsers.length; i++){
            var delta = i - currentPage;
            bool isOnRight = delta > 0;
            var start =  padding + max(primaryCardLeft - horizontalInset * -delta * (isOnRight ? 15:1), 0.0);

            var cardItem = Positioned.directional(
                top: padding + verticalInset * max(-delta, 0.0),
                bottom: padding + verticalInset * max(-delta, 0.0),
                start: start,
                textDirection: TextDirection.rtl,
                child: InkWell(
                  onTap: (){
                    print(mesUsers[i]);
                  },
                  child: AspectRatio(
                    aspectRatio: cardAspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: InkWell(
                        onTap: (){
                          print(mesUsers[i]);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Image.network(mesUsers[i], fit: BoxFit.cover),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(15.0),
                                    child: Container(
                                      padding: EdgeInsets.only(left: 10.0),
                                      height: 30,
                                      width: 130,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16.0),
                                        color: Colors.black12
                                      ),
                                      child: GestureDetector(
                                        onTap: (){
                                          print(mesUsers[i]);
                                        },
                                        child: Text("Voir plus", textAlign: TextAlign.start, style: Style.titre(20.0)),
                                      ),
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
          return new Stack(
            children: cardList,
          );
        }),
    );
  }
}
