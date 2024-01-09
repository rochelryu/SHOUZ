import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:im_stepper/stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shouz/Constant/ExtensionEnum.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Models/Event.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

import '../Constant/helper.dart';
import '../Constant/widget_common.dart';
import '../Utils/shared_pref_function.dart';

class CreateVote extends StatefulWidget {
  static String rootName = '/CreateVote';
  @override
  _CreateVoteState createState() => _CreateVoteState();
}

class _CreateVoteState extends State<CreateVote> {
  final picker = ImagePicker();
  DateTime? dateChoice;
  DateTime? dateChoiceEnd;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldMessengerState>();
  final ConsumeAPI consumeAPI = ConsumeAPI();
  String base64Image = "";
  String picture = "";
  TextEditingController titleCtrl = TextEditingController(),
      ctrlEvent = TextEditingController(),
      nameCategorieCtrl = TextEditingController();
  List<File> post = [];
  List<File> actors = [];
  List<TextEditingController> namesCtrlActors = [];
  String price = "";
  TextEditingController priceCtrl = TextEditingController();
  bool _isName = true, _isNameCategorie = false;
  bool available = false, displayResult = false;
  bool _isPrice = false;
  bool _isLoading = false, _isLoadingDone = false;
  bool monVal = false, showFloatingAction = true, isPosting = false;
  Event? eventChoice;
  ScrollController _scrollController = ScrollController();
  int indexStepper = 0;
  List<String> allNameRegister = [];

  TypeVotesInfoLoad _typeVotesInfoLoad = TypeVotesInfoLoad.none;
  TypePeriodicVotes _typePeriodicVotes = TypePeriodicVotes.none;

  Future<Null> selectDate(BuildContext context, bool begin) async {
    final actualDate = DateTime.now();
    final initialDate =
        begin ? dateChoice ?? actualDate : dateChoiceEnd ?? actualDate;
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(new DateTime.now().year),
        lastDate: new DateTime(new DateTime.now().year + 2));

    if (picked != null) {
      setState(() {
        if (begin) {
          dateChoice = picked;
        } else {
          dateChoiceEnd =
              DateTime(picked.year, picked.month, picked.day, 23, 59);
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
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

  loadData() async {
    final voteId = await getVoteIdToShared();
    setState(() {
      indexStepper = voteId.toString().isEmpty ? 0 : 1;
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
      }
      picture = image.name;
    }
  }

  Future getNomineProfil() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, allowCompression: true, type: FileType.image);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();

      // final newBase64Image = files
      //     .map((image) => base64Encode(image.readAsBytesSync()))
      //     .toList();
      List<TextEditingController> allNewControllers =
          files.map((e) => TextEditingController()).toList();
      final List<File> allImage = List.from(actors)..addAll(files);
      final List<TextEditingController> allCtrls = List.from(namesCtrlActors)
        ..addAll(allNewControllers);
      setState(() {
        namesCtrlActors = allCtrls;
        actors = allImage;
      });
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
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Style.white,),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          controller: _scrollController,
          children: [
            if (indexStepper == 0)
              Text(
                "Créer votre vôte !",
                style: Style.secondTitre(22),
                textAlign: TextAlign.center,
              ),
            if (indexStepper == 1)
              Text(
                "Ajouter les nominés",
                style: Style.secondTitre(22),
                textAlign: TextAlign.center,
              ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: IconStepper(
                activeStep: indexStepper,
                activeStepColor: colorText,
                enableNextPreviousButtons: false,
                enableStepTapping: false,
                lineLength: MediaQuery.of(context).size.width * 0.5,
                onStepReached: (index) {
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
            if (indexStepper == 0) firstStepCreationVote(),
            if (indexStepper == 1) secondStepCreationVote(),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    bool ready = true;
    if (_typeVotesInfoLoad == TypeVotesInfoLoad.none) {
      ready = false;

      showSnackBar(context,
          "Dites nous si le vôte est lié à un de vos évènement ou non !");
    }
    if (_typePeriodicVotes == TypePeriodicVotes.none) {
      ready = false;

      showSnackBar(context, "Dites nous qu'elle est la fréquence des vôtes !");
    }
    if (dateChoiceEnd == null || dateChoice == null) {
      ready = false;
      showSnackBar(context,
          "Veuillez sélectionner une date ${dateChoice == null ? "de debut" : "de fin"}");
    }
    if (available) {
      if ((price.isNotEmpty && int.parse(price) % 100 != 0) || price.isEmpty) {
        ready = false;
        showSnackBar(
            context, "Le montant pour le vôte doit être un multiple de 100");
      }
    }
    if (_typeVotesInfoLoad == TypeVotesInfoLoad.without_event) {
      if (base64Image.isEmpty) {
        ready = false;
        showSnackBar(
            context, "Veuillez sélectionner l'image d'affiche du vôte.");
      }
      if (titleCtrl.text.isEmpty) {
        ready = false;
        showSnackBar(context, "Veuillez entrer le nom du vôte.");
      }
    }

    if (ready) {
      final eventId =
          ExtensionEnumToValue.transformTypeVotesInfoLoadInCorrectValue(
              _typeVotesInfoLoad, eventChoice);
      setState(() {
        isPosting = true;
      });
      final setVote = await consumeAPI.createVote(
          eventId: eventId,
          price: price,
          base64: base64Image,
          picture: picture,
          name: titleCtrl.text,
          beginDate: dateChoice!,
          endDate: dateChoiceEnd!,
          frequence: _typePeriodicVotes,
          displayResult: displayResult);
      setState(() {
        isPosting = false;
      });
      if (setVote['etat'] == 'found') {
        setState(() {
          indexStepper++;
        });
      } else {
        await askedToLead(
            "Un problème lors de la création du vôte, veuillez reprendre ultérieurement s'il vous plait.",
            false,
            context);
      }
    }
  }

  void _submitCategorie({bool isDone = false}) async {
    bool ready = true;
    if (!isDone && nameCategorieCtrl.text.isEmpty) {
      ready = false;

      showSnackBar(
          context, "Veuillez faire entrer le nom de la categorie d'abord");
    }
    if (!isDone &&
        (namesCtrlActors.isEmpty || namesCtrlActors.length != actors.length)) {
      ready = false;

      showSnackBar(context,
          "Veuillez vous rassurer que tous les nominés pour cette categorie ont été àjouté.");
    }
    if (isDone && nameCategorieCtrl.text.isEmpty && namesCtrlActors.isEmpty) {
      ready = false;
      await dropVoteIdToShared();
      Navigator.pushNamedAndRemoveUntil(
          context, MenuDrawler.rootName, (route) => route.isFirst);
    }

    if (ready) {
      setState(() {
        if (isDone)
          _isLoadingDone = true;
        else
          isPosting = true;
      });
      final voteId = await getVoteIdToShared() as String;
      List<String> listNameActors = [];
      List<String> listNameImage = [];
      List<String> listBaseActors = [];
      actors.asMap().forEach((index, actor) {
        final imageName = actor.path.split('/').last;
        if (allNameRegister.contains('${voteId}_$imageName')) {
          listBaseActors.add('');
        } else {
          listBaseActors.add(base64Encode(actor.readAsBytesSync()));
        }
        listNameImage.add('${voteId}_$imageName');
        listNameActors.add(namesCtrlActors[index].text.toLowerCase());
      });
      final lastStepVote = await consumeAPI.createCategorieAndNomineVote(
          isDone: isDone,
          base64: listBaseActors.join(','),
          categorieName: nameCategorieCtrl.text,
          imageName: listNameImage.join(','),
          nameActors: listNameActors.join(','));
      setState(() {
        if (isDone)
          _isLoadingDone = false;
        else
          isPosting = false;
      });
      if (lastStepVote['etat'] == 'found') {
        allNameRegister = listNameImage;
        showSnackBar(context,
            "Les nominés de la categorie ${nameCategorieCtrl.text} ont été enregistré",
            isOk: true);
        setState(() {
          actors = [];
          nameCategorieCtrl.text = '';
          namesCtrlActors = [];
        });
        if (isDone) {
          await dropVoteIdToShared();
          Navigator.pushNamedAndRemoveUntil(
              context, MenuDrawler.rootName, (route) => route.isFirst);
        }
      } else {
        await askedToLead(
            "Un problème lors de la création du vôte, veuillez reprendre ultérieurement s'il vous plait.",
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
    List<Widget> tabs = [
      //Title
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.transparent,
          elevation: _isName ? 4.0 : 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
          child: Container(
            height: 50,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: backgroundColorSec,
                border: Border.all(
                    width: 1.0, color: _isName ? colorText : backgroundColor),
                borderRadius: BorderRadius.circular(50.0)),
            child: TextField(
              controller: titleCtrl,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              cursorColor: colorText,
              keyboardType: TextInputType.text,
              onChanged: (text) {
                setState(() {
                  _isName = true;
                  _isPrice = false;
                  _isLoading = false;
                  monVal = false;
                });
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.looks_one,
                      color: _isName ? colorText : Colors.grey),
                  hintText: "Titre du vôte",
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
    ];
    return tabs;
  }

  List<Widget> _listViewWithEvent() {
    return [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Veuillez selectionner l'évènement lié à ce vôte",
          /*textAlign: TextAlign.justify,*/ style: Style.sousTitre(13.0),
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
                controller: ctrlEvent,
                builder: (context, controller, focusNode) {
                  return TextField(
                    //autofautofocusocus: true,
                    controller: controller,
                    focusNode: focusNode,
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.w300),

                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Ecrivez le titre de cet évènement",
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.grey[500],
                          fontSize: 13.0),
                    ),
                  );
                },
                hideOnEmpty: true,
                suggestionsCallback: (pattern) async {
                  return consumeAPI.getAllEventByClient(pattern);
                },
                itemBuilder: (context, suggestion) {
                  final event = suggestion as Event;
                  return ListTile(
                    title: Text(event.title, style: Style.priceDealsProduct()),
                  );
                },
                onSelected: (suggestion) async {
                  final event = suggestion as Event;
                  ctrlEvent.text = event.title;
                  eventChoice = event;
                },
              ),
            ),
          )),
      SizedBox(
        height: 20,
      )
    ];
  }

  Widget firstStepCreationVote() {
    var loginBtn = ElevatedButton(
      onPressed: _submit,
      child: isPosting
          ? CircularProgressIndicator(
              color: colorPrimary,
            )
          : Text(
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
              if (_typeVotesInfoLoad == TypeVotesInfoLoad.without_event)
                ..._listViewWithoutEvent(),
              if (_typeVotesInfoLoad == TypeVotesInfoLoad.with_event)
                ..._listViewWithEvent(),
              Container(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    if (dateChoice == null && dateChoiceEnd == null)
                      Text(
                        "Cliquez sur les bouttons ci-dessous pour marquer les dates du vôte",
                        style: Style.sousTitre(13),
                        textAlign: TextAlign.center,
                      ),
                    if (dateChoice != null || dateChoiceEnd != null)
                      Text(
                          "${(dateChoice != null) ? formatedDateForLocal(dateChoice!) : ' '} - ${(dateChoiceEnd != null) ? formatedDateForLocal(dateChoiceEnd!) : ' '}",
                          style: Style.sousTitre(13)),
                    SizedBox(height: 15),
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
                margin: EdgeInsets.only(top: 15, bottom: 15),
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Afficher les resultats",
                              style: Style.sousTitre(14)),
                          Text(
                              "Tout le monde pourra voir les resultats de chaque nomminé",
                              style: Style.simpleTextOnBoard(13)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: customSwitch(displayResult, () {
                        setState(() {
                          displayResult = !displayResult;
                        });
                      }),
                    ),
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
                      child: Text("Les vôtes sont payant ?",
                          style: Style.sousTitre(14)),
                    ),
                    Expanded(
                      flex: 1,
                      child: customSwitch(available, () {
                        setState(() {
                          available = !available;
                        });
                      }),
                    ),
                  ],
                ),
              ),
              if (available)
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
                          try {
                            if (text.isNotEmpty) {
                              int.parse(text);
                              setState(() {
                                _isPrice = true;
                                _isName = false;
                                _isLoading = false;
                                monVal = false;
                                price = text;
                              });
                              priceCtrl.text = text;
                            }
                          } catch (e) {
                            priceCtrl.text = price;
                          }
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                                _typeVotesInfoLoad ==
                                        TypeVotesInfoLoad.without_event
                                    ? Icons.looks_two
                                    : Icons.looks_one,
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
                                      setState(() {
                                        _typePeriodicVotes =
                                            value as TypePeriodicVotes;
                                      });
                                    },
                                  ),
                                  Text("Unique",
                                      style: Style.simpleTextWithSizeAndColors(
                                          13)),
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
                                      setState(() {
                                        _typePeriodicVotes =
                                            value as TypePeriodicVotes;
                                      });
                                    },
                                  ),
                                  Text("1 vote/jr",
                                      style: Style.simpleTextWithSizeAndColors(
                                          13)),
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
                    style: Style.sousTitre(14), textAlign: TextAlign.center),
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
                                  setState(() {
                                    _typeVotesInfoLoad =
                                        value as TypeVotesInfoLoad;
                                  });
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
                                  setState(() {
                                    _typeVotesInfoLoad =
                                        value as TypeVotesInfoLoad;
                                  });
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

  Widget secondStepCreationVote() {
    final createCategorie = ElevatedButton(
      onPressed: _submitCategorie,
      child: isPosting
          ? CircularProgressIndicator(
              color: colorPrimary,
            )
          : Text(
              "Enregistrer une autre categorie",
              style: Style.sousTitreEvent(15),
            ),
      style: raisedButtonStyle,
    );
    final doneVote = ElevatedButton(
      onPressed: () {
        _submitCategorie(isDone: true);
      },
      child: _isLoadingDone
          ? CircularProgressIndicator(
              color: colorPrimary,
            )
          : Text(
              "Terminer avec cette categorie",
              style: Style.sousTitreEvent(15),
            ),
      style: raisedButtonStyleError,
    );
    var baseForm = Column(
      children: <Widget>[
        Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.transparent,
                  elevation: _isNameCategorie ? 4.0 : 0.0,
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
                                _isNameCategorie ? colorText : backgroundColor),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: TextField(
                      controller: nameCategorieCtrl,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                      cursorColor: colorText,
                      keyboardType: TextInputType.text,
                      onChanged: (text) {
                        setState(() {
                          _isNameCategorie = true;
                          _isPrice = false;
                          _isLoading = false;
                          _isName = false;
                          monVal = false;
                        });
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.looks_one,
                              color: _isName ? colorText : Colors.grey),
                          hintText: "Nom de la categorie",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
              Container(
                height: 210,
                width: double.infinity,
                padding: EdgeInsets.only(left: 0.0, top: 10.0, bottom: 10.0),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: actors.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: InkWell(
                            onTap: () {
                              getNomineProfil();
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              padding: EdgeInsets.all(6),
                              color: Colors.white,
                              strokeWidth: 1,
                              child: Container(
                                height: double.infinity,
                                width: 110,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(MyFlutterAppSecond.attach,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      "Charger les images des nominés.",
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
                        return Container(
                          width: 160,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  actors.removeAt(index - 1);
                                  namesCtrlActors.removeAt(index - 1);
                                  setState(() {});
                                },
                                child: Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                            image: FileImage(actors[index - 1]),
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                              ),
                              Card(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                child: Container(
                                  height: 40,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: backgroundColorSec,
                                      border: Border.all(
                                          width: 1.0, color: colorText),
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                  child: TextField(
                                    controller: namesCtrlActors[index - 1],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300),
                                    cursorColor: colorText,
                                    keyboardType: TextInputType.text,
                                    onChanged: (text) {},
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Nom du nominé",
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _isLoading ? const CircularProgressIndicator() : createCategorie,
        SizedBox(height: 20),
        _isLoadingDone ? const CircularProgressIndicator() : doneVote,
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
              "Faites entrer le nom de la categorie puis cliquez sur suivant si vous voulez enregistrer et passer à une autre categorie",
              style: Style.sousTitre(14),
              textAlign: TextAlign.center),
          SizedBox(
            height: 10,
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
