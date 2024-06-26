import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/helper.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:video_player/video_player.dart';

import '../Provider/VideoCompressApi.dart';
import 'LoadHide.dart';
import 'Login.dart';

class UpdateDeals extends StatefulWidget {
  final DealsSkeletonData dealsDetailsSkeleton;
  const UpdateDeals({required Key key, required this.dealsDetailsSkeleton});
  @override
  _UpdateDealsState createState() => _UpdateDealsState();
}

class _UpdateDealsState extends State<UpdateDeals> {
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final picker = ImagePicker();
  VideoPlayerController? _controller;
  File? video;
  List<dynamic> post = [];
  List<String> base64Image = [];
  String base64Video = "";
  int priceVip = 0;
  List<dynamic> postVideo = [];
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
  User? user;
  ConsumeAPI consumeAPI = new ConsumeAPI();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialiseData();
    loadCategorie();
  }

  initialiseData() {
    nameProductCtrl.text = widget.dealsDetailsSkeleton.title;
    priceCtrl.text = widget.dealsDetailsSkeleton.price.toString().replaceAll(new RegExp(r'[^0-9]'),'');
    quantityCtrl.text = widget.dealsDetailsSkeleton.quantity.toString().replaceAll(new RegExp(r'[^0-9]'),'');
    describeCtrl.text = widget.dealsDetailsSkeleton.describe;
    numeroCtrl.text = widget.dealsDetailsSkeleton.numero.replaceAll(new RegExp(r'[^0-9]'),'');
    positionCtrl.text = widget.dealsDetailsSkeleton.lieu;

    setState(() {
      nameProduct = widget.dealsDetailsSkeleton.title;
      price = widget.dealsDetailsSkeleton.price.toString().replaceAll(new RegExp(r'[^0-9]'),'');
      quantity = widget.dealsDetailsSkeleton.quantity.toString().replaceAll(new RegExp(r'[^0-9]'),'');
      describe = widget.dealsDetailsSkeleton.describe;
      numero = widget.dealsDetailsSkeleton.numero.replaceAll(new RegExp(r'[^0-9]'),'');
      position = widget.dealsDetailsSkeleton.lieu;
      for(int index = 0; index < widget.dealsDetailsSkeleton.imageUrl.length; index++) {
        post.add({"type": "Network", "content" : widget.dealsDetailsSkeleton.imageUrl[index]});
        base64Image.add(widget.dealsDetailsSkeleton.imageUrl[index]);
      }
      if(widget.dealsDetailsSkeleton.video != "") {
        _controller = VideoPlayerController.network("${ConsumeAPI.AssetProductServer}${widget.dealsDetailsSkeleton.video}");
        _controller!
          ..initialize().then((_) {
            _controller!.setLooping(true);
          });
        _controller!
          ..addListener(() {
          });
        postVideo.add(_controller!);
        base64Video = widget.dealsDetailsSkeleton.video;
      }
    });
  }

  loadCategorie() async {
    User newClient = await DBProvider.db.getClient();
    final data = await consumeAPI.getAllCategrieWithoutFilter("deal");
    for(int index = 0; index < data['result']["categories"].length ; index++){
      if(data['result']["categories"][index]['name'] == widget.dealsDetailsSkeleton.categorieName){
        setState(() {
          dropdownValue = data['result']["categories"][index]['_id'];
        });
      }
    }
    setState(() {
      allCategories = data['result']["categories"];
      priceVip = data['result']["AMOUNT_FOR_PAY_VIP_DEALS"];
      user = newClient;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, allowCompression: true, type: FileType.image);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      final end = (files.length > 6) ? 6 : files.length;
      if(6 - (end + post.length) >= 0) {
        final images = files.sublist(0, end - post.length > 0 ? end - post.length : end  );
        final imageFormated = [];
        for(int index = 0; index < images.length; index++) {
          imageFormated.add({"type": "File", "content" : images[index]});
        }
        final newBase64Image = imageFormated
            .map((image) => base64Encode(image["content"].readAsBytesSync()))
            .toList();
        final List<dynamic> allImage = List.from(post)..addAll(imageFormated);
        setState(() {
          post = allImage;
          base64Image = List.from(base64Image)..addAll(newBase64Image);
        });
        if(allImage.length == 1) {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Vous avez sélectionnez une seule image', "Une image c'est pas mal mais vous pouvez envoyer plus d'image pour que les clients puissent mieux voir votre article.\nVous pouvez ajouter les images d'article similaire par exemple.", context),
              barrierDismissible: false);
        }
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialogCustomError('Trop d\'image séléctionnées', "Vous ne pouvez que prendre 6 photos maximum pour un produit.\n", context),
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
          _controller!
            ..addListener(() {
            });
          postVideo.add(_controller!);

        });
        var videoCompressed = await VideoCompressApi.getMediaInfo(movie.path);
        if(videoCompressed!.filesize! / 1000000 < 10) {
          video = videoCompressed.file!;
          base64Video = base64Encode(videoCompressed.file!.readAsBytesSync());
        } else {
          if(widget.dealsDetailsSkeleton.video != "") {
            _controller = VideoPlayerController.network("${ConsumeAPI.AssetProductServer}${widget.dealsDetailsSkeleton.video}");
            _controller!
              ..initialize().then((_) {
                _controller!.setLooping(false);
              });
            _controller!
              ..addListener(() {
              });
            postVideo = [_controller!];
          }
          showSnackBar(context, "Nous avons compressé votre video mais elle est encore trop lourd, veuillez choisir une autre si possible");
        }

      } else {
        setState(() {
          _controller = VideoPlayerController.file(File(movie.path));
          _controller!
            ..initialize().then((_) {
              _controller!.setLooping(true);

            });
          _controller!
            ..addListener(() {

            });

          postVideo[0] = _controller!;
        });
        var videoCompressed = await VideoCompressApi.getMediaInfo(movie.path);
        if(videoCompressed!.filesize! / 1000000 < 10) {
          video = videoCompressed.file!;
          base64Video = base64Encode(videoCompressed.file!.readAsBytesSync());
        } else {
          if(widget.dealsDetailsSkeleton.video != "") {
            _controller = VideoPlayerController.network("${ConsumeAPI.AssetProductServer}${widget.dealsDetailsSkeleton.video}");
            _controller!
              ..initialize().then((_) {
                _controller!.setLooping(false);
              });
            _controller!
              ..addListener(() {
              });
            postVideo = [_controller!];
          }
          showSnackBar(context, "Nous avons compressé votre video mais elle est encore trop lourde, veuillez choisir une autre si possible");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var loginBtn = ElevatedButton(
      onPressed: _submit,
      child: Text(
        "Enregistrer",
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
                            color: _isName
                                ? colorText
                                : backgroundColor),
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

                                    price = text.toString();
                                  });
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.looks_two,
                                        color: _isPrice
                                            ? colorText
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
                            color: _isDescribe
                                ? colorText
                                : backgroundColor),
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
                              color: _isDescribe
                                  ? colorText
                                  : Colors.grey),
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
                                      "les images (${post.length}/6)",
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
                        final ImageProvider<Object> imageProvider = post[index - 1]['type'] == "Network" ? NetworkImage("${ConsumeAPI.AssetProductServer}${post[index - 1]['content']}") : FileImage(post[index - 1]['content']) as ImageProvider<Object>;
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
                                      .map((data) => data["type"] == "Network" ? data["content"] as String : base64Encode(data['content'].readAsBytesSync())).toList();
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
                                        image: imageProvider,
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
                            color: _isCategorie
                                ? colorText
                                : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: allCategories.length == 0 ? LoadingIndicator(indicatorType: Indicator.ballScale,colors: [colorText], strokeWidth: 2) :  DropdownButtonFormField<String>(

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
                                  color: _isNumber
                                      ? colorText
                                      : backgroundColor),
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
                                    color: _isNumber
                                        ? colorText
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
                            color: _isPosition
                                ? colorText
                                : backgroundColor),
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
                              color: _isPosition
                                  ? colorText
                                  : Colors.grey),
                          hintText: "Entrer un lieu pour la remise",
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
          icon: Icon(Icons.arrow_back, color: Style.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Modification de Votre Annonce",
                      style: Style.secondTitre(22), textAlign: TextAlign.center,),
                  SizedBox(height: 10.0),
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

    );
  }

  void _submit() async {

    bool ready = true;
    if(nameProduct.length < 3) {
      ready = false;

      showSnackBar(context, "Le nom du produit est trop court.");
    }
    if(describe.length < 7) {
      ready = false;
      showSnackBar(context, "Veuillez donner plus de détails dans le champs details articles.");
    }
    if(dropdownValue == null) {
      ready = false;
      showSnackBar(context, "Veuillez choisir une categorie pour l'article.");
    }
    if(base64Image.length == 0) {
      ready = false;
      showSnackBar(context, "Veuillez sélectionner au moins une image de l'article.");
    }
    if(numero.length != 10 ) {
      ready = false;
      showSnackBar(context, "Veuillez entrer un numéro de téléphone valide pour qu'on puisse vous appeler.");
    }
    if(position.length < 7 ) {
      ready = false;
      showSnackBar(context, "Donnez plus d'informations sur le lieu où on doit vous rencontrer pour récupérer l'article.");
    }
    if(price.length <= 2) {
      ready = false;
      showSnackBar(context, "Prix minimum d'un article doit être 500.");
    }
    if(ready) {
      setState(() => requestLoading = true);
      List<dynamic> imageListTitle =
      post.map((data) {

        if(data['type'] == "Network") {
          return data['content'].toString().trim();
        } else {
          return data['content'].path.split('/').last.trim();
        }
      }).toList();

      String imageTitle = imageListTitle.join(',');
      String imagesBuffers = base64Image.join(',');
      String videoPub = (video != null) ? video!.path.split('/').last : base64Video;
      final product = await consumeAPI.updateProductDeals(
        widget.dealsDetailsSkeleton.id,
          nameProduct,
          describe,
          dropdownValue!,
          imageTitle,
          imagesBuffers,
          position,
          numero,
          price,
          quantity, videoPub, base64Video);
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
            "Votre produit a été mis à jour, vous pouvez le manager où que vous soyez",
            true, context);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) => LoadProduct(key: UniqueKey(), productId: widget.dealsDetailsSkeleton.id, doubleComeBack: 1,)), (route) => route.isFirst);

      } else if (product == 'notFound') {

        showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialogCustomError('Plusieurs connexions à ce compte', "Pour une question de sécurité nous allons devoir vous déconnecter.", context),
            barrierDismissible: false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => Login()));
      }else if (product == 'FreeInPayPrice') {
        await askedToLead(
            "Un produit Gratuit ne peut être assimilé à un prix", false, context);
      } else if (product == 'IncorrectPrice') {
        await askedToLead("Erreur lors de la saisie des prix", false, context);
      } else {
        await askedToLead(
            "Echec avec la mise en ligne, veuillez ressayer ulterieurement",
            false, context);
      }
    }
  }
}

