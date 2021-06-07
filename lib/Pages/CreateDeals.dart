import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

class CreateDeals extends StatefulWidget {
  @override
  _CreateDealsState createState() => _CreateDealsState();
}

class _CreateDealsState extends State<CreateDeals> {
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  List<File> post = [];
  List<String> base64Image = [];
  List<dynamic> allCategorie = [];
  String nameProduct = "";
  TextEditingController nameProductCtrl = new TextEditingController();
  String describe = "";
  TextEditingController describeCtrl = new TextEditingController();
  String position = "";
  TextEditingController positionCtrl = new TextEditingController();
  String price = "";
  TextEditingController priceCtrl = new TextEditingController();
  String quantity = "";
  TextEditingController quantityCtrl = new TextEditingController();
  String dropdownValue;
  bool _isName = true;
  bool _isDescribe = false;
  bool _isPrice = false;
  bool _isQuantity = false;
  bool _isPosition = false;
  bool _isNumber = false;
  String numero = "";
  TextEditingController numeroCtrl = new TextEditingController();
  bool _isLoading = false;
  bool _isCategorie = false;
  bool monVal = false;

  selectDate(BuildContext context) async {
    User newClient = await DBProvider.db.getClient();
    numeroCtrl.text = newClient.numero;
    setState(() {
      numero = newClient.numero;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCategorie();
  }

  loadCategorie() async {
    final data = await new ConsumeAPI().getAllCategrieWithoutFilter("deal");
    setState(() {
      allCategorie = data;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getImage() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        allowMultiple: true, allowCompression: true, type: FileType.image);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path)).toList();
      final end = (files.length > 4) ? 4 : files.length;
      final images = files.sublist(0, end);
      setState(() {
        post = images;
        base64Image = images
            .map((image) => base64Encode(image.readAsBytesSync()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var loginBtn = new RaisedButton(
      onPressed: _submit,
      child: new Text(
        "Envoyer le produit",
        style: prefix0.Style.sousTitreEvent(15),
      ),
      color: prefix0.colorText,
      disabledElevation: 0.0,
      disabledColor: Colors.grey[300],
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
    );
    var loginForm = new Column(
      children: <Widget>[
        new Form(
          key: formKey,
          child: new Column(
            children: <Widget>[
              new Padding(
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
                        /*gradient: LinearGradient(
                            colors: [Colors.grey[200], Colors.black12],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight
                        ),*/
                        color: prefix0.backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isName
                                ? prefix0.colorText
                                : prefix0.backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: new TextField(
                      controller: nameProductCtrl,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      cursorColor: prefix0.colorText,
                      keyboardType: TextInputType.text,
                      onChanged: (text) {
                        setState(() {
                          _isName = true;
                          _isQuantity = false;
                          _isDescribe = false;
                          _isPrice = false;
                          _isPosition = false;
                          _isNumber = false;
                          _isLoading = false;
                          _isCategorie = false;
                          monVal = false;
                          nameProduct = text;
                        });
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_one,
                              color: _isName ? prefix0.colorText : Colors.grey),
                          hintText: "Nom du produit",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
              new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Card(
                            color: Colors.transparent,
                            elevation: _isPrice ? 4.0 : 0.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.5,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: prefix0.backgroundColorSec,
                                  border: Border.all(
                                      width: 1.0,
                                      color: _isPrice
                                          ? prefix0.colorText
                                          : prefix0.backgroundColor),
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: new TextField(
                                controller: priceCtrl,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                                cursorColor: prefix0.colorText,
                                onChanged: (text) {
                                  setState(() {
                                    _isPrice = true;
                                    _isQuantity = false;
                                    _isName = false;
                                    _isDescribe = false;
                                    _isPosition = false;
                                    _isNumber = false;
                                    _isLoading = false;
                                    _isCategorie = false;
                                    monVal = false;
                                    price = text.toString();
                                  });
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.looks_two,
                                        color: _isPrice
                                            ? prefix0.colorText
                                            : Colors.grey),
                                    hintText: "Prix",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.transparent,
                            elevation: _isQuantity ? 4.0 : 0.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.35,
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              decoration: BoxDecoration(
                                  color: prefix0.backgroundColorSec,
                                  border: Border.all(
                                      width: 1.0,
                                      color: _isQuantity
                                          ? prefix0.colorText
                                          : prefix0.backgroundColor),
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: new TextField(
                                controller: quantityCtrl,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                                cursorColor: prefix0.colorText,
                                onChanged: (text) {
                                  setState(() {
                                    _isQuantity = true;
                                    _isPrice = false;
                                    _isName = false;
                                    _isDescribe = false;
                                    _isPosition = false;
                                    _isNumber = false;
                                    _isLoading = false;
                                    _isCategorie = false;
                                    monVal = false;
                                    quantity = text.toString();
                                  });
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.looks_3,
                                        color: _isQuantity
                                            ? prefix0.colorText
                                            : Colors.grey),
                                    hintText: "Quantité",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                        ]),
                  )),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.transparent,
                  elevation: _isDescribe ? 4.0 : 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        /*gradient: LinearGradient(
                            colors: [Colors.grey[200], Colors.black12],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight
                        ),*/
                        color: prefix0.backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isDescribe
                                ? prefix0.colorText
                                : prefix0.backgroundColor),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: new TextField(
                      controller: describeCtrl,
                      onChanged: (text) {
                        setState(() {
                          _isName = false;
                          _isDescribe = true;
                          _isPrice = false;
                          _isPosition = false;
                          _isQuantity = false;
                          _isNumber = false;
                          _isLoading = false;
                          _isCategorie = false;
                          monVal = false;
                          describe = text;
                        });
                      },
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      maxLength: 260,
                      maxLines: 7,
                      cursorColor: prefix0.colorText,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_4,
                              color: _isDescribe
                                  ? prefix0.colorText
                                  : Colors.grey),
                          labelText: "Description du produit",
                          labelStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.transparent,
                  elevation: _isCategorie ? 4.0 : 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        /*gradient: LinearGradient(
                            colors: [Colors.grey[200], Colors.black12],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight
                        ),*/
                        color: prefix0.backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isCategorie
                                ? prefix0.colorText
                                : prefix0.backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: DropdownButton<String>(
                      hint: Text('Veuillez choisir une categorie',
                          style: prefix0.Style.sousTitre(14)),
                      value: dropdownValue,
                      icon: Icon(Icons.arrow_downward),
                      isExpanded: true,
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.white),
                      underline: Container(
                        height: 0,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _isCategorie = true;
                          dropdownValue = newValue;
                          _isName = false;
                          _isDescribe = false;
                          _isQuantity = false;
                          _isPrice = false;
                          _isPosition = false;
                          _isNumber = false;
                          _isLoading = false;
                          monVal = false;
                        });
                      },
                      items: allCategorie.map((value) {
                        return DropdownMenuItem<String>(
                          value: value['_id'],
                          child: Text(value['name'],
                              style: prefix0.Style.sousTitre(15)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Container(
                height: 130,
                width: double.infinity,
                padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: post.length + 1,
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
                                height: 100,
                                width: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Selectionner une image",
                                      style: prefix0.Style.titleInSegment(),
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
                                post.removeAt(index - 1);
                                if (post.length == 0) {
                                  base64Image = [];
                                } else {
                                  base64Image = post
                                      .map((image) =>
                                          base64Encode(image.readAsBytesSync()))
                                      .toList();
                                }
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
                                        image: FileImage(post[index - 1]),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Text(
                          "Cliquez sur l'icon pour signifier que c'est le même numero que ce celui de votre inscription sinon écrivez le",
                          style: prefix0.Style.sousTitre(13)),
                      SizedBox(height: 10),
                      Container(
                        height: 50,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FloatingActionButton(
                              child:
                                  Icon(Icons.smartphone, color: Colors.white),
                              onPressed: () {
                                selectDate(context);
                              },
                            ),
                            Card(
                              color: Colors.transparent,
                              elevation: _isNumber ? 4.0 : 0.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width / 1.6,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    color: prefix0.backgroundColorSec,
                                    border: Border.all(
                                        width: 1.0,
                                        color: _isNumber
                                            ? prefix0.colorText
                                            : prefix0.backgroundColor),
                                    borderRadius: BorderRadius.circular(50.0)),
                                child: new TextField(
                                  controller: numeroCtrl,
                                  onChanged: (text) {
                                    setState(() {
                                      _isNumber = true;
                                      _isName = false;
                                      _isDescribe = false;
                                      _isQuantity = false;
                                      _isPrice = false;
                                      _isPosition = false;
                                      _isLoading = false;
                                      _isCategorie = false;
                                      monVal = false;
                                      numero = text.toString();
                                    });
                                  },
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300),
                                  cursorColor: prefix0.colorText,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(Icons.looks_5,
                                          color: _isNumber
                                              ? prefix0.colorText
                                              : Colors.grey),
                                      hintText: "Numero de telephone",
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.transparent,
                  elevation: _isPosition ? 4.0 : 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: prefix0.backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isPosition
                                ? prefix0.colorText
                                : prefix0.backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: new TextField(
                      controller: positionCtrl,
                      onChanged: (text) {
                        setState(() {
                          _isPosition = true;
                          _isName = false;
                          _isNumber = false;
                          _isDescribe = false;
                          _isPrice = false;
                          _isLoading = false;
                          _isQuantity = false;
                          _isCategorie = false;
                          monVal = false;
                          position = text;
                        });
                      },
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      cursorColor: prefix0.colorText,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_6,
                              color: _isPosition
                                  ? prefix0.colorText
                                  : Colors.grey),
                          hintText: "Entrer un lieu pour la remise",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 40,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Checkbox(
                        value: monVal,
                        checkColor: Colors.white,
                        onChanged: (bool value) {
                          setState(() {
                            monVal = value;
                          });
                        },
                      ),
                      Text('Booster ce deal en VIP (1000 Frs)',
                          style: prefix0.Style.warning(11)),
                    ],
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
      backgroundColor: prefix0.backgroundColor,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Créer Votre Annonce !",
                          style: prefix0.Style.secondTitre(22)),
                      SizedBox(height: 10.0),
                      Text(
                        "Vendez tout ce que vous voulez,",
                        style: prefix0.Style.sousTitre(14),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "c’est sans frais.",
                        style: prefix0.Style.sousTitre(14),
                        textAlign: TextAlign.center,
                      ),
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
    final form = formKey.currentState;
    setState(() => _isLoading = true);
    //print('$nameProduct , $describe , $dropdownValue, $base64Image, $base64Video, ${dateChoice.toString()} , ${numero.toString()}, $position, $price');
    if (nameProduct.length > 4 &&
        describe.length > 20 &&
        dropdownValue != null &&
        base64Image.length > 0 &&
        numero.length == 10 &&
        position.length > 5 &&
        price.length > 2) {
      List<String> imageListTitle =
          post.map((image) => image.path.split('/').last).toList();
      String imageTitle = imageListTitle.join(',');
      String imagesBuffers = base64Image.join(',');
      int level = monVal ? 3 : 1;
      final product = await new ConsumeAPI().setProductDeals(
          nameProduct,
          describe,
          dropdownValue,
          imageTitle,
          imagesBuffers,
          position,
          level,
          numero,
          price,
          quantity);
      setState(() => _isLoading = false);
      print(product);
      if (product == 'found') {
        dropdownValue = null;
        post.clear();
        base64Image.clear();
        nameProductCtrl.clear();
        describeCtrl.clear();
        positionCtrl.clear();
        priceCtrl.clear();
        quantityCtrl.clear();
        numeroCtrl.clear();
        nameProduct = "";
        describe = "";
        position = "";
        price = "";
        numero = "";
        await _askedToLead(
            "Votre produit est en ligne, vous pouvez le manager où que vous soyez",
            true);
      } else if (product == 'FreeInPayPrice') {
        await _askedToLead(
            "Un produit Gratuit ne peut être assimilé à un prix", false);
      } else if (product == 'IncorrectPrice') {
        await _askedToLead("Erreur lors de la saisie des prix", false);
      } else {
        await _askedToLead(
            "Echec avec la mise en ligne, veuillez ressayer ulterieurement",
            false);
      }
    } else {
      setState(() => _isLoading = false);
      _showSnackBar("Remplissez correctement les champs avant d'envoyer");
    }
  }

  Future<Null> _askedToLead(String message, bool success) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: success
                ? Icon(MyFlutterAppSecond.checked,
                    size: 120, color: prefix0.colorSuccess)
                : Icon(MyFlutterAppSecond.cancel,
                    size: 120, color: prefix0.colorError),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(children: [
                  Text(message,
                      textAlign: TextAlign.center,
                      style: prefix0.Style.sousTitre(13)),
                  RaisedButton(
                      child: Text('Ok'),
                      color:
                          success ? prefix0.colorSuccess : prefix0.colorError,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ]),
              )
            ],
          );
        });
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      backgroundColor: prefix0.colorError,
      content: new Text(
        text,
        textAlign: TextAlign.center,
      ),
      action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            return true;
          }),
    ));
  }
}
