import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location_request.dart';
import 'package:huawei_location/location/location_settings_request.dart';
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/helper.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/create_travel.dart';
import 'package:shouz/Pages/update_info_basic.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';
import './CovoiturageChoicePlace.dart';
import 'package:huawei_location/location/location.dart' as loactionHuawei;


import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:async';

import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart' as prefix1;
import 'dart:io';

import 'demande_conducteur.dart';
import 'explication_travel.dart';

class Covoiturage extends StatefulWidget {
  @override
  _CovoiturageState createState() => _CovoiturageState();
}

const languages = const [
  const Language('Francais', 'fr_FR'),
  const Language('English', 'en_US'),
  const Language('Pусский', 'ru_RU'),
  const Language('Italiano', 'it_IT'),
  const Language('Español', 'es_ES'),
];

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

class _CovoiturageState extends State<Covoiturage> {
  final TextEditingController eCtrl = new TextEditingController();
  final TextEditingController eCtrl2 = new TextEditingController();
  User? newClient;
  bool ori = false;
  bool finishedLoadPosition = false;
  bool load1 = false;
  bool load2 = false;
  List<LatLng> global = [];
  String origine = '';
  String destination = '';
  late Location location;
  LocationData? locationData;
  late PermissionStatus _permissionGranted;
  late Stream<LocationData> stream;
  late bool _serviceEnabled;
  late Future<Map<String, dynamic>> covoiturage;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  PermissionHandler permissionHandler = PermissionHandler();
  FusedLocationProviderClient locationService = FusedLocationProviderClient();
  LocationRequest locationRequest = LocationRequest();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool isActivateCovoiturage =false;
  int level = 0;
  bool trueLoad = true;

  String transcription = '';



  @override
  void initState() {
    super.initState();
    location = new Location();
    internetCheck();
    getExplainCovoiturageMethod();
    verifyIfUserHaveReadModalExplain();
    getPositionCurrent();
  }

  verifyIfUserHaveReadModalExplain() async {
    final prefs = await SharedPreferences.getInstance();
    final bool asRead = prefs.getBool('readTravelModalExplain') ?? false;
    if(!asRead) {
      await modalForExplain("images/travelModal.png", "1 - Passager: Voyage à tout moment de ville en ville dans une voiture personnel en toute sécurité et avec un prix plus bas.\n2 - Conducteur: Tu es propriétaire d’un véhicule, tu veux voyager mais pas seul ? Avec SHOUZ COVOITURAGE gagne de l’argent en vendant des places de voyage.\nTout nos clients passagers ou conducteurs passent d'abord le test de verification d'identité avant de pouvoir acheter des tickets de voyages ou de créer un voyage.\nLa sécurité de nos clients avant tout.", context);
      await prefs.setBool('readTravelModalExplain', true);
    }
  }

  Future getExplainCovoiturageMethod() async {
    try {
      int explainCovoiturage = await getExplainCovoiturage();
      setState(() {
        level = explainCovoiturage;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  void internetCheck() async{
    User user = await DBProvider.db.getClient();

    setState(() {
      newClient = user;
    });
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final data = await consumeAPI.verifyIfClientIsActivateForCovoiturage();
        if(data['etat'] == 'found') {

          if(data['result']['isActivateCovoiturage']){
            setState(() {
              isActivateCovoiturage = true;
            });
          }
          if(data['result']['isActivateForBuyTravel'] == 2 && newClient!.isActivateForBuyTravel != 2) {
            await DBProvider.db.updateClientIsActivateForBuyTravel(2, newClient!.ident);
            user = await DBProvider.db.getClient();
            setState(() {
              newClient = user;
            });
          } else if(data['result']['isActivateForBuyTravel'] != 2 && newClient!.isActivateForBuyTravel == 2) {
            await DBProvider.db.updateClientIsActivateForBuyTravel(data['result']['isActivateForBuyTravel'], newClient!.ident);
            user = await DBProvider.db.getClient();
            setState(() {
              newClient = user;
            });
          }
        }
        else {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
              barrierDismissible: false);
        }
      }
    } on SocketException catch (_) {
      showDialog(
                            context: context,
                            builder: (BuildContext context) => dialogCustomError('Echec', 'Veuillez Verifier votre connexion internet', context),
                            barrierDismissible: false
      );
    }
  }

  getPositionCurrent() async {

    if(Platform.isAndroid){
      if(await isHms()) {
        try {
          bool status = await permissionHandler.hasLocationPermission();
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
            if(locations.latitude == null) {
              if(newClient!.lagitude != 0.0) {
                locations.latitude = newClient!.lagitude;
                locations.longitude = newClient!.longitude;
              } else {
                locations.latitude = defaultLatitude;
                locations.longitude = defaultLongitude;
              }
            }
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
              finishedLoadPosition = true;
            });
          } else {
            await permissionHandler.requestLocationPermission();
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
                  if(test.latitude == null) {
                    setState(() {
                      locationData = LocationData.fromMap(
                          {
                            "latitude" : newClient!.lagitude != 0.0 ? newClient!.lagitude: defaultLatitude,
                            "longitude" : newClient!.longitude != 0.0 ? newClient!.longitude: defaultLongitude,
                            "accuracy" : 0.0,
                            "altitude" : 0.0,
                            "speed" : 0.0,
                            "speed_accuracy" : 0.0,
                            "heading" : 0.0,
                            "time" : 0.0,
                            "isMock" : false,
                            "verticalAccuracy" : 0.0,
                            "headingAccuracy" : 0.0,
                            "elapsedRealtimeNanos" : 0.0,
                            "elapsedRealtimeUncertaintyNanos" : 0.0,
                            "satelliteNumber" : 1,
                            "provider" : '',
                          }
                      );
                    });

                  } else {
                    setState(() {
                      locationData = test;
                    });
                  }
                  setState(() {
                    finishedLoadPosition = true;
                  });
                }
              } else {
                var test = await location.getLocation();
                if(test.latitude == null) {
                  setState(() {
                    locationData = LocationData.fromMap(
                        {
                          "latitude" : newClient!.lagitude != 0.0 ? newClient!.lagitude: defaultLatitude,
                          "longitude" : newClient!.longitude != 0.0 ? newClient!.longitude: defaultLongitude,
                          "accuracy" : 0.0,
                          "altitude" : 0.0,
                          "speed" : 0.0,
                          "speed_accuracy" : 0.0,
                          "heading" : 0.0,
                          "time" : 0.0,
                          "isMock" : false,
                          "verticalAccuracy" : 0.0,
                          "headingAccuracy" : 0.0,
                          "elapsedRealtimeNanos" : 0.0,
                          "elapsedRealtimeUncertaintyNanos" : 0.0,
                          "satelliteNumber" : 1,
                          "provider" : '',
                        }
                    );
                  });

                } else {
                  setState(() {
                    locationData = test;
                  });
                }
                setState(() {
                  finishedLoadPosition = true;
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
                if(test.latitude == null) {
                  setState(() {
                    locationData = LocationData.fromMap(
                        {
                          "latitude" : newClient!.lagitude != 0.0 ? newClient!.lagitude: defaultLatitude,
                          "longitude" : newClient!.longitude != 0.0 ? newClient!.longitude: defaultLongitude,
                          "accuracy" : 0.0,
                          "altitude" : 0.0,
                          "speed" : 0.0,
                          "speed_accuracy" : 0.0,
                          "heading" : 0.0,
                          "time" : 0.0,
                          "isMock" : false,
                          "verticalAccuracy" : 0.0,
                          "headingAccuracy" : 0.0,
                          "elapsedRealtimeNanos" : 0.0,
                          "elapsedRealtimeUncertaintyNanos" : 0.0,
                          "satelliteNumber" : 1,
                          "provider" : '',
                        }
                    );
                    finishedLoadPosition = true;
                  });

                } else {
                  setState(() {
                    locationData = test;
                    finishedLoadPosition = true;
                  });
                }
              }
            } else {
              var test = await location.getLocation();
              setState(() {
                locationData = test;
              });
            }
            var test = await location.getLocation();
            if(test.latitude == null) {
              setState(() {
                locationData = LocationData.fromMap(
                    {
                      "latitude" : newClient!.lagitude != 0.0 ? newClient!.lagitude: defaultLatitude,
                      "longitude" : newClient!.longitude != 0.0 ? newClient!.longitude: defaultLongitude,
                      "accuracy" : 0.0,
                      "altitude" : 0.0,
                      "speed" : 0.0,
                      "speed_accuracy" : 0.0,
                      "heading" : 0.0,
                      "time" : 0.0,
                      "isMock" : false,
                      "verticalAccuracy" : 0.0,
                      "headingAccuracy" : 0.0,
                      "elapsedRealtimeNanos" : 0.0,
                      "elapsedRealtimeUncertaintyNanos" : 0.0,
                      "satelliteNumber" : 1,
                      "provider" : '',
                    }
                );
                finishedLoadPosition = true;
              });

            } else {
              setState(() {
                locationData = test;
                finishedLoadPosition = true;
              });
            }
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
                if(test.latitude == null) {
                  setState(() {
                    locationData = LocationData.fromMap(
                        {
                          "latitude" : newClient!.lagitude != 0.0 ? newClient!.lagitude: defaultLatitude,
                          "longitude" : newClient!.longitude != 0.0 ? newClient!.longitude: defaultLongitude,
                          "accuracy" : 0.0,
                          "altitude" : 0.0,
                          "speed" : 0.0,
                          "speed_accuracy" : 0.0,
                          "heading" : 0.0,
                          "time" : 0.0,
                          "isMock" : false,
                          "verticalAccuracy" : 0.0,
                          "headingAccuracy" : 0.0,
                          "elapsedRealtimeNanos" : 0.0,
                          "elapsedRealtimeUncertaintyNanos" : 0.0,
                          "satelliteNumber" : 1,
                          "provider" : '',
                        }
                    );
                    finishedLoadPosition = true;
                  });

                } else {
                  setState(() {
                    locationData = test;
                    finishedLoadPosition = true;
                  });
                }
              }
            } else {
              var test = await location.getLocation();
              if(test.latitude == null) {
                setState(() {
                  locationData = LocationData.fromMap(
                      {
                        "latitude" : newClient!.lagitude != 0.0 ? newClient!.lagitude: defaultLatitude,
                        "longitude" : newClient!.longitude != 0.0 ? newClient!.longitude: defaultLongitude,
                        "accuracy" : 0.0,
                        "altitude" : 0.0,
                        "speed" : 0.0,
                        "speed_accuracy" : 0.0,
                        "heading" : 0.0,
                        "time" : 0.0,
                        "isMock" : false,
                        "verticalAccuracy" : 0.0,
                        "headingAccuracy" : 0.0,
                        "elapsedRealtimeNanos" : 0.0,
                        "elapsedRealtimeUncertaintyNanos" : 0.0,
                        "satelliteNumber" : 1,
                        "provider" : '',
                      }
                  );
                  finishedLoadPosition = true;
                });

              } else {
                setState(() {
                  locationData = test;
                  finishedLoadPosition = true;
                });
              }
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
              if(test.latitude == null) {
                setState(() {
                  locationData = LocationData.fromMap(
                      {
                        "latitude" : newClient!.lagitude != 0.0 ? newClient!.lagitude: defaultLatitude,
                        "longitude" : newClient!.longitude != 0.0 ? newClient!.longitude: defaultLongitude,
                        "accuracy" : 0.0,
                        "altitude" : 0.0,
                        "speed" : 0.0,
                        "speed_accuracy" : 0.0,
                        "heading" : 0.0,
                        "time" : 0.0,
                        "isMock" : false,
                        "verticalAccuracy" : 0.0,
                        "headingAccuracy" : 0.0,
                        "elapsedRealtimeNanos" : 0.0,
                        "elapsedRealtimeUncertaintyNanos" : 0.0,
                        "satelliteNumber" : 1,
                        "provider" : '',
                      }
                  );
                  finishedLoadPosition = true;
                });

              } else {
                setState(() {
                  locationData = test;
                  finishedLoadPosition = true;
                });
              }
              setState(() {
                finishedLoadPosition = true;
              });
            }
          } else {
            var test = await location.getLocation();
            if(test.latitude == null) {
              setState(() {
                locationData = LocationData.fromMap(
                    {
                      "latitude" : newClient!.lagitude != 0.0 ? newClient!.lagitude: defaultLatitude,
                      "longitude" : newClient!.longitude != 0.0 ? newClient!.longitude: defaultLongitude,
                      "accuracy" : 0.0,
                      "altitude" : 0.0,
                      "speed" : 0.0,
                      "speed_accuracy" : 0.0,
                      "heading" : 0.0,
                      "time" : 0.0,
                      "isMock" : false,
                      "verticalAccuracy" : 0.0,
                      "headingAccuracy" : 0.0,
                      "elapsedRealtimeNanos" : 0.0,
                      "elapsedRealtimeUncertaintyNanos" : 0.0,
                      "satelliteNumber" : 1,
                      "provider" : '',
                    }
                );
                finishedLoadPosition = true;
              });

            } else {
              setState(() {
                locationData = test;
                finishedLoadPosition = true;
              });
            }
          }
          var test = await location.getLocation();
          if(test.latitude == null) {
            setState(() {
              locationData = LocationData.fromMap(
                  {
                    "latitude" : newClient!.lagitude != 0.0 ? newClient!.lagitude: defaultLatitude,
                    "longitude" : newClient!.longitude != 0.0 ? newClient!.longitude: defaultLongitude,
                    "accuracy" : 0.0,
                    "altitude" : 0.0,
                    "speed" : 0.0,
                    "speed_accuracy" : 0.0,
                    "heading" : 0.0,
                    "time" : 0.0,
                    "isMock" : false,
                    "verticalAccuracy" : 0.0,
                    "headingAccuracy" : 0.0,
                    "elapsedRealtimeNanos" : 0.0,
                    "elapsedRealtimeUncertaintyNanos" : 0.0,
                    "satelliteNumber" : 1,
                    "provider" : '',
                  }
              );
              finishedLoadPosition = true;
            });

          } else {
            setState(() {
              locationData = test;
              finishedLoadPosition = true;
            });
          }
        }

      } catch (e) {
        print("nous avons une erreur $e");
      }
    }


  }

  coordFromCityTwo() async{
    setState(() {
      load2 = true;
    });
    List<geocoding.Location> addresses = await geocoding.locationFromAddress("${origine.toLowerCase()}, Côte d'Ivoire");
    if(addresses.length > 0){
      geocoding.Location address = addresses.first;
      if(global.length > 1){
        setState(() {
          global[1] = new LatLng(address.latitude, address.longitude);
          load2 = false;
          eCtrl.text = origine;
        });
        covoiturage = consumeAPI.getCovoiturage(origine, destination);

      }
      else{
        setState(() {
          global.add(new LatLng(address.latitude, address.longitude));
          load2 = false;
          eCtrl.text = origine;
        });
        covoiturage = consumeAPI.getCovoiturage(origine, destination);
      }
    }
  }

  coordFromCity() async{
    setState(() {
      load1 = true;
    });
    List<geocoding.Location> addresses = await geocoding.locationFromAddress("${destination.toLowerCase()}, Côte d'Ivoire");
    if(addresses.length > 0){
      geocoding.Location address = addresses.first;
      if(global.length > 0){
        setState(() {
          global[0] = new LatLng(address.latitude, address.longitude);
          eCtrl2.text = destination;
          load1 = false;
          ori = true;
        });
        if(global.length > 1) {
          covoiturage = consumeAPI.getCovoiturage(origine, destination);
        }
      }
      else{
        setState(() {
          global.add(new LatLng(address.latitude, address.longitude));
          eCtrl2.text = destination;
          load1 = false;
          ori = true;
        });
      }
    }
  }

    @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          !finishedLoadPosition ? Center(child: LoadingIndicator(indicatorType: Indicator.ballScale,colors: [colorText], strokeWidth: 2)): mapping(context,locationData!.latitude ?? defaultLatitude,locationData!.longitude ?? defaultLongitude),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 20.0,
        onPressed: () {
          if(isActivateCovoiturage) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) => CreateTravel(key: UniqueKey())));
          } else {
            if(level == 0) {
              setExplain(2, "covoiturage");
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) => ExplicationTravel(key: UniqueKey(), typeRedirect: 1)));
            } else {
              Navigator.pushNamed(context, DemandeConducteur.rootName);
            }
          }

        },
        backgroundColor: colorText,
        tooltip: isActivateCovoiturage ? "Créer un voyage": "Faire une demande con",
        child: Icon(isActivateCovoiturage ? Icons.add: MyFlutterAppSecond.driver, color: Colors.white, size: 22.0),
      ),
    );
  }

  mapping(BuildContext context, double latitude, double longitude){
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new FlutterMap(
            options: MapOptions(
              center: LatLng(latitude, longitude),
              minZoom: 4.0,
              zoom: 7.0,
            ),
          children: [
              new TileLayer(
                urlTemplate:
                "https://api.mapbox.com/styles/v1/rochelryu/ck1piq46n2i5y1cpdlmq6e8e2/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoicm9jaGVscnl1IiwiYSI6ImNrMTkwbWkxMjAwM2UzZG9ka3hmejEybW0ifQ.9BIwdEGZfCz6MLIg8V6SIg",
                additionalOptions: {
                  'accessToken': 'pk.eyJ1Ijoicm9jaGVscnl1IiwiYSI6ImNrMTkwbWkxMjAwM2UzZG9ka3hmejEybW0ifQ.9BIwdEGZfCz6MLIg8V6SIg',
                  'id': 'mapbox.mapbox-streets-v8'
                },

              ),
              new MarkerLayer(markers: [
                new Marker(
                    width: 45.0,
                    height: 45.0,
                    point: LatLng(latitude, longitude),
                    builder: (context) => new Container(
                      child: Icon(Icons.location_on, color: colorText, size: 18.0),
                    ))
              ]),

              new PolylineLayer(
                  polylines: [
                    new Polyline(
                        points: global,
                        strokeWidth: 5.0,
                        isDotted: true,
                        color: colorText,
                        gradientColors: [colorText, Colors.redAccent],
                    )
                  ]
              )
            ],

        ),
        if(global.length == 2) Positioned(
          top: 120.0,
          left: MediaQuery.of(context).size.width * 0.49,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.0)
            ),
            child: Center(
              child: IconButton(
                icon: Icon(Icons.search, color: backgroundColor, size: 25.0,),
                onPressed: (){
                  if(global.length != 2) getPositionCurrent();
                  else{
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        elevation: 10.0,
                        builder: (builder){
                          return new Container(
                            height: 360,
                            decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(30.0), topLeft: Radius.circular(30.0))
                            ),
                            child: Center(
                              child: FutureBuilder(
                                  future: covoiturage,
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.none:

                                        return Column(
                                          children: <Widget>[
                                            Expanded(
                                                child: Center(
                                                  child: Text("Erreur de connexion", style: Style.titreEvent(18)),)
                                            ),
                                          ],
                                        );
                                      case ConnectionState.waiting:
                                        return  LoadingIndicator(indicatorType: Indicator.ballScale,colors: [colorText], strokeWidth: 2);
                                      case ConnectionState.active:
                                        return  LoadingIndicator(indicatorType: Indicator.ballScale,colors: [colorText], strokeWidth: 2);
                                      case ConnectionState.done:
                                        if (snapshot.hasError){
                                          return isErrorSubscribe(context);
                                        }
                                        var covoiturageFilter = snapshot.data;
                                        if (covoiturageFilter['result'].length == 0) {
                                          return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                new SvgPicture.asset(
                                                  "images/notdepart.svg",
                                                  semanticsLabel: 'NotTravel',
                                                  height: MediaQuery.of(context).size.height * 0.3,
                                                ),
                                                Text("Aucun voyage pour le moment selon ces coordonées", textAlign: TextAlign.center, style: Style.sousTitreEvent(15))
                                              ]);
                                        }
                                        return Container(
                                          height: MediaQuery.of(context).size.height/1.9,
                                          alignment: Alignment.bottomCenter,
                                          padding: EdgeInsets.only(left: 15.0),
                                          child: ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: covoiturageFilter['result'].length,
                                            itemBuilder: (context,index){
                                              final ident = covoiturageFilter['result'][index];
                                              final register = DateTime.parse(ident['travelDate']); //.toString();
                                              String afficheDate = (DateTime.now().difference(DateTime(register.year,register.month,register.day)).inDays > - 1) ?  "Après demain à ${register.hour.toString()}h ${register.minute.toString()}"  : "Le ${register.day.toString()}/${register.month.toString()}/${register.year.toString()} à ${register.hour.toString()}h ${register.minute.toString()}";
                                              afficheDate = (DateTime.now().difference(DateTime(register.year,register.month,register.day)).inDays == 0) ? "Demain à ${register.hour.toString()}h ${register.minute.toString()}"  : afficheDate;
                                              afficheDate = (DateTime.now().difference(DateTime(register.year,register.month,register.day)).inDays == 1) ? "Aujourd'hui à ${register.hour.toString()}h ${register.minute.toString()}"  : afficheDate;
                                              return new Padding(
                                                padding: EdgeInsets.only(left: 20.0, top: 40.0,bottom: 10.0),
                                                child: InkWell(
                                                  onTap: (){
                                                    if(newClient != null && newClient!.isActivateForBuyTravel == 2) {
                                                      Navigator.of(context).push((
                                                          MaterialPageRoute(
                                                              builder: (builder)=> CovoiturageChoicePlace(
                                                                ident['id'],
                                                                0,
                                                                ident['beginCity'],
                                                                ident['endCity'],
                                                                ident['lieuRencontre'],
                                                                ident['price'],
                                                                ident['travelDate'],
                                                                ident['authorId'],
                                                                ident['placePosition'],
                                                                ident['userPayCheck'],
                                                                ident['infoAuthor'],
                                                                ident['commentPayCheck'],
                                                                newClient != null && ident['authorId'] == newClient!.ident,
                                                                ident['state'],
                                                              )
                                                          )
                                                      ));
                                                    } else {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) =>
                                                              dialogCustomForValidateAction('Mesure de Sécurité',
                                                                "Vu que c'est votre première fois de vouloir acheter une place de voyage nous devons récupérer des informations supplémentaires sur votre identité",
                                                                "Ok c'est compris",
                                                                    ()=> Navigator.pushNamed(context, UpdateInfoBasic.rootName),
                                                                context,
                                                              ),
                                                          barrierDismissible: false);

                                                    }

                                                  },
                                                  child: Card(
                                                    elevation: 4.0,
                                                    color: backgroundColor,
                                                    child: Container(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Container(
                                                            height: 160,
                                                            width: 240,
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(6.0),
                                                                image: DecorationImage(
                                                                    image: NetworkImage("${ConsumeAPI.AssetTravelServer}${ident['authorId']}/${ident['infoAuthor']['vehiculeCover']}"),
                                                                    fit: BoxFit.cover
                                                                )
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 240,
                                                            child: Column(
                                                              children: <Widget>[
                                                                Padding(
                                                                  padding: EdgeInsets.all(5.0),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: <Widget>[
                                                                      Icon(prefix1.MyFlutterAppSecond.pin, color: colorText, size: 22.0),
                                                                      SizedBox(width: 10),
                                                                      Text(ident['endCity'].toString().toUpperCase(), maxLines: 3, style: Style.titleDealsProduct()),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.all(5.0),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: <Widget>[
                                                                      Icon(prefix1.MyFlutterAppSecond.pin, color: Colors.redAccent, size: 22.0),
                                                                      SizedBox(width: 10),
                                                                      Text(ident['beginCity'].toString().toUpperCase(), maxLines: 3, style: Style.titleDealsProduct()),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.all(5.0),
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: <Widget>[
                                                                      Row(mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: <Widget>[
                                                                          Icon(Icons.account_balance_wallet, color: Colors.white, size: 22.0),
                                                                          SizedBox(width: 10.0),
                                                                          Text(ident['price'].toString() + ' ' + ident['infoAuthor']['currencies'], style: Style.titleInSegment()),
                                                                        ],),
                                                                      SizedBox(height: 5.0),
                                                                      Row(mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: <Widget>[
                                                                          Icon(Icons.access_time, color: Colors.white, size: 22.0),
                                                                          SizedBox(width: 10.0),
                                                                          Text(afficheDate, style: Style.titleInSegment()),
                                                                        ],),

                                                                    ],
                                                                  ),
                                                                ),

                                                              ],
                                                            ),
                                                          )


                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                    }
                                  }
                              ),

                            ),
                          );
                        });
                  }
                },
              ),
            ),
          ),
        ),
        Positioned(
          top: 6.0,
          right: 32.0,
          left: 32.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Card(
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5.0,
                child: Container(
                    height: 38,
                    padding: EdgeInsets.all(5.0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        (!load1) ? Icon(prefix1.MyFlutterAppSecond.pin, color: colorText, size: 22.0):CircularProgressIndicator(value: null, strokeWidth: 1.0,),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          height: 30,
                          width: MediaQuery.of(context).size.width/1.7,
                          child: TextField(
                            maxLines: 1,
                            controller: eCtrl2,
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Ville ou point d'arrivé",
                              hintStyle: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey[800], fontSize: 12.0),
                            ),
                            onChanged: (text){
                              setState(() {
                                destination = text;
                              });
                            },
                            onSubmitted: (text){
                              setState(() {
                                destination = text;
                              });
                              coordFromCity();
                            },
                          ),
                        ),
                      ],
                    )
                ),
              ),
              SizedBox(height: 10.0),
              if (ori) Card(
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5.0,
                child: Container(
                    height: 38,
                    padding: EdgeInsets.all(5.0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        (!load1) ? Icon(prefix1.MyFlutterAppSecond.pin, color: Colors.redAccent, size: 22.0):CircularProgressIndicator(value: null, strokeWidth: 1.0,),
                        Container(
                          height: 30,
                          padding: EdgeInsets.only(left: 10),
                          width: MediaQuery.of(context).size.width/1.7,
                          child: TextField(
                            maxLines: 1,
                            controller: eCtrl,
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Ville ou point d'origine",
                              hintStyle: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey[800], fontSize: 12.0),
                            ),
                            onChanged: (text){
                              setState(() {
                                origine = text;
                              });
                            },
                            onSubmitted: (text){
                              setState(() {
                                origine = text;
                              });
                              coordFromCityTwo();
                            },
                          ),
                        ),

                      ],
                    )
                ),
              ),


            ],
          ),
        ),
      ],
    );
  }
}
