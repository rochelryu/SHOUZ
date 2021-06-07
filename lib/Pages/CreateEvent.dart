import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:video_player/video_player.dart';

class CreateEvent extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  VideoPlayerController _controller;
  final picker = ImagePicker();
  DateTime dateChoice;
  DateTime date = new DateTime.now();
  TimeOfDay time = new TimeOfDay.now();
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  List<File> post = [];
  File video;
  String base64Image = "";
  String base64Video = "";
  List<VideoPlayerController> postVideo = [];
  List<dynamic> allCategorie = [];
  String nameProduct = "";
  TextEditingController nameProductCtrl = new TextEditingController();
  String describe = "";
  TextEditingController describeCtrl = new TextEditingController();
  String position = "";
  TextEditingController positionCtrl = new TextEditingController();
  String price = "";
  TextEditingController priceCtrl = new TextEditingController();
  String dropdownValue;
  bool _isName = true;
  bool _isDescribe = false;
  bool _isPrice = false;
  bool _isPosition = false;
  bool _isNumber = false;
  int numero;
  TextEditingController numeroCtrl = new TextEditingController();
  bool _isLoading = false;
  bool _isCategorie = false;
  bool monVal = false;

  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: new DateTime(new DateTime.now().year),
        lastDate: new DateTime(new DateTime.now().year + 2));
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
      selectTime(context);
    }
  }

  Future<Null> selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: time);

    if (picked != null && picked != time) {
      setState(() {
        time = picked;
        dateChoice = new DateTime(
            date.year, date.month, date.day, time.hour, time.minute);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCategorie();
  }

  loadCategorie() async {
    final data = await new ConsumeAPI().getAllCategrieWithoutFilter("event");
    setState(() {
      allCategorie = data;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(() {});
    _controller.dispose();
  }

  Future getImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    if (image != null) {
      if (post.length < 1) {
        setState(() {
          post.add(File(image.path));
        });
        base64Image = base64Encode(File(image.path).readAsBytesSync());
      } else {
        setState(() {
          post[0] = File(image.path);
        });
        base64Image = base64Encode(File(image.path).readAsBytesSync());
      }
    }
  }

  Future getVideo() async {
    var image = await picker.getVideo(source: ImageSource.gallery);

    if (image != null) {
      if (postVideo.length < 1) {
        setState(() {
          _controller = VideoPlayerController.file(File(image.path));
          _controller
            ..initialize().then((_) {
              _controller.setLooping(true);
              setState(() {});
            });
          _controller
            ..addListener(() {
              setState(() {});
            });
          postVideo.add(_controller);
        });
        video = File(image.path);
        base64Video = base64Encode(File(image.path).readAsBytesSync());
      } else {
        setState(() {
          _controller = VideoPlayerController.file(File(image.path));
          _controller
            ..initialize().then((_) {
              _controller.setLooping(true);
              setState(() {});
            });
          _controller
            ..addListener(() {
              setState(() {});
            });
          postVideo[0] = _controller;
        });
        video = File(image.path);
        base64Video = base64Encode(File(image.path).readAsBytesSync());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var loginBtn = new RaisedButton(
      onPressed: _submit,
      child: new Text(
        "Enregistrer cet évenement",
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
                          hintText: "Titre de l'évenement",
                          hintStyle: TextStyle(
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
                          prefixIcon: Icon(Icons.looks_two,
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
                                base64Image = "";
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
              Container(
                height: 130,
                width: double.infinity,
                padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: postVideo.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: InkWell(
                            onTap: () {
                              getVideo();
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              padding: EdgeInsets.all(6),
                              color: Colors.white,
                              strokeWidth: 1,
                              child: Container(
                                height: 100,
                                width: 120,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Selectionner une video pour l'évenement",
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
                                postVideo.removeAt(index - 1);
                                base64Video = "";
                              });
                            },
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 100,
                                width: 120,
                                child: VideoPlayer(postVideo[index - 1]),
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
                          (dateChoice != null)
                              ? dateChoice.toLocal().toString().substring(
                                  0, dateChoice.toLocal().toString().length - 7)
                              : "Cliquez sur l'icone du calendrier pour choisir la date de cet evenement",
                          style: prefix0.Style.sousTitre(13)),
                      SizedBox(height: 10),
                      Container(
                        height: 60,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FloatingActionButton(
                              child: Icon(Icons.event_available,
                                  color: Colors.white),
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
                                      _isPrice = false;
                                      _isPosition = false;
                                      _isLoading = false;
                                      _isCategorie = false;
                                      monVal = false;
                                      numero = int.parse(text);
                                    });
                                  },
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300),
                                  cursorColor: prefix0.colorText,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(Icons.looks_4,
                                          color: _isNumber
                                              ? prefix0.colorText
                                              : Colors.grey),
                                      hintText: "Nombre de ticket",
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
                          prefixIcon: Icon(Icons.looks_5,
                              color: _isPosition
                                  ? prefix0.colorText
                                  : Colors.grey),
                          hintText:
                              "Lieu (ex: Palais de la Culture Treichville, Abidjan)",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          )),
                    ),
                  ),
                ),
              ),
              new Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    "Veuillez entrer les prix des différents tickets en les separants par des virgules",
                    style: prefix0.Style.sousTitre(13)),
              ),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.transparent,
                  elevation: _isPrice ? 4.0 : 0.0,
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
                            color: _isPrice
                                ? prefix0.colorText
                                : prefix0.backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: new TextField(
                      controller: priceCtrl,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      cursorColor: prefix0.colorText,
                      onChanged: (text) {
                        setState(() {
                          _isPrice = true;
                          _isName = false;
                          _isDescribe = false;
                          _isPosition = false;
                          _isNumber = false;
                          _isLoading = false;
                          _isCategorie = false;
                          monVal = false;
                          price = text;
                        });
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_6,
                              color:
                                  _isPrice ? prefix0.colorText : Colors.grey),
                          hintText: "(Ex: 2000, 5000) ou Gratuit",
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
                      Text("Créer Un Evenement !",
                          style: prefix0.Style.secondTitre(22)),
                      SizedBox(height: 10.0),
                      Text("Vendez vos tickets,",
                          style: prefix0.Style.sousTitre(14),
                          textAlign: TextAlign.center),
                      Text("managé votre évenement",
                          style: prefix0.Style.sousTitre(14),
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
    final form = formKey.currentState;
    setState(() => _isLoading = true);
    //print('$nameProduct , $describe , $dropdownValue, $base64Image, $base64Video, ${dateChoice.toString()} , ${numero.toString()}, $position, $price');
    if (nameProduct.length > 7 &&
        describe.length > 20 &&
        dropdownValue != null &&
        base64Image != '' &&
        dateChoice != null &&
        numero != null &&
        position.length > 5 &&
        price.length > 4) {
      String imageCover = post[0].path.split('/').last;
      String videoPub = (video != null) ? video.path.split('/').last : "";
      final event = await new ConsumeAPI().setEvent(
          nameProduct,
          describe,
          dropdownValue,
          imageCover,
          base64Image,
          position,
          dateChoice.toString(),
          numero,
          price,
          videoPub,
          base64Video);
      setState(() => _isLoading = false);
      print(event);
      if (event == 'found') {
        setState(() {
          dateChoice = null;
          video = null;
          dropdownValue = null;
          post.clear();
          postVideo.clear();

          nameProductCtrl.clear();
          describeCtrl.clear();
          positionCtrl.clear();
          priceCtrl.clear();
          numeroCtrl.clear();
          base64Image = '';
          base64Video = '';
          nameProduct = "";
          describe = "";
          position = "";
          price = "";
          numero = null;
        });
        await _askedToLead(
            "Votre évènement est en ligne, vous pouvez le manager où que vous soyez",
            true);
      } else if (event == 'FreeInPayPrice') {
        await _askedToLead(
            "Un evenemnt Gratuit ne peut être assimilé à un prix", false);
      } else if (event == 'IncorrectPrice') {
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
                        if (success) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                        }
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
