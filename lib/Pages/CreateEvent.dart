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
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../Constant/helper.dart';
import '../MenuDrawler.dart';
import '../Provider/VideoCompressApi.dart';

class CreateEvent extends StatefulWidget {
  static String rootName = '/createEvent';
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  VideoPlayerController? _controller;
  final picker = ImagePicker();
  DateTime? dateChoice;
  DateTime? dateChoiceEnd;
  late DateTime date = new DateTime.now();
  late DateTime dateEnd = new DateTime.now();
  late TimeOfDay time = new TimeOfDay.now();
  late TimeOfDay timeEnd = new TimeOfDay.now();
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldMessengerState>();
  final ConsumeAPI consumeAPI = new ConsumeAPI();
  int durrationEvent = 0;
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
  bool _isQuantity = false;
  bool _isLoading = false;
  bool monVal = false, showFloatingAction = true;
  ScrollController _scrollController = ScrollController();
  List<List<TextEditingController>> _controllers = [];
  List<Row> _fields = [];

  Future<Null> selectDate(BuildContext context, bool begin) async {
    final initialDate = begin ? date : dateEnd;
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(new DateTime.now().year),
        lastDate: new DateTime(new DateTime.now().year + 2));

    if (picked != null) {
      setState(() {
        if (begin) {
          date = picked;
        } else {
          dateEnd = picked;
        }
      });
      selectTime(context, begin);
    }
  }

  Future<Null> selectTime(BuildContext context, bool begin) async {
    final initialTime = begin ? time : timeEnd;
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: initialTime);

    if (picked != null) {
      setState(() {
        if (begin) {
          time = picked;
          dateChoice =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        } else {
          timeEnd = picked;
          dateChoiceEnd = DateTime(dateEnd.year, dateEnd.month, dateEnd.day,
              timeEnd.hour, timeEnd.minute);
        }
        if (dateChoice != null && dateChoiceEnd != null) {
          durrationEvent = daysBetween(dateChoice!, dateChoiceEnd!);
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCategorie();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        setState(() {
          showFloatingAction = false;
        });
      } else {
        setState(() {
          showFloatingAction = true;
        });
      }
    });
  }

  loadCategorie() async {
    final maxPlaceData = await consumeAPI.getMaxPlaceForCreateEvent();
    setState(() {
      //allCategorie = data;
      maxPlace = maxPlaceData;
    });
    addTypeTicket();
  }

  addTypeTicket() {
    final controllerPrice =
        TextEditingController(text: maxPlace == 10 ? 'gratuit' : '');
    final controllerQuantity = TextEditingController();
    final field =
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
            Widget>[
      Card(
        color: Colors.transparent,
        elevation: _isPrice ? 4.0 : 0.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.4,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: backgroundColorSec,
              border: Border.all(
                  width: 1.0, color: _isPrice ? colorText : backgroundColor),
              borderRadius: BorderRadius.circular(50.0)),
          child: TextField(
            controller: controllerPrice,
            enabled: maxPlace != 10,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
            cursorColor: colorText,
            onChanged: (text) {
              setState(() {
                _isName = true;
                _isDescribe = false;
                _isEmail = false;
                _isPrice = false;
                _isPosition = false;
                _isLoading = false;
                monVal = false;
              });
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Prix du ticket",
                hintStyle: TextStyle(
                  color: Colors.white,
                )),
          ),
        ),
      ),
      Card(
        color: Colors.transparent,
        elevation: _isQuantity ? 4.0 : 0.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.4,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: backgroundColorSec,
              border: Border.all(
                  width: 1.0, color: _isQuantity ? colorText : backgroundColor),
              borderRadius: BorderRadius.circular(50.0)),
          child: TextField(
            controller: controllerQuantity,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
            cursorColor: colorText,
            onChanged: (text) {
              setState(() {
                _isName = true;
                _isDescribe = false;
                _isEmail = false;
                _isPrice = false;
                _isPosition = false;
                _isLoading = false;
                monVal = false;
              });
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Nbre de ticket",
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
    if (_controller != null) {
      _controller!.removeListener(() {});
      _controller!.dispose();
    }
    _scrollController.dispose();
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
    var movie = await picker.pickVideo(source: ImageSource.gallery);
    if (movie != null) {
      if (postVideo.length < 1) {
        setState(() {
          _controller = VideoPlayerController.file(File(movie.path));
          _controller!
            ..initialize().then((_) {
              _controller!.setLooping(true);
            });
          _controller!..addListener(() {});
          postVideo.add(_controller!);
        });

        var videoCompressed = await VideoCompressApi.getMediaInfo(movie.path);
        if (videoCompressed!.filesize! / 1000000 < 10) {
          video = videoCompressed.file!;
          base64Video = base64Encode(videoCompressed.file!.readAsBytesSync());
        } else {
          setState(() {
            postVideo = [];
          });
          showSnackBar(context,
              "Nous avons compressé votre video mais elle est encore trop lourd, veuillez choisir une autre si possible");
        }
      } else {
        setState(() {
          _controller = VideoPlayerController.file(File(movie.path));
          _controller!
            ..initialize().then((_) {
              _controller!.setLooping(true);
            });
          _controller!..addListener(() {});
          postVideo[0] = _controller!;
        });
        var videoCompressed = await VideoCompressApi.getMediaInfo(movie.path);
        if (videoCompressed!.filesize! / 1000000 < 10) {
          video = videoCompressed.file!;
          base64Video = base64Encode(videoCompressed.file!.readAsBytesSync());
        } else {
          setState(() {
            postVideo = [];
          });
          showSnackBar(context,
              "Nous avons compressé votre video mais elle est encore trop lourd, veuillez choisir une autre si possible");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var loginBtn = ElevatedButton(
      onPressed: _submit,
      child: Text(
        "Enregistrer cet évenement",
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
                            color: _isName ? colorText : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: TextField(
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
              Padding(
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
                            color: _isDescribe ? colorText : backgroundColor),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: TextField(
                      controller: describeCtrl,
                      onChanged: (text) {
                        setState(() {
                          _isName = false;
                          _isEmail = false;
                          _isDescribe = true;
                          _isPrice = false;
                          _isPosition = false;
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
                              color: _isDescribe ? colorText : Colors.grey),
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
              if (maxPlace > 10)
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
                                        "Une video illustrative (Facultatif)",
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      if (dateChoice == null && dateChoiceEnd == null)
                        Text(
                            "Cliquez sur les bouttons ci-dessous pour marquer les dates de l'évènement",
                            style: Style.sousTitre(13)),
                      if (dateChoice != null || dateChoiceEnd != null)
                        Text(
                            "${(dateChoice != null) ? formatedDateForLocal(dateChoice!) : ' '} - ${(dateChoiceEnd != null) ? formatedDateForLocal(dateChoiceEnd!) : ' '}",
                            style: Style.sousTitre(13)),
                      SizedBox(height: 5),
                      if (durrationEvent > 0)
                        Text(
                          "L'évènement sera en ${durrationEvent.toString()} jour${durrationEvent > 1 ? 's' : ''} donc décodable ${durrationEvent > 1 ? durrationEvent : 'une'} fois",
                          style: Style.sousTitre(13, colorError),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: 5),
                      Container(
                        height: 60,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                selectDate(context, true);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    color: colorPrimary,
                                    size: 14,
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text("Date debut", style: Style.chatIsMe(15)),
                                ],
                              ),
                              style: raisedButtonStyle,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                selectDate(context, false);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    color: colorPrimary,
                                    size: 14,
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text("Date Fin", style: Style.chatIsMe(15)),
                                ],
                              ),
                              style: raisedButtonStyle,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
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
                            color: _isPosition ? colorText : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: TextField(
                      controller: positionCtrl,
                      onChanged: (text) {
                        setState(() {
                          _isPosition = true;
                          _isName = false;
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
                              color: _isPosition ? colorText : Colors.grey),
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
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    maxPlace > 10
                        ? "Si l'entrée est gratuite, écrivez gratuit à la place du prix"
                        : "Vous ne pouvez que faire des entrées gratuites avec ce abonnement",
                    style: Style.sousTitre(13)),
              ),
              ..._listView(),
              if (maxPlace != 10)
                OutlinedButton(
                    style: outlineButtonStyle,
                    onPressed: addTypeTicket,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: colorText,
                        ),
                        Text(
                            "Ajouter ${onClickOfAddPrice ? 'encore' : ''} un type de ticket"),
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
                            color: _isEmail ? colorText : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: TextField(
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
                          _isLoading = false;
                          monVal = false;
                          email = text;
                        });
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_6,
                              color: _isEmail ? colorText : Colors.grey),
                          hintText: "votre adresse email",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
              if (allCategorie.length < (maxPlace != 10 ? 3 : 1))
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Veuillez selectionner des categories pour votre évènement. (Max Categorie: ${maxPlace != 10 ? '3' : '1'})",
                    /*textAlign: TextAlign.justify,*/ style:
                        Style.sousTitre(13.0),
                  ),
                ),
              if (allCategorie.length < (maxPlace != 10 ? 3 : 1))
                Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 10.0,
                      child: Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 10.0),
                        width: MediaQuery.of(context).size.width,
                        child: TypeAheadField(
                          controller: eCtrl,
                          builder: (context, controller, focusNode) {
                            return TextField(
                              //autofautofocusocus: true,
                              controller: controller,
                              focusNode:focusNode,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w300),

                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                "Economie, Bourse, Festival, Coupé décalé, Gospel, Boom Party",
                                hintStyle: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey[500],
                                    fontSize: 13.0),
                              ),
                            );
                          },
                          hideOnEmpty: true,
                          suggestionsCallback: (pattern) async {
                            return await consumeAPI.getAllCategrie(
                                pattern.length > 0 ? pattern : '', 'not', '2');
                          },
                          itemBuilder: (context, suggestion) {
                            final categorie = suggestion as Categorie;
                            return ListTile(
                              title: Text(categorie.name,
                                  style: Style.priceDealsProduct()),
                              trailing: (categorie.popularity == 1)
                                  ? Icon(Icons.star, color: colorText)
                                  : Icon(Icons.star_border, color: colorText),
                            );
                          },
                          onSelected: (suggestion) async {
                            final categorie = suggestion as Categorie;
                            eCtrl.text = categorie.name;
                            final etat = await consumeAPI
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
                                      dialogCustomError(
                                          'Erreur',
                                          'Categorie inexistante dans notre registre',
                                          context),
                                  barrierDismissible: false);
                            }
                          },
                        ),
                      ),
                    )),
              Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: Text('Categories choisies',
                      textAlign: TextAlign.start,
                      style: Style.enterChoiceHobieInSecondaryOption(16.0))),
              allCategorie.length == 0
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 25.0),
                      child: Text(
                        "Veuillez choisir au moins une catégorie",
                        style: Style.titleInSegmentInTypeError(),
                      ))
                  : Wrap(
                      spacing: 6.0,
                      children: <Widget>[
                        MasonryGridView.count(
                          physics: const BouncingScrollPhysics(),
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
                                  child: Center(
                                    child: Text(
                                        allCategorie[index]
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: Style.simpleTextOnBoard(14, Style.white)),
                                  )),
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
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Style.white,)
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          controller: _scrollController,
          children: [
            Padding(
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
            )
          ],
        ),
      ),
      floatingActionButton: showFloatingAction
          ? Container(
              width: 180,
              child: ElevatedButton(
                style: raisedButtonStyle,
                onPressed: () async {
                  await launchUrl(
                      Uri.parse(
                          "https://wa.me/$serviceCall?text=Je veux créer mon évènement sur SHOUZ ÉVENEMENTIEL mais je ne sais pas comment m'y prendre."),
                      mode: LaunchMode.externalApplication);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.support_agent),
                    Text(
                      "Besoin aide ?",
                      style: Style.simpleTextOnBoard(14, colorPrimary),
                    ),
                  ],
                ),
              ))
          : null,
    );
  }

  void _submit() async {
    bool ready = true;
    if (nameProduct.length < 3) {
      ready = false;

      showSnackBar(context, "Le titre de l'évènement est trop court.");
    }
    if (describe.length < 17) {
      ready = false;
      showSnackBar(context,
          "Veuillez donner plus de détails dans le champs details de l'évènement.");
    }
    if (allCategorie.length == 0) {
      ready = false;
      showSnackBar(
          context, "Veuillez choisir au moins une categorie pour l'événement.");
    }
    if (allCategorie.length > 3) {
      ready = false;
      showSnackBar(context,
          "Vous ne pouvez que choisir au plus 3 categories pour l'événement.");
    }
    if (base64Image.length == 0) {
      ready = false;
      showSnackBar(context, "Veuillez sélectionner l'image de l'événement.");
    }

    if (dateChoice == null) {
      ready = false;
      showSnackBar(context, "Veuillez choisir la date de debut de l'évènement");
    }
    if (dateChoiceEnd == null) {
      ready = false;
      showSnackBar(context, "Veuillez choisir la date de fin de l'évènement");
    }
    if (durrationEvent >= 8) {
      ready = false;
      showSnackBar(context,
          "Votre évènement se deroulera sur ${durrationEvent.toString()} jours ? Verifiez les dates de debut et fin s'il vous plait.");
    }
    if (position.length < 6) {
      ready = false;
      showSnackBar(context,
          "Donnez plus d'informations sur le lieu où on doit vous rencontrer pour récupérer l'article.");
    }
    if (_controllers.length == 0) {
      ready = false;
      showSnackBar(
          context, "Faites entrer le prix et la quantité des types de ticket");
    }
    if (email.indexOf('@') <= 3) {
      ready = false;
      showSnackBar(context, "Faites entrer une adresse email valide.");
    }

    if (ready) {
      final array = _controllers
          .map((arrayItem) =>
              "${arrayItem[0].text}:${arrayItem[1].text.length > 0 ? arrayItem[1].text : '0'}")
          .toList()
          .where((element) => element != ":0")
          .toList();
      final placeTotal = array
          .map((e) => int.parse(e.substring(e.indexOf(':') + 1)))
          .reduce((value, element) => value + element);
      final List<bool> isValidArrayForPrice = array.map((e) {
        if (e.split(':')[0].toLowerCase().indexOf("gratuit") != -1 ||
            int.tryParse(e.split(':')[0]) != null) {
          return true;
        } else {
          return false;
        }
      }).toList();
      if (placeTotal <= maxPlace && isValidArrayForPrice.indexOf(false) == -1) {
        setState(() => _isLoading = true);
        String imageCover = post[0].path.split('/').last;
        String videoPub = (video != null) ? video!.path.split('/').last : "";
        final event = await consumeAPI.setEvent(
            nameProduct,
            describe,
            allCategorie,
            imageCover,
            base64Image,
            position,
            dateChoice.toString(),
            dateChoiceEnd.toString(),
            placeTotal,
            array.join(','),
            email,
            durrationEvent,
            videoPub,
            base64Video);
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
            base64Image = '';
            base64Video = '';
            nameProduct = "";
            describe = "";
            position = "";
            price = "";
            email = '';
          });
          await askedToLead(
              "Votre évènement est en ligne, vous pouvez le manager où que vous soyez",
              true,
              context);
          Navigator.pushNamedAndRemoveUntil(
              context, MenuDrawler.rootName, (Route<dynamic> route) => false);
        } else {
          await askedToLead(event['error'], false, context);
        }
      } else {
        await askedToLead(
            "Votre nombre maximum de ticket est de $maxPlace.\nSi un type de ticket est gratuit ecrivez juste gratuit à la place du prix du ticket",
            false,
            context);
      }
    }
  }

  Widget dialogCustomError(String title, String message, BuildContext context) {
    bool isIos = Platform.isIOS;
    return isIos
        ? CupertinoAlertDialog(
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
        : AlertDialog(
            title: Text(title),
            content: Text(message),
            elevation: 20.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            actions: <Widget>[
              TextButton(
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
