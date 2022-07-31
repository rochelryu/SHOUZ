import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location.dart' as loactionHuawei;
import 'package:huawei_location/location/location_request.dart';
import 'package:huawei_location/location/location_settings_request.dart';
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/CardTopNewActu.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/more_actuality_by_categorie.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';
import '../Constant/helper.dart';
import '../Models/User.dart';
import 'ChoiceHobie.dart';
import 'Login.dart';

class Actualite extends StatefulWidget {
  @override
  _ActualiteState createState() => _ActualiteState();
}

class _ActualiteState extends State<Actualite> {
  String firstTextMeteo = "";
  String secondTextMeteo = "";
  late Location location;
  LocationData? locationData;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late Future<Map<String, dynamic>> topActualite;
  late Future<Map<String, dynamic>> contentActulite;
  PermissionHandler permissionHandler = PermissionHandler();
  User? newClient;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  ConsumeAPI consumeAPI = ConsumeAPI();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();



  getPositionCurrent() async {
    if(Platform.isAndroid){
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if(androidInfo.brand!.indexOf('HUAWEI') != - 1 || androidInfo.brand!.indexOf('HONOR') != - 1) {
        try {
          bool status = await permissionHandler.requestLocationPermission();
          if(status) {
            FusedLocationProviderClient locationService = FusedLocationProviderClient();
            LocationRequest locationRequest = LocationRequest();
            LocationSettingsRequest locationSettingsRequest = LocationSettingsRequest(
              requests: <LocationRequest>[locationRequest],
              needBle: true,
              alwaysShow: true,
            );
            await locationService.checkLocationSettings(locationSettingsRequest);
            loactionHuawei.Location locations = await locationService.getLastLocation();
            setState(() {
              locationData = LocationData.fromMap(
                  {
                    "latitude" : locations.latitude,
                    "longitude" : locations.longitude,
                    "accuracy" : 0.0,
                    "altitude" : locations.altitude,
                    "speed" : locations.speed,
                    "speed_accuracy" : locations.speedAccuracyMetersPerSecond,
                    "heading" : locations.bearing,
                    "time" : 0.0,
                    "isMock" : false,
                    "verticalAccuracy" : locations.verticalAccuracyMeters,
                    "headingAccuracy" : locations.bearingAccuracyDegrees,
                    "elapsedRealtimeNanos" : 0.0,
                    "elapsedRealtimeUncertaintyNanos" : 0.0,
                    "satelliteNumber" : locations.elapsedRealtimeNanos,
                    "provider" : locations.provider,
                  }
              );
            });
          } else {
            getPositionCurrent();
          }
        } catch (e) {
          print(e);
        }
      } else {
        try {
          _permissionGranted = await location.hasPermission();
          if (_permissionGranted == PermissionStatus.denied) {
            _permissionGranted = await location.requestPermission();
            if (_permissionGranted != PermissionStatus.granted) {
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
            } else {
              _serviceEnabled = await location.serviceEnabled();
              if (!_serviceEnabled) {
                _serviceEnabled = await location.requestService();
                if (!_serviceEnabled) {
                  return;
                } else {
                  var test = await location.getLocation();
                  setState(() {
                    locationData = test;
                  });
                }
              } else {
                var test = await location.getLocation();
                setState(() {
                  locationData = test;
                });
              }
            }
          } else {
            _serviceEnabled = await location.serviceEnabled();
            if (!_serviceEnabled) {
              _serviceEnabled = await location.requestService();
              if (!_serviceEnabled) {
                return;
              } else {
                var test = await location.getLocation();
                setState(() {
                  locationData = test;
                });
              }
            } else {
              var test = await location.getLocation();
              setState(() {
                locationData = test;
              });
            }
            var test = await location.getLocation();
            setState(() {
              locationData = test;
            });
          }

        } catch (e) {
          print("nous avons une erreur $e");
        }
      }
    } else {
      try {
        _permissionGranted = await location.hasPermission();
        if (_permissionGranted == PermissionStatus.denied) {
          _permissionGranted = await location.requestPermission();
          if (_permissionGranted != PermissionStatus.granted) {
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
          } else {
            _serviceEnabled = await location.serviceEnabled();
            if (!_serviceEnabled) {
              _serviceEnabled = await location.requestService();
              if (!_serviceEnabled) {
                return;
              } else {
                var test = await location.getLocation();
                setState(() {
                  locationData = test;
                });
              }
            } else {
              var test = await location.getLocation();
              setState(() {
                locationData = test;
              });
            }
          }
        } else {
          _serviceEnabled = await location.serviceEnabled();
          if (!_serviceEnabled) {
            _serviceEnabled = await location.requestService();
            if (!_serviceEnabled) {
              return;
            } else {
              var test = await location.getLocation();
              setState(() {
                locationData = test;
              });
            }
          } else {
            var test = await location.getLocation();
            setState(() {
              locationData = test;
            });
          }
          var test = await location.getLocation();
          setState(() {
            locationData = test;
          });
        }

      } catch (e) {
        print("nous avons une erreur $e");
      }
    }


  }

  verifyIfUserHaveReadModalExplain() async {
    final prefs = await SharedPreferences.getInstance();
    final bool asRead = prefs.getBool('readActualityModalExplain') ?? false;
    if(!asRead) {
      await modalForExplain("images/news.gif", "Nous vous informons le plus tôt possible de ce qui se passe ici et ailleurs. Notre équipe s'occupe de démêler les fakes news afin de vous envoyer que ce qui est vrai, nous vous proposons même des appels d'offre & offres d'emploi.\nLe tout uniquement en fonction de vos préférences, alors si vous voulez plus de contenue vous pouvez allez complêter vos centres d'intérêts dans l'onglet Préférences.", context);
      await prefs.setBool('readActualityModalExplain', true);
    }
  }

  cityFromCoord() async {
    try{

      final latitude = (locationData == null || locationData!.latitude == null) ? (newClient != null && newClient!.lagitude != 0.0) ? newClient!.lagitude : defaultLatitude : locationData!.latitude;
      final longitude = (locationData == null || locationData!.longitude == null) ? (newClient != null && newClient!.longitude != 0.0) ? newClient!.longitude : defaultLongitude : locationData!.longitude;
      final addresses =
      await geocoding.placemarkFromCoordinates(latitude!, longitude!);
      geocoding.Placemark first = addresses.first;

      String finalPosition;
      if (first.locality != null  && first.locality != '') {
        finalPosition ='${first.locality}, ${first.isoCountryCode}';
      } else {
        finalPosition = '${first.administrativeArea}, ${first.country}';
      }
      finalPosition = finalPosition.trim();
      final speedAccuracy = locationData != null ? locationData!.speedAccuracy ?? 0.0 : 0.0;
      final user = await consumeAPI.updatePosition(
          finalPosition,
          latitude,
          longitude,
          speedAccuracy);
      if (user['etat'] == 'found') {
        await DBProvider.db.delClient();
        await DBProvider.db.newClient(user['user']);
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
            barrierDismissible: false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => Login()));
      }
      final meteo = await consumeAPI
          .getMeteo(latitude, longitude);
      if (meteo['etat'] == 'found') {
        setState(() {
          firstTextMeteo = "Il fait ${meteo['result'].toString()}ºC";
          secondTextMeteo = (first.locality != null && first.locality != '')
              ? "à ${first.locality} actuellement"
              : "à ${first.administrativeArea} actuellement";
        });
      }
    } catch(e) {
      print("ereeur depuis city");
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    loadInfo();
    location = Location();
    getPositionCurrent();
    topActualite = consumeAPI.getActualite();
    contentActulite = topActualite;
    verifyIfUserHaveReadModalExplain();
    Timer(const Duration(seconds: 5), cityFromCoord);
  }
  loadInfo() async {
    User user = await DBProvider.db.getClient();
    setState(() {
      newClient = user;
    });
  }

  Future loadActualite() async {
    setState(() {
      topActualite = consumeAPI.getActualite();
      contentActulite = topActualite;
    });
  }

  Widget listItemCustom(BuildContext context, String categorieName,
      String categorieId, List<dynamic> bodyItem) {
    List<Widget> itemOfList = bodyItem
        .map((value) => CardTopNewActu(
                value['title'],
                value['_id'],
                value['imageCover'],
                value['numberVue'],
                value['registerDate'],
                value['autherName'],
                value['authorProfil'],
                value['content'],
                value['comment'],
                value['imageCover'])
            .propotypingScrol(context))
        .toList();
    return new Container(
      height: 310,
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15.0, top: 5, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(categorieName, style: Style.titre(20.0)),
                TextButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => MoreActualityByCategorie(key: UniqueKey(), categorieId: categorieId, categorieName: categorieName)));
                }, child: Text("Voir plus", style: Style.moreViews())),
              ],
            ),
          ),
          SizedBox(height: 7.0),
          Container(
            height: 250,
            child: PageView(
              controller: PageController(viewportFraction: 0.8),
              scrollDirection: Axis.horizontal,
              pageSnapping: true,
              children: itemOfList,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
            child: Container(
              child: new Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  FutureBuilder(
                      future: contentActulite,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return isErrorSubscribe(context);
                          case ConnectionState.waiting:
                            return Container(
                              height: 300.0,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return new SizedBox(width: 20.0);
                                  } else {
                                    return loadDataSkeletonOfActuality(context);
                                  }
                                },
                              ),
                            );

                          case ConnectionState.active:
                            return Container(
                              height: 300.0,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return new SizedBox(width: 20.0);
                                  } else {
                                    return loadDataSkeletonOfActuality(context);
                                  }
                                },
                              ),
                            );

                          case ConnectionState.done:
                            if (snapshot.hasError) {
                              return isErrorSubscribe(context);
                            }
                            var actualiteOther = snapshot.data;
                            if (actualiteOther['otherActualite'].length <= 1) {
                              return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Padding(
                                      padding: EdgeInsets.only(
                                          left: 15.0,
                                          right: 15.0,
                                          bottom: 10.0,
                                          top: 5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(firstTextMeteo,
                                              style: Style.grandTitre(18.0)),
                                          SizedBox(height: 2.0),
                                          Text(secondTextMeteo,
                                              style: Style.grandTitre(14.0)),
                                          SizedBox(height: 20.0),
                                        ],
                                      ),
                                    ),
                                    new SvgPicture.asset(
                                      "images/not actu.svg",
                                      semanticsLabel: 'Shouz Pay',
                                      height: MediaQuery.of(context).size.height * 0.39,
                                    ),
                                    Text(
                                        "Aucune Actualité pour vos differentes préferences. Nous vous recommandons d'ajouter au moins une préference populaire afin d'avoir le minimum d'information d'actualité ",
                                        textAlign: TextAlign.center,
                                        style: Style.sousTitreEvent(15)),
                                    SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push((MaterialPageRoute(
                                            builder: (context) => ChoiceHobie())));
                                      },
                                      child: Text('Ajouter Préférence'),
                                      style: ElevatedButton.styleFrom(
                                        onPrimary: colorPrimary,
                                        primary: colorText,
                                        minimumSize: Size(88, 36),
                                        elevation: 4.0,
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                                      ),
                                    )
                                  ]);
                            }
                            return RefreshIndicator(
                                key: _refreshIndicatorKey,
                                onRefresh: loadActualite,
                                child:Container(
                                  height: MediaQuery.of(context).size.height * 0.95,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount:
                                      actualiteOther['otherActualite'].length + 2,
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return new Padding(
                                            padding: EdgeInsets.only(
                                                left: 15.0,
                                                right: 15.0,
                                                bottom: 10.0,
                                                top: 5.0),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(firstTextMeteo,
                                                    style: Style.grandTitre(18.0)),
                                                SizedBox(height: 2.0),
                                                Text(secondTextMeteo,
                                                    style: Style.grandTitre(14.0)),
                                                SizedBox(height: 20.0),
                                              ],
                                            ),
                                          );
                                        } else if (index <=
                                            actualiteOther['otherActualite'].length) {
                                          return listItemCustom(
                                              context,
                                              actualiteOther['otherActualite'][index - 1]
                                              ['name'],
                                              actualiteOther['otherActualite'][index - 1]
                                              ['block'],
                                              actualiteOther['otherActualite'][index - 1]
                                              ['body']);
                                        } else {
                                          return SizedBox(height: 150);
                                        }
                                      }),
                                ));

                          // return new CardTopNewActu()
                        }
                      }),
                ],
              ),
            ),
          );
  }
}
