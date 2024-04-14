import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/vote_event_detail.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../Constant/PageIndicatorSecond.dart';
import '../Constant/helper.dart';
import '../Constant/widget_common.dart';

class VoteScreen extends StatefulWidget {
  List<dynamic> allVoteEvent;

  VoteScreen(
      {required this.allVoteEvent});
  @override
  _VoteScreenState createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  late PageController _controller;
  int _counter = 0;
  bool lastPage = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = PageController(initialPage: _counter);
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.77,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              PageView.builder(
                itemCount: widget.allVoteEvent.length,
                controller: _controller,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  setState(() {
                    _counter = index;
                  });
                  if (_counter == widget.allVoteEvent.length - 1)
                    lastPage = true;
                  else
                    lastPage = false;
                },
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          var page = widget.allVoteEvent[index];
                          var delta;
                          var y = 1.0;

                          if (_controller.position.haveDimensions) {
                            delta = _controller.page! - index;
                            y = 1 - double.parse(delta.abs().clamp(0.0, 1.0).toString());
                          }

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push((MaterialPageRoute(
                                  builder: (context) => VoteEventDetail(voteItem: page,gradiant: gradient[index % 5],))));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  height: MediaQuery.of(context).size.height / 2.3,
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        width: 300,
                                        top: 36.0,
                                        right: 36.0,
                                        child: Card(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          elevation: 7.0,
                                          color: backgroundColor,
                                          child: Hero(
                                            tag: page['_id'],
                                            child: CachedNetworkImage(
                                              imageUrl: "${ConsumeAPI.AssetEventServer}${page['picture']}",
                                              imageBuilder: (context, imageProvider) => Container(
                                                height: MediaQuery.of(context).size.height / 2.6,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius: BorderRadius.circular(20)
                                                ),
                                              ),
                                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                                  Center(
                                                      child: CircularProgressIndicator(value: downloadProgress.progress)),
                                              errorWidget: (context, url, error) => notSignal(),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 12.0),
                                  child: Stack(
                                    children: <Widget>[
                                      Opacity(
                                        opacity: 0.10,
                                        child: GradientText(
                                          page['name'],
                                          colors: gradient[index % 5],
                                          style: Style.titleOnBoardShadow(fontSize: 30),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 30.0, left: 22.0),
                                        child: GradientText(
                                          page['name'],
                                          colors: gradient[index % 5],
                                          style: Style.titleOnBoard(fontSize: 27),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 0.0, left: 34.0, right: 10.0),
                                  child: Transform(
                                    transform: Matrix4.translationValues(
                                        0.0, 50 * (1 - y), 0.0),
                                    child: Row(

                                      children: [
                                        Expanded(
                                            child: Row(
                                              children: [
                                                Icon(Icons.alarm_on, color: colorText, size: 19,),
                                                SizedBox(width: 2,),
                                                Text(
                                                  "Debut: ${formatedDateForLocal(DateTime.parse(page['beginDate']), withTime: false)}",
                                                  style: Style.simpleTextOnBoard(14),
                                                ),
                                              ],
                                            )
                                        ),
                                        Expanded(
                                            child: Row(
                                              children: [
                                                Icon(Icons.alarm_off, color: colorText,size: 19,),
                                                SizedBox(width: 2,),
                                                Text(
                                                  "Fin: ${formatedDateForLocal(DateTime.parse(page['endDate']), withTime: false)}",
                                                  style: Style.simpleTextOnBoard(14),
                                                ),
                                              ],
                                              mainAxisAlignment: MainAxisAlignment.end,
                                            )
                                        ),
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    )
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0, left: 34.0, right: 10.0),
                                  child: Transform(
                                      transform: Matrix4.translationValues(
                                          0.0, 50 * (1 - y), 0.0),
                                      child: Row(

                                        children: [
                                          Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(Icons.wallet, color: colorText, size: 19,),
                                                  SizedBox(width: 2,),
                                                  Text(
                                                    "Prix: ${page['price'] > 0 ? '${page['price']} XOF': 'GRATUIT'}",
                                                    style: Style.simpleTextOnBoard(14),
                                                  ),
                                                ],
                                              )
                                          ),
                                          Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(Icons.star, color: colorText,size: 19,),
                                                  SizedBox(width: 2,),
                                                  Text(
                                                    "Nominés: ${totalNomine(page['categorie'])}",
                                                    style: Style.simpleTextOnBoard(14),
                                                  ),
                                                ],
                                                mainAxisAlignment: MainAxisAlignment.end,
                                              )
                                          ),
                                        ],
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      )
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0, left: 34.0, right: 10.0),
                                  child: Transform(
                                    transform: Matrix4.translationValues(
                                        0.0, 50 * (1 - y), 0.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push((MaterialPageRoute(
                                            builder: (context) => VoteEventDetail(voteItem: page,gradiant: gradient[index % 5],))));
                                      },
                                      child: Text('Voir les nominés'),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: colorPrimary, backgroundColor: colorText,
                                        minimumSize: Size(88, 36),
                                        elevation: 4.0,
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  );
                },
              ),
              Positioned(
                left: -50.0,
                top: 10.0,
                child: Transform.rotate(
                  angle: pi / 2,
                  child: Container(
                    width: 150.0,
                    height: MediaQuery.of(context).size.width,
                    child: PageIndicatorSecond(_counter, widget.allVoteEvent.length),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
   int totalNomine(List<dynamic> categories) {
    int totalItem = 0;
    for(final categorie in categories) {
      totalItem += categorie['allActors'].length as int;
    }
    return totalItem;
   }
}
