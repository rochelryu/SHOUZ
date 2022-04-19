
import 'dart:async';
import 'package:shouz/Constant/widget_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

class ShareTicket extends StatefulWidget {
  int placeTotal;
  String typeTicket;
  String ticketId;
  ShareTicket({required Key key, required this.ticketId, required this.placeTotal, required this.typeTicket}) : super(key: key);

  @override
  _ShareTicketState createState() => _ShareTicketState();
}

class _ShareTicketState extends State<ShareTicket> {
  TextEditingController eCtrl = new TextEditingController();
  String value = "";
  ConsumeAPI consumeAPI = new ConsumeAPI();
  Map<dynamic, dynamic>? friend;
  int placeTotal = 0;
  int place = 0;
  bool loadingForCliqueSendTicket = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    placeTotal = widget.placeTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, MenuDrawler.rootName);
          },
        ),
      ),
      backgroundColor: backgroundColor,
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: ListView(
          children: <Widget>[

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 15.0),
                Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                  child: friend == null ? Text(
                    "Partagez vos tickets avec vos amis si vous trouvez un cas d'indisponibilité, ou juste leur permettre de pouvoir participer 🤩",
                    /*textAlign: TextAlign.justify,*/ style:
                  Style.enterChoiceHobie(21.0),
                  ): ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                              image: NetworkImage("${ConsumeAPI.AssetProfilServer}${friend!['images']}")
                          )
                      ),
                    ),
                    title: Text(friend!['name'],
                        style: Style.priceDealsProduct()),
                    subtitle: Text("${friend!['prefix']} ${friend!['numero']}",
                        style: Style.simpleTextOnBoard()),
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
                            keyboardType: TextInputType.number,
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
                              friend = user;
                            });
                          },
                        ),
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 16),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "Tickets disponible: ",
                            style: Style.sousTitre(15),
                          ),
                          Text(
                            placeTotal.toString(),
                            style: Style.sousTitre(15),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.do_not_disturb_on,
                                color: colorText),
                            onPressed: () {
                              var normal = (place > 0) ? place - 1 : 0;
                              setState(() {
                                placeTotal =
                                (place != 0) ? placeTotal + 1 : placeTotal;
                                place = normal;

                              });
                            },
                          ),
                          Text(place.toString(), style: Style.titre(29)),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: colorText),
                            onPressed: () {
                              var normal = 0;

                              if(placeTotal > place) {
                                normal = (placeTotal > place) ? place + 1 : placeTotal;
                              } else {
                                if(placeTotal > 0) {
                                  normal = place + 1;
                                } else {
                                  normal = place;
                                }
                              }
                              setState(() {
                                place = normal;
                                placeTotal =
                                (placeTotal > 0) ? placeTotal - 1 : placeTotal;

                              });
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
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
                          setState(() {
                            loadingForCliqueSendTicket = true;
                          });
                          if(friend != null && place != 0) {
                            final shareTicket = await consumeAPI.shareEventTicket(widget.ticketId, place, friend!['numero'], friend!['prefix']);
                            if(shareTicket['etat'] == 'found') {
                              if(shareTicket['result']['placeTotal']> 0) {
                                await askedToLead(
                                    "Vous avez envoyer un ticket de $place place(s) à ${friend!['name']}, il vous reste encore ${shareTicket['result']['placeTotal'].toString()}",
                                    true, context);
                                setState(() {
                                  place = 0;
                                  friend = null;
                                });
                              } else {
                                await askedToLead(
                                    "Vous avez envoyer un ticket de $place place(s) à ${friend!['name']}.",
                                    true, context);
                                setState(() {
                                  place = 0;
                                  friend = null;
                                });
                                Timer(Duration(seconds: 3), () {
                                  Navigator.pushNamed(context, MenuDrawler.rootName);
                                });
                              }

                            }
                            else {
                              await askedToLead(shareTicket['error'], false, context);
                            }
                          } else if (friend != null && place == 0) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    dialogCustomError('Rien Partagé', "Vous n'avez pas renseigné le nombre de ticket que vous voulez envoyer à ${friend!['name']}", context),
                                barrierDismissible: false);
                          }else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    dialogCustomError('Aucun correspondant', "Vous n'avez pas renseigné de correspondant", context),
                                barrierDismissible: false);
                          }
                          setState(() {
                            loadingForCliqueSendTicket = false;
                          });
                        },
                        child: Text('ENVOYER'),
                      style: raisedButtonStyle,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
