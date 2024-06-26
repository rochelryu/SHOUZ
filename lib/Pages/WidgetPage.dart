import 'package:flutter/material.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart' as prefix1;
import 'package:shouz/Pages/CreateEvent.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

import '../Constant/Style.dart';
import '../Constant/widget_common.dart';
import 'choice_categorie_scan.dart';
import 'choice_method_payement.dart';
import 'list_filleul.dart';

class WidgetPage extends StatefulWidget {

  @override
  _WidgetPageState createState() => _WidgetPageState();
}

class _WidgetPageState extends State<WidgetPage> {
  List commande = [];
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInfo();
  }

  loadInfo() async {
    final info = await consumeAPI.setSettings();
    if (info['etat'] == 'found') {
      setState(() {
        commande = [
          {
                  "icon": "Vérification tickets",
                  "desc": "Décrypter le code reçu par vos invités"
                }
             ,

          (info['result']['myCodeParrain'] != "") ? {
            "icon": "Bonus Sponsor",
            "desc": "Vos commissions spossoring et filleul"
          } : {
            "icon": "",
            "desc": ""
          },
          /*{
            "icon": "pharmacie de garde",
            "desc": "Disponible pour votre localité"
          },
          {
            "icon": "prix des médicaments",
            "desc": "Liste standard de prix de médicament"
          },
          {
            "icon": "Récharger son ShouzPay",
            "desc": "Par Crypto Monnaie ou Mobile Money"
          },
          {
            "icon": "Rétirer son argent",
            "desc": "Par Crypto Monnaie ou Mobile Money"
          },*/
          (!info['result']['isActivateCovoiturage'])
              ? (info['result']['assuranceVehicule'].length > 0) ? {"icon": "Analyse Document Conducteur","desc":"Nous analysons vos documents envoyés"} : {"icon": "Devenir Conducteur","desc":"Enregistrer vos informations"}
              : {
                  "icon": "Modifier information Conducteur",
                  "desc": "Modifier Si elles ne sont plus d'actualité"
                },
          (info['result']['isActivateCovoiturage']) ? {
            "icon": "Statistique Covoiturage",
            "desc": "Bilan sur vos voyages extra-villes effectués"
          } : {
            "icon": "",
            "desc": ""
          },

          (info['result']['isActivateCovoiturage']) ? {
            "icon": "Statistique VTC",
            "desc": "Bilan sur vos voyages intra-villes effectués"
          } : {
            "icon": "",
            "desc": ""
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Style.white, size: 22.0),
        ),
        title: Text('Outils', style: Style.titleNews(),),
        centerTitle: true,
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
      case "Bonus Sponsor":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.deepPurple[200],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(Icons.account_circle_outlined,
                color: Colors.deepPurple[900], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: Style.sousTitre(11.0)),
          onTap: () {
            Navigator.of(context)
                .push((MaterialPageRoute(builder: (context) => ListFilleul(key: UniqueKey(),))));
          },
        );
        break;
      case "Statistique VTC":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.green[200],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(Icons.stacked_bar_chart,
                color: Colors.green[900], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: Style.sousTitre(11.0)),
          onTap: () {
          },
        );
        break;
      case "Modifier information Conducteur":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.red[200],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(prefix1.MyFlutterAppSecond.car_seat_with_seatbelt, color: Colors.red[900], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: Style.sousTitre(11.0)),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) =>
                    dialogCustomError('Indisponible', "Nous sommes en procédure judiciaire pour l'établissement de ce service.\nBientôt disponible", context),
                barrierDismissible: false);
          },
        );
        break;
      case "Vérification tickets":
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
              style: Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: Style.sousTitre(11.0)),
          onTap: () {
            Navigator.of(context)
                .push((MaterialPageRoute(builder: (context) => ChoiceCategorieScan())));
          },
        );
        break;
      case "Analyse Document Conducteur":
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
              style: Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: Style.sousTitre(11.0)),

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
              style: Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: Style.sousTitre(11.0)),
          onTap: () {
            Navigator.of(context).push((MaterialPageRoute(
                builder: (BuildContext context) => CreateEvent())));
          },
        );
        break;
      case "Statistique Covoiturage":
        block = ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(Icons.stacked_bar_chart,
                color: Colors.grey[700], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: Style.sousTitre(11.0)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) => ChoiceMethodPayement(key: UniqueKey(), isRetrait: false,)));
          },
        );
        break;

      case "Rétirer son argent":
        block = ListTile(
          contentPadding:
          EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          leading: Container(
            height: 55.0,
            width: 55.0,
            decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(50.0)),
            child: Icon(prefix1.MyFlutterAppSecond.credit_card,
                color: Colors.blue[900], size: 22.0),
          ),
          title: Text(item['icon'].toString().toUpperCase(),
              style: Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: Style.sousTitre(11.0)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) => ChoiceMethodPayement(key: UniqueKey(), isRetrait: true,)));
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
              style: Style.titre(15.0)),
          subtitle: Text(item['desc'].toString().toUpperCase(),
              style: Style.sousTitre(11.0)),
          onTap: () {
            //Navigator.pushNamed(context, DemandeConducteur.rootName);
            showDialog(
                context: context,
                builder: (BuildContext context) =>
                    dialogCustomError('Indisponible', "Nous sommes en procédure judiciaire pour l'établissement de ce service.\nBientôt disponible", context),
                barrierDismissible: false);
          },
        );
        break;
      default:
        block = SizedBox(height: 12);
        break;
    }

    return block;
  }
}
