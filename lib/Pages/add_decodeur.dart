import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Constant/widget_common.dart';

import 'Login.dart';

class AddDecodeur extends StatefulWidget {
  String eventId;
  AddDecodeur({required Key key, required this.eventId}) : super(key: key);

  @override
  _AddDecodeurState createState() => _AddDecodeurState();
}

class _AddDecodeurState extends State<AddDecodeur> {
  TextEditingController eCtrl = new TextEditingController();
  String value = "";
  ConsumeAPI consumeAPI = new ConsumeAPI();
  List<dynamic> decodeur = [];
  bool loadingForCliqueSendTicket = false;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Future getInfo() async {
    try {
      final data = await consumeAPI.getDecodeur(widget.eventId);
      if(data['etat'] == 'found') {
        final list = data['result'] as List<dynamic>;
        setState(() {
          decodeur = list;
        });
      } else {
        showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
              barrierDismissible: false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => Login()));
      }
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('ATTRIBUER DECODEUR'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: backgroundColor,
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15.0),
            Padding(
                padding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                child: decodeur.isEmpty ? Text(
                  "Choisissé qui aura le privilège de decoder vos tickets de cet évènement, vous pouvez choisir plusieurs personnes si vous le voulez",
                  /*textAlign: TextAlign.justify,*/ style:
                Style.enterChoiceHobie(21.0),
                ): Container(
                  height: 70,
                  width: double.infinity,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: decodeur.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: MediaQuery.of(context).size.width*0.75,
                          child: ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage("${ConsumeAPI.AssetProfilServer}${decodeur[index]['images']}")
                                  )
                              ),
                            ),
                            title: Text(decodeur[index]['name'],
                                style: Style.priceDealsProduct(), maxLines: 2),
                            subtitle: Text("${decodeur[index]['prefix']} ${decodeur[index]['numero']}",
                                style: Style.simpleTextOnBoard()),
                          ),
                        );
                      }),
                )
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
                        keyboardType: TextInputType.number,
                        controller: eCtrl,
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w300),

                        decoration: InputDecoration(
                          border: InputBorder.none,

                          hintText:
                          "Recherche par son numero",
                          hintStyle: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.grey[500],
                              fontSize: 13.0),
                        ),
                      ),
                      hideOnEmpty: true,
                      suggestionsCallback: (pattern) async {
                        return consumeAPI.getAllUser(pattern.length >= 8 ? pattern :'');
                      },
                      itemBuilder: (context, suggestion) {
                        final user = suggestion as Map<dynamic,dynamic>;
                        return ListTile(
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage("${ConsumeAPI.AssetProfilServer}${user['images']}")
                                )
                            ),
                          ),
                          title: Text(user['name'],
                              style: Style.priceDealsProduct()),
                          subtitle: Text("${user['prefix']} ${user['numero']}",
                              style: Style.simpleTextOnBoard()),
                        );
                      },
                      onSuggestionSelected: (suggestion) async {
                        final user = suggestion as Map<dynamic,dynamic>;
                        eCtrl.text = user['prefix'] + ' ' + user['numero'];
                        setState(() {
                          decodeur.insert(0,user);
                        });
                      },
                    ),
                  ),
                )),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                loadingForCliqueSendTicket ? Container(
                  height: 60,
                  width: 60,
                  child: LoadingIndicator(indicatorType: Indicator.ballRotate,colors: [colorText], strokeWidth: 2),
                ) : ElevatedButton(
                  onPressed: () async {

                    if(decodeur.isNotEmpty) {
                      setState(() {
                        loadingForCliqueSendTicket = true;
                      });
                      final stringfyDecodeur = decodeur.map((e) => "${e['prefix']}:${e['numero']}").toList().toString();
                      final AddDecodeur = await consumeAPI.shareDecodeur(widget.eventId,stringfyDecodeur);
                      if(AddDecodeur['etat'] == 'found') {
                        await askedToLead(
                            "${decodeur.length > 1 ? 'Les décodeurs ont été enregistré avec succès ils sont maintenant éligibles pour décoder cet évènement': 'Le décodeur a été enregistré avec succès il est maintenant éligible pour décoder cet évènement'}",
                            true, context);
                        setState(() {
                          loadingForCliqueSendTicket = false;
                        });
                        Navigator.pushNamed(context, MenuDrawler.rootName);
                      }
                      else {
                        await askedToLead(AddDecodeur['error'], false, context);
                      }
                      setState(() {
                        loadingForCliqueSendTicket = false;
                      });
                    } else {
                      await askedToLead("Il doit avoir au moins un décodeur pour pouvoir lancer un enregistrement", false, context);
                    }
                  },
                  child: Text('ENREGISTRER'),
                  style: raisedButtonStyle,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
