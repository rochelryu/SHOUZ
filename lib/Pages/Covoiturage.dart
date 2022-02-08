import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location_request.dart';
import 'package:huawei_location/location/location_settings_request.dart';
import 'package:huawei_location/location/location_settings_states.dart';
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import './CovoiturageChoicePlace.dart';
import 'package:huawei_location/location/location.dart' as loactionHuawei;

import 'package:speech_to_text/speech_to_text.dart';


import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:async';

import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart' as prefix1;
import 'dart:io';

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
  bool meac1 = true;
  bool meac2 = true;
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


  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  bool trueLoad = true;

  String transcription = '';

  //String _currentLocale = 'en_US';
  Language selectedLang = languages.first;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    location = new Location();
    internetCheck();
    getPositionCurrent();
    //activateSpeechRecognizer();

    _initSpeech();
  }

  void internetCheck() async{
    User user = await DBProvider.db.getClient();

    setState(() {
      newClient = user;

    });
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      showDialog(
                            context: context,
                            builder: (BuildContext context) => DialogCustomError('Echec', 'Veuillez Verifier votre connexion internet', context),
                            barrierDismissible: false
                          );
    }
  }

  getPositionCurrent() async {
    if(Platform.isAndroid){
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if(androidInfo.brand.indexOf('HUAWEI') != - 1 || androidInfo.brand.indexOf('HONOR') != - 1) {
        try {
          bool status = await permissionHandler.requestLocationPermission();
          print('status');
          print(status);
          LocationSettingsRequest locationSettingsRequest = LocationSettingsRequest(
            requests: <LocationRequest>[locationRequest],
            needBle: true,
            alwaysShow: true,
          );
          LocationSettingsStates states =
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
            finishedLoadPosition = true;
          });
          print("locationData Huawei");
          print(locationData!.toString());
        } catch (e) {
          print(e);
        }
      } else {
        try {
          _permissionGranted = await location.hasPermission();
          if (_permissionGranted == PermissionStatus.denied) {
            _permissionGranted = await location.requestPermission();
            if (_permissionGranted != PermissionStatus.granted) {
              return;
            } else {
              _serviceEnabled = await location.serviceEnabled();
              if (!_serviceEnabled) {
                _serviceEnabled = await location.requestService();
                if (!_serviceEnabled) {
                  return;
                }
              }
              var test = await location.getLocation();
              setState(() {
                locationData = test;
                finishedLoadPosition = true;
              });

            }
          } else {
            _serviceEnabled = await location.serviceEnabled();
            if (!_serviceEnabled) {
              _serviceEnabled = await location.requestService();
              if (!_serviceEnabled) {
                return;
              }
            }
            var test = await location.getLocation();
            setState(() {
              locationData = test;
              finishedLoadPosition = true;
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
            return;
          } else {
            _serviceEnabled = await location.serviceEnabled();
            if (!_serviceEnabled) {
              _serviceEnabled = await location.requestService();
              if (!_serviceEnabled) {
                return;
              }
            }
            var test = await location.getLocation();
            setState(() {
              locationData = test;
              finishedLoadPosition = true;
            });

          }
        } else {
          _serviceEnabled = await location.serviceEnabled();
          if (!_serviceEnabled) {
            _serviceEnabled = await location.requestService();
            if (!_serviceEnabled) {
              return;
            }
          }
          var test = await location.getLocation();
          setState(() {
            locationData = test;
            finishedLoadPosition = true;
          });
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
    List<geocoding.Location> addresses = await geocoding.locationFromAddress(origine);
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
    List<geocoding.Location> addresses = await geocoding.locationFromAddress(destination);
    if(addresses.length > 0){
      geocoding.Location address = addresses.first;
      if(global.length > 0){
        setState(() {
          global[0] = new LatLng(address.latitude, address.longitude);
          eCtrl2.text = destination;
          load1 = false;
          ori = true;
        });
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
          !finishedLoadPosition ? Center(child: LoadingIndicator(indicatorType: Indicator.ballScale,colors: [colorText], strokeWidth: 2)): mapping(context,locationData!.latitude!,locationData!.longitude!),
        ],
      ),
    );
  }

  Widget DialogCustomError(String title, String message, BuildContext context) {
  bool isIos = Platform.isIOS;
  return isIos ? 
  new CupertinoAlertDialog(
    title: Text(title),
    content: Text(message),
    actions: <Widget>[
      CupertinoDialogAction(child: Text("Ok"),
       onPressed: () {
              Navigator.of(context).pop();
            }
      )
    ],
  )
  : new AlertDialog(
    title: Text(title),
    content: Text(message),
    elevation: 20.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0)
    ),
    actions: <Widget>[
      FlatButton(
        child: Text("Ok"),
        onPressed: () {
              Navigator.of(context).pop();
            }
            )
    ],

  );
}


  mapping(BuildContext context, double latitude, double longitude){
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new FlutterMap(
            options: new MapOptions(
                center: LatLng(latitude, longitude),
                minZoom: 4.0,
              zoom: 7.0,
            ),
            layers: [
              new TileLayerOptions(
                  urlTemplate:
                  "https://api.mapbox.com/styles/v1/rochelryu/ck1piq46n2i5y1cpdlmq6e8e2/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoicm9jaGVscnl1IiwiYSI6ImNrMTkwbWkxMjAwM2UzZG9ka3hmejEybW0ifQ.9BIwdEGZfCz6MLIg8V6SIg",
                  additionalOptions: {
                    'accessToken': 'pk.eyJ1Ijoicm9jaGVscnl1IiwiYSI6ImNrMTkwbWkxMjAwM2UzZG9ka3hmejEybW0ifQ.9BIwdEGZfCz6MLIg8V6SIg',
                    'id': 'mapbox.mapbox-streets-v8'
                  },
                attributionBuilder: (_) {
                  return Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text("© ICORE MAP", style: Style.copyRight(),),
                      )
                    ],
                  );
                },
              ),
              new MarkerLayerOptions(markers: [
                new Marker(
                    width: 45.0,
                    height: 45.0,
                    point: LatLng(latitude, longitude),
                    builder: (context) => new Container(
                      child: Icon(Icons.location_on, color: colorText, size: 45.0),
                    ))
              ]),

              new PolylineLayerOptions(
                polylines: [
                  new Polyline(
                    points: global,
                    strokeWidth: 5.0,
                    isDotted: true,
                    color: colorText,
                  )
                ]
              )
            ]
        ),
        Positioned(
          bottom: 36.0,
          right: 22.0,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50.0)
            ),
            child: Center(
              child: IconButton(
                icon: (global.length != 2) ? Icon(Icons.my_location, color: backgroundColor, size: 25.0,):  Icon(prefix1.MyFlutterAppSecond.checked, color: backgroundColor, size: 25.0,),
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
                                            return Column(
                                              children: <Widget>[
                                                Expanded(child: Padding(
                                                    padding: EdgeInsets.all(30),
                                                    child: Center(
                                                      child: Text("${snapshot.error}", style: Style.sousTitreEvent(15))
                                                      )
                                                    )
                                                  )
                                              ]
                                            );
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
                                        print(ident);
                                        Navigator.of(context).push((
                                            MaterialPageRoute(
                                                builder: (builder)=> CovoiturageChoicePlace(
                                                  ident['id'],
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
                                                height: 130,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      (!load1) ? Icon(prefix1.MyFlutterAppSecond.pin, color: colorText, size: 22.0):CircularProgressIndicator(value: null, strokeWidth: 1.0,),
                      Container(
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
                      InkWell(
                        child: (!_isListening && _speechEnabled && meac1) ? Icon(Icons.mic, color: Colors.black87, size: 25.0) : Icon(Icons.stop, color: Colors.black87, size: 25.0),
                        onTap: (){
                          if(!_isListening && _speechEnabled) {
                            setState(() {
                              meac1 = false;
                            });
                            _startListening();
                          }
                          else if(_isListening){
                            setState(() {
                              meac1 = true;
                            });
                            _stopListening();

                          }
                        },
                      )
                    ],
                  )
                ),
              ),
              SizedBox(height: 10.0),
                (ori)? Card(
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5.0,
                  child: Container(
                      height: 38,
                      padding: EdgeInsets.all(5.0),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          (!load1) ? Icon(prefix1.MyFlutterAppSecond.pin, color: Colors.redAccent, size: 22.0):CircularProgressIndicator(value: null, strokeWidth: 1.0,),
                          Container(
                            height: 30,
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
                          InkWell(
                            child: (!_isListening && _speechEnabled && meac2) ? Icon(Icons.mic, color: Colors.black87, size: 25.0) : Icon(Icons.stop, color: Colors.black87, size: 25.0),
                            onTap: (){
                              if(!_isListening && _speechEnabled) {
                                setState(() {
                                  meac2 = false;
                                });
                                _startListening();
                              }
                              else if(_isListening){
                                setState(() {
                                  meac2 = true;
                                });
                                _stopListening();
                              }
                            },
                          )
                        ],
                      )
                  ),
                ):SizedBox(height: 10.0),
              /*TextField(
                    controller: eCtrl,
                    autofocus: true,
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(icon: Icon(Icons.mic, color: Colors.black87, size: 32.0), onPressed: (){
                        print("Origine");
                      }),
                      hintText: "Point de départ",
                      hintStyle: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey[500], fontSize: 13.0),
                    ),
                    onChanged: (text){
                      setState(() {
                        origine = text;
                      });
                    },
                  ),*/


            ],
          ),
        ),
      ],
    );
  }

  void _selectLangHandler(Language lang) {
    setState(() => selectedLang = lang);
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isListening = true;
    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {

    if(!ori){
      setState((){
        destination = result.recognizedWords;
      });
      eCtrl2.text = destination;
    }
    else{
      setState(() {
        origine = result.recognizedWords;
      });
      eCtrl.text = origine;
    }
  }



  /*void activateSpeechRecognizer() {
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(
            (bool result) => setState(() => _speechRecognitionAvailable = result)
    );
    _speech.setRecognitionStartedHandler(() => setState(() => _isListening = true));
    _speech.setRecognitionResultHandler((String text) {
      if(!ori){
        setState((){
          destination = text;
        });
        eCtrl2.text = destination;
      }
      else{
        setState(() {
          origine = text;
        });
        eCtrl.text = origine;
      }
    });

    //_speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionCompleteHandler(() {
      setState(() => _isListening = false);
      if(!ori){
        coordFromCity();
      }
      else{
        coordFromCityTwo();
      }
    });
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  void start() => _speech
      .listen(locale: selectedLang.code)
      .then((result) => print('_MyAppState.start => result $result'));

  void cancel() =>
      _speech.cancel().then((result) => setState(() => _isListening = result));

  void stop() => _speech.stop().then((result) {
    setState(() => _isListening = result);
  });

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    setState(
            () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) => setState(() => transcription = text);

  void onRecognitionComplete() => setState(() => _isListening = false);

  void errorHandler() => activateSpeechRecognizer();*/
}




/*Center(
            child: Text(
                'Latitude ${locationData.latitude} & Longitude ${locationData.longitude} speed ${locationData.speed} hashCode ${locationData.hashCode} times ${locationData.time} accu ${locationData.speedAccuracy} ', textAlign: TextAlign.center, style: Style.location(),
            )*/