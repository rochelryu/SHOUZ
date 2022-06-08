
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

import '../Constant/widget_common.dart';
import '../MenuDrawler.dart';
import '../Models/Categorie.dart';

class ChoiceOtherHobie extends StatefulWidget {
  @override
  _ChoiceOtherHobieState createState() => _ChoiceOtherHobieState();
}

class _ChoiceOtherHobieState extends State<ChoiceOtherHobie> {
  TextEditingController eCtrl = TextEditingController();
  List<dynamic> choice = [];
  bool changeLoading = false;
  String value = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPreference();
  }

  loadPreference() async {
    final preference = await ConsumeAPI().getAllPreference();
    setState(() {
      choice = preference;
    });
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  highlightColor: Colors.black,
                  icon: Icon(Icons.arrow_back, color: colorPrimary, size: 32.0),
                ),
                choice.length > 4 ?
                InkWell(
                  onTap: () async {
                    if (choice.length > 4) {
                      setState(() {
                        changeLoading = true;
                      });
                      /*final profils = await DBProvider.db.getProfil();*/
                      final updateHobbies = await new ConsumeAPI()
                          .updateHobie(choice);
                      if (updateHobbies['etat'] == 'found') {
                        await DBProvider.db.delClient();
                        await DBProvider.db.newClient(updateHobbies['user']);
                        setState(() {
                          changeLoading = false;
                        });
                        Navigator.of(context).push((MaterialPageRoute(
                            builder: (context) => MenuDrawler())));
                      } else {
                        setState(() {
                          changeLoading = false;
                        });
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialogCustomError(
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
                          builder: (BuildContext context) => dialogCustomError(
                              'Erreur',
                              'Veuillez choisir au moins 5 préferences',
                              context),
                          barrierDismissible: false);
                    }
                  },
                  child: Container(
                    width: 140,
                    height: 50,
                    padding: EdgeInsets.only(right: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !changeLoading ? Text("Suivant", style: Style.titre(15),): Text("Charg..", style: Style.titre(15),),
                        iconAction(choice.length, changeLoading),
                      ],
                    ),
                  ),
                ): SizedBox(width: 10),

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
                            final etat = await new ConsumeAPI()
                                .verifyCategorieExist(eCtrl.text);
                            if (etat) {
                              if (choice.indexOf(eCtrl.text) == -1) {
                                setState(() {
                                  choice.insert(0, eCtrl.text);
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

                SizedBox(height: 25),
                Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                    child: Text('Vos préférences actuelle',
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
                            setState(() {
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


  Widget iconAction(int length, bool action) {
    if (action) {
      return LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2);
    } else {
      return Icon(Icons.navigate_next,
          color: colorPrimary, size: 32.0);
    }
  }
}
