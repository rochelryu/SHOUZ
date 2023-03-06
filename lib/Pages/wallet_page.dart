import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constant/Style.dart';
import '../Constant/helper.dart';
import '../Constant/my_flutter_app_second_icons.dart';
import '../Constant/widget_common.dart';
import '../Models/User.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import '../Utils/Database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login.dart';
import 'choice_method_payement.dart';

class WalletPage extends StatefulWidget {
  static String rootName = '/Wallet_Page';
  const WalletPage({required Key key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  ConsumeAPI consumeAPI = new ConsumeAPI();
  User? newClient;
  List<dynamic> arrayOfAllTransaction = [];
  bool isLoading = true, isError = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Future getInfo() async {
    User user = await DBProvider.db.getClient();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        newClient = user;
      });

      final getAllTransactions = await consumeAPI.getTransactionHistory();
      if(getAllTransactions['etat'] == 'notFound') {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialogCustomError('Plusieurs connexions à ce compte', "Pour une question de sécurité nous allons devoir vous déconnecter.", context),
            barrierDismissible: false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => Login()));
      } else if(getAllTransactions['etat'] == 'found') {
        user = await DBProvider.db.getClient();
        setState(() {
          arrayOfAllTransaction = getAllTransactions['result']['arrayOfAllTransaction'];
          newClient = user;
          isLoading = false;
        });
        await prefs.setString('transactionHistory', jsonEncode(getAllTransactions['result']['arrayOfAllTransaction']));
      }
      else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }

    } catch (e) {
      final transactionHistoryString = prefs.getString("transactionHistory");
      if(transactionHistoryString != null) {
        setState(() {
          arrayOfAllTransaction = jsonDecode(transactionHistoryString) as List<dynamic>;
        });
      }
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: backgroundColor,
        title: Text('Portefeuille'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: getInfo,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              Container(
                width: double.infinity,
                  child: Text("Votre Solde", style: Style.titleInSegment(20), textAlign: TextAlign.center,)),
              SizedBox(height: 10),
              Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(newClient != null )Text(reformatNumberForDisplayOnPrice(newClient!.wallet), style: Style.titre(40),),
                      if(newClient != null ) Text(newClient!.currencies, style: Style.titre(12),)
                    ],
                  )
              ),
              SizedBox(height: 25),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 35),
                child: Row(
                  children: [
                    Expanded(child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => ChoiceMethodPayement(key: UniqueKey(), isRetrait: false)));
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 50,
                              margin: EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(MyFlutterAppSecond.money,
                                      color: Colors.grey[700], size: 30.0)
                                ],
                              ),
                            ),

                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text("Recharger", style: Style.grandTitreBlack(12),)
                            ),

                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    )),
                    SizedBox(width: 15),
                    Expanded(child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => ChoiceMethodPayement(key: UniqueKey(), isRetrait: true)));
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.lightBlue[100],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 50,
                              margin: EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(MyFlutterAppSecond.credit_card,
                                      color: Colors.blue[900], size: 30.0)
                                ],
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text("Retirer", style: Style.grandTitreBlack(12),),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    )),
                    SizedBox(width: 15),
                    Expanded(child: GestureDetector(
                      onTap: () async {
                        await launchUrl(
                            Uri.parse("https://wa.me/2250564250219"),
                          mode: LaunchMode.externalApplication
                        );
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green[200],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 50,
                              margin: EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.support_agent_outlined,
                                      color: Colors.green[900], size: 30.0)
                                ],
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text("Aide", style: Style.grandTitreBlack(12),),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    )),

                  ],
                ),
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Text("Historique", style: Style.titleInSegment(20)),
              ),
              if(isLoading) Center(child: Container(
                height: 200,
                width: 200,
                child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2),
              ),),
              if(isError && arrayOfAllTransaction.length == 0) isErrorSubscribe(context, 450),
              if(!isLoading && arrayOfAllTransaction.length > 0) ...transactionItem()
              //...transactionItem(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> transactionItem() {
    List<Widget> allTransactions = [];
    for(int index = 0; index < arrayOfAllTransaction.length; index++) {
      final transaction = arrayOfAllTransaction[index];
      final register = DateTime.parse(transaction['registerDate']);
      String afficheDate = (DateTime.now()
          .difference(DateTime(register.year, register.month, register.day)).inDays < 1)
          ? "Auj. à ${register.hour.toString()}h ${register.minute.toString()}"
          : "${register.day.toString()}/${register.month.toString()}/${register.year.toString()} à ${register.hour.toString()}h ${register.minute.toString()}";
      afficheDate = (DateTime.now()
          .difference(DateTime(register.year, register.month, register.day)).inDays == 1)
          ? "Hier à ${register.hour.toString()}h ${register.minute.toString()}"
          : afficheDate;
      allTransactions.add(
          Slidable(
            key: UniqueKey(),
            startActionPane: ActionPane(
              // A motion is a widget used to control how the pane animates.
              motion: const DrawerMotion(),

              // All actions are defined in the children parameter.
              children: [
                if(transaction["state"] == 1) SlidableAction(
                  onPressed: (context) async {
                    await consumeAPI.removeTransaction(transaction["_id"], transaction["typeTransaction"]);
                    setState(() {
                      arrayOfAllTransaction.removeAt(index);
                    });
                  },
                  backgroundColor: colorError,
                  foregroundColor: Colors.white,
                  icon: Icons.stop_circle,
                  label: 'Annuler',
                ),
                if(transaction["state"] != 1) SlidableAction(
                  onPressed: (context) async {
                    await launchUrl(
                        Uri.parse("https://wa.me/2250564250219?text=Problème sur mon ${transaction["typeTransaction"] == "WITHDRAW" ? "retrait" : "rechargement"} par ${transaction["network"].toString().toUpperCase()}.\nCode référence: ${transaction["_id"]}.\n${transaction["address"].length == 10 ? "Numero Mobile Money: " + transaction["address"]: "Adresse Crypto: "+ transaction["address"]}.\nDate Opération: ${formatedDateForLocal(register)}" ),
                        mode: LaunchMode.externalApplication
                    );
                  },
                  backgroundColor: colorText,
                  foregroundColor: colorPrimary,
                  icon: Icons.support_agent,
                  label: 'Signaler',
                ),
                SlidableAction(
                  // An action can be bigger than the others.
                  onPressed: (context) async {
                    await consumeAPI.hideTransaction(transaction["network"], transaction["_id"], transaction["typeTransaction"]);
                    setState(() {
                      arrayOfAllTransaction.removeAt(index);
                    });
                  },
                  backgroundColor: colorWarning,
                  foregroundColor: Colors.black,
                  icon: Icons.visibility_off_outlined,
                  label: 'Masquer',
                ),


              ],
            ),

            // The end action pane is the one at the right or the bottom side.
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  // An action can be bigger than the others.
                  onPressed: (context) async {
                    await consumeAPI.hideTransaction(transaction["network"], transaction["_id"], transaction["typeTransaction"]);
                    setState(() {
                      arrayOfAllTransaction.removeAt(index);
                    });
                  },
                  backgroundColor: colorWarning,
                  foregroundColor: Colors.black,
                  icon: Icons.visibility_off_outlined,
                  label: 'Masquer',
                ),
                if(transaction["state"] != 1) SlidableAction(
                  onPressed: (context) async {
                    await launchUrl(
                        Uri.parse("https://wa.me/2250564250219?text=Problème sur mon ${transaction["typeTransaction"] == "WITHDRAW" ? "retrait" : "rechargement"} par ${transaction["network"].toString().toUpperCase()}.\nCode référence: ${transaction["_id"]}.\n${transaction["address"].length == 10 ? "Numero Mobile Money: " + transaction["address"]: "Adresse Crypto: "+ transaction["address"]}.\nDate Opération: ${formatedDateForLocal(register)}" ),
                        mode: LaunchMode.externalApplication
                    );
                  },
                  backgroundColor: colorText,
                  foregroundColor: colorPrimary,
                  icon: Icons.support_agent,
                  label: 'Signaler',
                ),
                if(transaction["state"] == 1) SlidableAction(
                  onPressed: (context) async {
                    await consumeAPI.removeTransaction(transaction["_id"], transaction["typeTransaction"]);
                    setState(() {
                      arrayOfAllTransaction.removeAt(index);
                    });
                  },
                  backgroundColor: colorError,
                  foregroundColor: Colors.white,
                  icon: Icons.stop_circle,
                  label: 'Annuler',
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    image: DecorationImage(
                      image: AssetImage(imagePictureByNetwork(transaction["network"])),
                      fit: BoxFit.cover,
                    )
                ),
              ),
              title: Text(transaction["address"], style: Style.titre(15),),
              subtitle: Text(transaction["state"] == 1 ? "En attente" : transaction["state"] == 2 ? "Echouée" : afficheDate, style: Style.simpleTextOnBoardWithBolder(12)),
              trailing: Container(
                width: 120,
                height: 28,
                child: amountDisplayByStatus(transaction["state"], transaction["typeTransaction"], transaction["amount"]),
              ),
            ),
          )
      );
    }

    return allTransactions;
  }
  Widget amountDisplayByStatus(int state, String typeTransaction, dynamic amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${typeTransaction == "WITHDRAW" ? "-" : "+"}${reformatNumberForDisplayOnPrice(amount)}", style: Style.simpleTextWithSizeAndColors(14, state == 1 ? colorSecondary: typeTransaction == "WITHDRAW" ? colorError : colorSuccess),),
        Text(newClient!.currencies, style: Style.simpleTextWithSizeAndColors(7, state == 1 ? colorSecondary: typeTransaction == "WITHDRAW" ? colorError : colorSuccess),),
      ],
    );
  }

  String imagePictureByNetwork(String network) {
    switch(network) {
      case "bitcoin":
        return "images/bitcoin.png";
      case "ethereum":
        return "images/eth.png";
      case "wave":
        return "images/wave.png";
      case "orange":
        return "images/om.png";
      case "mtn":
        return "images/momo.jpeg";
      case "moov":
        return "images/moov.png";
      default:
        return "images/moov.png";
    }

  }
}
