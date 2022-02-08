import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Provider/AppState.dart';

import '../ServicesWorker/ConsumeAPI.dart';

class Checkout extends StatefulWidget {
  static String rootName = '/checkout';
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  late AppState appState;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  String txHashBtc = '';
  String txHashEth = '';
  bool verifyUser = false;

  TypePayement _character = TypePayement.bitcoin;

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
            title: Text("Rechargement Crypto"),
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


                        Card(
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
                                  child: SvgPicture.asset(
                                    "images/bitcoin.svg",
                                    semanticsLabel: 'Recharge Bitcoin',
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                        Card(
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
                                  height: 50,
                                  width: 50,
                                  child: SvgPicture.asset(
                                    "images/ethereum.svg",
                                    semanticsLabel: 'Recharge Ethereum',
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

              Container(
                  height: MediaQuery.of(context).size.height/4,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("1. Faite une transaction bitcoin du montant que vous voulez pour le rechargement à l'addresse suivante :", style: Style.sousTitre(11)),
                      SelectableText('1NPRbtWD5qK3p4natG2ubTEwupeRT8HUcy', style: Style.addressCrypto(),
                        toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
                        showCursor: true,
                        cursorWidth: 2,
                        cursorColor: Colors.red,
                        cursorRadius: const Radius.circular(5),

                      ),
                      Text("2. Une fois que vous avez fait la transaction du montant voulu, veuillez recupérer le code de reference de cette transaction (TxHash ou TxId) puis la coller dans le champ ci-dessous 👇", style: Style.sousTitre(11)),
                    ],
                  )
              ),
              Container(
                height: MediaQuery.of(context).size.height/8,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 10.0, right: 3.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
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
                    FloatingActionButton(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.check,color: Colors.white),
                      onPressed: () async {
                        if(txHashBtc.trim().length == 64) {
                          final rechargeCrypto = await consumeAPI.rechargeCrypto('bitcoin', txHashBtc.trim());
                          if(rechargeCrypto['etat'] == 'found') {
                            final titleAlert = "Super! vous avez envoyé \$${rechargeCrypto['result']['valueInDollars'].toString()}. Avec les frais de Shouz votre compte à été soldé de ${rechargeCrypto['result']['valueInCurrencieOfTransaction']}";
                            await askedToLead(titleAlert, true, context);
                          } else {
                            await askedToLead(rechargeCrypto['error'], false, context);
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: 'TxHash (TxId) incorrect, veuillez bien verifier',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: colorError,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      case TypePayement.ethereum:
        return Container(
          height: MediaQuery.of(context).size.height/2.4,
          width: MediaQuery.of(context).size.width/1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              Container(
                  height: MediaQuery.of(context).size.height/4,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("1. Faites une transaction ethereum du montant que vous voulez pour le rechargement à l'addresse suivante :", style: Style.sousTitre(11)),
                      SelectableText('0x8a508B2F5615Ef7453ECa2D89F61bE50a7158231', style: Style.addressCrypto(),
                        toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
                        showCursor: true,
                        cursorWidth: 2,
                        cursorColor: Colors.red,
                        cursorRadius: const Radius.circular(5),

                      ),
                      Text("2. Une fois que vous avez fait la transaction du montant voulu, veuillez recupérer le code de reference de cette transaction (TxHash ou TxId) puis la coller dans le champ ci-dessous 👇", style: Style.sousTitre(11)),
                    ],
                  )
              ),
              Container(
                height: MediaQuery.of(context).size.height/8,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 10.0, right: 3.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
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
                    FloatingActionButton(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.check,color: Colors.white),
                      onPressed: () async {
                        if(txHashBtc.trim().length == 66) {
                          final rechargeCrypto = await consumeAPI.rechargeCrypto('ethereum', txHashEth.trim());
                          if(rechargeCrypto['etat'] == 'found') {
                            final titleAlert = "Super! vous avez envoyé \$${rechargeCrypto['result']['valueInDollars'].toString()}. Avec les frais de Shouz votre compte à été soldé de ${rechargeCrypto['result']['valueInCurrencieOfTransaction']}";
                            await askedToLead(titleAlert, true, context);
                          } else {
                            await askedToLead(rechargeCrypto['error'], false, context);
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: 'TxHash (TxId) incorrect, veuillez bien verifier',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: colorError,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return Container(
          height: 50,
          width: 50,
        );
        break;
    }
  }
}
