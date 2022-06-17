import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/Constant/widget_common.dart';

import '../Models/User.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import '../Utils/Database.dart';
import 'Login.dart';
import 'Notifications.dart';

class CheckoutRechargeMobileMoney extends StatefulWidget {
  static String rootName = '/CheckoutRechargeMobileMoney';
  CheckoutRechargeMobileMoney({required Key key}) : super(key: key);

  @override
  _CheckoutRechargeMobileMoneyState createState() =>
      _CheckoutRechargeMobileMoneyState();
}

class _CheckoutRechargeMobileMoneyState
    extends State<CheckoutRechargeMobileMoney> {
  late AppState appState;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  String orangeNumero = '';
  String mtnNumero = '';
  String moovNumero = '';
  String waveNumero = '';
  String previsionMontant = 'N/A';
  bool loadConfirmation = false;
  Map<dynamic, dynamic>? info;
  TextEditingController _controller = TextEditingController();

  TypePayement _character = TypePayement.wave;

  User? newClient;


  void initState() {
    super.initState();
    _controller.text = '0';
    appState = Provider.of<AppState>(context, listen: false);
    LoadInfo();
  }

  Future LoadInfo() async {
    try {

      final data = await consumeAPI.getMobileMoneyAvalaible();
      if(data["etat"] == 'found') {
        setState(() {
          info = data["result"];
        });
        User user = await DBProvider.db.getClient();
        setState(() {
          newClient = user;
        });
      } else if(data["etat"] == 'notFound') {
        showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
              barrierDismissible: false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => Login()));

      } else {
        Fluttertoast.showToast(
            msg: "Une Erreur s'est produit, veuillez ressayer ulterieurement",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: colorError,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }

    } catch (e) {
      print("Erreur $e");
    }
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
        title: Text("Rechargement Mobile Money"),
        backgroundColor: backgroundColor,
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: ()=>FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.height/2,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text("Votre solde: ${newClient != null ? newClient!.wallet : ''}", textAlign: TextAlign.center, style: Style.titre(20.0),),

                      GestureDetector(
                        onTap: () {
                          setState(() { _character = TypePayement.wave; });
                        },
                        child: Card(
                          elevation: (_character == TypePayement.wave) ? 15.0:1.0,
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
                                  value: TypePayement.wave,
                                  groupValue: _character,
                                  onChanged: (value) {
                                    setState(() { _character = value as TypePayement; });
                                  },
                                ),
                                Text("Wave", style: Style.titre(18)),
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Image.asset("images/wave.png", fit: BoxFit.cover,),
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() { _character = TypePayement.mtn; });
                        },
                        child: Card(
                          elevation: (_character == TypePayement.mtn) ? 15.0:1.0,
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
                                  activeColor: Colors.yellow,
                                  value: TypePayement.mtn,
                                  groupValue: _character,
                                  onChanged: (value) {
                                    setState(() { _character = value as TypePayement; });
                                  },
                                ),
                                Text("MoMo", style: Style.titre(18)),
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: Image.asset("images/momo.png", fit: BoxFit.contain,),
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() { _character = TypePayement.orange; });
                        },
                        child: Card(
                          elevation: (_character == TypePayement.orange) ? 15.0:1.0,
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
                                  activeColor: Colors.deepOrangeAccent,
                                  value: TypePayement.orange,
                                  groupValue: _character,
                                  onChanged: (value) {
                                    setState(() { _character = value as TypePayement; });
                                  },
                                ),
                                Text("Orange Money", style: Style.titre(18)),
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: Image.asset("images/om.png", fit: BoxFit.contain,),
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() { _character = TypePayement.moov; });
                        },
                        child: Card(
                          elevation: (_character == TypePayement.moov) ? 15.0:1.0,
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
                                  activeColor: Colors.blueAccent,
                                  value: TypePayement.moov,
                                  groupValue: _character,
                                  onChanged: (value) {
                                    setState(() { _character = value as TypePayement; });
                                  },
                                ),
                                Text("Moov", style: Style.titre(18)),
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: Image.asset("images/moov.png", fit: BoxFit.contain,),
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
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 35.0),
                child: blockus(context,_character),
              ),
            ],
          ),
        ),
      ),

    );

  }

  Widget blockus(BuildContext context,TypePayement type){
    switch(type){

      case TypePayement.mtn:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("1. Faites entrer votre numero de telephone Mtn qui est censé faire la transaction puis le montant de votre transaction (Montant Min: 2000)", style: Style.sousTitre(11)),
            SizedBox(height: 10),
            Container(
              height: 45,
              width: double.infinity,
              padding: EdgeInsets.only(left: 10.0, right: 3.0),
              
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 3,
                      child: Container(
                    height: 45,
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 10.0, right: 3.0),
                    decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,

                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Numero Tel",
                        hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                      ),
                      onChanged: (text){
                        setState(() {
                          mtnNumero = text;
                        });
                      },
                    ),
                  )),
                  SizedBox(width: 15,),
                  Expanded(flex: 2,
                      child: Container(
                    height: 45,
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 10.0, right: 3.0),
                    decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _controller,
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Montant",
                        hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                      ),
                      onChanged: (value) {
                        setState(() {
                          final amount = int.parse(value);
                          if (amount >= 2000 ) {
                            setState(() {
                              previsionMontant = (amount * (1 - appState.getPercentageRecharge)).toString();
                            });
                          } else {
                            setState(() {
                              previsionMontant = "N/A";
                            });
                          }
                        });
                      },
                    ),
                  ))
                ],
              ),
            ),

            Text("vous allez recevoir $previsionMontant sur votre compte SHOUZPAY", style: Style.sousTitre(9)),
            SizedBox(height: 10),
            Text("2. Faites la transaction Mtn Money au numero suivante :", style: Style.sousTitre(11)),
            SelectableText(info == null ? '' : '+225 ${info!['mtn']}', style: Style.mobileMoneyMtn(),
              toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
              showCursor: true,
              cursorWidth: 2,
              cursorColor: Colors.white,
              cursorRadius: const Radius.circular(5),

            ),
            SizedBox(height: 15,),
            loadConfirmation ? Container(height: 30,child: Center(child:  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.yellow], strokeWidth: 2),),) : ElevatedButton(
                style: raisedButtonStyleMtnMoney,
                onPressed: () async {
                  if(mtnNumero.trim().length == 10) {
                    setState(() {
                      loadConfirmation = true;
                    });
                    final rechargeCrypto = await consumeAPI.rechargeMobileMoney('mtn', mtnNumero.trim(), _controller.text);
                    setState(() {
                      loadConfirmation = false;
                    });
                    if(rechargeCrypto['etat'] == 'found') {
                      final titleAlert = "Votre compte vient d'être rechargé avec succès";
                      await askedToLead(titleAlert, true, context);
                      _controller.clear();
                      Navigator.pushNamed(context, MenuDrawler.rootName);
                    } else if(rechargeCrypto['etat'] == 'inWait') {
                      final titleAlert = "Nous analysons cette transaction au près de MTN, une fois confirmation votre compte sera soldé immédiatement, soyez sans crainte.";
                      await askedToLead(titleAlert, true, context);
                      _controller.clear();
                      Navigator.pushNamed(context, Notifications.rootName);
                    } else {
                      await askedToLead(rechargeCrypto['error'], false, context);
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Numero Mtn incorrect, veuillez bien verifier',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: colorError,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
                },
                child: Text('Confirmer'))
          ],
        );
      case TypePayement.wave:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Text("1. Faites entrer votre numero de telephone Wave qui est censé faire la transaction puis le montant de votre transaction (Montant Min: 2000)", style: Style.sousTitre(11)),
            SizedBox(height: 10),
            Container(
              height: 45,
              width: double.infinity,
              padding: EdgeInsets.only(left: 10.0, right: 3.0),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 10.0, right: 3.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,

                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Numero Tel",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (text){
                            setState(() {
                              waveNumero = text;
                            });
                          },
                        ),
                      )),
                  SizedBox(width: 15,),
                  Expanded(flex: 2,
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 10.0, right: 3.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _controller,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Montant",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (value) {
                            setState(() {
                              if(value.length > 3) {
                                final amount = int.parse(value);
                                if (amount >= 2000 ) {
                                  setState(() {
                                    previsionMontant = (amount * (1 - appState.getPercentageRecharge)).toString();
                                  });
                                } else {
                                  setState(() {
                                    previsionMontant = "N/A";
                                  });
                                }
                              } else {
                                setState(() {
                                  previsionMontant = "N/A";
                                });
                              }
                            });
                          },
                        ),
                      ))
                ],
              ),
            ),

            Text("vous allez recevoir $previsionMontant sur votre compte SHOUZPAY", style: Style.sousTitre(9)),
            SizedBox(height: 10),
            Text("2. Faites la transaction Wave au numero suivante :", style: Style.sousTitre(11)),
            SelectableText(info == null ? '' : '+225 ${info!['wave']}', style: Style.mobileMoneyWave(),
              toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
              showCursor: true,
              cursorWidth: 2,
              cursorColor: Colors.white,
              cursorRadius: const Radius.circular(5),

            ),
            SizedBox(height: 15,),
            loadConfirmation ? Container(height: 30,child: Center(child:  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.blue], strokeWidth: 2),),) : ElevatedButton(
                style: raisedButtonStyleWave,
                onPressed: () async {
                  if(waveNumero.trim().length == 10) {
                    setState(() {
                      loadConfirmation = true;
                    });
                    final rechargeCrypto = await consumeAPI.rechargeMobileMoney('wave', waveNumero.trim(), _controller.text);
                    setState(() {
                      loadConfirmation = false;
                    });
                    if(rechargeCrypto['etat'] == 'found') {

                      final titleAlert = "Votre compte vient d'être rechargé avec succès";
                      await askedToLead(titleAlert, true, context);
                      _controller.clear();
                      Navigator.pushNamed(context, MenuDrawler.rootName);
                    } else if(rechargeCrypto['etat'] == 'inWait') {
                      final titleAlert = "Nous analysons cette transaction au près de Wave, une fois confirmation votre compte sera soldé immédiatement, soyez sans crainte.";
                      await askedToLead(titleAlert, true, context);
                      _controller.clear();
                      Navigator.pushNamed(context, Notifications.rootName);
                    } else {
                      await askedToLead(rechargeCrypto['error'], false, context);
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Numero Wave incorrect, veuillez bien verifier',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: colorError,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
                },
                child: Text('Confirmer'))
          ],
        );
      case TypePayement.orange:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Text("1. Faites entrer votre numero de telephone Orange qui est censé faire la transaction puis le montant de votre transaction (Montant Min: 2000)", style: Style.sousTitre(11)),
            SizedBox(height: 10),
            Container(
              height: 45,
              width: double.infinity,
              padding: EdgeInsets.only(left: 10.0, right: 3.0),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 10.0, right: 3.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,

                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Numero Tel",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (text){
                            setState(() {
                              orangeNumero = text;
                            });
                          },
                        ),
                      )),
                  SizedBox(width: 15,),
                  Expanded(flex: 2,
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 10.0, right: 3.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _controller,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Montant",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (value) {
                            setState(() {
                              final amount = int.parse(value);
                              if (amount >= 2000 ) {
                                setState(() {
                                  previsionMontant = (amount * (1 - appState.getPercentageRecharge)).toString();
                                });
                              } else {
                                setState(() {
                                  previsionMontant = "N/A";
                                });
                              }
                            });
                          },
                        ),
                      ))
                ],
              ),
            ),

            Text("vous allez recevoir $previsionMontant sur votre compte SHOUZPAY", style: Style.sousTitre(9)),
            SizedBox(height: 10),
            Text("2. Faites la transaction Orange au numero suivante :", style: Style.sousTitre(11)),
            SelectableText(info == null ? '' : '+225 ${info!['orange']}', style: Style.mobileMoneyOrange(),
              toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
              showCursor: true,
              cursorWidth: 2,
              cursorColor: Colors.white,
              cursorRadius: const Radius.circular(5),

            ),
            SizedBox(height: 15,),
            loadConfirmation ? Container(height: 30,child: Center(child:  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.deepOrangeAccent], strokeWidth: 2),),) : ElevatedButton(
                style: raisedButtonStyleOrangeMoney,
                onPressed: () async {
                  if(orangeNumero.trim().length == 10) {
                    setState(() {
                      loadConfirmation = true;
                    });
                    final rechargeCrypto = await consumeAPI.rechargeMobileMoney('orange', orangeNumero.trim(), _controller.text);
                    setState(() {
                      loadConfirmation = false;
                    });
                    if(rechargeCrypto['etat'] == 'found') {
                      final titleAlert = "Votre compte vient d'être rechargé avec succès";
                      await askedToLead(titleAlert, true, context);
                      _controller.clear();
                      Navigator.pushNamed(context, MenuDrawler.rootName);
                    } else if(rechargeCrypto['etat'] == 'inWait') {
                      final titleAlert = "Nous analysons cette transaction au près de Orange, une fois confirmation votre compte sera soldé immédiatement, soyez sans crainte.";
                      await askedToLead(titleAlert, true, context);
                      _controller.clear();
                      Navigator.pushNamed(context, Notifications.rootName);
                    } else {
                      await askedToLead(rechargeCrypto['error'], false, context);
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Numero Orange incorrect, veuillez bien verifier',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: colorError,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
                },
                child: Text('Confirmer'))
          ],
        );
      case TypePayement.moov:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Text("1. Faites entrer votre numero de telephone Moov qui est censé faire la transaction puis le montant de votre transaction (Montant Min: 2000)", style: Style.sousTitre(11)),
            SizedBox(height: 10),
            Container(
              height: 45,
              width: double.infinity,
              padding: EdgeInsets.only(left: 10.0, right: 3.0),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 10.0, right: 3.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,

                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Numero Tel",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (text){
                            setState(() {
                              moovNumero = text;
                            });
                          },
                        ),
                      )),
                  SizedBox(width: 15,),
                  Expanded(flex: 2,
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 10.0, right: 3.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _controller,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Montant",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (value) {
                            setState(() {
                              final amount = int.parse(value);
                              if (amount >= 2000 ) {
                                setState(() {
                                  previsionMontant = (amount * (1 - appState.getPercentageRecharge)).toString();
                                });
                              } else {
                                setState(() {
                                  previsionMontant = "N/A";
                                });
                              }
                            });
                          },
                        ),
                      ))
                ],
              ),
            ),

            Text("vous allez recevoir $previsionMontant sur votre compte SHOUZPAY", style: Style.sousTitre(9)),
            SizedBox(height: 10),
            Text("2. Faites la transaction Moov au numero suivante :", style: Style.sousTitre(11)),
            SelectableText(info == null ? '' : '+225 ${info!['moov']}', style: Style.mobileMoneyMoov(),
              toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
              showCursor: true,
              cursorWidth: 2,
              cursorColor: Colors.red,
              cursorRadius: const Radius.circular(5),

            ),
            SizedBox(height: 15,),
            loadConfirmation ? Container(height: 30,child: Center(child:  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.blueAccent], strokeWidth: 2),),) : ElevatedButton(
                style: raisedButtonStyleMoovMoney,
                onPressed: () async {
                  if(moovNumero.trim().length == 10) {
                    setState(() {
                      loadConfirmation = true;
                    });
                    final rechargeCrypto = await consumeAPI.rechargeMobileMoney('moov', moovNumero.trim(), _controller.text);
                    setState(() {
                      loadConfirmation = false;
                    });
                    if(rechargeCrypto['etat'] == 'found') {
                      final titleAlert = "Votre compte vient d'être rechargé avec succès";
                      await askedToLead(titleAlert, true, context);
                      _controller.clear();
                      Navigator.pushNamed(context, MenuDrawler.rootName);
                    } else if(rechargeCrypto['etat'] == 'inWait') {
                      final titleAlert = "Nous analysons cette transaction au près de Moov, une fois confirmation votre compte sera soldé immédiatement, soyez sans crainte.";
                      await askedToLead(titleAlert, true, context);
                      _controller.clear();
                      Navigator.pushNamed(context, Notifications.rootName);
                    } else {
                      await askedToLead(rechargeCrypto['error'], false, context);
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Numero Moov incorrect, veuillez bien verifier',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: colorError,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
                },
                child: Text('Confirmer'))
          ],
        );
      default:
        return Container(
          height: 50,
          width: 50,
        );
    }
  }
}