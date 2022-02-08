import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shouz/Constant/Painture.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Pages/ChoiceHobie.dart';
import 'package:shouz/Utils/Database.dart';

import '../Constant/my_flutter_app_second_icons.dart' as prefix1;

class CreateProfil extends StatefulWidget {
  static String rootName = '/createProfil';

  @override
  _CreateProfil createState() => _CreateProfil();
}

class _CreateProfil extends State<CreateProfil> {
  String value = '';
  String? base64Image;
  final picker = ImagePicker();
  File? tmpFile;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getImage(BuildContext context) async {
    var image = await picker.getImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profil = {"type": 2, "data": File(image.path)};
      });
      Navigator.pop(context);
      setState(() {
        tmpFile = File(image.path);
        base64Image = base64Encode(File(image.path).readAsBytesSync());
      });
    }
  }

  Future getCamera(BuildContext context) async {
    var image = await picker.getImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        profil = {"type": 2, "data": File(image.path)};
      });
      Navigator.pop(context);
      setState(() {
        tmpFile = File(image.path);
        base64Image = base64Encode(File(image.path).readAsBytesSync());
      });
    }
  }

  Map profil = {"type": 1, "data": "images/boss.png"};

  double heigth = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    heigth = MediaQuery.of(context).size.height / 5.8;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: prefix0.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (value.length >= 5) {
            setState(() {
              heigth = 0;
            });
            final name = await DBProvider.db.updateName(value);
            print(name);
            if (tmpFile == null) {
              final fileName = profil["data"];
              final profils = await DBProvider.db.newProfil(fileName, '');
              print(profils);
            } else {
              final fileName = tmpFile?.path.split('/').last;
              final profils =
                  await DBProvider.db.newProfil(fileName!, base64Image!);
              print(profils);
            }
            prefix0.setLevel(4);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (builder) => ChoiceHobie()));
          } else
            _displaySnackBar(context);
        },
        disabledElevation: 0.0,
        backgroundColor: prefix0.colorText,
        child: Icon(Icons.arrow_forward, color: Colors.white),
      ),
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Stack(children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: heigth,
              child: Painture(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 210,
                  width: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)),
                          elevation: 6.0,
                          color: Colors.transparent,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                    image: ChoiceType(
                                        profil["type"], profil["data"]),
                                    fit: BoxFit.cover)),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  bottom: 8,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          elevation: 10.0,
                                          builder: (builder) {
                                            return new Container(
                                                height: 200,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15),
                                                decoration: BoxDecoration(
                                                    color:
                                                        prefix0.backgroundColor,
                                                    borderRadius:
                                                        BorderRadius.circular(7)
                                                    //borderRadius: BorderRadius.only(topRight: Radius.circular(30.0), topLeft: Radius.circular(30.0))
                                                    ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 15),
                                                        child: Text(
                                                            "Photo de profil",
                                                            style: prefix0.Style
                                                                .titleInSegment())),
                                                    Divider(
                                                        color: Colors.white12),
                                                    Expanded(
                                                      child: Container(
                                                        height: double.infinity,
                                                        width: double.infinity,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            IconButton(
                                                              onPressed: () {
                                                                getCamera(
                                                                    context);
                                                              },
                                                              icon: Icon(
                                                                  Icons
                                                                      .camera_alt,
                                                                  color: prefix0
                                                                      .colorText,
                                                                  size: 40),
                                                              tooltip:
                                                                  "Prendre une Photo",
                                                            ),
                                                            SizedBox(width: 50),
                                                            IconButton(
                                                              onPressed: () {
                                                                getImage(
                                                                    context);
                                                              },
                                                              icon: Icon(
                                                                  prefix1
                                                                      .MyFlutterAppSecond
                                                                      .attach,
                                                                  color: prefix0
                                                                      .colorText,
                                                                  size: 40),
                                                              tooltip:
                                                                  "Choisir une Photo",
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                        color: Colors.white12),
                                                    FlatButton(
                                                      child: Text("Retour",
                                                          style: prefix0.Style
                                                              .sousTitre(12)),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                ));
                                          });
                                    },
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: new Color.fromRGBO(2, 136, 209,
                                              0.5) // Specifies the background color and the opacity
                                          ),
                                      child: Center(
                                        child: Icon(Icons.camera,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('SHOUZ', style: prefix0.Style.titre(24)),
                        Text('vous souhaite la bienvenue',
                            style: prefix0.Style.sousTitreWelcome(15)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 35),
                Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    child: Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 15.0, top: 2.0),
                        width: MediaQuery.of(context).size.width,
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.person_outline,
                                color: Colors.grey[500]),
                            hintText: "Votre nom et prénoms",
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.grey[500],
                                fontSize: 15.0),
                          ),
                          onChanged: (text) {
                            setState(() {
                              value = text;
                            });
                          },
                        ),
                      ),
                    )),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  ChoiceType(type, data) {
    if (type == 1) {
      return new AssetImage(data);
    } else {
      return new FileImage(data);
    }
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(
        backgroundColor: prefix0.backgroundColorSec,
        content: Row(
          children: <Widget>[
            Icon(Icons.mood_bad),
            SizedBox(width: 3.0),
            Text('Votre nom et prénoms doivent depasser 4 caractères'),
          ],
        ));
    _scaffoldKey.currentState?.showSnackBar(snackBar);
  }
}
