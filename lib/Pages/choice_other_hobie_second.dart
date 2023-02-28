import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

import '../Constant/widget_common.dart';
import '../MenuDrawler.dart';

class ChoiceOtherHobieSecond extends StatefulWidget {
  const ChoiceOtherHobieSecond({required Key key}) : super(key: key);

  @override
  _ChoiceOtherHobieSecondState createState() =>
      _ChoiceOtherHobieSecondState();
}

class _ChoiceOtherHobieSecondState extends State<ChoiceOtherHobieSecond> {
  List<dynamic> choice = [];
  List<dynamic> allCategorie = [];
  bool changeLoading = false;
  String value = "";
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPreference();
    verifyIfUserHaveReadModalExplain();
  }

  verifyIfUserHaveReadModalExplain() async {
    final prefs = await SharedPreferences.getInstance();
    final bool asRead = prefs.getBool('readPreferenceModalExplain') ?? false;
    if(!asRead) {
      await modalForExplain("${ConsumeAPI.AssetPublicServer}preferences.gif", "Nous vous présentons des articles de qualité, des évènements, des actualités, des appels d'offres et offres d'emplois uniquement en fonction de vos préférences.\nSélectionnez vos préférences pour continuer, vous pourriez les modifier ou complêter plus tard.", context);
      await prefs.setBool('readPreferenceModalExplain', true);
    }
  }

  loadPreference() async {
    List<String> myPref = [];
    final allCategorie = await consumeAPI.getAllCategrie("");
    for (var categorie in allCategorie) {
      if(categorie.isHobie) {
        myPref.add(categorie.name.toString());
      }
    }
    setState(() {
      this.choice = myPref;
      this.allCategorie = allCategorie;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    highlightColor: Colors.black,
                    icon: Icon(Icons.clear, color: colorPrimary, size: 22.0),
                  ),
                  choice.length > 4 ?
                  InkWell(
                    onTap: () async {
                      if (choice.length > 4) {
                        setState(() {
                          changeLoading = true;
                        });
                        choice.sort((a, b) => a.toString().compareTo(b.toString()));
                        final updateHobbies = await consumeAPI
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
            ),
            Padding(
              padding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
              child: Text(
                "Qu'est-ce que vous aimez en terme d'actualité, deals et évènement ?\n(au moins 5 centres d'intérêts avant de continuer)",
                style:
              Style.enterChoiceHobie(17.0),
              ),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: allCategorie.length,
                    itemBuilder: (context, index) {
                      final categorie = allCategorie[index];
                      final placeHolderAvatarArray = categorie.name.toString().replaceAll(RegExp('[^A-ZŒÉÈÊ]'), '').trim();//.split('.');
                      final placeHolderAvatar = placeHolderAvatarArray.length > 1 ? '${placeHolderAvatarArray[0].trim().substring(0,1)}${placeHolderAvatarArray[placeHolderAvatarArray.length - 1].trim().substring(0,1)}': placeHolderAvatarArray[0].trim().substring(0,1);
                      return ListTile(
                        leading: badges.Badge(
                          showBadge: categorie.popularity == 1,
                          badgeStyle: badges.BadgeStyle(badgeColor: colorText,),
                          badgeContent: Icon(Icons.star_border_purple500_outlined, color: colorPrimary, size: 15,),
                          child: CircleAvatar(
                              backgroundColor: backgroundColorSec,
                              child: Text(placeHolderAvatar,
                                  style:TextStyle(color: Colors.white))),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width*0.53,
                                child: Text(categorie.name, style: Style.sousTitre(13, colorPrimary), maxLines: 2, overflow: TextOverflow.ellipsis,)),

                          ],
                        ),
                        trailing: Switch(
                          value: allCategorie[index].isHobie,
                          activeColor: colorText,
                          onChanged: (bool value) {

                            setState(() {
                              if(!value) {
                                choice.remove(categorie.name);
                              }else {
                                choice.add(categorie.name);
                              }
                              allCategorie[index].isHobie = value;
                            });
                          },
                        ),
                      );
                    }
                )
            )

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
