import 'dart:convert';
import 'dart:io';


import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';

import '../Constant/helper.dart';
import 'Login.dart';
class UpdateInfoBasic extends StatefulWidget {
  static String rootName = '/updateInfoBasic';
  UpdateInfoBasic({required Key key}) : super(key: key);

  @override
  _UpdateInfoBasicState createState() => _UpdateInfoBasicState();
}

class _UpdateInfoBasicState extends State<UpdateInfoBasic> {
  User? user;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final ConsumeAPI consumeAPI = new ConsumeAPI();

  String name = "";

  TextEditingController nameCtrl = new TextEditingController();
  String email = "";
  TextEditingController emailCtrl = new TextEditingController();
  List<File> piece = [];
  List<String> basePiece = [];
  TextEditingController priceCtrl = new TextEditingController();
  String photoProfil = '';
  List<File> postClient = [];
  bool _isName = true;
  bool _isEmail = false;
  int displayAttributePiece = -1;
  bool _isLoading = false;
  bool _isLoadingSecond = false;
  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProfil();
  }


  loadProfil() async {
    final client = await DBProvider.db.getClient();
    setState(() {
      user = client;
    });
    nameCtrl.text = user?.name as String;
    emailCtrl.text = user?.email as String;
    setState(() {
      displayAttributePiece = user?.isActivateForBuyTravel as int;
      name = user?.name as String;
      email = user?.email as String;
    });
  }



  @override
  void dispose() {
    super.dispose();
  }

  Future getImagesPieces() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, allowCompression: true, type: FileType.image);

    if (result != null) {
      List<File> files = result.paths.map((path) {
        return File(path!);
      }).toList();
      final end = (files.length > 2) ? 2 : files.length;
      final images = files.sublist(0, end);
      setState(() {
        piece = images;
        basePiece = images
            .map((image) => base64Encode(image.readAsBytesSync()))
            .toList();
      });
    }
  }

  Future getImagePhoto() async {
    var image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      if (postClient.length < 1) {
        setState(() {
          postClient.add(File(image.path));
        });
        photoProfil = base64Encode(File(image.path).readAsBytesSync());
      } else {
        setState(() {
          postClient[0] = File(image.path);
        });
        photoProfil = base64Encode(File(image.path).readAsBytesSync());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var loginBtn = Padding(
      padding: EdgeInsets.only(top: 15),
      child: ElevatedButton(
        onPressed: _submit,
        child: new Text(
          "Enregistrer",
          style: Style.sousTitreEvent(15),
        ),
        style: raisedButtonStyle,
      ),
    );
    var loginForm = new Column(
      children: <Widget>[
        new Form(
          key: formKey,
          child: new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.transparent,
                  elevation: _isName ? 4.0 : 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(

                        color: backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isName
                                ? colorText
                                : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: new TextField(
                      controller: nameCtrl,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      cursorColor: colorText,
                      keyboardType: TextInputType.text,
                      onChanged: (text) {
                        setState(() {
                          _isName = true;
                          _isEmail = false;
                          name = text;
                        });
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_one,
                              color: _isName ? colorText : Colors.grey),
                          hintText: "Nom & prénom",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.transparent,
                  elevation: _isEmail ? 4.0 : 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(

                        color: backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isEmail
                                ? colorText
                                : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: new TextField(
                      controller: emailCtrl,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      cursorColor: colorText,
                      keyboardType: TextInputType.text,
                      onChanged: (text) {
                        setState(() {
                          _isName = false;
                          _isEmail = true;
                          email = text;
                        });
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_two,
                              color: _isName ? colorText : Colors.grey),
                          hintText: "Email",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _isLoading ? new CircularProgressIndicator() : loginBtn
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
                      Text("Informations basiques",
                          style: Style.secondTitre(22), textAlign: TextAlign.center,),

                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: loginForm,
                ),
                Padding(padding: EdgeInsets.all(10),
                child: Divider(color: colorWelcome,),),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Informations voyages",
                        style: Style.secondTitre(22), textAlign: TextAlign.center,),
                      displaySectionPiece(context, displayAttributePiece)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    formKey.currentState;

    if (name.length > 5 ) {
      setState(() => _isLoading = true);
      final update = await consumeAPI.changeBasicInfo(name, email);
      setState(() => _isLoading = false);
      if (update == 'found') {
        await askedToLead(
            "Information bien enregistrée",
            true, context);
        Navigator.pushNamed(context, MenuDrawler.rootName);
      } else if(update == 'notFound') {
        showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
              barrierDismissible: false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => Login()));
      } else if(update == 'already') {
        await askedToLead(
            "Cet email est déjà associé à un autre compte",
            false, context);
      } else {
        await askedToLead(
            "Une erreur de serveur s'est produite, veuillez ressayer ulterieurement",
            false, context);
      }
    } else {
      setState(() => _isLoading = false);
      showSnackBar(context, "Remplissez correctement les champs avant d'envoyer");
    }
  }

  void _submitSecond() async {
    formKey.currentState;

    if (piece.length == 2 &&
        postClient.length == 1 ) {
      setState(() => _isLoadingSecond = true);
      String pieceRectoName = piece[0].path.split('/').last;
      String pieceVersoName = piece[1].path.split('/').last;
      String pictureProfil = postClient[0].path.split('/').last;
      final demandeConducteur = await consumeAPI.demandeVoyageur(pieceRectoName, basePiece[0], pieceVersoName, basePiece[1], pictureProfil, photoProfil);
      setState(() => _isLoadingSecond = false);
      if (demandeConducteur['etat'] == 'found') {

        await askedToLead(
            "Soumission faites avec succès, nous analysons vos documents par nos robots. Delai de reponse 48h maximum",
            true, context);
        Navigator.pushNamed(context, MenuDrawler.rootName);
      } else if(demandeConducteur['etat'] == 'notFound') {
        showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
              barrierDismissible: false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => Login()));
      } else {
        await askedToLead(
            demandeConducteur['error'],
            false, context);
      }
    } else {
      showSnackBar(context,"Remplissez correctement les champs avant d'envoyer");
    }
  }

  Widget displaySectionPiece(BuildContext context, int displayAttributePieceParams) {
    if(displayAttributePieceParams == -1){
      return SizedBox(width: 10);
    } else if(displayAttributePieceParams == 0){
      return Container(
        height: 420,
        margin: EdgeInsets.only(top: 25),
        child: Column(
          children: [
            Text("Vous pouvez envoyez l'une des pièces suivante (CNI, PASSPORT, ATTESTATION, PERMIS)", style: Style.simpleTextOnBoard(),),
            Container(
              height: 150,
              width: double.infinity,
              padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: piece.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(right: 25),
                        child: InkWell(
                          onTap: () {
                            getImagesPieces();
                          },
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(12),
                            padding: EdgeInsets.all(6),
                            color: Colors.white,
                            strokeWidth: 1,
                            child: Container(
                              height: 110,
                              width: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.portrait,
                                      color: Colors.white, size: 30),
                                  SizedBox(height: 5),
                                  Text(
                                    "Pièce (Recto/Verso)",
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
                              piece.removeAt(index - 1);
                              basePiece.removeAt(index - 1);
                            });
                          },
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: Container(
                              height: 110,
                              width: 120,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                      image: FileImage(piece[index - 1]),
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
                  itemCount: postClient.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(right: 25),
                        child: InkWell(
                          onTap: () {
                            getImagePhoto();
                          },
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(12),
                            padding: EdgeInsets.all(6),
                            color: Colors.white,
                            strokeWidth: 1,
                            child: Container(
                              height: 120,
                              width: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.camera,
                                      color: Colors.white, size: 30),
                                  SizedBox(height: 5),
                                  Text(
                                    "Photo de vous attrapant la pièce",
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
                              postClient.removeAt(index - 1);
                              photoProfil = "";
                            });
                          },
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: Container(
                              height: 110,
                              width: 120,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                      image: FileImage(postClient[index - 1]),
                                      fit: BoxFit.cover)),
                            ),
                          ),
                        ),
                      );
                    }
                  }),
            ),
            _isLoadingSecond ? new CircularProgressIndicator() :ElevatedButton(onPressed: _submitSecond, child: Text('ENVOYER'), style: raisedButtonStyle,)
          ],
        ),
      );
    } else if(displayAttributePieceParams == 1){
      return Container(
        margin: EdgeInsets.only(top: 25),
        child: Center(
          child: Text("Les document que vous avez envoyé sont en cours d'analyse nous vous reviendrons dans les plus brefs delais", style: Style.simpleTextOnNews(),),
        ),
      );
    } else if(displayAttributePieceParams == 2){
      return Container(
        margin: EdgeInsets.only(top: 25),
        child: Center(
          child: Text("Votre compte est actif pour effectuer des achats de tickets de voyage.", style: Style.simpleTextOnNews(),),
        ),
      );
    } else {
      return SizedBox(width: 10);
    }
  }
}