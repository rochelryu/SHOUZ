import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/ChangePin.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Constant/VerifyUser.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart' as prefix1;
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

class Setting extends StatefulWidget {
  static String rootName = '/setting';
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late AppState appState;
  final picker = ImagePicker();
  bool createPass = true;
  String pin = '';
  Map<String, dynamic> newClient = {
    'name': '',
    'level': '',
  };
  Map profil = {"type": 1, "data": ''};

  Future getNewPin() async {
    try {
      String pin = await prefix0.getPin();

      setState(() {
        this.pin = pin;
        createPass = (this.pin.length > 0) ? false : true;
      });
      print("pindeOuf $pin, ${createPass.toString()}");
    } catch (e) {
      print("Erreur $e");
    }
  }

  void initState() {
    super.initState();
    loadInfo();
    getNewPin();
  }

  loadInfo() async {
    final info = await new ConsumeAPI().setSettings();
    if (info['etat'] == 'found') {
      setState(() {
        newClient = info['result'];
        profil['data'] = info['result']['images'];
      });
    }
  }

  Future getImage(BuildContext context) async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imm = File(image.path);
      final base64Image = base64Encode(imm.readAsBytesSync());
      String imageCover = imm.path.split('/').last;
      setState(() {
        profil = {"type": 2, "data": File(image.path)};
      });
      final info = await new ConsumeAPI()
          .changeProfilPicture(imageName: imageCover, base64: base64Image);
      Navigator.pop(context);
      print(info);
    }
  }

  Future getCamera(BuildContext context) async {
    var image = await picker.getImage(source: ImageSource.camera);
    if (image != null) {
      File imm = File(image.path);
      final base64Image = base64Encode(imm.readAsBytesSync());
      String imageCover = imm.path.split('/').last;
      setState(() {
        profil = {"type": 2, "data": File(image.path)};
      });
      appState.changeProfilPicture(imageName: imageCover, base64: base64Image);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      backgroundColor: prefix0.backgroundColor,
      appBar: AppBar(
        title: Text("Paramêtre"),
        elevation: 0.0,
        leading: SizedBox(height: 5),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                await Navigator.pushNamed(context, MenuDrawler.rootName);
              },
            ),
          )
        ],
        backgroundColor: prefix0.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
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
                                image: choiceType(profil["type"], profil["data"]),
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
                                                vertical: 10, horizontal: 15),
                                            decoration: BoxDecoration(
                                                color: prefix0.backgroundColor,
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
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 15),
                                                    child: Text(
                                                        "Photo de profil",
                                                        style: prefix0.Style
                                                            .titleInSegment())),
                                                Divider(color: Colors.white12),
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
                                                            getCamera(context);
                                                          },
                                                          icon: Icon(
                                                              Icons.camera_alt,
                                                              color: prefix0
                                                                  .colorText,
                                                              size: 40),
                                                          tooltip:
                                                              "Prendre une Photo",
                                                        ),
                                                        SizedBox(width: 50),
                                                        IconButton(
                                                          onPressed: () {
                                                            getImage(context);
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
                                                Divider(color: Colors.white12),
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
                                      borderRadius: BorderRadius.circular(50),
                                      color: new Color.fromRGBO(2, 136, 209,
                                          0.5) // Specifies the background color and the opacity
                                      ),
                                  child: Center(
                                    child:
                                        Icon(Icons.camera, color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(newClient['name'],
                            textAlign: TextAlign.center,
                            style: prefix0.Style.grandTitre(18))),
                    aboutInfoCompte(newClient['level']),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.white12),
            ),
            SizedBox(height: 5),
            ListTile(
              onTap: () {
                print("Level");
              },
              leading: Icon(Icons.person, color: prefix0.colorText, size: 35),
              title: Text("Compte", style: prefix0.Style.titre(14)),
              subtitle: Text(
                "Nom, numéro, email, wallet",
                style: prefix0.Style.sousTitre(12),
              ),
            ),
            ListTile(
              onTap: () {
                if (createPass) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => VerifyUser(
                          redirect: Setting.rootName, key: UniqueKey(),)));
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => ChangePin()));
                }
              },
              leading: Icon(Icons.security, color: prefix0.colorText, size: 33),
              title: Text("Sécurité", style: prefix0.Style.titre(14)),
              subtitle: Text(
                "Créer/Modifier votre mot de passe",
                style: prefix0.Style.sousTitre(12),
              ),
            ),
            ListTile(
              onTap: () {
                print("Level");
              },
              leading:
                  Icon(Icons.event_seat, color: prefix0.colorText, size: 33),
              title:
                  Text("Compte évènementiel", style: prefix0.Style.titre(14)),
              subtitle: Text("Vendre les tickets de votre évènement",
                  style: prefix0.Style.sousTitre(12)),
            ),
            ListTile(
              onTap: () {
                print("Level");
              },
              leading: Icon(Icons.directions_car,
                  color: prefix0.colorText, size: 33),
              title:
                  Text("Compte Automobiliste", style: prefix0.Style.titre(14)),
              subtitle: Text("Fructifier vos voyages",
                  style: prefix0.Style.sousTitre(12)),
            ),
            ListTile(
              onTap: () {
                print("Level");
              },
              leading:
                  Icon(Icons.help_outline, color: prefix0.colorText, size: 33),
              title: Text("Aide", style: prefix0.Style.titre(14)),
              subtitle: Text(
                "Q&R, contactez-nous, CPC",
                style: prefix0.Style.sousTitre(12),
              ),
            ),
            ListTile(
              onTap: () {
                print("Level");
              },
              leading: Icon(Icons.people, color: prefix0.colorText, size: 33),
              title: Text("Partager", style: prefix0.Style.titre(14)),
              subtitle: Text(
                "Inviter des amis",
                style: prefix0.Style.sousTitre(12),
              ),
            ),
            ListTile(
              onTap: () {
                print("Level");
              },
              leading: Icon(Icons.bookmark, color: prefix0.colorText, size: 33),
              title: Text("A propos", style: prefix0.Style.titre(14)),
              subtitle: Text(
                "Info sur l'application, ICORE ",
                style: prefix0.Style.sousTitre(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  choiceType(type, data) {
    if (type == 1) {
      return  NetworkImage("${ConsumeAPI.AssetProfilServer}$data");
    } else {
      return  FileImage(data);
    }
  }

  Widget aboutInfoCompte(level) {
//    final parE = event ? "évenementiel" : "";
//    final parD = deals ? "de vente" : "";
//    final parT = travel ? "de voyageur" : "";
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Text("Compte ${level.toString()}",
            style: prefix0.Style.sousTitre(14.0), textAlign: TextAlign.center));
  }
}
