import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/Login.dart';

import './Constant/PageIndicator.dart';
import './Constant/PageTransition.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  PageController _controller;
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
                          delta = _controller.page - index;
                          y = 1 - delta.abs().clamp(0.0, 1.0);
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(page.imageUrl),
                            Container(
                              height: 80.0,
                              margin: EdgeInsets.only(left: 12.0),
                              child: Stack(
                                children: <Widget>[
                                  Opacity(
                                    opacity: 0.10,
                                    child: GradientText(
                                      page.title,
                                      gradient: LinearGradient(
                                          colors: page.titleGradient),
                                      style: Style.titleOnBoardShadow(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 27.0, left: 15.0),
                                    child: GradientText(
                                      page.title,
                                      gradient: LinearGradient(
                                          colors: page.titleGradient),
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
              left: 30.0,
              bottom: 40.0,
              child: Container(
                width: 180.0,
                child: PageIndicator(_counter, pageList.length),
              ),
            ),
            Positioned(
              right: 30.0,
              bottom: 30.0,
              child: lastPage
                  ? FloatingActionButton(
                      backgroundColor: backgroundColor,
                      child: Icon(
                        Icons.arrow_forward,
                        color: colorPrimary,
                        size: 22.0,
                      ),
                      onPressed: () {
                        Navigator.push(context, ScaleRoute(widget: Login()));
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
