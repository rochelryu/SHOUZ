import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:huawei_location/huawei_location.dart' as huawei_location;
import 'package:geocoding/geocoding.dart' as geocoding;
import '../Constant/Style.dart';
import '../Constant/helper.dart';
import '../Constant/widget_common.dart';
import '../Models/User.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import '../Utils/Database.dart';
import 'Login.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class VtcDriverHome extends StatefulWidget {
  const VtcDriverHome({required Key key}) : super(key: key);

  @override
  _VtcDriverHomeState createState() => _VtcDriverHomeState();
}

class _VtcDriverHomeState extends State<VtcDriverHome> {
  late CameraPosition _initialCameraPosition;
  late MapboxMapController controller;
  late Location location;
  LocationData? locationData;
  double centerPositionLongitude = defaultLongitude;
  double centerPositionLatitude = defaultLatitude;
  bool notPermission = false;
  User? newClient;

  late PermissionStatus _permissionGranted;
  late Stream<LocationData> stream;
  late bool _serviceEnabled;

  bool available = false;

  ConsumeAPI consumeAPI = ConsumeAPI();

  @override
  void initState() {
    super.initState();
    location = Location();
    _initialCameraPosition = CameraPosition(target: LatLng(centerPositionLatitude, centerPositionLongitude), zoom: 15);
    //verifyIfUserHaveReadModalExplain();
    getPositionCurrent();
  }

  void internetCheck() async {
    User user = await DBProvider.db.getClient();

    if(user.numero != 'null') {
      setState(() {
        newClient = user;
        centerPositionLongitude = user.longitude!;
        centerPositionLatitude = user.lagitude!;
      });

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
            await repositioningCamera();
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
                  await repositioningCamera();
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
                await repositioningCamera();
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
                  await repositioningCamera();
                } else {
                  setState(() {
                    locationData = test;
                    //finishedLoadPosition = true;
                  });
                  await repositioningCamera();
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
                await repositioningCamera();
              } else {
                setState(() {
                  locationData = test;
                  //finishedLoadPosition = true;
                });
                await repositioningCamera();
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
                await repositioningCamera();

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
              await repositioningCamera();
            }
          }
        } else {
          print('permission accordé');
          _serviceEnabled = await location.serviceEnabled();
          print('_serviceEnabled $_serviceEnabled');
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
              await repositioningCamera();
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
            await repositioningCamera();
          }

        }
      } catch (e) {
        print("nous avons une erreur $e");
      }
    }
  }

  repositioningCamera() async {
    try{

      setState(() {
        centerPositionLongitude = locationData!.longitude!;
        centerPositionLatitude = locationData!.latitude!;
      });
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(locationData!.latitude!, locationData!.longitude!), zoom: 14)));
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

  _onMapCreated(MapboxMapController controller) async {
    this.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: MapboxMap(
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: _onMapCreated,
              styleString: 'mapbox://styles/rochelryu/clc6d61lx000q14o87fakmyrp',
              accessToken: "pk.eyJ1Ijoicm9jaGVscnl1IiwiYSI6ImNrMTkwbWkxMjAwM2UzZG9ka3hmejEybW0ifQ.9BIwdEGZfCz6MLIg8V6SIg",
              //onStyleLoadedCallback: _onStyleLoadedCallback,
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
              minMaxZoomPreference: const MinMaxZoomPreference(11, 17),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10.0, top: 60),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: LinearGradient(
                      colors: [Color(0x00000000), tint],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 22.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

            ],
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 700,
              child: displayDraggableScrollableSheet()
          )
        ],
      ),
    );
  }

  Widget displayDraggableScrollableSheet() {
    return DraggableScrollableSheet(builder: (_, controller) {
      return Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: colorSecondary.withOpacity(0.8),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Disponibilité", style: Style.grandTitreBlack(19),),
                  customSwitch(available, (){
                    setState(() {
                      available = !available;
                    });
                  }),
                ],
              ),
            ),
            Text("Commandes :", style: Style.grandTitreBlack(14),),
            SizedBox(height: 15),
            Slidable(
              key: UniqueKey(),
              startActionPane: ActionPane(
                // A motion is a widget used to control how the pane animates.
                motion: const DrawerMotion(),

                // All actions are defined in the children parameter.
                children: [
                  SlidableAction(
                    onPressed: (context) async {

                    },
                    backgroundColor: colorError,
                    foregroundColor: Colors.white,
                    icon: Icons.stop_circle,
                    label: 'Annuler',
                  ),
                  SlidableAction(
                    onPressed: (context) async {

                    },
                    backgroundColor: colorText,
                    foregroundColor: colorPrimary,
                    icon: Icons.check_circle_outline,
                    label: 'Accepter',
                  ),


                ],
              ),

              // The end action pane is the one at the right or the bottom side.
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    // An action can be bigger than the others.
                    onPressed: (context) async {

                    },
                    backgroundColor: colorWarning,
                    foregroundColor: colorWarning,
                    icon: Icons.call,
                    label: 'Appeler',
                  ),
                  SlidableAction(
                    onPressed: (context) async {

                    },
                    backgroundColor: colorText,
                    foregroundColor: colorSuccess,
                    icon: Icons.location_on_outlined,
                    label: 'Arriver',
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30.0,
                  backgroundImage:
                  NetworkImage("https://img.freepik.com/photos-gratuite/portrait-femme-affaires-aide-son-telephone-mobile-chemin-du-travail-dans-voiture-concept-entreprise_58466-14412.jpg"),
                  backgroundColor: Colors.transparent,
                ),
                title: Text("Une place prise", style: Style.grandTitreBlack(15),),
                subtitle: Text("Angré Nouveau CHU", style: Style.simpleTextOnBoardWithBolder(12)),
                trailing: Container(
                  padding: EdgeInsets.only(right: 5),
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("700", style: Style.titre(20),),
                      Text("XOF", style: Style.titre(8),)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
