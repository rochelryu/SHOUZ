import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

import '../Constant/helper.dart';

class DemandeConducteur extends StatefulWidget {
  static String rootName = '/DemandeConducteur';
  @override
  _DemandeConducteurState createState() => _DemandeConducteurState();
}

class _DemandeConducteurState extends State<DemandeConducteur> {
  final picker = ImagePicker();
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final ConsumeAPI consumeAPI = new ConsumeAPI();
  List<File> postCarteGrise = [];
  List<String> base64CarteGrise = [];
  List<File> postPermis = [];
  List<String> base64Permis = [];
  List<File> postTechnique = [];
  List<String> base64Technique = [];
  List<File> postAssurance = [];
  List<String> base64Assurance = [];
  String base64VehiculeCover = '';
  List<File> postVehiculeCover = [];
  String base64PhotoChauffeur = '';
  List<File> postPhotoChauffeur = [];
  String describe = "";
  TextEditingController describeCtrl = new TextEditingController();

  bool _isDescribe = true;

  bool _isNumber = false;
  int? numero;
  TextEditingController numeroCtrl = new TextEditingController();
  bool _isLoading = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

  }

  Future getImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (postVehiculeCover.length < 1) {
        setState(() {
          postVehiculeCover.add(File(image.path));
        });
        base64VehiculeCover = base64Encode(File(image.path).readAsBytesSync());
      } else {
        setState(() {
          postVehiculeCover[0] = File(image.path);
        });
        base64VehiculeCover = base64Encode(File(image.path).readAsBytesSync());
      }
    }
  }

  Future getImagePhotoConducteur() async {
    var image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      if (postPhotoChauffeur.length < 1) {
        setState(() {
          postPhotoChauffeur.add(File(image.path));
        });
        base64PhotoChauffeur = base64Encode(File(image.path).readAsBytesSync());
      } else {
        setState(() {
          postPhotoChauffeur[0] = File(image.path);
        });
        base64PhotoChauffeur = base64Encode(File(image.path).readAsBytesSync());
      }
    }
  }

  Future getImages(List<File> post, List<String> base64) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, allowCompression: true, type: FileType.image);

    if (result != null) {
      List<File> files = result.paths.map((path) {
        return File(path!);
      }).toList();
      final end = (files.length > 2) ? 2 : files.length;
      final images = files.sublist(0, end);
      setState(() {
        post = images;
        base64 = images
            .map((image) => base64Encode(image.readAsBytesSync()))
            .toList();
      });
    }
  }
  Future getImagesPermis() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, allowCompression: true, type: FileType.image);

    if (result != null) {
      List<File> files = result.paths.map((path) {
        return File(path!);
      }).toList();
      final end = (files.length > 2) ? 2 : files.length;
      final images = files.sublist(0, end);
      setState(() {
        postPermis = images;
        base64Permis = images
            .map((image) => base64Encode(image.readAsBytesSync()))
            .toList();
      });
    }
  }
  Future getImagesAssurance() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, allowCompression: true, type: FileType.image);

    if (result != null) {
      List<File> files = result.paths.map((path) {
        return File(path!);
      }).toList();
      final end = (files.length > 2) ? 2 : files.length;
      final images = files.sublist(0, end);
      setState(() {
        postAssurance = images;
        base64Assurance = images
            .map((image) => base64Encode(image.readAsBytesSync()))
            .toList();
      });
    }
  }
  Future getImagesTechnique() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, allowCompression: true, type: FileType.image);

    if (result != null) {
      List<File> files = result.paths.map((path) {
        return File(path!);
      }).toList();
      final end = (files.length > 2) ? 2 : files.length;
      final images = files.sublist(0, end);
      setState(() {
        postTechnique = images;
        base64Technique = images
            .map((image) => base64Encode(image.readAsBytesSync()))
            .toList();
      });
    }
  }
  Future getImagesGrise() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, allowCompression: true, type: FileType.image);

    if (result != null) {
      List<File> files = result.paths.map((path) {
        return File(path!);
      }).toList();
      final end = (files.length > 2) ? 2 : files.length;
      final images = files.sublist(0, end);
      setState(() {
        postCarteGrise = images;
        base64CarteGrise = images
            .map((image) => base64Encode(image.readAsBytesSync()))
            .toList();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    var loginBtn = ElevatedButton(
      onPressed: _submit,
      child: Text(
        "Soumettre",
        style: Style.sousTitreEvent(15),
      ),
      style: raisedButtonStyle,
    );
    var loginForm = Column(
      children: <Widget>[
        Form(
          key: formKey,
          child: Column(
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.transparent,
                  elevation: _isDescribe ? 4.0 : 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      /*gradient: LinearGradient(
                            colors: [Colors.grey[200], Colors.black12],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight
                        ),*/
                        color: backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isDescribe
                                ? colorText
                                : backgroundColor),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: TextField(
                      controller: describeCtrl,
                      onChanged: (text) {
                        setState(() {
                          _isDescribe = true;
                          _isNumber = false;
                          describe = text;
                        });
                      },
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      maxLength: 360,
                      maxLines: 4,
                      cursorColor: colorText,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_one,
                              color: _isDescribe
                                  ? colorText
                                  : Colors.grey),
                          labelText: "Vos caracteristiques au volant",

                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                        hintText: "Je fume,j'ecoute la musique, j'aime converser, pas de cigarette"
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 150,
                width: double.infinity,
                padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: postCarteGrise.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              getImagesGrise();
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              padding: EdgeInsets.all(6),
                              color: Colors.white,
                              strokeWidth: 1,
                              child: Container(
                                height: 140,
                                width: 130,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Carte Grise (Recto/Verso)",
                                      style: Style.titleInSegment(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                postCarteGrise.removeAt(index - 1);
                                base64CarteGrise.removeAt(index - 1);
                              });
                            },
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                        image: FileImage(postCarteGrise[index - 1]),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
              Container(
                height: 150,
                width: double.infinity,
                padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: postTechnique.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              getImagesTechnique();
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              padding: EdgeInsets.all(6),
                              color: Colors.white,
                              strokeWidth: 1,
                              child: Container(
                                height: 140,
                                width: 130,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Carte Visite (Recto/Verso)",
                                      style: Style.titleInSegment(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                postTechnique.removeAt(index - 1);
                                base64Technique.removeAt(index - 1);
                              });
                            },
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                        image: FileImage(postTechnique[index - 1]),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
              Container(
                height: 150,
                width: double.infinity,
                padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: postPermis.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              getImagesPermis();
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              padding: EdgeInsets.all(6),
                              color: Colors.white,
                              strokeWidth: 1,
                              child: Container(
                                height: 140,
                                width: 130,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Permis conduire (Recto/Verso)",
                                      style: Style.titleInSegment(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                postPermis.removeAt(index - 1);
                                base64Permis.removeAt(index - 1);
                              });
                            },
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                        image: FileImage(postPermis[index - 1]),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
              Container(
                height: 150,
                width: double.infinity,
                padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: postAssurance.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              getImagesAssurance();
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              padding: EdgeInsets.all(6),
                              color: Colors.white,
                              strokeWidth: 1,
                              child: Container(
                                height: 140,
                                width: 130,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Assurance Auto (Page info)",
                                      style: Style.titleInSegment(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                postAssurance.removeAt(index - 1);
                                base64Assurance.removeAt(index - 1);
                              });
                            },
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                        image: FileImage(postAssurance[index - 1]),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
              Container(
                height: 150,
                width: double.infinity,
                padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: postVehiculeCover.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              getImage();
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              padding: EdgeInsets.all(6),
                              color: Colors.white,
                              strokeWidth: 1,
                              child: Container(
                                height: 140,
                                width: 130,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Photo de votre vehicule (de profil)",
                                      style: Style.titleInSegment(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                postVehiculeCover.removeAt(index - 1);
                                base64VehiculeCover = "";
                              });
                            },
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 100,
                                width: 120,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                        image: FileImage(postVehiculeCover[index - 1]),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
              Container(
                height: 130,
                width: double.infinity,
                padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: postPhotoChauffeur.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              getImagePhotoConducteur();
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              padding: EdgeInsets.all(6),
                              color: Colors.white,
                              strokeWidth: 1,
                              child: Container(
                                height: 100,
                                width: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Photo de Vous",
                                      style: Style.titleInSegment(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                postPhotoChauffeur.removeAt(index - 1);
                                base64PhotoChauffeur = "";
                              });
                            },
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                        image: FileImage(postPhotoChauffeur[index - 1]),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 130,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Text(
                            "Votre vehicule prend combien de place disponible hors mis la place du chaufeur ?",
                            style: Style.sousTitre(13)),
                      ),
                      Expanded(
                        flex: 1,
                          child: Center(
                            child: Card(
                              color: Colors.transparent,
                              elevation: _isNumber ? 4.0 : 0.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                    color: backgroundColorSec,
                                    border: Border.all(
                                        width: 1.0,
                                        color: _isNumber
                                            ? colorText
                                            : backgroundColor),
                                    borderRadius: BorderRadius.circular(50.0)),
                                child: TextField(
                                  controller: numeroCtrl,
                                  onChanged: (text) {
                                    setState(() {
                                      _isNumber = true;
                                      _isDescribe = false;

                                      numero = int.parse(text);
                                    });
                                  },
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300),
                                  cursorColor: colorText,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,

                                      hintText: "Nbre Place",
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ),
                          )),

                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
        _isLoading ? const CircularProgressIndicator() : loginBtn
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Devenir Conducteur !",
                          style: Style.secondTitre(22)),
                      SizedBox(height: 10.0),
                      Text("Rémunéré vos voyages",
                          style: Style.sousTitre(14),
                          textAlign: TextAlign.center),
                      Text("Renseignez tous les documents afin que nous analysons votre demande",
                          style: Style.sousTitre(14),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: loginForm,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    formKey.currentState;
    setState(() => _isLoading = true);
    if (postCarteGrise.length == 2 &&
        postTechnique.length == 2 &&
        postAssurance.length == 2 &&
        postPermis.length == 2 &&
        postVehiculeCover.length == 1 &&
        postPhotoChauffeur.length == 1 &&
        describe.length > 5 &&
        numero != null ) {
      String carteGriseRectoName = postCarteGrise[0].path.split('/').last;
      String carteGriseVersoName = postCarteGrise[1].path.split('/').last;
      String carteTechniqueRectoName = postTechnique[0].path.split('/').last;
      String carteTechniqueVersoName = postTechnique[1].path.split('/').last;
      String permisRectoName = postPermis[0].path.split('/').last;
      String permisVersoName = postPermis[1].path.split('/').last;
      String assurancePageOneName = postAssurance[0].path.split('/').last;
      String assurancePageTwoName = postAssurance[1].path.split('/').last;
      String pictureVehiculeName = postVehiculeCover[0].path.split('/').last;
      String pictureProfilConducteurName = postPhotoChauffeur[0].path.split('/').last;
      final demandeConducteur = await consumeAPI.demandeConducteur(describe, carteGriseRectoName, base64CarteGrise[0], carteGriseVersoName, base64CarteGrise[1], carteTechniqueRectoName, base64Technique[0], carteTechniqueVersoName, base64Technique[1], permisRectoName, base64Permis[0], permisVersoName, base64Permis[1], assurancePageOneName, base64Assurance[0], assurancePageTwoName, base64Assurance[1], pictureVehiculeName, base64VehiculeCover, pictureProfilConducteurName, base64PhotoChauffeur, numero!);
      setState(() => _isLoading = false);
      if (demandeConducteur['etat'] == 'found') {

        await askedToLead(
            "Soumission faites avec succès, nous analysons vos documents par nos robots. Delai de reponse 48h maximum",
            true, context);
        Navigator.pushNamed(context, MenuDrawler.rootName);
      } else {
        await askedToLead(
            demandeConducteur['error'],
            false, context);
      }
    } else {
      setState(() => _isLoading = false);
      showSnackBar(context, "Remplissez correctement les champs avant d'envoyer");
    }
  }

}
