import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/VerifyUser.dart';
import 'package:shouz/Pages/Checkout.dart';
import 'package:shouz/Pages/checkout_recharge_mobile_money.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Constant/widget_common.dart';

import 'Login.dart';
import 'checkout_retrait.dart';
import 'checkout_retrait_mobile_money.dart';

class ChoiceMethodPayement extends StatefulWidget {
  bool isRetrait;
  ChoiceMethodPayement({required Key key, required this.isRetrait}) : super(key: key);

  @override
  _ChoiceMethodPayementState createState() => _ChoiceMethodPayementState();
}

class _ChoiceMethodPayementState extends State<ChoiceMethodPayement> {
  Map<dynamic, dynamic>? info;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  late AppState appState;

  void initState() {
    super.initState();
    appState = Provider.of<AppState>(context, listen: false);
    LoadInfo();
  }

  Future LoadInfo() async {
    try {

      final data = await consumeAPI.getAllPercentage();

      if(data["etat"] == 'found') {
        setState(() {
          info = data["result"];
        });
      } else if(data["etat"] == 'notFound') {
        showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Plusieurs connexions à ce compte', "Pour une question de sécurité nous allons devoir vous déconnecter.", context),
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
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        title: Text("${widget.isRetrait ? 'Retrait' : 'Rechargement' } ShouzPay"),
        backgroundColor: backgroundColor,
        elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                child: Text(widget.isRetrait ?
                "Vous pouvez retirer votre argent par differents moyens. Nous vous garantissons sécurité, fiabilité, rapidité, maniabilité."
                    :
                "Rechargez votre compte pour passer des achats d'articles, des tickets d'évènements, de tickets de voyages et autres services 🤗",
                style: Style.simpleTextOnNews(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                child: Text("Selectionnez le mode de paiement :", style: Style.simpleTextOnNews(),),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () {
                          appState.setPercentageRecharge(info!['PERCENTAGE_SHOUZPAY_CRYPTO']);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => VerifyUser(key: UniqueKey(), redirect: widget.isRetrait ? CheckoutRetrait.rootName : Checkout.rootName,)));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 100,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("images/cryptopayement.jpg"),
                                      fit: BoxFit.contain
                                  )
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text("Crypto Monnaie", style: Style.grandTitreBlack(12),),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(info == null || widget.isRetrait ? "" : "Frais ${(info!['PERCENTAGE_SHOUZPAY_CRYPTO'] * 100).toString()}%", style: Style.simpleTextBlack(),),
                            ),
                          ],
                        ),
                      ),

                    ),
                    Card(
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () {
                          appState.setPercentageRecharge(info!['PERCENTAGE_SHOUZPAY_MOBILE_MONEY']);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => VerifyUser(key: UniqueKey(), redirect: widget.isRetrait ? CheckoutRetraitMobileMoney.rootName : CheckoutRechargeMobileMoney.rootName,)));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 100,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("images/mobile_money.jpg"),
                                      fit: BoxFit.contain
                                  )
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text("Mobile Money", style: Style.grandTitreBlack(12),),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(info == null || widget.isRetrait ? "" : "Frais ${(info!['PERCENTAGE_SHOUZPAY_MOBILE_MONEY'] * 100).toString()}%", style: Style.simpleTextBlack(),),
                            ),
                          ],
                        ),
                      ),

                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}