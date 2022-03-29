import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/Categorie.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:video_player/video_player.dart';

import '../MenuDrawler.dart';

class CreateEvent extends StatefulWidget {
  static String rootName = '/createEvent';
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  VideoPlayerController? _controller;
  final picker = ImagePicker();
  DateTime? dateChoice;
  late DateTime date = new DateTime.now();
  late TimeOfDay time = new TimeOfDay.now();
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final ConsumeAPI consumeAPI = new ConsumeAPI();
  int maxPlace = 0;
  List<File> post = [];
  File? video;
  String base64Image = "";
  String base64Video = "";
  List<VideoPlayerController> postVideo = [];
  List<String> allCategorie = [];
  String nameProduct = "";
  TextEditingController nameProductCtrl = new TextEditingController();
  TextEditingController eCtrl = new TextEditingController();
  String describe = "";
  String email = "";
  TextEditingController describeCtrl = new TextEditingController();
  TextEditingController emailCtrl = new TextEditingController();
  String position = "";
  TextEditingController positionCtrl = new TextEditingController();
  String price = "";
  TextEditingController priceCtrl = new TextEditingController();
  bool _isName = true;
  bool _isEmail = false;
  bool _isDescribe = false;
  bool _isPrice = false;
  bool onClickOfAddPrice = false;
  bool _isPosition = false;
  bool _isNumber = false;
  bool _isQuantity = false;
  int? numero;
  TextEditingController numeroCtrl = new TextEditingController();
  bool _isLoading = false;
  bool monVal = false;
  List<List<TextEditingController>> _controllers = [];
  List<Row> _fields = [];



  Future<Null> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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
    final TimeOfDay? picked =
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
    //final data = await consumeAPI.getAllCategrieWithoutFilter("event");
    final maxPlaceData = await consumeAPI.getMaxPlaceForCreateEvent();
    setState(() {
      //allCategorie = data;
      maxPlace = maxPlaceData;
    });
  }

  addTypeTicket() {
    final controllerPrice = TextEditingController();
    final controllerQuantity = TextEditingController();
    final field = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Card(
            color: Colors.transparent,
            elevation: _isPrice ? 4.0 : 0.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0)),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.35,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: backgroundColorSec,
                  border: Border.all(
                      width: 1.0,
                      color: _isPrice
                          ? colorText
                          : backgroundColor),
                  borderRadius: BorderRadius.circular(50.0)),
              child: new TextField(
                controller: controllerPrice,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300),
                cursorColor: colorText,
                onChanged: (text) {
                  setState(() {
                    _isName = true;
                    _isDescribe = false;
                    _isEmail = false;
                    _isPrice = false;
                    _isPosition = false;
                    _isNumber = false;
                    _isLoading = false;
                    monVal = false;
                  });
                },
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    border: InputBorder.none,
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
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: backgroundColorSec,
                  border: Border.all(
                      width: 1.0,
                      color: _isQuantity
                          ? colorText
                          : backgroundColor),
                  borderRadius: BorderRadius.circular(50.0)),
              child: new TextField(
                controller: controllerQuantity,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300),
                cursorColor: colorText,
                onChanged: (text) {
                  setState(() {
                    _isName = true;
                    _isDescribe = false;
                    _isEmail = false;
                    _isPrice = false;
                    _isPosition = false;
                    _isNumber = false;
                    _isLoading = false;
                    monVal = false;
                  });
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Quantité",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ),
          ),
        ]);

    setState(() {
      _controllers.add([controllerPrice, controllerQuantity]);
    _fields.add(field);
    onClickOfAddPrice = true;
    });
  }

  @override
  void dispose() {
    if(_controller != null) {
      _controller!.removeListener(() {});
      _controller!.dispose();
    }
    super.dispose();
  }

  Future getImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);

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
    var image = await picker.pickVideo(source: ImageSource.gallery);

    if (image != null) {
      if (postVideo.length < 1) {
        setState(() {
          _controller = VideoPlayerController.file(File(image.path));
          _controller!
            ..initialize().then((_) {
              _controller!.setLooping(true);
              setState(() {});
            });
          _controller!
            ..addListener(() {
              setState(() {});
            });
          postVideo.add(_controller!);
        });
        video = File(image.path);
        base64Video = base64Encode(File(image.path).readAsBytesSync());
      } else {
        setState(() {
          _controller = VideoPlayerController.file(File(image.path));
          _controller!
            ..initialize().then((_) {
              _controller!.setLooping(true);
              setState(() {});
            });
          _controller!
            ..addListener(() {
              setState(() {});
            });
          postVideo[0] = _controller!;
        });
        video = File(image.path);
        base64Video = base64Encode(File(image.path).readAsBytesSync());
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    var loginBtn = ElevatedButton(
      onPressed: _submit,
      child: new Text(
        "Enregistrer cet évenement",
        style: Style.sousTitreEvent(15),
      ),
      style: raisedButtonStyle,
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
                        color: backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isName
                                ? colorText
                                : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: new TextField(
                      controller: nameProductCtrl,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      cursorColor: colorText,
                      keyboardType: TextInputType.text,
                      onChanged: (text) {
                        setState(() {
                          _isName = true;
                          _isDescribe = false;
                          _isEmail = false;
                          _isPrice = false;
                          _isPosition = false;
                          _isNumber = false;
                          _isLoading = false;
                          monVal = false;
                          nameProduct = text;
                        });
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_one,
                              color: _isName ? colorText : Colors.grey),
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
                    height: 190,
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
                    child: new TextField(
                      controller: describeCtrl,
                      onChanged: (text) {
                        setState(() {
                          _isName = false;
                          _isEmail = false;
                          _isDescribe = true;
                          _isPrice = false;
                          _isPosition = false;
                          _isNumber = false;
                          _isLoading = false;
                          monVal = false;
                          describe = text;
                        });
                      },
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      maxLength: 360,
                      maxLines: 9,
                      cursorColor: colorText,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_two,
                              color: _isDescribe
                                  ? colorText
                                  : Colors.grey),
                          labelText: "Description de l'évènement",
                          labelStyle: TextStyle(
                            color: Colors.white,
                          )),
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
                                height: 110,
                                width: 110,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Charger une image",
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
                                post.removeAt(index - 1);
                                base64Image = "";
                              });
                            },
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 110,
                                width: 110,
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
                height: 155,
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
                                height: 140,
                                width: 130,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.movie_filter_outlined,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Une video illustrative (Pas obligatoire)",
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
                                postVideo.removeAt(index - 1);
                                base64Video = "";
                              });
                            },
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 140,
                                width: 130,
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
                              ? dateChoice!.toLocal().toString().substring(
                                  0, dateChoice!.toLocal().toString().length - 7)
                              : "Cliquez sur l'icone du calendrier pour choisir la date de cet evenement",
                          style: Style.sousTitre(13)),
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
                                    color: backgroundColorSec,
                                    border: Border.all(
                                        width: 1.0,
                                        color: _isNumber
                                            ? colorText
                                            : backgroundColor),
                                    borderRadius: BorderRadius.circular(50.0)),
                                child: new TextField(
                                  controller: numeroCtrl,
                                  onChanged: (text) {
                                    setState(() {
                                      _isNumber = true;
                                      _isName = false;
                                      _isEmail = false;
                                      _isDescribe = false;
                                      _isPrice = false;
                                      _isPosition = false;
                                      _isLoading = false;
                                      monVal = false;
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
                                      prefixIcon: Icon(Icons.looks_3,
                                          color: _isNumber
                                              ? colorText
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
                        color: backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isPosition
                                ? colorText
                                : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: new TextField(
                      controller: positionCtrl,
                      onChanged: (text) {
                        setState(() {
                          _isPosition = true;
                          _isName = false;
                          _isNumber = false;
                          _isEmail = false;
                          _isDescribe = false;
                          _isPrice = false;
                          _isLoading = false;
                          monVal = false;
                          position = text;
                        });
                      },
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      cursorColor: colorText,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_4,
                              color: _isPosition
                                  ? colorText
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
                    "Si l'entrée est gratuite, écrivez gratuit à la place du prix",
                    style: Style.sousTitre(13)),
              ),
              ..._listView(),
              /*new Padding(
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
                        color: backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isPrice
                                ? colorText
                                : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: new TextField(
                      controller: priceCtrl,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      cursorColor: colorText,
                      onChanged: (text) {
                        setState(() {
                          _isPrice = true;
                          _isName = false;
                          _isEmail = false;
                          _isDescribe = false;
                          _isPosition = false;
                          _isNumber = false;
                          _isLoading = false;
                          monVal = false;
                          price = text;
                        });
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_5,
                              color:
                                  _isPrice ? colorText : Colors.grey),
                          hintText: "(Ex: 2000:45, 5000:30) ou Gratuit",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),*/
              OutlinedButton(
                style: outlineButtonStyle,
                  onPressed: addTypeTicket, child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: colorText,),
                  Text("Ajouter ${onClickOfAddPrice ?'encore':''} un type de ticket"),
                ],
              )),
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
                      onChanged: (text) {
                        setState(() {
                          _isPrice = false;
                          _isName = false;
                          _isEmail = true;
                          _isDescribe = false;
                          _isPosition = false;
                          _isNumber = false;
                          _isLoading = false;
                          monVal = false;
                          email = text;
                        });
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_6,
                              color:
                              _isEmail ? colorText : Colors.grey),
                          hintText: "votre adresse email",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
              allCategorie.length < 3 ? Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Veuillez selectionner des categories pour votre évènement. (Max Categorie: 3)",
                  /*textAlign: TextAlign.justify,*/ style:
                Style.sousTitre(13.0),
                ),
              ):SizedBox(width: 10),
              allCategorie.length < 3 ? Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 10.0,
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.only(left: 10.0),
                      width: MediaQuery.of(context).size.width,
                      child: TypeAheadField(
                        hideSuggestionsOnKeyboardHide: false,
                        textFieldConfiguration: TextFieldConfiguration(
                          //autofautofocusocus: true,
                          controller: eCtrl,
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w300),

                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                                icon: Icon(Icons.add,
                                    color: Colors.black87, size: 32.0),
                                onPressed: () async {
                                  final etat = await new ConsumeAPI()
                                      .verifyCategorieExist(eCtrl.text);
                                  if (etat) {
                                    if (allCategorie.indexOf(eCtrl.text) == -1) {
                                      setState(() {
                                        allCategorie.add(eCtrl.text);
                                      });
                                    }
                                    eCtrl.clear();
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            DialogCustomError(
                                                'Erreur',
                                                'Categorie inexistante dans notre registre',
                                                context),
                                        barrierDismissible: false);
                                  }
                                }),
                            hintText:
                            "Economie, Bourse, Festival, Coupé décalé, Gospel, Boom Party",
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.grey[500],
                                fontSize: 13.0),
                          ),
                        ),
                        hideOnEmpty: true,
                        suggestionsCallback: (pattern) async {
                          return new ConsumeAPI().getAllCategrie(pattern.length > 0 ? pattern :'', 'not', '2');
                        },
                        itemBuilder: (context, suggestion) {
                          final categorie = suggestion as Categorie;
                          return ListTile(
                            title: Text(categorie.name,
                                style: Style.priceDealsProduct()),
                            trailing: (categorie.popularity == 1)
                                ? Icon(Icons.star, color: colorText)
                                : Icon(Icons.star_border,
                                color: colorText),
                          );
                        },
                        onSuggestionSelected: (suggestion) async {
                          final categorie = suggestion as Categorie;
                          eCtrl.text = categorie.name;
                        },
                      ),
                    ),
                  )):SizedBox(width: 10),
              Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: Text('Categories choisies',
                      textAlign: TextAlign.start,
                      style: Style.enterChoiceHobieInSecondaryOption(
                          16.0))),
              allCategorie.length == 0
                  ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 25.0),
                  child: Text(
                    "Veuillez choisir au moins une catégorie",
                    style: Style.sousTitreEvent(15),
                  ))
                  : Wrap(
                spacing: 6.0,
                children: <Widget>[
                  MasonryGridView.count(
                    physics: new BouncingScrollPhysics(),
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    padding: EdgeInsets.all(0.0),
                    itemCount: allCategorie.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Chip(
                        elevation: 10.0,
                        deleteIcon: Icon(Icons.delete,
                            color: Colors.black87, size: 17.0),
                        deleteButtonTooltipMessage: "Retirer",
                        onDeleted: () async {
                          setState(() {
                            allCategorie.removeAt(index);
                          });
                        },
                        avatar: CircleAvatar(
                            backgroundColor: colorText,
                            child: Text(
                                allCategorie[index]
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(color: Colors.white))),
                        label: Text(allCategorie[index]),
                        backgroundColor: Colors.white,
                      );
                    },

                  ),
                ],
              )
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
                      Text("Créer Un Evenement !",
                          style: Style.secondTitre(22)),
                      SizedBox(height: 10.0),
                      Text("Vendez vos tickets,",
                          style: Style.sousTitre(14),
                          textAlign: TextAlign.center),
                      Text("managé votre évenement",
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
    
    if (nameProduct.length > 5 &&
        describe.length > 20 &&
        allCategorie.length <= 3 &&
        allCategorie.length > 0 &&
        base64Image != '' &&
        dateChoice != null &&
        numero != null &&
        numero! <= maxPlace  &&
        position.length > 5 &&
        _controllers.length > 0 &&
        email.indexOf('@') > 4) {
      final array = _controllers
          .map((arrayItem) => "${arrayItem[0].text}:${arrayItem[1].text.length > 0 ? arrayItem[1].text:'0'}")
          .toList()
          .where((element) => element != ":0")
          .toList();
      final placeTotal = array.map((e) => int.parse(e.substring(e.indexOf(':') +1))).reduce((value, element) => value + element);
      if(numero == placeTotal){
        String imageCover = post[0].path.split('/').last;
        String videoPub = (video != null) ? video!.path.split('/').last : "";
        final event = await new ConsumeAPI().setEvent(
            nameProduct,
            describe,
            allCategorie,
            imageCover,
            base64Image,
            position,
            dateChoice.toString(),
            numero!,
            array.join(','),
            email,
            videoPub,
            base64Video

        );
        setState(() => _isLoading = false);
        if (event['etat'] == 'found') {
          setState(() {
            dateChoice = null;
            video = null;
            allCategorie = [];
            post.clear();
            postVideo.clear();

            emailCtrl.clear();
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
            email = '';
            numero = null;
          });
          await askedToLead(
              "Votre évènement est en ligne, vous pouvez le manager où que vous soyez",
              true, context);
          Navigator.pushNamed(context, MenuDrawler.rootName);
        }
        else {
          await askedToLead(
              event['error'],
              false, context);
        }
      }else {
        setState(() => _isLoading = false);
        await askedToLead(
            "Le nombre de ticket de tous vos types de tickets est différent du nombre total de ticket que vous avez fait rentrer dans la section [3].\nVeuillez rectifier cela pour pouvoir envoyer votre évènement",
            false, context);
      }
    } else {
      setState(() => _isLoading = false);
      _showSnackBar("Remplissez correctement les champs avant d'envoyer (NB: Max Place ${maxPlace.toString()})");
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState?.showSnackBar(new SnackBar(
      backgroundColor: colorError,
      content: new Text(
        text,
        textAlign: TextAlign.center,
      ),
      action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
          }),
    ));
  }

  Widget DialogCustomError(String title, String message, BuildContext context) {
    bool isIos = Platform.isIOS;
    return isIos
        ? new CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        CupertinoDialogAction(
            child: Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop();
            })
      ],
    )
        : new AlertDialog(
      title: Text(title),
      content: Text(message),
      elevation: 20.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)),
      actions: <Widget>[
        FlatButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop();
            })
      ],
    );
  }

  List<Widget> _listView() {
    List<Widget> tabs = [];
    _fields.map((value) {
      tabs.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 60,
            width: double.infinity,
            child: value,
          )));
    }).toList();
    return tabs;
  }
}
