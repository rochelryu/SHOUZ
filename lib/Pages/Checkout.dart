import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
class Checkout extends StatefulWidget {
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  AppState appState;
  bool verifyUser = false;

  prefix0.TypePayement _character = prefix0.TypePayement.shouzPay;

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
        return Scaffold(
          backgroundColor: prefix0.backgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
            title: Text("Paiement"),
            backgroundColor: prefix0.backgroundColor,
            elevation: 0.0,
          ),
          body: GestureDetector(
            onTap: ()=>FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height/3 - 40,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Card(
                          elevation: (_character == prefix0.TypePayement.shouzPay) ? 15.0:1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0)
                          ),
                          color: prefix0.backgroundColorSec,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsets.only(right: 20, left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Radio(
                                  activeColor: Colors.white,
                                  value: prefix0.TypePayement.shouzPay,
                                  groupValue: _character,
                                  onChanged: (prefix0.TypePayement value) {
                                    setState(() { _character = value; });
                                  },
                                ),
                                Text("Shouz Pay", style: prefix0.Style.titre(18)),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("images/visa.png"),
                                      fit: BoxFit.cover
                                    )
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),

                        Card(
                          elevation: (_character == prefix0.TypePayement.orange) ? 15.0:1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0)
                          ),
                          color: prefix0.backgroundColorSec,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsets.only(right: 20, left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Radio(
                                  activeColor: Colors.orange,
                                  value: prefix0.TypePayement.orange,
                                  groupValue: _character,
                                  onChanged: (prefix0.TypePayement value) {
                                    setState(() { _character = value; });
                                  },
                                ),
                                Text("Orange Money", style: prefix0.Style.titre(18)),
                                Container(
                                  height: 50,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("images/om.png"),
                                      fit: BoxFit.contain
                                    )
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                        Card(
                          elevation: (_character == prefix0.TypePayement.mtn) ? 15.0:1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0)
                          ),
                          color: prefix0.backgroundColorSec,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsets.only(right: 20, left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Radio(
                                  activeColor: Colors.yellow,
                                  value: prefix0.TypePayement.mtn,
                                  groupValue: _character,
                                  onChanged: (prefix0.TypePayement value) {
                                    setState(() { _character = value; });
                                  },
                                ),
                                Text("MoMo", style: prefix0.Style.titre(18)),
                                Container(
                                  height: 50,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("images/momo.png"),
                                      fit: BoxFit.contain
                                    )
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height/2 - 60,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Blockus(context,_character),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomSheet: Container(
            color: prefix0.backgroundColor,
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 20.0),
            child: Center(
              child: RaisedButton(
                color: prefix0.colorText,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("VALIDER L'ACHAT", style: prefix0.Style.titleInSegment())
                  ],
                ),
                onPressed: () async {

                  final event = await new ConsumeAPI().buyEvent(appState.getidEvent, appState.getPriceTicketTotal, appState.getNumberTicket);
                  if (event['etat'] == 'found') {
                    User user = event['user'];
                    await DBProvider.db.delClient();
                    await DBProvider.db.delAllHobies();
                    await DBProvider.db.newClient(user);
                    await _askedToLead(
                      (int.parse(appState.getNumberTicket) > 1 ) ? "Vos tickets ont bien été acheté, voici votre code." : "Votre ticket a bien été acheté, voici votre code.",
                      true, event['result']['nameImage']);
                  }
                  else {
                    await _askedToLead(event['error'], false, '');
                  }
                },
              ),
            ),
          ),
        );    
  
    }


  Future<Null> _askedToLead(String message, bool success, String imgUrl) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: success ? 
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("${ConsumeAPI.AssetBuyEventServer}${appState.getidEvent}/${imgUrl}"),
              fit: BoxFit.contain,
              ))
        )
        : Icon(MyFlutterAppSecond.cancel, size: 120, color: prefix0.colorError),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children : [
                Text(message, textAlign: TextAlign.center, style: prefix0.Style.sousTitre(13)),
                RaisedButton(
                  child: Text('Ok'),
                  color: success ? prefix0.colorText: prefix0.colorError,
                  onPressed: (){
                    Navigator.pop(context);
                }),
              ]
            ),)
        ],
      );
    }
  );
}


  Widget Blockus(BuildContext context,prefix0.TypePayement type){
    switch(type){
      case prefix0.TypePayement.shouzPay:
        return Container(
          height: MediaQuery.of(context).size.height/2,
          width: MediaQuery.of(context).size.width/1.2,
          child: Center(
            child: new SvgPicture.asset(
                "images/wallet.svg",
                semanticsLabel: 'Shouz Pay'
            ),
          ),
        );
        break;
      case prefix0.TypePayement.orange:
        return Container(
          height: MediaQuery.of(context).size.height/3,
          width: MediaQuery.of(context).size.width/1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height/7,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 30.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "+225 XX XX XX XX",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (text){
                            print(text);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 15.0),
                    FloatingActionButton(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.check,color: Colors.white),
                      onPressed: (){
                        print("Conf");
                      },
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height/7,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Tapez #144*641# puis entrez votre code secret et entrer ci-dessous le code qui s'affiche ou reçu par SMS", style: prefix0.Style.sousTitre(12)),
                    Center(
                      child: Container(
                        height: 45,
                        width: 100,
                        padding: EdgeInsets.only(left: 25.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "XXXX",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (text){
                            print(text);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        );
        break;
      case prefix0.TypePayement.mtn:
        return Container(
          height: MediaQuery.of(context).size.height/2.4,
          width: MediaQuery.of(context).size.width/1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height/8,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 30.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "+225 XX XX XX XX",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (text){
                            print(text);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 15.0),
                    FloatingActionButton(
                      backgroundColor: Colors.yellow,
                      child: Icon(Icons.check,color: Colors.black),
                      onPressed: (){
                        print("Conf");
                      },
                    )
                  ],
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height/6,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("1. Acceptez la notification reçue sur votre téléphone en entrant le chiffre 1 pour vous identifier", style: prefix0.Style.sousTitre(11)),
                      Text("2. *133# pour approuver la demande de paiement.", style: prefix0.Style.sousTitre(12)),
                      Text("3. Confirmer le paiement en saisissant votre code secret MTN Mobile Money.", style: prefix0.Style.sousTitre(12)),
                    ],
                  )
              ),
            ],
          ),
        );
        break;
      default:
        return Container(
          height: 50,
          width: 50,
        );
        break;
    }
  }
}
