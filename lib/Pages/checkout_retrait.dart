import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/Utils/Database.dart';

import '../Constant/helper.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import 'Notifications.dart';

class CheckoutRetrait extends StatefulWidget {
  static String rootName = '/checkoutRetrait';
  @override
  _CheckoutRetraitState createState() => _CheckoutRetraitState();
}

class _CheckoutRetraitState extends State<CheckoutRetrait> {
  late AppState appState;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  String txHashBtc = '';
  String txHashEth = '';
  String amount = '';
  bool loadingFetchButton = false;
  User? newClient;

  TypePayement _character = TypePayement.bitcoin;
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerSecond = TextEditingController();

  @override
  void initState() {
    super.initState();
    LoadInfo();
  }

  LoadInfo() async {
    User user = await DBProvider.db.getClient();
    setState(() {
      newClient = user;

    });
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            }),
        title: Text("Retrait Crypto"),
        backgroundColor: backgroundColor,
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
                      Text("Votre solde: ${newClient != null ? reformatNumberForDisplayOnPrice(newClient!.wallet) : ''}", textAlign: TextAlign.center, style: Style.titre(20.0),),
                      GestureDetector(
                        onTap: () {
                          setState(() { _character = TypePayement.bitcoin; });
                        },
                        child: Card(
                          elevation: (_character == TypePayement.bitcoin) ? 15.0:1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0)
                          ),
                          color: backgroundColorSec,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsets.only(right: 20, left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Radio(
                                  activeColor: Colors.orange,
                                  value: TypePayement.bitcoin,
                                  groupValue: _character,
                                  onChanged: (value) {
                                    setState(() { _character = value as TypePayement; });
                                  },
                                ),
                                Text("Bitcoin", style: Style.titre(18)),
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      image: DecorationImage(
                                        image: AssetImage("images/bitcoin.png"),
                                        fit: BoxFit.cover,
                                      )
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() { _character = TypePayement.ethereum; });
                        },
                        child: Card(
                          elevation: (_character == TypePayement.ethereum) ? 15.0:1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0)
                          ),
                          color: backgroundColorSec,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsets.only(right: 20, left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Radio(
                                  activeColor: Colors.blue,
                                  value: TypePayement.ethereum,
                                  groupValue: _character,
                                  onChanged: (value) {
                                    setState(() { _character = value as TypePayement; });
                                  },
                                ),
                                Text("Ethereum", style: Style.titre(18)),
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      image: DecorationImage(
                                        image: AssetImage("images/eth.png"),
                                        fit: BoxFit.cover,
                                      )
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ),
              Container(
                height: MediaQuery.of(context).size.height/1.5 - 60,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Blockus(context,_character),
                ),
              ),
            ],
          ),
        ),
      ),

    );

  }

  Widget Blockus(BuildContext context,TypePayement type){
    switch(type){

      case TypePayement.bitcoin:
        return Container(
          height: MediaQuery.of(context).size.height/2.4,
          width: MediaQuery.of(context).size.width/1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text("1. Entrez le montant que vous voulez retirer", style: Style.sousTitre(11)),
              SizedBox(height: 15),
              Container(
                height: 45,
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.only(left: 10.0, right: 3.0),
                decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(30.0)
                ),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "5000....",
                    hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                  ),
                  onChanged: (text){
                    setState(() {
                      amount = text;
                    });
                  },
                ),
              ),
              SizedBox(height: 15),
              Text("2. Entrez votre adresse Bitcoin dans le champ ci-dessous 👇", style: Style.sousTitre(11)),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 10.0, right: 3.0),
                      decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(30.0)
                      ),
                      child: TextField(
                        controller: _controllerSecond,
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "xxxxxxxxxxxxxxxxxxxxxxxxxx",
                          hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                        ),
                        onChanged: (text){
                          setState(() {
                            txHashBtc = text;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 15.0),
                  !loadingFetchButton ? FloatingActionButton(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.check,color: Colors.white),
                    onPressed: () async {
                      if(txHashBtc.trim().length > 30) {
                        if(int.parse(amount) > minAmountOfTransaction && int.parse(amount) % 100 == 0 && double.parse(amount) <= newClient!.wallet) {
                          setState(() {
                            loadingFetchButton = true;
                          });
                          final demandeRetrait = await consumeAPI.demandeRetrait('bitcoin', txHashBtc.trim(), amount.trim());
                          if(demandeRetrait['etat'] == 'found') {
                            final titleAlert = "Super! votre demande est en cours de traitement";
                            await askedToLead(titleAlert, true, context);

                          } else if( demandeRetrait['etat'] == "badLevel") {
                            final titleAlert = "Vous avez rechargé votre compte il y a moins de 24H, c'est 24H après un rechargement qu'il peut y avoir un possible retrait";
                            await askedToLead(titleAlert, false, context);
                          } else {
                            await askedToLead(demandeRetrait['error'], false, context);
                          }
                          setState(() {
                            amount = '';
                            txHashBtc = '';
                            loadingFetchButton = false;
                          });
                          _controller.clear();
                          _controllerSecond.clear();

                        } else {
                          Fluttertoast.showToast(
                              msg: 'Montant minimum de retrait est 1000 XOF et on peut retirer un montant multiple de 100',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: colorError,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }

                      } else {
                        Fluttertoast.showToast(
                            msg: 'Adresse Bitcoin invalide veuillez bien la verifier',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                    },
                  ) : SizedBox(width:50, height: 50,child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.orange], strokeWidth: 2),),
                ],
              ),
            ],
          )
        );
      case TypePayement.ethereum:
        return Container(
          height: MediaQuery.of(context).size.height/2.4,
          width: MediaQuery.of(context).size.width/1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text("1. Entrez le montant que vous voulez retirer", style: Style.sousTitre(11)),
              SizedBox(height: 15),
              Container(
                height: 45,
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.only(left: 10.0, right: 3.0),
                decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(30.0)
                ),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "5000....",
                    hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                  ),
                  onChanged: (text){
                    setState(() {
                      amount = text;
                    });
                  },
                ),
              ),
              SizedBox(height: 15),
              Text("2. Entrez votre adresse Ethereum dans le champ ci-dessous 👇", style: Style.sousTitre(11)),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 10.0, right: 3.0),
                      decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(30.0)
                      ),
                      child: TextField(
                        controller: _controllerSecond,
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "xxxxxxxxxxxxxxxxxxxxxxxxxx",
                          hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                        ),
                        onChanged: (text){
                          setState(() {
                            txHashEth = text;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 15.0),
                  !loadingFetchButton ? FloatingActionButton(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.check,color: Colors.white),
                    onPressed: () async {
                      if(txHashEth.trim().length > 30) {
                        if(int.parse(amount) > minAmountOfTransaction && int.parse(amount) % 100 == 0  && double.parse(amount) <= newClient!.wallet) {
                          setState(() {
                            loadingFetchButton = true;
                          });
                          final demandeRetrait = await consumeAPI.demandeRetrait('ethereum', txHashEth.trim(), amount.trim());
                          if(demandeRetrait['etat'] == 'found' || demandeRetrait['etat'] == 'inWait') {
                            final titleAlert = "Super! votre transaction vient d'être faites vous allez la recevoir d'ici peu";
                            await askedToLead(titleAlert, true, context);
                          } else if( demandeRetrait['etat'] == "badLevel") {
                            final titleAlert = "Vous avez rechargé votre compte il y a moins de 24H, c'est 24H après un rechargement qu'il peut y avoir un possible retrait";
                            await askedToLead(titleAlert, false, context);
                          } else {
                            await askedToLead(demandeRetrait['error'], false, context);
                          }
                          setState(() {
                            amount = '';
                            txHashEth = '';
                            loadingFetchButton = false;
                          });
                          _controller.clear();
                          _controllerSecond.clear();

                        } else {
                          Fluttertoast.showToast(
                              msg: 'Montant minimum de retrait est 1000 XOF et on peut retirer un montant multiple de 100',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: colorError,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }

                      } else {
                        Fluttertoast.showToast(
                            msg: 'Adresse Ethereum invalide veuillez bien la verifier',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                    },
                  ) : SizedBox(width:50, height: 50,child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2),),
                ],
              ),
            ],
          )
        );
      default:
        return Container(
          height: 50,
          width: 50,
        );
    }
  }
}
