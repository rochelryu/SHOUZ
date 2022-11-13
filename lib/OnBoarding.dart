import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/helper.dart';
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
                  lastPage = false;
                  if(Platform.isAndroid) {

                    if (await isHms()) {
                      bool status = await permissionsLocation();
                      bool statusPermanent = await permissionsPermanentDenied();
                      if(!status && !statusPermanent) {
                        await incrementPermanentDenied();
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidateAction(
                                    'Permission de Localisation importante',
                                    "Shouz doit avoir cette autorisation pour vous presenter le covoiturage dans votre localité mais aussi pour la conversion appropriée de votre monnaie locale",
                                    "D'accord",
                                        () async => await permission.Permission.locationWhenInUse.request(),
                                    context, false),
                            barrierDismissible: false);
                      }
                      else if(!status && statusPermanent) {

                        await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidateAction(
                                    'Permission de Localisation importante',
                                    "Sans cette autorisation vous ne pourriez pas bénéficier de certains services comme le covoiturage et vtc",
                                    "Ouvrir paramètre",
                                        () async => await openSettingApp(),
                                    context, true, "Réfuser"),
                            barrierDismissible: false);
                      }
                    } else {
                      final _permissionGranted = await location.hasPermission();
                      bool statusPermanent = await permissionsPermanentDenied();
                      if (_permissionGranted == PermissionStatus.denied && !statusPermanent) {
                        await incrementPermanentDenied();
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidateAction(
                                    'Permission de Localisation importante',
                                    "Shouz doit avoir cette autorisation pour vous presenter le covoiturage dans votre localité mais aussi pour la conversion appropriée de votre monnaie locale",
                                    "D'accord",
                                        () async => await location.requestPermission(),
                                    context, false),
                            barrierDismissible: false);
                      }
                      else if(_permissionGranted == PermissionStatus.denied && statusPermanent) {
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidateAction(
                                    'Permission de Localisation importante',
                                    "Sans cette autorisation vous ne pourriez pas bénéficier de certains services comme le covoiturage et vtc",
                                    "Ouvrir paramètre",
                                        () async => await openSettingApp(),
                                    context, true, "Réfuser"),
                            barrierDismissible: false);
                      }
                    }
                  } else {
                    final _permissionGranted = await location.hasPermission();
                    bool statusPermanent = await permissionsPermanentDenied();
                    if (_permissionGranted == PermissionStatus.denied && !statusPermanent) {
                      await incrementPermanentDenied();
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              dialogCustomForValidateAction(
                                  'Permission de Localisation importante',
                                  "Shouz doit avoir cette autorisation pour vous presenter le covoiturage dans votre localité mais aussi pour la conversion appropriée de votre monnaie locale",
                                  "D'accord",
                                      () async => await location.requestPermission(),
                                  context, false),
                          barrierDismissible: false);
                    }
                    else if(_permissionGranted == PermissionStatus.denied && statusPermanent) {
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidateAction(
                                    'Permission de Localisation importante',
                                    "Sans cette autorisation vous ne pourriez pas bénéficier de certains services comme le covoiturage et vtc",
                                    "Ouvrir paramètre",
                                        () async => await openSettingApp(),
                                    context, true, "Réfuser"),
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
                            Image.asset(page.imageUrl, height: MediaQuery.of(context).size.height * 0.5,),
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
              left: 20.0,
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
            ),
            if(!lastPage) Positioned(
                right: 15.0,
                bottom: 20.0,
                child: TextButton(
                  onPressed: () async {
                    if(Platform.isAndroid) {

                      if (await isHms()) {
                        bool status = await permissionsLocation();
                        bool statusPermanent = await permissionsPermanentDenied();
                        if(!status && !statusPermanent) {
                          await incrementPermanentDenied();
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  dialogCustomForValidateAction(
                                      'Permission de Localisation importante',
                                      "Shouz doit avoir cette autorisation pour vous presenter le covoiturage dans votre localité mais aussi pour la conversion appropriée de votre monnaie locale",
                                      "D'accord",
                                          () async => await permission.Permission.locationWhenInUse.request(),
                                      context, false),
                              barrierDismissible: false);
                        }
                        else if(!status && statusPermanent) {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidateAction(
                                    'Permission de Localisation importante',
                                    "Sans cette autorisation vous ne pourriez pas bénéficier de certains services comme le covoiturage et vtc",
                                    "Ouvrir paramètre",
                                        () async => await openSettingApp(),
                                    context, true, "Réfuser"),
                            barrierDismissible: false);
                        }
                      } else {
                        final _permissionGranted = await location.hasPermission();
                        bool statusPermanent = await permissionsPermanentDenied();
                        if (_permissionGranted == PermissionStatus.denied && !statusPermanent) {
                          await incrementPermanentDenied();
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  dialogCustomForValidateAction(
                                      'Permission de Localisation importante',
                                      "Shouz doit avoir cette autorisation pour vous presenter le covoiturage dans votre localité mais aussi pour la conversion appropriée de votre monnaie locale",
                                      "D'accord",
                                          () async => await location.requestPermission(),
                                      context, false),
                              barrierDismissible: false);
                        }
                        else if(_permissionGranted == PermissionStatus.denied && statusPermanent) {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidateAction(
                                    'Permission de Localisation importante',
                                    "Sans cette autorisation vous ne pourriez pas bénéficier de certains services comme le covoiturage et vtc",
                                    "Ouvrir paramètre",
                                        () async => await openSettingApp(),
                                    context, true, "Réfuser"),
                            barrierDismissible: false);
                        }
                      }
                    } else {
                      final _permissionGranted = await location.hasPermission();
                      bool statusPermanent = await permissionsPermanentDenied();
                      if (_permissionGranted == PermissionStatus.denied && !statusPermanent) {
                        await incrementPermanentDenied();
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidateAction(
                                    'Permission de Localisation importante',
                                    "Shouz doit avoir cette autorisation pour vous presenter le covoiturage dans votre localité mais aussi pour la conversion appropriée de votre monnaie locale",
                                    "D'accord",
                                        () async => await location.requestPermission(),
                                    context, false),
                            barrierDismissible: false);
                      }
                      else if(_permissionGranted == PermissionStatus.denied && statusPermanent) {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomForValidateAction(
                                    'Permission de Localisation importante',
                                    "Sans cette autorisation vous ne pourriez pas bénéficier de certains services comme le covoiturage et vtc",
                                    "Ouvrir paramètre",
                                        () async => await openSettingApp(),
                                    context, true, "Réfuser"),
                            barrierDismissible: false);
                      }
                    }
                    Navigator.push(context, ScaleRoute(widget: Login()));

                  },
                  child: Text("TOUT IGNORER", style: Style.skipedMessage(13, colorError),),
                )
            ),
          ],
        ),
      ),
    );
  }
}
