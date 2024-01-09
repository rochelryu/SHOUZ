
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shouz/Constant/Style.dart';

import '../Constant/PageIndicator.dart';
import '../Constant/widget_common.dart';
//import 'demande_conducteur.dart';

class ExplicationTravel extends StatefulWidget {
  int typeRedirect;
  ExplicationTravel({required this.typeRedirect, required Key key});

  @override
  _ExplicationTravelState createState() => _ExplicationTravelState();
}

class _ExplicationTravelState extends State<ExplicationTravel> {
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
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView.builder(
              itemCount: pageExplicationTravelList.length,
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _counter = index;
                });
                if (_counter == pageExplicationTravelList.length - 1)
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
                        var page = pageExplicationTravelList[index];
                        var delta;
                        var y = 1.0;

                        if (_controller.position.haveDimensions) {
                          delta = _controller.page! - index;
                          y = 1 - double.parse(delta.abs().clamp(0.0, 1.0).toString());
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            page.imageUrl.toString().indexOf('.svg') == -1 ? Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Image.asset(page.imageUrl),
                            ): SvgPicture.asset(
                              page.imageUrl,
                              semanticsLabel: page.imageUrl.toString().toUpperCase(),
                              height:
                              MediaQuery.of(context).size.height *
                                  0.3,
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                  top: 12.0, left: 10.0, right: 10.0),
                              child: Transform(
                                transform: Matrix4.translationValues(
                                    0.0, 50 * (1 - y), 0.0),
                                child: Text(
                                  page.body,
                                  style: Style.simpleTextOnBoard(_counter == 0 ? 19.0 : 14.0),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    )
                  ],
                );
              },
            ),
            Positioned(
              left: 30.0,
              bottom: 40.0,
              child: Container(
                width: 180.0,
                child: PageIndicator(_counter, pageExplicationTravelList.length),
              ),
            ),
            Positioned(
              right: 30.0,
              bottom: 30.0,
              child: lastPage
                  ? FloatingActionButton(
                shape: CircleBorder(),
                backgroundColor: backgroundColor,
                child: Icon(
                  Icons.arrow_forward,
                  color: colorPrimary,
                  size: 22.0,
                ),
                onPressed: () {
                  if(widget.typeRedirect == 0) {
                    Navigator.pop(context);
                  } else if(widget.typeRedirect == 1 ) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            dialogCustomError('Indisponible', "Nous sommes en procédure judiciaire pour l'établissement de ce service.\nBientôt disponible", context),
                        barrierDismissible: false);
                    //Navigator.pushNamed(context, DemandeConducteur.rootName);
                  }
                },
              )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
}
