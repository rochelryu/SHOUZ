import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../Constant/PageIndicatorSecond.dart';

class Public extends StatefulWidget {
  @override
  _PublicState createState() => _PublicState();
}

class _PublicState extends State<Public> {
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView.builder(
              itemCount: pageList.length,
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _counter = index;
                });
                if (_counter == pageList.length - 1)
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
                        var page = pageList[index];
                        var delta;
                        var y = 1.0;

                        if (_controller.position.haveDimensions) {
                          delta = _controller.page! - index;
                          y = 1 - double.parse(delta.abs().clamp(0.0, 1.0).toString());
                        }

                        return Column(
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
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2.6,
                                      child: Image.asset(page.imageUrl),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 80.0,
                              margin: EdgeInsets.only(left: 12.0),
                              child: Stack(
                                children: <Widget>[
                                  Opacity(
                                    opacity: 0.10,
                                    child: GradientText(
                                      page.title,
                                      colors: page.titleGradient,
                                      style: Style.titleOnBoardShadow(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 30.0, left: 22.0),
                                    child: GradientText(
                                      page.title,
                                      colors: page.titleGradient,
                                      style: Style.titleOnBoard(),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 12.0, left: 34.0, right: 10.0),
                              child: Transform(
                                transform: Matrix4.translationValues(
                                    0.0, 50 * (1 - y), 0.0),
                                child: Text(
                                  page.body,
                                  style: Style.simpleTextOnBoard(),
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
              left: -50.0,
              top: 10.0,
              child: Transform.rotate(
                angle: pi / 2,
                child: Container(
                  width: 150.0,
                  height: MediaQuery.of(context).size.width,
                  child: PageIndicatorSecond(_counter, pageList.length),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
