import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:im_stepper/stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/Categorie.dart';
import 'package:shouz/Models/Event.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:video_player/video_player.dart';

import '../Constant/helper.dart';
import '../Constant/widget_common.dart';

class CreateVote extends StatefulWidget {
  static String rootName = '/CreateVote';
  @override
  _CreateVoteState createState() => _CreateVoteState();
}

class _CreateVoteState extends State<CreateVote> {
  final picker = ImagePicker();
  DateTime? dateChoice;
  DateTime? dateChoiceEnd;
  late DateTime date = new DateTime.now();
  late DateTime dateEnd = new DateTime.now();
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
  TextEditingController ctrlCategorie = new TextEditingController();
  TextEditingController ctrlEvent = new TextEditingController();
  String describe = "";
  String email = "";
  TextEditingController emailCtrl = new TextEditingController();

  String price = "";
  TextEditingController priceCtrl = new TextEditingController();
  bool _isName = true;
  bool available = false;
  bool _isPrice = false;
  bool _isLoading = false;
  bool monVal = false, showFloatingAction = true;
  ScrollController _scrollController = ScrollController();
  List<List<TextEditingController>> _controllers = [];
  int indexStepper = 0;

  TypeVotesInfoLoad _typeVotesInfoLoad = TypeVotesInfoLoad.none;
  TypePeriodicVotes _typePeriodicVotes = TypePeriodicVotes.none;

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
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      print(_scrollController.position.pixels);
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

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: backgroundColor,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          controller: _scrollController,
          children: [
            if(indexStepper == 0) Text("Créer votre vôte !",
                style: Style.secondTitre(22), textAlign: TextAlign.center,),
            if(indexStepper == 1) Text("Ajouter les nominés",
                style: Style.secondTitre(22), textAlign: TextAlign.center,),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: IconStepper(
                activeStep: indexStepper,
                activeStepColor: colorText,
                enableNextPreviousButtons: false,
                enableStepTapping: false,
                lineLength: MediaQuery.of(context).size.width * 0.5,
                onStepReached: (index) {
                  print(index);
                  setState(() {
                    indexStepper = index;
                  });
                },
                icons: [
                  Icon(Icons.filter_1_outlined),
                  Icon(Icons.filter_2_outlined),
                ],
              ),
            ),
            firstStepCreationVote(),
          ],
        ),
      ),
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

  List<Widget> _listViewWithoutEvent() {
    /*Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 60,
          width: double.infinity,
          child: value,
        ));*/
    List<Widget> tabs = [
      //Title
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
                  _isPrice = false;
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
      // cover
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
                              "Charger l'image de couverture",
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
                  hideSuggestionsOnKeyboardHide: false,
                  textFieldConfiguration: TextFieldConfiguration(
                    //autofautofocusocus: true,
                    controller: ctrlCategorie,
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
                  ),
                  hideOnEmpty: true,
                  suggestionsCallback: (pattern) async {
                    return consumeAPI.getAllCategrie(
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
                  onSuggestionSelected: (suggestion) async {
                    final categorie = suggestion as Categorie;
                    ctrlCategorie.text = categorie.name;
                    final etat = await consumeAPI
                        .verifyCategorieExist(ctrlCategorie.text);
                    if (etat) {
                      if (allCategorie.indexOf(ctrlCategorie.text) == -1) {
                        setState(() {
                          allCategorie.add(ctrlCategorie.text);
                        });
                      }
                      ctrlCategorie.clear();
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
    ];
    return tabs;
  }

  List<Widget> _listViewWithEvent() {
    return [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Veuillez selectionner l'évènement lié à ce vôte",
          /*textAlign: TextAlign.justify,*/ style:
        Style.sousTitre(13.0),
        ),
      ),
      Padding(
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
                  controller: ctrlEvent,
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w300),

                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                    "Ecrivez le titre de cet évènement",
                    hintStyle: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.grey[500],
                        fontSize: 13.0),
                  ),
                ),
                hideOnEmpty: true,
                suggestionsCallback: (pattern) async {
                  return consumeAPI.getAllEventByClient(pattern);
                },
                itemBuilder: (context, suggestion) {
                  final event = suggestion as Event;
                  return ListTile(
                    title: Text(event.title,
                        style: Style.priceDealsProduct()),
                  );
                },
                onSuggestionSelected: (suggestion) async {
                  final event = suggestion as Event;
                  ctrlEvent.text = event.title;
                  /*final etat = await consumeAPI
                      .verifyCategorieExist(ctrlCategorie.text);
                  if (etat) {
                    if (allCategorie.indexOf(ctrlCategorie.text) == -1) {
                      setState(() {
                        allCategorie.add(ctrlCategorie.text);
                      });
                    }
                    ctrlCategorie.clear();
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            dialogCustomError(
                                'Erreur',
                                'Categorie inexistante dans notre registre',
                                context),
                        barrierDismissible: false);
                  }*/
                },
              ),
            ),
          )),
      SizedBox(height: 20,)

    ];
  }

  Widget firstStepCreationVote() {
    var loginBtn = ElevatedButton(
      onPressed: _submit,
      child: Text(
        "Enregistrer et continuer",
        style: Style.sousTitreEvent(15),
      ),
      style: raisedButtonStyle,
    );
    var baseForm = Column(
      children: <Widget>[
        Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              if(_typeVotesInfoLoad == TypeVotesInfoLoad.without_event) ..._listViewWithoutEvent(),
              if(_typeVotesInfoLoad == TypeVotesInfoLoad.with_event) ..._listViewWithEvent(),
              Container(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    if (dateChoice == null && dateChoiceEnd == null)
                      Text(
                          "Cliquez sur les bouttons ci-dessous pour marquer les dates du vôte",
                          style: Style.sousTitre(13), textAlign: TextAlign.center,),
                    if (dateChoice != null || dateChoiceEnd != null)
                      Text(
                          "${(dateChoice != null) ? formatedDateForLocal(dateChoice!) : ' '} - ${(dateChoiceEnd != null) ? formatedDateForLocal(dateChoiceEnd!) : ' '}",
                          style: Style.sousTitre(13)),
                    SizedBox(height: 5),
                    if (durrationEvent > 0)
                      Text(
                        "Le vôte sera en ${durrationEvent.toString()} jour${durrationEvent > 1 ? 's' : ''}",
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

              Container(
                margin: EdgeInsets.only(top: 15),
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                          "Les vôtes sont payant ?",
                          style: Style.sousTitre(14)),
                    ),
                    Expanded(
                      flex: 1,
                      child: customSwitch(available, (){
                        print(available);
                        setState(() {
                          available = !available;
                        });
                      }),
                    ),
                  ],
                ),
              ),

              if(available)
                // price
                Padding(
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
                              color: _isPrice ? colorText : backgroundColor),
                          borderRadius: BorderRadius.circular(50.0)),
                      child: TextField(
                        controller: priceCtrl,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300),
                        cursorColor: colorText,
                        onChanged: (text) {
                          setState(() {
                            _isPrice = true;
                            _isName = false;
                            _isLoading = false;
                            monVal = false;
                            price = text;
                          });
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(_typeVotesInfoLoad == TypeVotesInfoLoad.without_event ? Icons.looks_two: Icons.looks_one,
                                color: _isPrice ? colorText : Colors.grey),
                            hintText: "Prix du vote",
                            hintStyle: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Qu'elle est la fréquence des votes ?",
                        style: Style.sousTitre(14),
                        textAlign: TextAlign.center),
                    Container(
                      width: double.infinity,
                      //padding: EdgeInsets.only(right: 20, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Column(
                                children: [
                                  Radio(
                                    activeColor: colorText,
                                    value: TypePeriodicVotes.only,
                                    groupValue: _typePeriodicVotes,
                                    onChanged: (value) {
                                      setState(() { _typePeriodicVotes = value as TypePeriodicVotes; });
                                    },
                                  ),
                                  Text("Unique", style: Style.simpleTextWithSizeAndColors(13)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                children: [
                                  Radio(
                                    activeColor: colorText,
                                    value: TypePeriodicVotes.one_day_vote,
                                    groupValue: _typePeriodicVotes,
                                    onChanged: (value) {
                                      setState(() { _typePeriodicVotes = value as TypePeriodicVotes; });
                                    },
                                  ),
                                  Text("1 vote/jr", style: Style.simpleTextWithSizeAndColors(13)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                children: [
                                  Radio(
                                    activeColor: colorText,
                                    value: TypePeriodicVotes.two_day_vote,
                                    groupValue: _typePeriodicVotes,
                                    onChanged: (value) {
                                      setState(() { _typePeriodicVotes = value as TypePeriodicVotes; });
                                    },
                                  ),
                                  Text("1 vote/2 jrs", style: Style.simpleTextWithSizeAndColors(13)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                children: [
                                  Radio(
                                    activeColor: colorText,
                                    value: TypePeriodicVotes.three_day_vote,
                                    groupValue: _typePeriodicVotes,
                                    onChanged: (value) {
                                      setState(() { _typePeriodicVotes = value as TypePeriodicVotes; });
                                    },
                                  ),
                                  Text("1 vote/3 jrs", style: Style.simpleTextWithSizeAndColors(13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _isLoading ? const CircularProgressIndicator() : loginBtn
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Ce vôte est-il lié à un de vos événement ?",
                    style: Style.sousTitre(14),
                    textAlign: TextAlign.center),
                Container(
                  width: double.infinity,
                  height: 50,
                  //padding: EdgeInsets.only(right: 20, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Radio(
                                activeColor: colorText,
                                value: TypeVotesInfoLoad.with_event,
                                groupValue: _typeVotesInfoLoad,
                                onChanged: (value) {
                                  setState(() { _typeVotesInfoLoad = value as TypeVotesInfoLoad; });
                                },
                              ),
                              Text("Oui", style: Style.titre(18)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Row(
                            children: [
                              Radio(
                                activeColor: colorText,
                                value: TypeVotesInfoLoad.without_event,
                                groupValue: _typeVotesInfoLoad,
                                onChanged: (value) {
                                  setState(() { _typeVotesInfoLoad = value as TypeVotesInfoLoad; });
                                },
                              ),
                              Text("Non", style: Style.titre(18)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            child: baseForm,
          )
        ],
      ),
    );
  }
}
