import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/Painture.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Constant/helper.dart';
import 'package:shouz/Utils/Database.dart';

import '../Constant/my_flutter_app_second_icons.dart' as prefix1;
import '../Constant/widget_common.dart';
import '../MenuDrawler.dart';
import '../ServicesWorker/ConsumeAPI.dart';

class CreateProfil extends StatefulWidget {
  static String rootName = '/createProfil';

  @override
  _CreateProfil createState() => _CreateProfil();
}

class _CreateProfil extends State<CreateProfil> {
  String value = '';
  String codeParrain = '';
  Map<String, dynamic> profilParrain = {"images": '', 'name': ''};
  bool error = false;
  String base64Image = "";
  final picker = ImagePicker();
  File? tmpFile;
  TextEditingController _controllerParrain = new TextEditingController();
  bool changeLoading = false;

  Future getImage(BuildContext context) async {
    var image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profil = {"type": 2, "data": File(image.path)};
      });
      base64Image = base64Encode(File(image.path).readAsBytesSync());
      tmpFile = File(image.path);
      Navigator.pop(context);
    }
  }

  Future getCamera(BuildContext context) async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        profil = {"type": 2, "data": File(image.path)};
      });
      base64Image = base64Encode(File(image.path).readAsBytesSync());
      tmpFile = File(image.path);
      Navigator.pop(context);
    }
  }

  Map profil = {"type": 1, "data": "images/boss.png"};

  double heigth = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInfo();
  }

  loadInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final codeSponsorSave = await prefs.getString("codeSponsor") ?? "";
    setState(() {
      codeParrain = codeSponsorSave;
      if(codeSponsorSave.length == 6) {
        _controllerParrain.text = codeSponsorSave;
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    heigth = MediaQuery.of(context).size.height / 5.8;
    return Scaffold(
      backgroundColor: prefix0.backgroundColor,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () async {
          if (value.length >= 5) {

            await DBProvider.db.updateName(value);
            if (tmpFile == null) {
              await showDialog(
                  context: context,
                  builder: (BuildContext context) => dialogCustomForNotChangeProfil(
                      "Aucune photo de profil",
                      "Vous n'avez pas choisi d'image de profil pour votre compte.\nVoulez vous vraiment continuer sans cela ?",
                      "Oui",
                          () async {
                            setState(() {
                              heigth = 0;
                              changeLoading = true;
                            });
                            final fileName = "images/boss.png";
                            final signinUser = await consumeAPI.signinSecondStep(fileName, '', [], codeParrain);
                            if (signinUser['etat'] == 'found') {
                              await DBProvider.db.delClient();
                              await DBProvider.db.newClient(signinUser['user']);
                              await DBProvider.db.delProfil();
                              prefix0.setLevel(5);
                              setState(() {
                                changeLoading = false;
                              });
                              Navigator.of(context).pushNamedAndRemoveUntil(MenuDrawler.rootName, (Route<dynamic> route) => false);
                            } else {
                              Navigator.pop(context);
                              setState(() {
                                changeLoading = false;
                              });
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      dialogCustomError(
                                          'Echec',
                                          'Veuillez ressayer ulterieurement',
                                          context),
                                  barrierDismissible: false);
                            }

                      }, context, true, "Non"),
                  barrierDismissible: false);

            } else {
              setState(() {
                heigth = 0;
                changeLoading = true;
              });
              final fileName = tmpFile?.path.split('/').last;
              final signinUser = await consumeAPI.signinSecondStep(fileName, base64Image, [], codeParrain);
              if (signinUser['etat'] == 'found') {
                await DBProvider.db.delClient();
                await DBProvider.db.newClient(signinUser['user']);
                await DBProvider.db.delProfil();
                prefix0.setLevel(5);
                setState(() {
                  changeLoading = false;
                });
                Navigator.of(context).pushNamedAndRemoveUntil(MenuDrawler.rootName, (Route<dynamic> route) => false);
              } else {
                setState(() {
                  changeLoading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        dialogCustomError(
                            'Echec',
                            'Veuillez ressayer ulterieurement',
                            context),
                    barrierDismissible: false);
              }
            }

          } else
            _displaySnackBar(context);
        },
        disabledElevation: 0.0,
        backgroundColor: prefix0.colorText,
        child: changeLoading ? LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [prefix0.colorPrimary], strokeWidth: 2) : Icon(Icons.arrow_forward, color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
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
                                    image: choiceType(
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
                                            return Container(
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
                                                                  Icons.camera,
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
                                                    TextButton(
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
                                          color: const Color.fromRGBO(2, 136, 209,
                                              0.5) // Specifies the background color and the opacity
                                          ),
                                      child: Center(
                                        child: Icon(Icons.camera_alt,
                                            color: Colors.white, size: 20,),
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
                    height: 70,
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
                SizedBox(height: 15),
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
                          controller: _controllerParrain,
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.local_activity_outlined,
                                color: Colors.grey[500]),
                            hintText: "Code promo (facultatif)",
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.grey[500],
                                fontSize: 15.0),
                          ),
                          onChanged: (text) async {
                            setState(() {
                              codeParrain = text;
                            });
                            if(text.trim().length == 6) {
                              final verifyCodeParrain = await consumeAPI.verifyCodeParrain(text);
                              if(verifyCodeParrain['etat'] == 'found'){
                                setState(() {
                                  error = false;
                                  profilParrain = verifyCodeParrain['result'];
                                });
                              }else {
                                setState(() {
                                  error = true;
                                  profilParrain = {"images": '', 'name': ''};
                                });
                              }
                            }
                            else{
                              setState(() {
                                error = false;
                                profilParrain = {"images": '', 'name': ''};
                              });
                            }
                          },
                        ),
                      ),
                    )),
                if(profilParrain["name"] != "") Container(
                  height: 80,
                  padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
                  width: double.infinity,
                  child: ListTile(
                    leading: Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: DecorationImage(image: NetworkImage("${ConsumeAPI.AssetProfilServer}${profilParrain["images"]}"), fit: BoxFit.cover)
                      ),
                    ),
                    title: Text(profilParrain["name"]!, style: prefix0.Style.sousTitre(14, prefix0.colorPrimary),),
                    subtitle: Text("Sera votre parrain.", style: prefix0.Style.simpleTextOnBoard(12),),
                  ),
                ),
                if(error) Padding(padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0), child: Text("Aucun Utilisateur n'a se code promo", style: prefix0.Style.titleInSegmentInTypeError(),))
              ],
            ),
          ]),
        ),
      ),
    );
  }

  choiceType(type, data) {
    if (type == 1) {
      return AssetImage(data);
    } else {
      return FileImage(data);
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
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
