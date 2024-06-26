import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/helper.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../Provider/VideoCompressApi.dart';
import 'Login.dart';
import 'choice_method_payement.dart';

class CreateDeals extends StatefulWidget {
  static String rootName = '/createDeals';
  @override
  _CreateDealsState createState() => _CreateDealsState();
}

class _CreateDealsState extends State<CreateDeals> {
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final picker = ImagePicker();
  VideoPlayerController? _controller;
  File? video;
  List<File> post = [];
  List<String> base64Image = [];
  String base64Video = "";
  int priceVip = 0;
  List<VideoPlayerController> postVideo = [];
  List<dynamic> allCategories = [];
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
  String? dropdownValue;
  bool _isName = true;
  bool _isDescribe = false;
  bool _isPrice = false;
  bool _isQuantity = false;
  bool _isPosition = false;
  bool _isNumber = false;
  String numero = "";
  TextEditingController numeroCtrl = new TextEditingController();
  bool requestLoading = false;
  bool _isCategorie = false;
  bool monVal = false, showFloatingAction = true;
  User? user;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCategorie();
    //verifyIfUserHaveReadModalExplain();
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
    User newClient = await DBProvider.db.getClient();
    final data = await consumeAPI.getAllCategrieWithoutFilter("deal");
    numeroCtrl.text = newClient.numero != "null" ? newClient.numero : "";
    setState(() {
      allCategories = data['result']["categories"];
      priceVip = data['result']["AMOUNT_FOR_PAY_VIP_DEALS"];
      user = newClient;
      numero = newClient.numero;
    });
  }

  verifyIfUserHaveReadModalExplain() async {
    final prefs = await SharedPreferences.getInstance();
    final bool asRead = prefs.getBool('readCreateDealsModalExplain') ?? false;
    if (!asRead) {
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}premium.svg",
          "💁🏽‍♂️ Si vous enregistrez plus de 25 différents articles nous vous offrons une publication d'article en mode VIP gratuitement 🤝.\n(Le mode VIP vous permet d'avoir plus de publicité, de fonctionnalité et de visibilité).",
          context,
          true);
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}createShop.png",
          "1/5 - ⚠️ Attention: Vous ne devez pas mettre votre numero ni le prix de l'article sur les images ou la description de l'article.\nVeuillez envoyer des images professionnelles, bien rognées, qui ne comportent pas des espaces noirs de capture d'écran.",
          context);

      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}createShop.png",
          "2/5 - Vous pouvez vendre tout article déplaçable, les clients intéressés vous contacterons dans l'application et une fois accord conclu entre vous, nous nous occupons de livrer au client.\nVous detenez un compte dans l'application qui vous permet de recevoir l'argent des clients et vous pouvez retrier cet argent cumulé par mobile money, crypto-monnaie ou carte bancaire.",
          context);
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}createShop.png",
          "3/5 - ⚠️ Attention: Vous n'avez pas besoin de créer plusieurs postes d'articles qui ont le même titre et qui ont des images presque similaires.\nVous pouvez enregistrer l'article, mentionner dans les details de l'article qu'il y en a de plusieurs types et envoyer les différentes images de ces types d'articles.",
          context);
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}createShop.png",
          "4/5 - ⚠️ Attention: Si nous remarquons que vous bourrez la liste des publications d'articles toutes les 72h d'un même article dans l'optique d'être en tête d'affichage à chaque fois, nous serons dans l'obligation de suspendre temporairement votre compte Shouz.",
          context);
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}createShop.png",
          "5/5 - Tout article que vous envoyé sur Shouz peut être marchandé par les clients dans l'optique d'obtenir des réductions, mais libre à vous d'accepter ou de rejeter l'offre du client. C'est Shouz qui s'occupera de la livraison et non vous.",
          context);
      await prefs.setBool('readCreateDealsModalExplain', true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, allowCompression: true, type: FileType.image);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      final end = (files.length > 6) ? 6 : files.length;
      if (6 - (end + post.length) >= 0) {
        final images =
            files.sublist(0, end - post.length > 0 ? end - post.length : end);
        final newBase64Image = images
            .map((image) => base64Encode(image.readAsBytesSync()))
            .toList();
        final List<File> allImage = List.from(post)..addAll(images);
        setState(() {
          post = allImage;
          base64Image = List.from(base64Image)..addAll(newBase64Image);
        });
        if (allImage.length == 1) {
          showDialog(
              context: context,
              builder: (BuildContext context) => dialogCustomError(
                  'Vous avez sélectionnez une seule image',
                  "Une image c'est pas mal mais vous pouvez envoyer plus d'image pour que les clients puissent mieux voir votre article.\nVous pouvez ajouter les images d'article similaire par exemple.",
                  context),
              barrierDismissible: false);
        }
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => dialogCustomError(
                'Trop d\'image séléctionnées',
                "Vous ne pouvez que prendre 6 photos maximum pour un produit.\n",
                context),
            barrierDismissible: false);
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
        MediaInfo? videoCompressed =
            await VideoCompressApi.getMediaInfo(movie.path);

        if (videoCompressed!.filesize! / 1000000 < 10) {
          video = videoCompressed.file!;
          base64Video = base64Encode(videoCompressed.file!.readAsBytesSync());
        } else {
          setState(() {
            postVideo = [];
          });
          showSnackBar(context,
              "Nous avons compressé votre video mais elle est encore trop lourde, veuillez choisir une autre si possible");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var loginBtn = ElevatedButton(
      onPressed: _submit,
      child: Text(
        "Envoyer le produit",
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
                          _isQuantity = false;
                          _isDescribe = false;
                          _isPrice = false;
                          _isPosition = false;
                          _isNumber = false;
                          requestLoading = false;
                          _isCategorie = false;
                          monVal = false;
                          nameProduct = text;
                        });
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_one,
                              color: _isName ? colorText : Colors.grey),
                          hintText: "Nom du produit",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
              Padding(
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
                              width: MediaQuery.of(context).size.width * 0.42,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: backgroundColorSec,
                                  border: Border.all(
                                      width: 1.0,
                                      color: _isPrice
                                          ? colorText
                                          : backgroundColor),
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: TextField(
                                controller: priceCtrl,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                                cursorColor: colorText,
                                onChanged: (text) {
                                  setState(() {
                                    _isPrice = true;
                                    _isQuantity = false;
                                    _isName = false;
                                    _isDescribe = false;
                                    _isPosition = false;
                                    _isNumber = false;
                                    requestLoading = false;
                                    _isCategorie = false;
                                    monVal = false;
                                    price = text.toString();
                                  });
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.looks_two,
                                        color:
                                            _isPrice ? colorText : Colors.grey),
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
                              width: MediaQuery.of(context).size.width * 0.42,
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              decoration: BoxDecoration(
                                  color: backgroundColorSec,
                                  border: Border.all(
                                      width: 1.0,
                                      color: _isQuantity
                                          ? colorText
                                          : backgroundColor),
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: TextField(
                                controller: quantityCtrl,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                                cursorColor: colorText,
                                onChanged: (text) {
                                  setState(() {
                                    _isQuantity = true;
                                    _isPrice = false;
                                    _isName = false;
                                    _isDescribe = false;
                                    _isPosition = false;
                                    _isNumber = false;
                                    requestLoading = false;
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
                                            ? colorText
                                            : Colors.grey),
                                    hintText: "Qte en Stock",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                        ]),
                  )),
              Padding(
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
                          _isDescribe = true;
                          _isPrice = false;
                          _isPosition = false;
                          _isQuantity = false;
                          _isNumber = false;
                          requestLoading = false;
                          _isCategorie = false;
                          monVal = false;
                          describe = text;
                        });
                      },
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      maxLength: 260,
                      maxLines: 7,
                      cursorColor: colorText,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_4,
                              color: _isDescribe ? colorText : Colors.grey),
                          labelText: "Donnez plus de details sur l'article",
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
                                height: 100,
                                width: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Charger les images",
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
                        color: backgroundColorSec,
                        border: Border.all(
                            width: 1.0,
                            color: _isCategorie ? colorText : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: allCategories.length == 0
                        ? LoadingIndicator(
                            indicatorType: Indicator.ballScale,
                            colors: [colorText],
                            strokeWidth: 2)
                        : DropdownButtonFormField<String>(
                            hint: Text('Veuillez choisir une categorie',
                                style: Style.sousTitre(14)),
                            value: dropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            isExpanded: true,
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.white),
                            onChanged: (newValue) {
                              setState(() {
                                _isCategorie = true;
                                dropdownValue = newValue!;
                                _isName = false;
                                _isDescribe = false;
                                _isQuantity = false;
                                _isPrice = false;
                                _isPosition = false;
                                _isNumber = false;
                                requestLoading = false;
                                monVal = false;
                              });
                            },
                            items: allCategories.map((value) {
                              return DropdownMenuItem<String>(
                                value: value['_id'],
                                child: Text(value['name'],
                                    style: Style.sousTitre(15)),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 130,
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Text(
                          "Faites entrer un numéro sur lequel on pourra vous joindre pour la recuperation de l'article",
                          style: Style.sousTitre(13)),
                      SizedBox(height: 10),
                      Card(
                        color: Colors.transparent,
                        elevation: _isNumber ? 4.0 : 0.0,
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
                                  color:
                                      _isNumber ? colorText : backgroundColor),
                              borderRadius: BorderRadius.circular(50.0)),
                          child: TextField(
                            controller: numeroCtrl,
                            onChanged: (text) {
                              setState(() {
                                _isNumber = true;
                                _isName = false;
                                _isDescribe = false;
                                _isQuantity = false;
                                _isPrice = false;
                                _isPosition = false;
                                requestLoading = false;
                                _isCategorie = false;
                                monVal = false;
                                numero = text.toString();
                              });
                            },
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                            cursorColor: colorText,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.looks_5,
                                    color: _isNumber ? colorText : Colors.grey),
                                hintText: "Numero de telephone",
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ),
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
                          _isNumber = false;
                          _isDescribe = false;
                          _isPrice = false;
                          requestLoading = false;
                          _isQuantity = false;
                          _isCategorie = false;
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
                          prefixIcon: Icon(Icons.looks_6,
                              color: _isPosition ? colorText : Colors.grey),
                          hintText: "Dans quelle commune/quartier l'article se trouve",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12
                          )),
                    ),
                  ),
                ),
              ),
              if(1 != 1) Padding(
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
                        onChanged: (value) async {
                          if (user!.numero != 'null' &&
                              user!.wallet >= priceVip) {
                            setState(() {
                              monVal = value!;
                            });
                          } else {
                            if (user!.numero != 'null' && user!.numero.isNotEmpty) {
                              Fluttertoast.showToast(
                                  msg:
                                      "Votre solde est insufisant pour vouloir rendre ce produit V.I.P",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: colorError,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              Timer(const Duration(seconds: 2), () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (builder) => ChoiceMethodPayement(
                                          key: UniqueKey(),
                                          isRetrait: false,
                                        )));
                              });
                            } else {
                              await modalForExplain(
                                  "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                                  "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
                                  context,
                                  true);
                              Navigator.pushNamed(context, Login.rootName);
                            }
                          }
                        },
                      ),
                      Text(
                          'Booster cet article en VIP (${reformatNumberForDisplayOnPrice(priceVip)} ${user != null && user?.numero != 'null' ? user?.currencies : 'XOF'})',
                          style: Style.warning(11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        requestLoading ? const CircularProgressIndicator() : loginBtn
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
                            style: Style.secondTitre(22)),
                        SizedBox(height: 10.0),
                        Text(
                          "Vendez tout ce que vous voulez,",
                          style: Style.sousTitre(14),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "c’est sans frais.",
                          style: Style.sousTitre(14),
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
                          "https://wa.me/$serviceCall?text=Je veux mettre mon article en vente sur SHOUZ E-COMMERCE mais je ne sais pas comment m'y prendre."),
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
    if(user!.numero != 'null' && user!.numero.isNotEmpty) {
      if (nameProduct.length < 3) {
        ready = false;

        showSnackBar(context, "Le nom du produit est trop court.");
      }
      if (quantity.length > 0 && int.parse(quantity) > 100) {
        ready = false;

        showSnackBar(context,
            "La quantité maximal qu'un article peut avoir dans Shouz est de 100");
      }
      if (describe.length < 25) {
        ready = false;
        showSnackBar(context,
            "Veuillez donner plus de détails dans le champs details articles.");
      }
      if (dropdownValue == null) {
        ready = false;
        showSnackBar(context, "Veuillez choisir une categorie pour l'article.");
      }
      if (base64Image.length == 0) {
        ready = false;
        showSnackBar(
            context, "Veuillez sélectionner au moins une image de l'article.");
      }
      if (numero.length != 10) {
        ready = false;
        showSnackBar(context,
            "Veuillez entrer un numéro de téléphone valide pour qu'on puisse vous appeler.");
      }
      if (position.length < 7) {
        ready = false;
        showSnackBar(context,
            "Donnez plus d'informations sur le lieu où on doit vous rencontrer pour récupérer l'article.");
      }
      if (price.length <= 2) {
        ready = false;
        showSnackBar(context, "Prix minimum d'un article doit être 500.");
      }
      if (base64Image.length < 2) {
        ready = false;
        showSnackBar(context,
            "Veuillez charger au moins 2 images de l'article afin que nos acheteurs puissent mieux voir votre article.");
      }
      if (ready) {
        if (user!.numero != "null") {
          setState(() => requestLoading = true);
          List<String> imageListTitle =
          post.map((image) => image.path.split('/').last).toList();

          String imageTitle = imageListTitle.join(',');
          String imagesBuffers = base64Image.join(',');
          String videoPub = (video != null) ? video!.path.split('/').last : "";
          int level = monVal ? 3 : 1;
          final product = await consumeAPI.setProductDeals(
              nameProduct,
              describe,
              dropdownValue!,
              imageTitle,
              imagesBuffers,
              position,
              level,
              numero,
              price,
              quantity,
              videoPub,
              base64Video);
          setState(() => requestLoading = false);
          if (product == 'found') {
            dropdownValue = null;
            post.clear();
            postVideo.clear();
            base64Image.clear();
            base64Video = "";
            nameProductCtrl.clear();
            describeCtrl.clear();
            priceCtrl.clear();
            quantityCtrl.clear();
            nameProduct = "";
            describe = "";
            price = "";

            await askedToLead(
                level == 3
                    ? "Votre produit est en ligne, vous pouvez le manager où que vous soyez"
                    : "Votre produit est en attente d'approbation par notre service de régularisation, vous recevrez une notification si votre article a été approuvé ou pas",
                true,
                context);
            openAppReview(context);
          } else if (product == 'notFound') {
            showDialog(
                context: context,
                builder: (BuildContext context) => dialogCustomError(
                    'Plusieurs connexions à ce compte',
                    "Pour une question de sécurité nous allons devoir vous déconnecter.",
                    context),
                barrierDismissible: false);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (builder) => Login()));
          } else if (product == 'FreeInPayPrice') {
            await askedToLead(
                "Un produit Gratuit ne peut être assimilé à un prix",
                false,
                context);
          } else if (product == 'IncorrectPrice') {
            await askedToLead(
                "Erreur lors de la saisie des prix", false, context);
          } else {
            await askedToLead(
                "Echec avec la mise en ligne, veuillez ressayer ulterieurement",
                false,
                context);
          }
          setState(() {
            monVal = false;
          });
        } else {
          await modalForExplain(
              "${ConsumeAPI.AssetPublicServer}ready_station.svg",
              "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
              context,
              true);
          Navigator.pushNamed(context, Login.rootName);
        }
      }
    } else {
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}ready_station.svg",
          "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
          context,
          true);
      Navigator.pushNamed(context, Login.rootName);
    }
  }
}
