import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Constant/widget_common.dart';

import 'Login.dart';

class DecodeByNumber extends StatefulWidget {
  int type;
  String title;
  String idOfType;
  DecodeByNumber({required Key key, required this.type, required this.title, required this.idOfType}) : super(key: key);

  @override
  _DecodeByNumberState createState() => _DecodeByNumberState();
}

class _DecodeByNumberState extends State<DecodeByNumber> {
  TextEditingController eCtrl = new TextEditingController();
  ConsumeAPI consumeAPI = new ConsumeAPI();
  List<dynamic> decodeur = [];
  bool scanned = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(widget.title.toUpperCase(), style: Style.titleNews(),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Style.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
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
                  "Ici se trouvera les informations des dernières personnes qui ont passé pour le decodage de ticket",
                  /*textAlign: TextAlign.justify,*/ style:
                Style.enterChoiceHobie(16.0),
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
                            subtitle: Text("Nbre Place : ${decodeur[index]['placeTotal'].toString()}\n${widget.type== 1? 'Type':'Prix'} Ticket: ${decodeur[index]['typeTicket']}",
                                style: Style.simpleTextOnBoard(12)),
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
                      controller: eCtrl,
                      builder: (context, controller, focusNode) {
                        return TextField(
                          //autofautofocusocus: true,
                          keyboardType: TextInputType.number,
                          controller: controller,
                          focusNode: focusNode,
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w300),

                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: scanned ? CircularProgressIndicator(value: 15, strokeWidth: 1.0,): Icon(Icons.search, color: colorText, size: 15),
                            hintText:
                            "Recherche par son numero",
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.grey[500],
                                fontSize: 13.0),
                          ),
                        );
                      },
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
                        );
                      },
                      onSelected: (suggestion) async {
                        final user = suggestion as Map<dynamic,dynamic>;
                        eCtrl.text = user['prefix'] + ' ' + user['numero'];
                        setState(() {
                          scanned = true;
                        });
                        final inforDecode = widget.type == 1 ? await consumeAPI.decodeTicketEventByNumero(widget.idOfType, user['numero']):await consumeAPI.decodeTicketTravelByNumero(widget.idOfType, user['numero']);
                        if(inforDecode['etat'] == 'found') {
                          setState(() {
                            scanned = false;
                          });
                          await askedToLead(
                              inforDecode['result'],
                              true, context);

                          eCtrl.text = '';
                          if(inforDecode['result'] != "Tous vos passagers sont arrivé à destination donc nous venons de virer le montant des tickets directement sur votre compte SHOUZPAY") {
                            setState(() {
                              decodeur.insert(0,inforDecode['info']);
                            });
                          }
                        }
                        else if(inforDecode['etat'] =='notFound' && inforDecode['etat'] == "Vous n'êtes pas authorisé") {
                          setState(() {
                            scanned = false;
                          });
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  dialogCustomError('Plusieurs connexions à ce compte', "Pour une question de sécurité nous allons devoir vous déconnecter.", context),
                              barrierDismissible: false);

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => Login()));
                        }
                        else {
                          setState(() {
                            scanned = false;
                          });
                          await askedToLead(
                              inforDecode['error'],
                              false, context);
                        }

                      },
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}