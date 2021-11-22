import 'package:flutter/material.dart';
import 'package:shouz/Constant/CodeScanner.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Constant/VerifyUser.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart' as prefix1;
import 'package:shouz/Pages/Checkout.dart';
import 'package:shouz/Pages/CreateEvent.dart';
import 'package:shouz/Pages/ExplainEvent.dart';
import 'package:shouz/Pages/IntPharma.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

class WidgetPage extends StatefulWidget {
  static bool isUnlock = true;

  @override
  _WidgetPageState createState() => _WidgetPageState();
}

class _WidgetPageState extends State<WidgetPage> {
  List commande = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInfo();
  }

  loadInfo() async {
    final info = await new ConsumeAPI().setSettings();
    if (info['etat'] == 'found') {
      setState(() {
        commande = [
          (WidgetPage.isUnlock)
              ? {
                  "icon": "Verification tickets",
                  "desc": "Decoder le code réçu par vos invités"
                }
              : {
                  "icon": "Vérification tickets bloqué",
                  "desc":
                      "Débloquer votre compte évenementiel afin de bénéficier à ce service"
                },
          {
            "icon": "pharmacie de garde",
            "desc": "Les pharmacies de garde votre localité"
          },
          {
            "icon": "prix des médicaments",
            "desc": "Liste standard de prix de médicament"
          },
          {
            "icon": "Récharger son shouzpay",
            "desc": "Recharger votre compte ShouzPay"
          },
          (info['result']['isActivateForfait'])
              ? {
                  "icon": "Creer un evenement",
                  "desc": "Créer votre evenement et manager le"
                }
              : {
                  "icon": "Compte evenement",
                  "desc": "Débloquer votre compte évenementiel"
                },
          (WidgetPage.isUnlock)
              ? {
                  "icon": "Devenir Conducteur",
                  "desc":
                      "Enregistrer vos informations de conducteur et le tour est joué"
                }
              : {
                  "icon": "Compte evenement",
                  "desc": "Débloquer votre compte évenementiel"
                },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prefix0.backgroundColor,
      appBar: AppBar(
        backgroundColor: prefix0.backgroundColor,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.0),
        ),
        title: Text('Outils'),
      ),
      body: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          itemCount: commande.length,
          itemBuilder: (context, index) => block(context, commande[index])),
    );
  }

  Widget block(context, item) {
    Widget block;
    switch (item['icon']) {
      case "pharmacie de garde":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.deepPurple[200],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(prefix1.MyFlutterAppSecond.pharmacy,
                color: Colors.deepPurple[900], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: prefix0.Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: prefix0.Style.sousTitre(11.0)),
          onTap: () {
            Navigator.of(context).push((MaterialPageRoute(
                builder: (BuildContext context) => IntPharma())));
          },
        );
        break;
      case "prix des médicaments":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.green[200],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(prefix1.MyFlutterAppSecond.medicine,
                color: Colors.green[900], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: prefix0.Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: prefix0.Style.sousTitre(11.0)),
          onTap: () {
            print(item);
          },
        );
        break;
      case "Compte evenement":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.red[200],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(Icons.lock_open, color: Colors.red[900], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: prefix0.Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: prefix0.Style.sousTitre(11.0)),
          onTap: () {
            Navigator.of(context).push((MaterialPageRoute(
                // builder: (BuildContext context)=> CreateEvent()
                builder: (BuildContext context) => ExplainEvent())));
          },
        );
        break;
      case "Verification tickets":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.amber[200],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(Icons.settings_overscan,
                color: Colors.amber[900], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: prefix0.Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: prefix0.Style.sousTitre(11.0)),
          onTap: () {
            Navigator.of(context)
                .push((MaterialPageRoute(builder: (context) => CodeScanner())));
          },
        );
        break;
      case "Vérification tickets bloqué":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(50.0)),
            child:
                Icon(Icons.lock_outline, color: Colors.blue[900], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: prefix0.Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: prefix0.Style.sousTitre(11.0)),
          onTap: () {
            print(item);
          },
        );
        break;
      case "Creer un evenement":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(Icons.event_seat, color: Colors.blue[900], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: prefix0.Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: prefix0.Style.sousTitre(11.0)),
          onTap: () {
            Navigator.of(context).push((MaterialPageRoute(
                builder: (BuildContext context) => CreateEvent())));
          },
        );
        break;
      case "Récharger son shouzpay":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(prefix1.MyFlutterAppSecond.credit_card,
                color: Colors.grey[700], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: prefix0.Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: prefix0.Style.sousTitre(11.0)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) => VerifyUser(
                    redirect: Checkout.rootName)));
          },
        );
        break;
      case "Devenir Conducteur":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.brown[300],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(prefix1.MyFlutterAppSecond.car_seat_with_seatbelt,
                color: Colors.brown[700], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: prefix0.Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: prefix0.Style.sousTitre(11.0)),
          onTap: () {
            print(item);
          },
        );
        break;
      default:
        block = null;
        break;
    }

    return block;
  }
}
