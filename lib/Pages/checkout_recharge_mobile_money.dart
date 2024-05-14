import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/Constant/widget_common.dart';

import '../Constant/helper.dart';
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
  ConsumeAPI consumeAPI = ConsumeAPI();
  String orangeNumero = '';
  String mtnNumero = '';
  String moovNumero = '';
  String waveNumero = '';
  String otp = '';
  String previsionMontant = 'N/A';
  int indexStepper = 0;
  bool loadConfirmation = false, displayInfoTransaction = false;
  late SharedPreferences prefs;
  Map<dynamic, dynamic>? info;
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerForReceive = TextEditingController();
  TextEditingController _controllerOtp = TextEditingController();

  TypePayement _character = TypePayement.orange;

  User? newClient;


  void initState() {
    super.initState();
    appState = Provider.of<AppState>(context, listen: false);
    LoadInfo();
  }

  Future LoadInfo() async {
    try {

      prefs = await SharedPreferences.getInstance();
      final amountRecharge = prefs.getDouble("amountRecharge") ?? 0.0;
      // final data = await consumeAPI.getMobileMoneyAvalaible();
      // if(data["etat"] == 'found') {
      //   setState(() {
      //     info = data["result"];
      //   });
        User user = await DBProvider.db.getClient();
        setState(() {
          newClient = user;
        });
        if(amountRecharge >= 500) {
          final intAmountToString = amountRecharge.ceil().toString().split('.')[0];
          final amount = int.parse(intAmountToString);
            if(amount % 100 == 0) {
              setState(() {
                displayInfoTransaction = true;
              });
              _controllerForReceive.text = amount.toString();
              _controller.text = (amount / (1 - appState.getPercentageRecharge)).ceil().toString();
              setState(() {
                displayInfoTransaction = true;
              });
            } else {
              _controller.text = "";
              setState(() {
                displayInfoTransaction = false;
              });
            }
        } else {
          _controller.text = "";
          setState(() {
            displayInfoTransaction = false;
          });
        }
      // } else if(data["etat"] == 'notFound') {
      //   showDialog(
      //         context: context,
      //         builder: (BuildContext context) =>
      //             dialogCustomError('Plusieurs connexions à ce compte', "Pour une question de sécurité nous allons devoir vous déconnecter.", context),
      //         barrierDismissible: false);
      //   Navigator.of(context).push(MaterialPageRoute(
      //       builder: (builder) => Login()));
      //
      // }
      // else {
      //   Fluttertoast.showToast(
      //       msg: "Une Erreur s'est produit, veuillez ressayer ulterieurement",
      //       toastLength: Toast.LENGTH_LONG,
      //       gravity: ToastGravity.CENTER,
      //       timeInSecForIosWeb: 1,
      //       backgroundColor: colorError,
      //       textColor: Colors.white,
      //       fontSize: 16.0
      //   );
      // }

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
            icon: Icon(Icons.arrow_back, color: Style.white,),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            }),
        title: Text("Rechargement Mobile Money", style: Style.titleNews(),),
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
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text("Votre solde: ${newClient != null ? reformatNumberForDisplayOnPrice(newClient!.wallet) : ''}", textAlign: TextAlign.center, style: Style.titre(20.0),),
                      GestureDetector(
                        onTap: () {
                          setState(() { _character = TypePayement.orange; indexStepper = 0; });
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
                          setState(() { _character = TypePayement.mtn; indexStepper = 0; });
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
                          setState(() { _character = TypePayement.moov; indexStepper = 0; });
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
                      GestureDetector(
                        onTap: () {
                          setState(() { _character = TypePayement.wave; indexStepper = 0; });
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
                      ),
                    ],
                  )
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(right: 20),
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
        return SingleChildScrollView(
          padding: EdgeInsets.all(0),
          child: Stepper(
            margin: EdgeInsets.only(left: 50),
              currentStep: indexStepper,
              onStepCancel: () {
                if(indexStepper > 0) {
                  setState(() {
                    indexStepper -= 1;
                  });
                }
              },
              onStepContinue: () {
                if(indexStepper <= 1) {
                  if(indexStepper == 0) {
                    if(mtnNumero.trim().length == 10 && _controller.text.length >= 3) {
                      bool isValid = true;
                      if(double.parse(_controllerForReceive.text) + newClient!.wallet > maxAmountOnAccount) {
                        isValid = false;
                        Fluttertoast.showToast(
                            msg: "Le montant maximum qu'un compte SHOUZPAY peut accumuler en 30 jours est $maxAmountOnAccount",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 5,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      if(double.parse(_controllerForReceive.text) > maxAmountOfTransaction) {
                        isValid = false;
                        Fluttertoast.showToast(
                            msg: "Le montant maximum pour une transaction SHOUZPAY est $maxAmountOfTransaction",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 5,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      if(isValid) {
                        setState(() {
                          indexStepper += 1;
                        });
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Numero Mtn incorrect ou le montant est insufisant',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 5,
                          backgroundColor: colorError,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  } else {
                    setState(() {
                      indexStepper += 1;
                    });
                  }

                }
              },
              controlsBuilder: (BuildContext context, ControlsDetails controlsDetails){
                return Row(
                  children: [
                    if(indexStepper <= 1) ElevatedButton(
                        style: raisedButtonStyleMtnMoney,
                        onPressed: controlsDetails.onStepContinue,
                        child: Text('Suivant')),
                    SizedBox(width: 15),
                    if(indexStepper > 0) TextButton(
                        onPressed: controlsDetails.onStepCancel,
                        child: Text('Précédent', style: Style.warning(13),)),




                  ],
                );
              },
              steps: <Step>[
                Step(
                    title: Text("Information sur la transaction", style: Style.titre(13)),
                    content: Column(
                      children: [
                        Text("Faites entrer votre numero de telephone Mtn qui est censé faire la transaction (Montant Min: 500)", style: Style.sousTitre(11)),
                        SizedBox(height: 5),
                        Container(
                          height: 35,
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 10.0, right: 3.0),
                          decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          child: TextField(
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              hintText: "Numero Tel (Ex: 05XXXXXXXX)",
                              hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                            ),
                            onChanged: (text){
                              setState(() {
                                mtnNumero = text;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 0.39,
                                  padding: EdgeInsets.only(left: 10.0, right: 3.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white30,
                                      borderRadius: BorderRadius.circular(30.0)
                                  ),
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    controller: _controller,
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Montant à envoyer",
                                      hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                                    ),
                                    onChanged: (value) {
                                      if(value.length >= 2) {
                                        final amount = int.parse(value);
                                        if (amount >= 500 && amount % 100 == 0 ) {
                                          _controllerForReceive.text = (amount * (1 - appState.getPercentageRecharge)).floor().toString();
                                          setState(() {
                                            displayInfoTransaction = true;
                                          });

                                        } else {
                                          setState(() {
                                            _controllerForReceive.text = "";
                                            displayInfoTransaction = false;
                                          });
                                        }
                                      } else {
                                        _controllerForReceive.text = "";
                                        setState(() {
                                          displayInfoTransaction = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 0.39,
                                  padding: EdgeInsets.only(left: 10.0, right: 3.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white30,
                                      borderRadius: BorderRadius.circular(30.0)
                                  ),
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    controller: _controllerForReceive,
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Montant à recevoir",
                                      hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                                    ),
                                    onChanged: (value) {
                                      if(value.length >= 2) {
                                        final amount = int.parse(value);
                                        if (amount >= 500) {
                                          if(amount % 100 == 0) {
                                            _controller.text = (amount / (1 - appState.getPercentageRecharge)).ceil().toString();
                                            setState(() {
                                              displayInfoTransaction = true;
                                            });
                                          } else {
                                            _controller.text = "";
                                            setState(() {
                                              displayInfoTransaction = false;
                                            });
                                          }
                                        }
                                      } else {
                                        _controller.text = "";
                                        setState(() {
                                          displayInfoTransaction = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )),
                        if(displayInfoTransaction) Text("Vous allez tranférer ${_controller.text} de votre Mtn Money afin de recevoir ${_controllerForReceive.text} sur votre compte Shouz 🙂", style: Style.sousTitre(12, colorSuccess)),
                      ],
                    )
                ),
                Step(
                    title: Text("Confirmation", style: Style.titre(13)),
                    content: Column(
                      children: [
                        Text("Le $mtnNumero sera débité de ${_controller.text} ${newClient?.currencies} pour recevoir ${_controllerForReceive.text} ${newClient?.currencies} sur votre compte SHOUZPAY.\nSi vous êtes d'accord cliquez sur 'suivant'", style: Style.sousTitre(15)),
                        SizedBox(height: 10),

                      ],
                    )
                ),
                Step(
                  title: Text("Dernière étape", style: Style.titre(13)),
                  content: Column(
                    children: [
                      Text("Préparez-vous à faire entrer votre code Mtn Money sur le téléphone qui detient ce numero ${moovNumero.trim()}", style: Style.sousTitre(15)),
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
                                await prefs.remove('amountRecharge');
                                Navigator.pushNamed(context, MenuDrawler.rootName);
                              } else if(rechargeCrypto['etat'] == 'inWait') {
                                final titleAlert = "Nous vous avons envoyez une demande de confirmation de cette transaction, une fois confirmation faite votre compte sera soldé immédiatement, soyez sans crainte. 🤌";
                                await askedToLead(titleAlert, true, context);
                                _controller.clear();
                                await prefs.remove('amountRecharge');
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
                          child: Text('Oui, je suis prêt')),
                      SizedBox(height: 10),
                    ],
                  )
                ),
              ]),
        );
      case TypePayement.wave:
        return SingleChildScrollView(
          padding: EdgeInsets.all(0),
          child: Stepper(
              margin: EdgeInsets.only(left: 50),
              currentStep: indexStepper,
              onStepCancel: () {
                if(indexStepper > 0) {

                  setState(() {
                    indexStepper -= 1;
                  });
                }
              },
              onStepContinue: () {
                if(indexStepper <= 1) {
                  if(indexStepper == 0) {
                    if(_controller.text.length >= 3) {
                      bool isValid = true;
                      if(double.parse(_controllerForReceive.text) + newClient!.wallet > maxAmountOnAccount) {
                        isValid = false;
                        Fluttertoast.showToast(
                            msg: "Le montant maximum qu'un compte SHOUZPAY peut accumuler en 30 jours est $maxAmountOnAccount",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 5,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      if(double.parse(_controllerForReceive.text) > maxAmountOfTransaction) {
                        isValid = false;
                        Fluttertoast.showToast(
                            msg: "Le montant maximum pour une transaction SHOUZPAY est $maxAmountOfTransaction",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 5,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      if(isValid) {
                        setState(() {
                          indexStepper += 1;
                        });
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Le montant minimum de rechargement est $minAmountOfTransaction',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 5,
                          backgroundColor: colorError,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  } else {
                    setState(() {
                      indexStepper += 1;
                    });
                  }

                }
              },
              controlsBuilder: (BuildContext context, ControlsDetails controlsDetails){
                return Row(
                  children: [
                    if(indexStepper <= 1) ElevatedButton(
                        style: raisedButtonStyleWave,
                        onPressed: controlsDetails.onStepContinue,
                        child: Text('Suivant')),
                    SizedBox(width: 15),
                    if(indexStepper > 0) TextButton(
                        onPressed: controlsDetails.onStepCancel,
                        child: Text('Précédent', style: Style.warning(13),)),
                  ],
                );
              },
              steps: <Step>[
                Step(
                    title: Text("Information sur la transaction", style: Style.titre(13)),
                    content: Column(
                      children: [
                        if(!displayInfoTransaction) Text("Faites entrer le montant de votre réchargement (Montant Min: 500)", style: Style.sousTitre(11)),
                        if(!displayInfoTransaction) SizedBox(height: 5),
                        Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 35,
                              width: MediaQuery.of(context).size.width * 0.39,
                              padding: EdgeInsets.only(left: 10.0, right: 3.0),
                              decoration: BoxDecoration(
                                  color: Colors.white30,
                                  borderRadius: BorderRadius.circular(30.0)
                              ),
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                controller: _controller,
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Montant à envoyer",
                                  hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                                ),
                                onChanged: (value) {
                                  if(value.length >= 2) {
                                    final amount = int.parse(value);
                                    if (amount >= 500 && amount % 100 == 0 ) {
                                      _controllerForReceive.text = (amount * (1 - appState.getPercentageRecharge)).floor().toString();
                                      setState(() {
                                        displayInfoTransaction = true;
                                      });
                                    } else {
                                      setState(() {
                                        _controllerForReceive.text = "";
                                        displayInfoTransaction = false;
                                      });
                                    }
                                  } else {
                                    _controllerForReceive.text = "";
                                    setState(() {
                                      displayInfoTransaction = false;
                                    });
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 35,
                              width: MediaQuery.of(context).size.width * 0.39,
                              padding: EdgeInsets.only(left: 10.0, right: 3.0),
                              decoration: BoxDecoration(
                                  color: Colors.white30,
                                  borderRadius: BorderRadius.circular(30.0)
                              ),
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                controller: _controllerForReceive,
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Montant à recevoir",
                                  hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                                ),
                                onChanged: (value) {
                                  if(value.length >= 2) {
                                    final amount = int.parse(value);
                                    if (amount >= 500 ) {
                                      if(amount % 100 == 0) {
                                        _controller.text = (amount / (1 - appState.getPercentageRecharge)).ceil().toString();
                                        setState(() {
                                          displayInfoTransaction = true;
                                        });
                                      } else {
                                        _controller.text = "";
                                        setState(() {
                                          displayInfoTransaction = false;
                                        });
                                      }
                                    }
                                  } else {
                                    _controller.text = "";
                                    setState(() {
                                      displayInfoTransaction = false;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )),
                        if(displayInfoTransaction) Text("Vous allez tranférer ${_controller.text} de votre Wave afin de recevoir ${_controllerForReceive.text} sur votre compte Shouz 🙂", style: Style.sousTitre(12, colorSuccess)),

                      ],
                    )
                ),
                Step(
                  title: Text("Passé à l'action", style: Style.titre(13)),
                  content: Column(
                    children: [
                      Text("Faites la transaction Wave de ${_controller.text} au numero suivante :", style: Style.sousTitre(13)),
                      SizedBox(height: 5),
                      SelectableText(info == null ? '' : '${info!['wave']}', style: Style.mobileMoneyWave(),
                        toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
                        showCursor: true,
                        cursorWidth: 2,
                        cursorColor: Colors.white,
                        cursorRadius: const Radius.circular(5),

                      )
                    ],
                  ),
                ),
                Step(
                    title: Text("Confirmation", style: Style.titre(13)),
                    content: Column(
                      children: [
                        Text("Après la transaction, vous avez reçu un message de confirmation envoyé par Wave.\nÀ la dernière ligne du message se trouve le code de référence de la transaction.\nCopié le et venez le coller ici 👇", style: Style.sousTitre(10)),
                        SizedBox(height: 5,),
                        Container(
                          height: 45,
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 10.0, right: 3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 45,
                                width: 250,
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
                                    hintText: "Code référence",
                                    hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                                  ),
                                  onChanged: (text){
                                    setState(() {
                                      waveNumero = text;
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 5,),
                        loadConfirmation ? Container(height: 30,child: Center(child:  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.blue], strokeWidth: 2),),) : ElevatedButton(
                            style: raisedButtonStyleWave,
                            onPressed: () async {
                              if(waveNumero.trim().length > 5) {
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
                                  await prefs.remove('amountRecharge');
                                  Navigator.pushNamed(context, MenuDrawler.rootName);
                                } else if(rechargeCrypto['etat'] == 'inWait') {
                                  final titleAlert = "Nous analysons cette transaction au près de Wave, une fois confirmation faite votre compte sera soldé immédiatement, soyez sans crainte.";
                                  await askedToLead(titleAlert, true, context);
                                  _controller.clear();
                                  await prefs.remove('amountRecharge');
                                  Navigator.pushNamed(context, Notifications.rootName);
                                } else {
                                  await askedToLead(rechargeCrypto['error'], false, context);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: 'Code de ref incorrect, veuillez bien verifier',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: colorError,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              }
                            },
                            child: Text('Terminer')),
                        SizedBox(height: 10),
                      ],
                    )
                ),
              ]),
        );

      case TypePayement.orange:
        return SingleChildScrollView(
          padding: EdgeInsets.all(0),
          child: Stepper(
              margin: EdgeInsets.only(left: 50),
              currentStep: indexStepper,
              onStepCancel: () {
                if(indexStepper > 0) {

                  setState(() {
                    indexStepper -= 1;
                  });
                }
              },
              onStepContinue: () {
                if(indexStepper <= 1) {
                  if(indexStepper == 0) {
                    if(orangeNumero.trim().length == 10 && _controller.text.length >= 3) {
                      bool isValid = true;
                      if(double.parse(_controllerForReceive.text) + newClient!.wallet > maxAmountOnAccount) {
                        isValid = false;
                        Fluttertoast.showToast(
                            msg: "Le montant maximum qu'un compte SHOUZPAY peut accumuler en 30 jours est $maxAmountOnAccount",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 5,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      if(double.parse(_controllerForReceive.text) > maxAmountOfTransaction) {
                        isValid = false;
                        Fluttertoast.showToast(
                            msg: "Le montant maximum pour une transaction SHOUZPAY est $maxAmountOfTransaction",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 5,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      if(isValid) {
                        setState(() {
                          indexStepper += 1;
                        });
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Numero Orange incorrect ou le montant est insufisant',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 5,
                          backgroundColor: colorError,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  } else {
                    if(otp.length == 4) {
                      setState(() {
                        indexStepper += 1;
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: "Le code temporaire (code d'autorisation) doit être forcement de 4 chiffres",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 5,
                          backgroundColor: colorError,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  }

                }
              },
              controlsBuilder: (BuildContext context, ControlsDetails controlsDetails){
                return Row(
                  children: [
                    if(indexStepper <= 1) ElevatedButton(
                        style: raisedButtonStyleOrangeMoney,
                        onPressed: controlsDetails.onStepContinue,
                        child: Text('Suivant')),
                    SizedBox(width: 15),
                    if(indexStepper > 0) TextButton(
                        onPressed: controlsDetails.onStepCancel,
                        child: Text('Précédent', style: Style.warning(13),)),
                  ],
                );
              },
              steps: <Step>[
                Step(
                    title: Text("Information sur la transaction", style: Style.titre(13)),
                    content: Column(
                      children: [
                        Text("Faites entrer votre numero de telephone Orange qui est censé faire la transaction (Montant Min: 500)", style: Style.sousTitre(11)),
                        SizedBox(height: 5),
                        Container(
                          height: 35,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          child: TextField(
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 12),
                              counterText: '',
                              border: InputBorder.none,
                              hintText: "Numero Tel (Ex: 07XXXXXXXX)",
                              hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                            ),
                            onChanged: (text){
                              setState(() {
                                orangeNumero = text;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 0.39,
                                  padding: EdgeInsets.only(left: 10.0, right: 3.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white30,
                                      borderRadius: BorderRadius.circular(30.0)
                                  ),
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    controller: _controller,
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(bottom: 12),
                                      hintText: "Montant à envoyer",
                                      hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                                    ),
                                    onChanged: (value) {
                                      if(value.length >= 2) {
                                        final amount = int.parse(value);
                                        if (amount >= 500 && amount % 100 == 0 ) {
                                          _controllerForReceive.text = (amount * (1 - appState.getPercentageRecharge)).floor().toString();
                                          setState(() {
                                            displayInfoTransaction = true;
                                          });
                                        } else {
                                          setState(() {
                                            _controllerForReceive.text = "";
                                            displayInfoTransaction = false;
                                          });
                                        }
                                      } else {
                                        _controllerForReceive.text = "";
                                        displayInfoTransaction = false;
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 0.39,
                                  padding: EdgeInsets.only(left: 10.0, right: 3.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white30,
                                      borderRadius: BorderRadius.circular(30.0)
                                  ),
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    controller: _controllerForReceive,
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(bottom: 12),
                                      border: InputBorder.none,
                                      hintText: "Montant à recevoir",
                                      hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                                    ),
                                    onChanged: (value) {
                                      if(value.length >= 2) {
                                        final amount = int.parse(value);
                                        if (amount >= 500 ) {
                                          if(amount % 100 == 0) {
                                            _controller.text = (amount / (1 - appState.getPercentageRecharge)).ceil().toString();
                                            setState(() {
                                              displayInfoTransaction = true;
                                            });
                                          } else {
                                            _controller.text = "";
                                            setState(() {
                                              displayInfoTransaction = false;
                                            });
                                          }
                                        }
                                      } else {
                                        _controller.text = "";
                                        setState(() {
                                          displayInfoTransaction = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )),
                        if(displayInfoTransaction) Text("Vous allez tranférer ${_controller.text} de votre Orange Money afin de recevoir ${_controllerForReceive.text} sur votre compte Shouz 🙂", style: Style.sousTitre(12, colorSuccess)),
                      ],
                    )
                ),
                Step(
                  title: Text("Passé à l'action", style: Style.titre(13)),
                  content: Column(
                    children: [
                      Text("Composez le #144*82#, Orange vous démandera de faire entrer votre code et vous donnera un code temporaire.\nFaites entrez ce code temporaire de 4 chiffres dans le champ ci-dessous", style: Style.sousTitre(11)),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Container(
                            height: 35,
                            width: MediaQuery.of(context).size.width * 0.49,
                            padding: EdgeInsets.only(left: 10.0, right: 3.0),
                            decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(30.0)
                            ),
                            child: TextField(
                              maxLength: 4,
                              keyboardType: TextInputType.phone,
                              controller: _controllerOtp,
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 12),
                                counterText: '',
                                border: InputBorder.none,
                                hintText: "Code d'autorisation",
                                hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                              ),
                              onChanged: (value) {
                                if(value.length < 5) {
                                  setState(() {
                                    otp = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Step(
                    title: Text("Confirmation", style: Style.titre(13)),
                    content: Column(
                      children: [
                        Text("Le $orangeNumero sera débité de ${_controller.text} ${newClient?.currencies} pour recevoir ${_controllerForReceive.text} ${newClient?.currencies} sur votre compte SHOUZPAY.\nVous Confirmez cela ?", style: Style.sousTitre(10)),
                        SizedBox(height: 10),
                        loadConfirmation ? Container(height: 30,child: Center(child:  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [Colors.deepOrangeAccent], strokeWidth: 2),),) : ElevatedButton(
                            style: raisedButtonStyleOrangeMoney,
                            onPressed: () async {
                              if(orangeNumero.trim().length == 10) {
                                setState(() {
                                  loadConfirmation = true;
                                });
                                final rechargeCrypto = await consumeAPI.rechargeMobileMoney('orange', orangeNumero.trim(), _controller.text, _controllerOtp.text);
                                setState(() {
                                  loadConfirmation = false;
                                });
                                if(rechargeCrypto['etat'] == 'found') {
                                  await askedToLead(rechargeCrypto['result']['content'], true, context);
                                  _controller.clear();
                                  await prefs.remove('amountRecharge');
                                  Navigator.pushNamed(context, MenuDrawler.rootName);
                                } else if(rechargeCrypto['etat'] == 'inWait') {
                                  final titleAlert = "Nous analysons cette transaction au près de Orange, une fois confirmation faite votre compte sera soldé immédiatement, soyez sans crainte.";
                                  await askedToLead(titleAlert, true, context);
                                  _controller.clear();
                                  await prefs.remove('amountRecharge');
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
                            child: Text('Oui, je confirme')),
                        SizedBox(height: 10),
                      ],
                    )
                ),
              ]),
        );

      case TypePayement.moov:
        return SingleChildScrollView(
          padding: EdgeInsets.all(0),
          child: Stepper(
              margin: EdgeInsets.only(left: 50),
              currentStep: indexStepper,
              onStepCancel: () {
                if(indexStepper > 0) {

                  setState(() {
                    indexStepper -= 1;
                  });
                }
              },
              onStepContinue: () {
                if(indexStepper <= 1) {
                  if(indexStepper == 0) {
                    if(moovNumero.trim().length == 10 && _controller.text.length >= 3) {
                      bool isValid = true;
                      if(double.parse(_controllerForReceive.text) + newClient!.wallet > maxAmountOnAccount) {
                        isValid = false;
                        Fluttertoast.showToast(
                            msg: "Le montant maximum qu'un compte SHOUZPAY peut accumuler en 30 jours est $maxAmountOnAccount",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 5,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      if(double.parse(_controllerForReceive.text) > maxAmountOfTransaction) {
                        isValid = false;
                        Fluttertoast.showToast(
                            msg: "Le montant maximum pour une transaction SHOUZPAY est $maxAmountOfTransaction",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 5,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      if(isValid) {
                        setState(() {
                          indexStepper += 1;
                        });
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Numero Moov incorrect ou le montant est insufisant',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 5,
                          backgroundColor: colorError,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  } else {
                    setState(() {
                      indexStepper += 1;
                    });
                  }

                }
              },
              controlsBuilder: (BuildContext context, ControlsDetails controlsDetails){
                return Row(
                  children: [
                    if(indexStepper <= 1) ElevatedButton(
                        style: raisedButtonStyleMoovMoney,
                        onPressed: controlsDetails.onStepContinue,
                        child: Text('Suivant')),
                    SizedBox(width: 15),
                    if(indexStepper > 0) TextButton(
                        onPressed: controlsDetails.onStepCancel,
                        child: Text('Précédent', style: Style.warning(13),)),
                  ],
                );
              },
              steps: <Step>[
                Step(
                    title: Text("Information sur la transaction", style: Style.titre(13)),
                    content: Column(
                      children: [
                        Text("Faites entrer votre numero de telephone Moov qui est censé faire la transaction (Montant Min: 500)", style: Style.sousTitre(11)),
                        SizedBox(height: 5),
                        Container(
                          height: 35,
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 10.0, right: 3.0),
                          decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          child: TextField(
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 12),
                              counterText: '',
                              border: InputBorder.none,
                              hintText: "Numero Tel (Ex: 01XXXXXXXX)",
                              hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                            ),
                            onChanged: (text){
                              setState(() {
                                moovNumero = text;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 0.39,
                                  padding: EdgeInsets.only(left: 10.0, right: 3.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white30,
                                      borderRadius: BorderRadius.circular(30.0)
                                  ),
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    controller: _controller,
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(bottom: 12),
                                      border: InputBorder.none,
                                      hintText: "Montant à envoyer",
                                      hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                                    ),
                                    onChanged: (value) {
                                      if(value.length >= 2) {
                                        final amount = int.parse(value);
                                        if (amount >= 500 && amount % 100 == 0 ) {
                                          _controllerForReceive.text = (amount * (1 - appState.getPercentageRecharge)).floor().toString();
                                          setState(() {
                                            displayInfoTransaction = true;
                                          });
                                        } else {
                                          setState(() {
                                            _controllerForReceive.text = "";
                                            displayInfoTransaction = false;
                                          });
                                        }
                                      } else {
                                        _controllerForReceive.text = "";
                                        setState(() {
                                          displayInfoTransaction = false;
                                        });
                                      }
                                    },

                                  ),
                                ),
                                Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 0.39,
                                  padding: EdgeInsets.only(left: 10.0, right: 3.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white30,
                                      borderRadius: BorderRadius.circular(30.0)
                                  ),
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    controller: _controllerForReceive,
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(bottom: 12),
                                      border: InputBorder.none,
                                      hintText: "Montant à recevoir",
                                      hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[200]),
                                    ),
                                    onChanged: (value) {
                                      if(value.length >= 2) {
                                        final amount = int.parse(value);
                                        if (amount >= 500 ) {
                                          if(amount % 100 == 0) {
                                            _controller.text = (amount / (1 - appState.getPercentageRecharge)).ceil().toString();
                                            setState(() {
                                              displayInfoTransaction = true;
                                            });
                                          } else {
                                            _controller.text = "";
                                            setState(() {
                                              displayInfoTransaction = false;
                                            });
                                          }
                                        }
                                      } else {
                                        _controller.text = "";
                                        setState(() {
                                          displayInfoTransaction = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )),
                        if(displayInfoTransaction) Text("Vous allez tranférer ${_controller.text} de votre Moov Money afin de recevoir ${_controllerForReceive.text} sur votre compte Shouz 🙂", style: Style.sousTitre(12, colorSuccess)),
                      ],
                    )
                ),
                Step(
                  title: Text("Confirmation", style: Style.titre(13)),
                  content: Column(
                    children: [
                      Text("Le $moovNumero sera débité de ${_controller.text} ${newClient?.currencies} pour recevoir ${_controllerForReceive.text} ${newClient?.currencies} sur votre compte SHOUZPAY.\nSi vous êtes d'accord cliquez sur 'suivant'", style: Style.sousTitre(11)),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
                Step(
                    title: Text("Dernière étape", style: Style.titre(13)),
                    content: Column(
                      children: [
                        Text("Préparez vous à faire entrer votre code Moov Money sur le téléphone qui detient ce numero ${moovNumero.trim()}", style: Style.sousTitre(15)),
                        SizedBox(height: 10),
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
                                  await prefs.remove('amountRecharge');
                                  Navigator.pushNamed(context, MenuDrawler.rootName);
                                } else if(rechargeCrypto['etat'] == 'inWait') {
                                  final titleAlert = "Nous vous avons envoyez une demande de confirmation de cette transaction, une fois confirmation faite votre compte sera soldé immédiatement, soyez sans crainte. 🤌";
                                  await askedToLead(titleAlert, true, context);
                                  _controller.clear();
                                  await prefs.remove('amountRecharge');
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
                            child: Text('Oui, je suis prêt')),
                        SizedBox(height: 10),
                      ],
                    )
                ),
              ]),
        );
      default:
        return Container(
          height: 50,
          width: 50,
        );
    }
  }
}