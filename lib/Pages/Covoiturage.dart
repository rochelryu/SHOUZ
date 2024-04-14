import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:huawei_location/huawei_location.dart' as huawei_location;
import 'package:latlong2/latlong.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox_gl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/helper.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/Login.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:async';

import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart' as prefix1;
import 'dart:io';

import 'choice_type_create_travel.dart';
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

class _CovoiturageState extends State<Covoiturage> with SingleTickerProviderStateMixin {
  final TextEditingController eCtrl = TextEditingController();
  final TextEditingController eCtrl2 = TextEditingController();
  User? newClient;
  bool showBottom = false;
  bool selectMutualise = false;
  bool selectConfort = false;
  bool firstItemOpen = false;
  bool secondItemOpen = false;
  List<LatLng> global = [];
  List<dynamic> originItems = [];
  List<double> originChoice = [];//long,lat
  List<dynamic> destinateItmens = [];
  List<double> destinateChoice = [];//long,lat
  String origine = '';
  double distance = 0;
  double duration = 0;
  String destination = '';
  late Location location;
  LocationData? locationData;
  late PermissionStatus _permissionGranted;
  late Stream<LocationData> stream;
  late bool _serviceEnabled;
  late Future<Map<String, dynamic>> covoiturage;
  ConsumeAPI consumeAPI = ConsumeAPI();
  bool isActivateCovoiturage = false;
  int level = 0, place =  1;
  bool trueLoad = true;


  String transcription = '';
  bool notPermission = false;
  double centerPositionLongitude = defaultLongitude;
  double centerPositionLatitude = defaultLatitude;
  late TabController _controller;


  late mapbox_gl.CameraPosition _initialCameraPosition;
  late mapbox_gl.MapboxMapController controller;



  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    location = Location();
    _initialCameraPosition = mapbox_gl.CameraPosition(target: mapbox_gl.LatLng(centerPositionLatitude, centerPositionLongitude), zoom: 7);
    internetCheck();
    getExplainCovoiturageMethod();
    //verifyIfUserHaveReadModalExplain();
    getPositionCurrent();
  }

  /*Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    //_directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);

    _options = MapBoxOptions(

        zoom: 19.0,
        enableRefresh: true,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        simulateRoute: true,
        mapStyleUrlDay: 'mapbox://styles/rochelryu/ckj3rq4ykbukh19rpata2eez3',
        mapStyleUrlNight: 'mapbox://styles/rochelryu/ckj3rq4ykbukh19rpata2eez3',
        language: "fr");

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }
  Future<void> _onEmbeddedRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction!;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }*/

  verifyIfUserHaveReadModalExplain() async {
    final prefs = await SharedPreferences.getInstance();
    final bool asRead = prefs.getBool('readTravelModalExplain') ?? false;
    if (!asRead) {
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}travelModal.png",
          "1/4 - Passager: Voyage à tout moment de ville en ville, de commune en commune ou dans la même commune dans un vehicule personnel ou commercial en toute sécurité et avec un prix plus bas.\nTout nos clients passagers passent d'abord le teste de verification d'identité avant de pouvoir acheter des tickets de voyages.",
          context);
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}travelModal.png",
          "2/4 - Conducteur: Tu es propriétaire d’un véhicule personnel, tu veux voyager ou aller au travail mais pas seul ? Avec SHOUZ gagne de l’argent en vendant des places libre de ton véhicule à ton prix.\nTout nos conducteurs de vehicule personnel passent d'abord le teste de verification d'identité avant de pouvoir créer un voyage.",
          context);
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}travelModal.png",
          "3/4 - Chauffeur: Tu es conduit un véhicule commercial comme activité ? Nous te donnons des clients qui veulent se deplacer dans la ville à notre prix.\nTout nos conducteurs de vehicule commercial passent d'abord le teste de verification d'identité avant de pouvoir créer un voyage.",
          context);
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}travelModal.png",
          "4/4 - Service Indisponible: ce service (SHOUZ COVOITURAGE & VTC) sortira bientôt.",
          context);
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

  cityFromCoord() async {
    try{
      setState(() {
        centerPositionLongitude = locationData!.longitude!;
        centerPositionLatitude = locationData!.latitude!;
      });
      controller.animateCamera(
          mapbox_gl.CameraUpdate.newCameraPosition(mapbox_gl.CameraPosition(target: mapbox_gl.LatLng(locationData!.latitude!, locationData!.longitude!), zoom: 16)));
      final addresses =
      await geocoding.placemarkFromCoordinates(locationData!.latitude!, locationData!.longitude!);
      geocoding.Placemark first = addresses.first;
      String finalPosition = '';

      if (first.locality != null  && first.locality != '') {
        finalPosition ='${first.locality}, ${first.isoCountryCode}';
      } else {
        finalPosition = '${first.administrativeArea}, ${first.country}';
      }
      finalPosition = finalPosition.trim();
      final speedAccuracy = locationData != null ? locationData!.speedAccuracy ?? 0.0 : 0.0;
      if(newClient != null && newClient?.numero != 'null') {
        final user = await consumeAPI.updatePosition(
            finalPosition,
            locationData!.latitude!,
            locationData!.longitude!,
            speedAccuracy);
        if (user['etat'] == 'found') {
          await DBProvider.db.delClient();
          await DBProvider.db.newClient(user['user']);
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Plusieurs connexions à ce compte', "Pour une question de sécurité nous allons devoir vous déconnecter.", context),
              barrierDismissible: false);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (builder) => Login()));
        }
      }

    } catch(e) {
      print("erreur depuis city");
      print(e);
    }
  }

  void internetCheck() async {
    User user = await DBProvider.db.getClient();

    if(user.numero != 'null') {
      setState(() {
        newClient = user;
        centerPositionLongitude = user.longitude!;
        centerPositionLatitude = user.lagitude!;
      });
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          final data = await consumeAPI.verifyIfClientIsActivateForCovoiturage();
          if (data['etat'] == 'found') {
            if (data['result']['isActivateCovoiturage']) {
              setState(() {
                isActivateCovoiturage = true;
              });
            }
            if (data['result']['isActivateForBuyTravel'] == 2 &&
                newClient!.isActivateForBuyTravel != 2) {
              await DBProvider.db
                  .updateClientIsActivateForBuyTravel(2, newClient!.ident);
              user = await DBProvider.db.getClient();
              setState(() {
                newClient = user;
              });
            } else if (data['result']['isActivateForBuyTravel'] != 2 &&
                newClient!.isActivateForBuyTravel == 2) {
              await DBProvider.db.updateClientIsActivateForBuyTravel(
                  data['result']['isActivateForBuyTravel'], newClient!.ident);
              user = await DBProvider.db.getClient();
              setState(() {
                newClient = user;
              });
            }
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) => dialogCustomError(
                    'Plusieurs connexions à ce compte',
                    "Pour une question de sécurité nous allons devoir vous déconnecter.",
                    context),
                barrierDismissible: false);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (builder) => Login()));
          }
        }
      } on SocketException catch (_) {
        showDialog(
            context: context,
            builder: (BuildContext context) => dialogCustomError(
                'Echec', 'Veuillez Verifier votre connexion internet', context),
            barrierDismissible: false);
      }
    }

  }


  getPositionCurrent() async {
    if (Platform.isAndroid) {
      if (await isHms()) {
        try {
          bool status = await permissionsLocation();
          if (status) {
            huawei_location.FusedLocationProviderClient locationService =
                huawei_location.FusedLocationProviderClient();

            huawei_location.LocationRequest locationRequest =
                huawei_location.LocationRequest();

            huawei_location.LocationSettingsRequest locationSettingsRequest =
                huawei_location.LocationSettingsRequest(
              requests: <huawei_location.LocationRequest>[locationRequest],
              needBle: true,
              alwaysShow: true,
            );
            await locationService
                .checkLocationSettings(locationSettingsRequest);
            huawei_location.Location locations =
                await locationService.getLastLocation();
            if (locations.latitude == null) {
              if (newClient!= null && newClient!.lagitude != 0.0) {
                locations.latitude = newClient!.lagitude;
                locations.longitude = newClient!.longitude;
              } else {
                locations.latitude = defaultLatitude;
                locations.longitude = defaultLongitude;
              }
            }
            setState(() {
              locationData = LocationData.fromMap({
                "latitude": locations.latitude,
                "longitude": locations.longitude,
                "accuracy": 0.0,
                "altitude": locations.altitude,
                "speed": locations.speed,
                "speed_accuracy": locations.speedAccuracyMetersPerSecond,
                "heading": locations.bearing,
                "time": 0.0,
                "isMock": false,
                "verticalAccuracy": locations.verticalAccuracyMeters,
                "headingAccuracy": locations.bearingAccuracyDegrees,
                "elapsedRealtimeNanos": 0.0,
                "elapsedRealtimeUncertaintyNanos": 0.0,
                "satelliteNumber": locations.elapsedRealtimeNanos,
                "provider": locations.provider,
              });
              //finishedLoadPosition = true;
            });
            await cityFromCoord();
          } else {
            final resultPermission =
                await permission.Permission.locationWhenInUse.request();
            if (resultPermission.isGranted) {
              getPositionCurrent();
            } else {
              setState(() {
                notPermission = true;
              });
            }
          }
        } catch (e) {
          print(e);
        }
      } else {
        try {
          _permissionGranted = await location.hasPermission();
          if (_permissionGranted == PermissionStatus.denied) {
            final resultPermission = await location.requestPermission();

            if (resultPermission != PermissionStatus.granted) {
              setState(() {
                notPermission = true;
              });
            } else {
              _serviceEnabled = await location.serviceEnabled();
              if (!_serviceEnabled) {
                _serviceEnabled = await location.requestService();
                if (!_serviceEnabled) {
                  setState(() {
                    notPermission = true;
                  });
                } else {
                  var test = await location.getLocation();
                  if (test.latitude == null) {
                    setState(() {
                      locationData = LocationData.fromMap({
                        "latitude": newClient!= null && newClient!.lagitude != 0.0
                            ? newClient!.lagitude
                            : defaultLatitude,
                        "longitude": newClient!= null && newClient!.longitude != 0.0
                            ? newClient!.longitude
                            : defaultLongitude,
                        "accuracy": 0.0,
                        "altitude": 0.0,
                        "speed": 0.0,
                        "speed_accuracy": 0.0,
                        "heading": 0.0,
                        "time": 0.0,
                        "isMock": false,
                        "verticalAccuracy": 0.0,
                        "headingAccuracy": 0.0,
                        "elapsedRealtimeNanos": 0.0,
                        "elapsedRealtimeUncertaintyNanos": 0.0,
                        "satelliteNumber": 1,
                        "provider": '',
                      });
                    });
                  } else {
                    setState(() {
                      locationData = test;
                    });
                  }
                  await cityFromCoord();
                }
              } else {
                var test = await location.getLocation();
                if (test.latitude == null) {
                  setState(() {
                    locationData = LocationData.fromMap({
                      "latitude": newClient!= null && newClient!.lagitude != 0.0
                          ? newClient!.lagitude
                          : defaultLatitude,
                      "longitude": newClient!= null && newClient!.longitude != 0.0
                          ? newClient!.longitude
                          : defaultLongitude,
                      "accuracy": 0.0,
                      "altitude": 0.0,
                      "speed": 0.0,
                      "speed_accuracy": 0.0,
                      "heading": 0.0,
                      "time": 0.0,
                      "isMock": false,
                      "verticalAccuracy": 0.0,
                      "headingAccuracy": 0.0,
                      "elapsedRealtimeNanos": 0.0,
                      "elapsedRealtimeUncertaintyNanos": 0.0,
                      "satelliteNumber": 1,
                      "provider": '',
                    });
                  });
                } else {
                  setState(() {
                    locationData = test;
                  });
                }
                await cityFromCoord();
              }
            }
          } else {
            _serviceEnabled = await location.serviceEnabled();
            if (!_serviceEnabled) {
              _serviceEnabled = await location.requestService();
              if (!_serviceEnabled) {
                setState(() {
                  notPermission = true;
                });
              } else {
                var test = await location.getLocation();
                if (test.latitude == null) {
                  setState(() {
                    locationData = LocationData.fromMap({
                      "latitude": newClient!= null && newClient!.lagitude != 0.0
                          ? newClient!.lagitude
                          : defaultLatitude,
                      "longitude": newClient!= null && newClient!.longitude != 0.0
                          ? newClient!.longitude
                          : defaultLongitude,
                      "accuracy": 0.0,
                      "altitude": 0.0,
                      "speed": 0.0,
                      "speed_accuracy": 0.0,
                      "heading": 0.0,
                      "time": 0.0,
                      "isMock": false,
                      "verticalAccuracy": 0.0,
                      "headingAccuracy": 0.0,
                      "elapsedRealtimeNanos": 0.0,
                      "elapsedRealtimeUncertaintyNanos": 0.0,
                      "satelliteNumber": 1,
                      "provider": '',
                    });
                    //finishedLoadPosition = true;
                  });
                  await cityFromCoord();
                } else {
                  setState(() {
                    locationData = test;
                    //finishedLoadPosition = true;
                  });
                  await cityFromCoord();
                }
              }
            } else {
              var test = await location.getLocation();
              if (test.latitude == null) {
                setState(() {
                  locationData = LocationData.fromMap({
                    "latitude": newClient!= null && newClient!.lagitude != 0.0
                        ? newClient!.lagitude
                        : defaultLatitude,
                    "longitude": newClient!= null && newClient!.longitude != 0.0
                        ? newClient!.longitude
                        : defaultLongitude,
                    "accuracy": 0.0,
                    "altitude": 0.0,
                    "speed": 0.0,
                    "speed_accuracy": 0.0,
                    "heading": 0.0,
                    "time": 0.0,
                    "isMock": false,
                    "verticalAccuracy": 0.0,
                    "headingAccuracy": 0.0,
                    "elapsedRealtimeNanos": 0.0,
                    "elapsedRealtimeUncertaintyNanos": 0.0,
                    "satelliteNumber": 1,
                    "provider": '',
                  });
                  //finishedLoadPosition = true;
                });
                await cityFromCoord();
              } else {
                setState(() {
                  locationData = test;
                  //finishedLoadPosition = true;
                });
                await cityFromCoord();
              }
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

          final resultPermission = await location.requestPermission();

          if (resultPermission != PermissionStatus.granted) {
            setState(() {
              notPermission = true;
            });
          } else {
            _serviceEnabled = await location.serviceEnabled();
            if (!_serviceEnabled) {
              _serviceEnabled = await location.requestService();
              if (!_serviceEnabled) {
                setState(() {
                  notPermission = true;
                });
              } else {
                var test = await location.getLocation();

                if (test.latitude == null) {
                  setState(() {
                    locationData = LocationData.fromMap({
                      "latitude": newClient!= null && newClient!.lagitude != 0.0
                          ? newClient!.lagitude
                          : defaultLatitude,
                      "longitude": newClient!= null && newClient!.longitude != 0.0
                          ? newClient!.longitude
                          : defaultLongitude,
                      "accuracy": 0.0,
                      "altitude": 0.0,
                      "speed": 0.0,
                      "speed_accuracy": 0.0,
                      "heading": 0.0,
                      "time": 0.0,
                      "isMock": false,
                      "verticalAccuracy": 0.0,
                      "headingAccuracy": 0.0,
                      "elapsedRealtimeNanos": 0.0,
                      "elapsedRealtimeUncertaintyNanos": 0.0,
                      "satelliteNumber": 1,
                      "provider": '',
                    });
                  });
                } else {
                  setState(() {
                    locationData = test;
                  });
                }
                await cityFromCoord();

              }
            } else {
              var test = await location.getLocation();

              if (test.latitude == null) {
                setState(() {
                  locationData = LocationData.fromMap({
                    "latitude": newClient!= null && newClient!.lagitude != 0.0
                        ? newClient!.lagitude
                        : defaultLatitude,
                    "longitude": newClient!= null && newClient!.longitude != 0.0
                        ? newClient!.longitude
                        : defaultLongitude,
                    "accuracy": 0.0,
                    "altitude": 0.0,
                    "speed": 0.0,
                    "speed_accuracy": 0.0,
                    "heading": 0.0,
                    "time": 0.0,
                    "isMock": false,
                    "verticalAccuracy": 0.0,
                    "headingAccuracy": 0.0,
                    "elapsedRealtimeNanos": 0.0,
                    "elapsedRealtimeUncertaintyNanos": 0.0,
                    "satelliteNumber": 1,
                    "provider": '',
                  });
                });

              } else {
                setState(() {
                  locationData = test;
                });
              }
              await cityFromCoord();
            }
          }
        } else {
          _serviceEnabled = await location.serviceEnabled();
          if (!_serviceEnabled) {
            _serviceEnabled = await location.requestService();
            if (!_serviceEnabled) {
              setState(() {
                notPermission = true;
              });
            } else {
              var test = await location.getLocation();
              if (test.latitude == null) {
                setState(() {
                  locationData = LocationData.fromMap({
                    "latitude": newClient!= null && newClient!.lagitude != 0.0
                        ? newClient!.lagitude
                        : defaultLatitude,
                    "longitude": newClient!= null && newClient!.longitude != 0.0
                        ? newClient!.longitude
                        : defaultLongitude,
                    "accuracy": 0.0,
                    "altitude": 0.0,
                    "speed": 0.0,
                    "speed_accuracy": 0.0,
                    "heading": 0.0,
                    "time": 0.0,
                    "isMock": false,
                    "verticalAccuracy": 0.0,
                    "headingAccuracy": 0.0,
                    "elapsedRealtimeNanos": 0.0,
                    "elapsedRealtimeUncertaintyNanos": 0.0,
                    "satelliteNumber": 1,
                    "provider": '',
                  });
                });
              } else {
                setState(() {
                  locationData = test;
                });
              }
              await cityFromCoord();
            }
          } else {
            var test = await location.getLocation();
            if (test.latitude == null) {
              setState(() {
                locationData = LocationData.fromMap({
                  "latitude": newClient!= null && newClient!.lagitude != 0.0
                      ? newClient!.lagitude
                      : defaultLatitude,
                  "longitude": newClient!= null && newClient!.longitude != 0.0
                      ? newClient!.longitude
                      : defaultLongitude,
                  "accuracy": 0.0,
                  "altitude": 0.0,
                  "speed": 0.0,
                  "speed_accuracy": 0.0,
                  "heading": 0.0,
                  "time": 0.0,
                  "isMock": false,
                  "verticalAccuracy": 0.0,
                  "headingAccuracy": 0.0,
                  "elapsedRealtimeNanos": 0.0,
                  "elapsedRealtimeUncertaintyNanos": 0.0,
                  "satelliteNumber": 1,
                  "provider": '',
                });
              });
            } else {
              setState(() {
                locationData = test;
              });

            }
            await cityFromCoord();
          }

        }
      } catch (e) {
        print("nous avons une erreur $e");
      }
    }
  }

  _addSourceAndLineLayer() async {
    final getItineraire = await consumeAPI.getItineraire(originChoice[0], originChoice[1], destinateChoice[0], destinateChoice[1]);
    // Add a polyLine between source and destination
    setState(() {
      distance = (getItineraire['distance']/1000);
      duration = getItineraire['duration'];
    });
    Map geometry = {
      "coordinates": getItineraire['coordinates'],
      "type": "LineString"
    };
    final _fills = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": 0,
          "properties": <String, dynamic>{},
          "geometry": geometry,
        },
      ]
    };

    // Remove lineLayer and source if it exists
      await controller.removeLayer("lines");
      await controller.removeSource("fills");

      await controller.removeLayer("times");
      await controller.removeSource("times");

    // Add new source and lineLayer
    await controller.addSource("fills", mapbox_gl.GeojsonSourceProperties(data: _fills));

    await controller.addLineLayer(
        "fills",
        "lines",
        mapbox_gl.LineLayerProperties(
            lineColor: colorText.toHexStringRGB(),
            lineCap: "round",
            lineJoin: "round",
            lineWidth: 5));

    await controller.addSymbolLayer(
      "times",
      "vehicles",
      mapbox_gl.SymbolLayerProperties(
        textField: "${getItineraire['distance']/1000} Km / ${formatedTime(seconds: getItineraire['duration'])}",
      ),
    );

    Map<String, dynamic> featureCollection = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": getItineraire['coordinates'][getItineraire['coordinates'].length - 1],
          }
        }
      ]
    };

    await controller.addGeoJsonSource("times", featureCollection);
    setState(() {
      showBottom = true;
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            setState(() {
              firstItemOpen = false;
              secondItemOpen = false;
            });
          });
        },
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: mapbox_gl.MapboxMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: _onMapCreated,
                  styleString: 'mapbox://styles/rochelryu/ckj3rq4ykbukh19rpata2eez3',
                  accessToken: "pk.eyJ1Ijoicm9jaGVscnl1IiwiYSI6ImNrMTkwbWkxMjAwM2UzZG9ka3hmejEybW0ifQ.9BIwdEGZfCz6MLIg8V6SIg",
                  //onStyleLoadedCallback: _onStyleLoadedCallback,
                  myLocationEnabled: true,
                  myLocationTrackingMode: mapbox_gl.MyLocationTrackingMode.TrackingGPS,
                  minMaxZoomPreference: const mapbox_gl.MinMaxZoomPreference(11, 20),
                ),)
              ],
            ),
            Positioned(
              bottom: 0,
                left: 1,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Container(
                    height: 45,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width*0.98,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(25.0)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                  "Voyagez de ville en ville ou deplacez vous à bas prix dans Abidjan 🤌",
                                  textStyle: Style.titre(12),
                                  speed: const Duration(milliseconds: 100)
                              ),
                            ],
                            totalRepeatCount: 1,
                            pause: const Duration(milliseconds: 1500),
                            displayFullTextOnTap: false,
                            stopPauseOnTap: true,
                          ),
                        )
                      ],
                    ),
                  ),
                )
            ),
            Positioned(
              bottom: 56,
                left: 10,
                child: GestureDetector(
                  onTap: () async {
                    await getPositionCurrent();
                  },
                  child: Card(
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle
                      ),
                      child: Center(child: Icon(Icons.location_searching, color: colorText,),),
                    ),
                  ),
                ),

            ),
            Positioned(
              bottom: 56,
              right: 10,
              child: GestureDetector(
                onTap: (){
                  if (isActivateCovoiturage) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => ChoiceTypeCreateTravel(key: UniqueKey())));
                  } else {
                    if (level == 0) {
                      setExplain(2, "covoiturage");
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (builder) =>
                              ExplicationTravel(key: UniqueKey(), typeRedirect: 1)));
                    } else {
                      Navigator.pushNamed(context, DemandeConducteur.rootName);
                    }
                  }
                },
                child: Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle
                    ),
                    child: Center(child: Icon(
                        isActivateCovoiturage ? Icons.add : MyFlutterAppSecond.driver,
                        color: colorText,
                        size: 22.0),),
                  ),
                ),
              ),

            ),
            //Ville ou point de depart
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
                                Icon(prefix1.MyFlutterAppSecond.pin,
                                color: colorText, size: 22.0),

                            Container(
                              padding: EdgeInsets.only(left: 10),
                              height: 30,
                              width: MediaQuery.of(context).size.width / 1.7,
                              child: TextField(
                                onTap: () {
                                  setState(() {
                                    secondItemOpen = false;
                                    showBottom = false;
                                    firstItemOpen = true;
                                  });
                                },
                                maxLines: 1,
                                controller: eCtrl,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w300),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Ville ou point de depart",
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey[800],
                                      fontSize: 12.0),
                                ),
                                onChanged: (text) async {
                                  setState(() {
                                    origine = text;
                                  });
                                  if(origine.length > 4) {
                                    final itemOriginServer = await consumeAPI.getAutoComplete(origine);
                                    setState(() {
                                      originItems = itemOriginServer;
                                    });
                                  }
                                },
                                onSubmitted: (text) async {
                                  setState(() {
                                    origine = text;
                                  });
                                  if(origine.length > 4) {
                                    final itemOriginServer = await consumeAPI.getAutoComplete(origine);
                                    setState(() {
                                      originItems = itemOriginServer;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )),
                  ),
                  SizedBox(height: 10.0),
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
                              Icon(prefix1.MyFlutterAppSecond.pin,
                                  color: Colors.redAccent, size: 22.0),
                              Container(
                                height: 30,
                                padding: EdgeInsets.only(left: 10),
                                width: MediaQuery.of(context).size.width / 1.7,
                                child: TextField(
                                  onTap: () {
                                    setState(() {
                                      secondItemOpen = false;
                                      showBottom = false;
                                      firstItemOpen = false;
                                    });
                                  },
                                  maxLines: 1,
                                  controller: eCtrl2,
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w300),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Ville ou point d'arrivé",
                                    hintStyle: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.grey[800],
                                        fontSize: 12.0),
                                  ),
                                  onChanged: (text) async {
                                    setState(() {
                                      destination = text;
                                    });
                                    if(text.length > 3) {
                                      final itemDestinationServer = await consumeAPI.getAutoComplete(destination);
                                      setState(() {
                                        destinateItmens = itemDestinationServer;
                                        firstItemOpen = false;
                                        secondItemOpen = true;
                                        showBottom = false;
                                      });

                                    }else {
                                      setState(() {
                                        firstItemOpen = false;
                                        showBottom = false;
                                        secondItemOpen = false;
                                      });
                                    }
                                  },
                                  onSubmitted: (text) async {
                                    setState(() {
                                      destination = text;
                                    });
                                    if(text.length > 3) {
                                      final itemDestinationServer = await consumeAPI.getAutoComplete(destination);
                                      setState(() {
                                        destinateItmens = itemDestinationServer;
                                        firstItemOpen = false;
                                        secondItemOpen = true;
                                        showBottom = false;
                                      });

                                    }else {
                                      setState(() {
                                        firstItemOpen = false;
                                        showBottom = false;
                                        secondItemOpen = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          )),
                    ),
                ],
              ),
            ),
            if(firstItemOpen) Positioned(
                top: 46.0,
                right: 32.0,
                left: 32.0,
                height: 200,
                child: Card(
                  child: ListView.builder(
                      itemCount: originItems.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            onTap: () async {
                              setState(() {
                                firstItemOpen = false;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                              eCtrl.text = "Position actuelle";
                              /*await controller.addSymbolLayer(
                              "scooter25_layer",
                              "vehicles",
                              const mapbox_gl.SymbolLayerProperties(
                              iconImage: "images/marqueur_begin.png",
                              iconAllowOverlap: true,
                              ),
                              );*/
                              if(locationData != null) {
                                await controller.addSymbol(
                                  mapbox_gl.SymbolOptions(
                                    geometry: mapbox_gl.LatLng(locationData!.latitude!, locationData!.longitude!),
                                    iconImage: "images/marqueur_begin.png",
                                    iconSize: 0.3,
                                  ),
                                );
                                originChoice = [locationData!.longitude!, locationData!.latitude!];
                              }
                              await getPositionCurrent();
                              originChoice = [locationData!.longitude!, locationData!.latitude!];


                            },
                            leading: Icon(Icons.location_searching, color: colorText, size: 20,),
                            title: Text("Choisir ma position actuelle", style: Style.simpleTextOnBoard(14)),
                          );
                        } else {
                          return ListTile(
                            onTap: () async {
                              setState(() {
                                firstItemOpen = false;
                              });
                              eCtrl.text = originItems[index-1]['title'].trim();
                              originChoice = [originItems[index-1]['longitude'], originItems[index-1]['latitude']];
                              FocusScope.of(context).requestFocus(FocusNode());
                              controller.animateCamera(
                                  mapbox_gl.CameraUpdate.newCameraPosition(mapbox_gl.CameraPosition(target: mapbox_gl.LatLng(originItems[index-1]['latitude'], originItems[index-1]['longitude']), zoom: 15)));
                              controller.addSymbol(
                                mapbox_gl.SymbolOptions(
                                  geometry: mapbox_gl.LatLng(originItems[index-1]['latitude'], originItems[index-1]['longitude']),
                                  iconImage: "images/marqueur_begin.png",
                                  iconSize: 0.3,

                                ),
                              );
                              //await _addSourceAndLineLayer();
                            },
                            leading: Icon(Icons.local_library_outlined, color: colorError, size: 20,),
                            title: Text(originItems[index-1]['title'].trim(), style: Style.simpleTextOnBoard(14, colorBlack)),
                            subtitle: Text(originItems[index-1]['info'].trim(), style: Style.simpleTextOnBoard(12)),
                          );
                        }
                      }
                  ),
                )
            ),
            if(secondItemOpen) Positioned(
                top: 106.0,
                right: 32.0,
                left: 32.0,
                height: 200,
                child: Card(
                  child: ListView.builder(
                      itemCount: destinateItmens.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () async {
                            setState(() {
                              secondItemOpen = false;
                            });
                            eCtrl2.text = destinateItmens[index]['title'].trim();
                            destinateChoice = [destinateItmens[index]['longitude'], destinateItmens[index]['latitude']];
                            FocusScope.of(context).requestFocus(FocusNode());
                            controller.animateCamera(
                                mapbox_gl.CameraUpdate.newCameraPosition(mapbox_gl.CameraPosition(target: mapbox_gl.LatLng(destinateItmens[index]['latitude'], destinateItmens[index]['longitude']), zoom: 15)));
                            controller.addSymbol(
                              mapbox_gl.SymbolOptions(
                                geometry: mapbox_gl.LatLng(destinateItmens[index]['latitude'], destinateItmens[index]['longitude']),
                                iconImage: "images/marqueur_end.png",
                                iconSize: 0.3,

                              ),
                            );
                            await _addSourceAndLineLayer();
                          },
                          leading: Icon(Icons.local_library_outlined, color: colorError, size: 20,),
                          title: Text(destinateItmens[index]['title'].trim(), style: Style.simpleTextOnBoard(14, colorBlack)),
                          subtitle: Text(destinateItmens[index]['info'].trim(), style: Style.simpleTextOnBoard(12)),
                        );
                      }
                  ),
                )),
            if(showBottom) Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 500,
                child: displayDraggableScrollableSheet()
            )
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        elevation: 20.0,
        onPressed: () {
        covoiturage = consumeAPI.getCovoiturage(origine, destination);
          if (isActivateCovoiturage) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) => CreateTravel(key: UniqueKey())));
          } else {
            if (level == 0) {
              setExplain(2, "covoiturage");
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) =>
                      ExplicationTravel(key: UniqueKey(), typeRedirect: 1)));
            } else {
              Navigator.pushNamed(context, DemandeConducteur.rootName);
            }
          }
        },
        backgroundColor: colorText,
        tooltip:
            isActivateCovoiturage ? "Créer un voyage" : "Faire une demande con",
        child: Icon(
            isActivateCovoiturage ? Icons.add : MyFlutterAppSecond.driver,
            color: Colors.white,
            size: 22.0),
      ),*/
    );
  }

  Widget displayDraggableScrollableSheet() {
    return DraggableScrollableSheet(builder: (_, controller) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.96),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              child: TabBar(
                controller: _controller,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: colorText,
                tabs: [
                  Tab(
                    text: 'COURSE',
                  ),
                  Tab(
                    text: 'LIVRAISON',
                  ),
                  Tab(
                    text: 'VOYAGE',
                  ),
                ],
              ),
            ),
              Expanded(
                child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  Column(
                    children: [
                      SizedBox(height: 5,),
                      Container(
                        decoration: BoxDecoration(
                          color: selectMutualise ? backgroundColorSec: Colors.transparent
                        ),
                        child: ListTile(
                          leading: Container(
                              padding: EdgeInsets.only(left: 5),
                              child: Image.asset("images/taxi.png", fit: BoxFit.cover,)),
                          title: Text("Mutualisé", style: Style.titre(15),),
                          subtitle: Text("Embarqué avec d'autres personnes. Max 3 places.", style: Style.simpleTextOnBoard(13),),
                          trailing: Container(
                            padding: EdgeInsets.only(right: 5),
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(priceMutualise(place, distance), style: Style.titre(20),),
                                Text("XOF", style: Style.titre(8),)
                              ],
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          onTap: (){
                            setState(() {
                              selectMutualise = true;
                              selectConfort = false;
                            });

                          },
                        ),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        decoration: BoxDecoration(
                            color: selectConfort ? backgroundColorSec: Colors.transparent
                        ),
                        child: ListTile(
                          leading: Container(
                              padding: EdgeInsets.only(left: 5),
                              child: Image.asset("images/car.png", fit: BoxFit.cover,)),
                          title: Text("Confort", style: Style.titre(15),),
                          subtitle: Text("Mettez-vous à l'aise dans un vehicule de confort.", style: Style.simpleTextOnBoard(13),),
                          trailing: Container(
                            padding: EdgeInsets.only(right: 5),
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(priceConfort(distance), style: Style.titre(20),),
                                Text("XOF", style: Style.titre(8),)
                              ],
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          onTap: (){
                            setState(() {
                              selectMutualise = false;
                              selectConfort = true;
                            });

                          },
                        ),
                      ),
                      SizedBox(height: 5,),
                      if(selectMutualise) Expanded(
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 5),
                              Text("Nbre de place:", style: Style.simpleTextBlack(),),
                              SizedBox(width: 5),
                              Container(
                                width:110,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.do_not_disturb_on, color: colorText),
                                      onPressed: () {
                                        var normal = (place > 1) ? place - 1 : 1;
                                        setState(() {
                                          place = normal;
                                        });

                                      },
                                    ),
                                    Text(place.toString(), style: Style.titre(15)),
                                    IconButton(
                                      icon: Icon(Icons.add_circle, color: colorText),
                                      onPressed: () {
                                        final normal =
                                        (place > 2) ? 3 : place + 1;
                                        setState(() {
                                          place = normal;
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () {

                                },
                                child: Text('COMMANDER'),
                                style: raisedButtonStyle,
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                      ),
                      if(selectConfort) ElevatedButton(
                        onPressed: () {

                        },
                        child: Text('COMMANDER'),
                        style: raisedButtonStyle,
                      )

                    ],
                  ),
                  Text("Livraison"),
                  Text("Voyage"),
                ]
                )
              )
          ],
        ),
      );
    });
  }

  _onMapCreated(mapbox_gl.MapboxMapController controller) async {
    this.controller = controller;
  }
}
