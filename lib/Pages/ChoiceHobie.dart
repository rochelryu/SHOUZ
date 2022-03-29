import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/Categorie.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';

import '../MenuDrawler.dart';

class ChoiceHobie extends StatefulWidget {
  static String rootName = '/choiceHobie';
  @override
  _ChoiceHobieState createState() => _ChoiceHobieState();
}

class _ChoiceHobieState extends State<ChoiceHobie> {
  TextEditingController eCtrl = new TextEditingController();
  List<String> choice = [];
  bool changeLoading = false;
  late Future<List<dynamic>> populaireInitial; // For display categorie of beginin
  late Future<List<dynamic>> populaire; // For display All categorie
  String value = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    populaireInitial = new ConsumeAPI().getAllCategrie("", "only") as Future<List<dynamic>>;
    populaire = new ConsumeAPI().getAllCategrie("", "only") as Future<List<dynamic>>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: IconAction(choice.length, changeLoading),
                  highlightColor: Colors.black,
                  onPressed: () async {
                    if (choice.length > 4) {
                      setState(() {
                        changeLoading = true;
                      });
                      final profils = await DBProvider.db.getProfil();
                      final signinUser = await new ConsumeAPI()
                          .signinSecondStep(
                              profils['name'], profils['base'], choice);
                      if (signinUser['etat'] == 'found') {
                        await DBProvider.db.delClient();
                        await DBProvider.db.newClient(signinUser['user']);
                        setLevel(5);
                        setState(() {
                          changeLoading = false;
                        });
                        Navigator.pushNamed(context, MenuDrawler.rootName);
                      } else {
                        setState(() {
                          changeLoading = false;
                        });
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                DialogCustomError(
                                    'Echec',
                                    'Veuillez ressayer ulterieurement',
                                    context),
                            barrierDismissible: false);
                      }
                    } else {
                      setState(() {
                        changeLoading = false;
                      });
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => DialogCustomError(
                              'Erreur',
                              'Veuillez choisir au moins 5 préferences',
                              context),
                          barrierDismissible: false);
                    }
                  },
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 15.0),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                  child: Text(
                    "SHOUZ est plus intéressant avec vos préférences. Qu'est-ce que vous aimez en terme d'actualité, deals et évènement ?",
                    /*textAlign: TextAlign.justify,*/ style:
                        Style.enterChoiceHobie(21.0),
                  ),
                ),
                Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
                                      if (choice.indexOf(eCtrl.text) == -1) {
                                        setState(() {
                                          choice.add(eCtrl.text);
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
                                  "Architecture, Sport, Imobilier, Coupé décalé, Forum",
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey[500],
                                  fontSize: 13.0),
                            ),
                          ),
                          hideOnEmpty: true,
                          suggestionsCallback: (pattern) async {
                            return new ConsumeAPI().getAllCategrie(pattern.length > 0 ? pattern :'');
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
                    )),
                Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                    child: Text('Préférences Populaires',
                        textAlign: TextAlign.start,
                        style: Style.enterChoiceHobieInSecondaryOption(
                            16.0))),
                FutureBuilder(
                  future: populaire,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return isErrorSubscribe(context);
                      case ConnectionState.waiting:
                        return Center(
                          child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2),
                        );
                      case ConnectionState.active:
                        return Center(
                          child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2),
                        );
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return isErrorSubscribe(context);
                        }
                        var populaire = snapshot.data;
                        return new Wrap(
                          spacing: 6.0,
                          children: <Widget>[
                            MasonryGridView.count(
                              physics: new BouncingScrollPhysics(),
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              padding: EdgeInsets.all(0.0),
                              itemCount: populaire.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Chip(
                                  elevation: 1.0,
                                  deleteIcon: Icon(Icons.add,
                                      color: Colors.black87, size: 17.0),
                                  deleteButtonTooltipMessage: "Sélectionné",
                                  onDeleted: () {
                                    setState(() {
                                      if (choice
                                              .indexOf(populaire[index].name) ==
                                          -1) {
                                        choice.add(populaire[index].name);
                                      }
                                      populaire.removeAt(index);
                                    });
                                  },
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      child: Text(
                                          populaire[index]
                                              .name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style:
                                              TextStyle(color: Colors.white))),
                                  label: Text(populaire[index].name),
                                  backgroundColor: Colors.white,
                                );
                              },

                            ),
                          ],
                        );
                    }
                  },
                ),
                SizedBox(height: 25),
                Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                    child: Text('Préférences choisies',
                        textAlign: TextAlign.start,
                        style: Style.enterChoiceHobieInSecondaryOption(
                            16.0))),
                choice.length == 0
                    ? Center(
                        child: Text(
                        "Veuillez choisir au moins 5 préferences",
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
                            itemCount: choice.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Chip(
                                elevation: 10.0,
                                deleteIcon: Icon(Icons.delete,
                                    color: Colors.black87, size: 17.0),
                                deleteButtonTooltipMessage: "Retirer",
                                onDeleted: () async {
                                  final items = await populaireInitial;
                                  setState(() {
                                    for (Categorie item in items) {
                                      if (item.name == choice[index]) {
                                        populaire.then((val) {
                                          int level = 0;
                                          for (Categorie values in val) {
                                            if (values.name == item.name) {
                                              level = 1;
                                            }
                                          }
                                          if ((level == 0)) {
                                            return val.add(item);
                                          } else {
                                            return null;
                                          }
                                        });
                                      }
                                    }
                                    choice.removeAt(index);
                                  });
                                },
                                avatar: CircleAvatar(
                                    backgroundColor: colorText,
                                    child: Text(
                                        choice[index]
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(color: Colors.white))),
                                label: Text(choice[index]),
                                backgroundColor: Colors.white,
                              );
                            },

                          ),
                        ],
                      )
              ],
            ),
          ],
        ),
      ),
    );
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

  Widget IconAction(int length, bool action) {
    if (action) {
      return LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2);
    } else {
      if (length <= 4) {
        return Icon(Icons.close, color: colorPrimary, size: 32.0);
      } else {
        return Icon(Icons.navigate_next,
            color: colorPrimary, size: 32.0);
      }
    }
  }
}
