import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:location/location.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/Login.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:shouz/Constant/widget_common.dart';

import './Constant/PageIndicator.dart';
import './Constant/PageTransition.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  late PageController _controller;
  int _counter = 0;
  bool lastPage = false;
  late Location location;
  late PermissionStatus _permissionGranted;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  PermissionHandler permissionHandler = PermissionHandler();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location = new Location();
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
              itemCount: pageList.length,
              controller: _controller,
              onPageChanged: (index) async {
                setState(() {
                  _counter = index;
                });
                if(_counter == 4) {
                  if(Platform.isAndroid) {
                    AndroidDeviceInfo androidInfo = await deviceInfo
                        .androidInfo;
                    if (androidInfo.brand!.indexOf('HUAWEI') != -1 ||
                        androidInfo.brand!.indexOf('HONOR') != -1) {
                      bool status = await permissionHandler.requestLocationPermission();

                      if(!status) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidatePermissionNotification(
                                    'Permission de Localisation importante',
                                    "Shouz a besoin d'avoir cette permission pour vous presenter des covoiturages dans votre localité mais aussi pour la bonne conversion de votre monnaie locale",
                                    "D'accord",
                                        () async => await permissionHandler.requestLocationPermission(),
                                    context),
                            barrierDismissible: false);
                      }
                    } else {
                      _permissionGranted = await location.hasPermission();
                      if (_permissionGranted == PermissionStatus.denied) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidatePermissionNotification(
                                    'Permission de Localisation importante',
                                    "Shouz a besoin d'avoir cette permission pour vous presenter des covoiturages dans votre localité mais aussi pour la bonne conversion de votre monnaie locale",
                                    "D'accord",
                                        () async => await location.requestPermission(),
                                    context),
                            barrierDismissible: false);
                      }
                    }
                  } else {
                    _permissionGranted = await location.hasPermission();
                    if (_permissionGranted == PermissionStatus.denied) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              dialogCustomForValidatePermissionNotification(
                                  'Permission de Localisation importante',
                                  "Shouz a besoin d'avoir cette permission pour vous presenter des covoiturages dans votre localité mais aussi pour la bonne conversion de votre monnaie locale",
                                  "D'accord",
                                      () async => await location.requestPermission(),
                                  context),
                          barrierDismissible: false);
                    }
                  }
                }
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
                                      colors: page.titleGradient,
                                      style: Style.titleOnBoardShadow(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 27.0, left: 15.0),
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
              left: 30.0,
              bottom: 40.0,
              child: Container(
                width: 180.0,
                child: PageIndicator(_counter, pageList.length),
              ),
            ),
            if(lastPage) Positioned(
              right: 30.0,
              bottom: 30.0,
              child: FloatingActionButton(
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
            )
          ],
        ),
      ),
    );
  }
}
