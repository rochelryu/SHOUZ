

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

class CheckoutRetraitMobileMoney extends StatefulWidget {
  static String rootName = '/CheckoutRetraitMobileMoney';
  CheckoutRetraitMobileMoney({required Key key}) : super(key: key);

  @override
  _CheckoutRetraitMobileMoneyState createState() =>
      _CheckoutRetraitMobileMoneyState();
}

class _CheckoutRetraitMobileMoneyState
    extends State<CheckoutRetraitMobileMoney> {
  late AppState appState;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  String orangeNumero = '';
  String mtnNumero = '';
  String moovNumero = '';
  String waveNumero = '';
  String previsionMontant = 'N/A';
  bool loadConfirmation = false;
  TextEditingController _controller = TextEditingController();
  User? newClient;
  TypePayement _character = TypePayement.orange;


  void initState() {
    super.initState();
    _controller.text = '0';
    appState = Provider.of<AppState>(context, listen: false);
    LoadInfo();
  }

  Future LoadInfo() async {
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
            icon: Icon(Icons.arrow_back, color: Style.white,),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            }),
        title: Text("Retrait Mobile Money", style: Style.titleNews(),),
        centerTitle: true,
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
                      Text("Votre solde: ${newClient != null ? reformatNumberForDisplayOnPrice(newClient!.wallet) : ''}", textAlign: TextAlign.center, style: Style.titre(20.0),),

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
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      image: DecorationImage(
                                        image: AssetImage("images/om.png"),
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
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    image: DecorationImage(
                                      image: AssetImage("images/momo.jpeg"),
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
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      image: DecorationImage(
                                        image: AssetImage("images/moov.png"),
                                        fit: BoxFit.cover,
                                      )
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                      /*GestureDetector(
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
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      image: DecorationImage(
                                        image: AssetImage("images/wave.png"),
                                        fit: BoxFit.cover,
                                      )
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                      ),*/
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
            Text("1. Faites entrer votre numero de telephone Mtn qui doit recevoir la transaction puis le montant de votre transaction. Montant Min: 500 Frs (frais de timbre & taxe ${appState.getAmountTvaWithdraw.toString()} Frs pour n'importe qu'elle montant)", style: Style.sousTitre(11)),
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
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            counterText: '',
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
                          keyboardType: TextInputType.phone,
                          controller: _controller,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Montant",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),

                        ),
                      ))
                ],
              ),
            ),
            SizedBox(height: 5),
            if (int.parse(_controller.text) - appState.getAmountTvaWithdraw > 0) Text("Vous allez recevoir ${int.parse(_controller.text) - appState.getAmountTvaWithdraw}", style: Style.sousTitre(11)),
            SizedBox(height: 10),
            loadConfirmation ? Container(height: 30,child: Center(child:  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.yellow], strokeWidth: 2),),) : ElevatedButton(
                style: raisedButtonStyleMtnMoney,
                onPressed: () async {
                  if(mtnNumero.trim().length == 10 && int.parse(_controller.text) >= 500 && int.parse(_controller.text) % 100 == 0 && double.parse(_controller.text) <= newClient!.wallet) {
                    setState(() {
                      loadConfirmation = true;
                    });
                    final demandeRetrait = await consumeAPI.demandeRetrait('mtn', mtnNumero.trim(), _controller.text);
                    if(demandeRetrait['etat'] == 'found') {
                      final titleAlert = demandeRetrait['result']['content'];
                      await askedToLead(titleAlert, true, context);
                    } else if( demandeRetrait['etat'] == "badLevel") {
                      final titleAlert = "Vous avez rechargé votre compte il y a moins d'une heure, c'est une heure après un rechargement qu'il peut y avoir un possible retrait";
                      await askedToLead(titleAlert, false, context);
                    } else if( demandeRetrait['etat'] == "inWait") {
                      final titleAlert = "Votre demande est en cours de traitement, vous allez la recevoir dans les plus brefs délais";
                      await askedToLead(titleAlert, true, context);
                    } else {
                      await askedToLead(demandeRetrait['error'], false, context);
                    }
                    setState(() {
                      mtnNumero = '';
                      loadConfirmation = false;
                    });
                    _controller.text = '0';


                  } else {
                    Fluttertoast.showToast(
                        msg: 'Verifié le numero Mtn ainsi que le montant (le montant doit être un multiple de 100 et être supérieur ou egal à 500 Frs)',
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

            Text("1. Faites entrer votre numero de telephone Wave qui doit recevoir la transaction puis le montant de votre transaction. Montant Min: 500 Frs (frais de timbre & taxe ${appState.getAmountTvaWithdraw.toString()} Frs pour n'importe qu'elle montant)", style: Style.sousTitre(11)),
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
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            counterText: '',
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
                          keyboardType: TextInputType.phone,
                          controller: _controller,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Montant",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),

                        ),
                      ))
                ],
              ),
            ),
            SizedBox(height: 5),
            if (int.parse(_controller.text) - appState.getAmountTvaWithdraw > 0) Text("Vous allez recevoir ${int.parse(_controller.text) - appState.getAmountTvaWithdraw}", style: Style.sousTitre(11)),
            SizedBox(height: 10),
            loadConfirmation ? Container(height: 30,child: Center(child:  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.blue], strokeWidth: 2),),) : ElevatedButton(
                style: raisedButtonStyleWave,
                onPressed: () async {
                  if(waveNumero.trim().length == 10 && double.parse(_controller.text) >= 500 && int.parse(_controller.text) % 100 == 0 && double.parse(_controller.text) <= newClient!.wallet) {
                    setState(() {
                      loadConfirmation = true;
                    });
                    final demandeRetrait = await consumeAPI.demandeRetrait('wave', waveNumero.trim(), _controller.text);
                    if(demandeRetrait['etat'] == 'found') {
                      final titleAlert = demandeRetrait['result']['content'];
                      await askedToLead(titleAlert, true, context);
                    } else if( demandeRetrait['etat'] == "badLevel") {
                      final titleAlert = "Vous avez rechargé votre compte il y a moins d'une heure, c'est une heure après un rechargement qu'il peut y avoir un possible retrait";
                      await askedToLead(titleAlert, false, context);
                    } else if( demandeRetrait['etat'] == "inWait") {
                      final titleAlert = "Votre demande est en cours de traitement, vous allez la recevoir dans les plus brefs délais";
                      await askedToLead(titleAlert, true, context);
                    } else {
                      await askedToLead(demandeRetrait['error'], false, context);
                    }
                    setState(() {
                      waveNumero = '';
                      loadConfirmation = false;
                    });
                    _controller.text = '0';
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Verifié le numero Wave ainsi que le montant (le montant doit être un multiple de 100 et être supérieur ou egal à 500 Frs)',
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

            Text("1. Faites entrer votre numero de telephone Orange qui doit recevoir la transaction puis le montant de votre transaction. Montant Min: 500 Frs (frais de timbre & taxe ${appState.getAmountTvaWithdraw.toString()} Frs pour n'importe qu'elle montant)", style: Style.sousTitre(11)),
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
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            counterText: '',
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
                          keyboardType: TextInputType.phone,
                          controller: _controller,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Montant",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                        ),
                      ))
                ],
              ),
            ),
            SizedBox(height: 5),
            if (int.parse(_controller.text) - appState.getAmountTvaWithdraw > 0) Text("Vous allez recevoir ${int.parse(_controller.text) - appState.getAmountTvaWithdraw}", style: Style.sousTitre(11)),
            SizedBox(height: 10),
            loadConfirmation ? Container(height: 30,child: Center(child:  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.deepOrangeAccent], strokeWidth: 2),),) : ElevatedButton(
                style: raisedButtonStyleOrangeMoney,
                onPressed: () async {
                  if(orangeNumero.trim().length == 10 && int.parse(_controller.text) >= 500 && int.parse(_controller.text) % 100 == 0 && double.parse(_controller.text) <= newClient!.wallet) {
                    setState(() {
                      loadConfirmation = true;
                    });
                    final demandeRetrait = await consumeAPI.demandeRetrait('orange', orangeNumero.trim(), _controller.text);
                    if(demandeRetrait['etat'] == 'found') {
                      final titleAlert = demandeRetrait['result']['content'];
                      await askedToLead(titleAlert, true, context);
                    } else if( demandeRetrait['etat'] == "badLevel") {
                      final titleAlert = "Vous avez rechargé votre compte il y a moins d'une heure, c'est une heure après un rechargement qu'il peut y avoir un possible retrait";
                      await askedToLead(titleAlert, false, context);
                    } else if( demandeRetrait['etat'] == "inWait") {
                      final titleAlert = "Votre demande est en cours de traitement, vous allez la recevoir dans les plus brefs délais";
                      await askedToLead(titleAlert, true, context);
                    } else {
                      await askedToLead(demandeRetrait['error'], false, context);
                    }
                    setState(() {
                      orangeNumero = '';
                      loadConfirmation = false;
                    });
                    _controller.text = '0';
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Verifié le numero Orange ainsi que le montant (le montant doit être un multiple de 100 et être supérieur ou egal à 500 Frs)',
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
            Text("1. Faites entrer votre numero de telephone Moov qui doit recevoir la transaction puis le montant de votre transaction. Montant Min: 500 Frs (frais de timbre & taxe ${appState.getAmountTvaWithdraw.toString()} Frs pour n'importe qu'elle montant)", style: Style.sousTitre(11)),
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
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            counterText: '',
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
                          keyboardType: TextInputType.phone,
                          controller: _controller,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Montant",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                        ),
                      ))
                ],
              ),
            ),
            SizedBox(height: 5),
            if (int.parse(_controller.text) - appState.getAmountTvaWithdraw > 0) Text("Vous allez recevoir ${int.parse(_controller.text) - appState.getAmountTvaWithdraw}", style: Style.sousTitre(11)),
            SizedBox(height: 10),
            loadConfirmation ? Container(height: 30,child: Center(child:  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.blueAccent], strokeWidth: 2),),) : ElevatedButton(
                style: raisedButtonStyleMoovMoney,
                onPressed: () async {
                  if(moovNumero.trim().length == 10 && int.parse(_controller.text) >= 500 && int.parse(_controller.text) % 100 == 0 && double.parse(_controller.text) <= newClient!.wallet) {
                    setState(() {
                      loadConfirmation = true;
                    });
                    final demandeRetrait = await consumeAPI.demandeRetrait('moov', moovNumero.trim(), _controller.text);
                    if(demandeRetrait['etat'] == 'found') {
                      final titleAlert = demandeRetrait['result']['content'];
                      await askedToLead(titleAlert, true, context);
                    } else if( demandeRetrait['etat'] == "badLevel") {
                      final titleAlert = "Vous avez rechargé votre compte il y a moins d'une heure, c'est une heure après un rechargement qu'il peut y avoir un possible retrait";
                      await askedToLead(titleAlert, false, context);
                    } else if( demandeRetrait['etat'] == "inWait") {
                      final titleAlert = "Votre demande est en cours de traitement, vous allez la recevoir dans les plus brefs délais";
                      await askedToLead(titleAlert, true, context);
                    } else {
                      await askedToLead(demandeRetrait['error'], false, context);
                    }
                    setState(() {
                      moovNumero = '';
                      loadConfirmation = false;
                    });
                    _controller.text = '0';
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Verifié le numero Moov ainsi que le montant (le montant doit être un multiple de 100 et être supérieur ou egal à 500 Frs)',
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