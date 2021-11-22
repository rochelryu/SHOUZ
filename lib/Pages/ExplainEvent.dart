import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/VerifyUser.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/ResultSubscribeForfait.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/Utils/Database.dart';

class ExplainEvent extends StatefulWidget {
  @override
  _ExplainEventState createState() => _ExplainEventState();
}

class _ExplainEventState extends State<ExplainEvent> {
  AppState appState;
  bool createPass = true;
  List<int> forfait = [0, 0, 0, 0, 0];
  List<Map<String, String>> displayItem = [
    {
      "title": "BASIQUE",
      'background': 'images/none.jpg',
      'numberTotalEvent': 'Nbre Max Evenements/mois : 1',
      'maxPlace': 'Nbre Max place : 1000',
    },
    {
      "title": "PREMIUM",
      'background': 'images/premiumCard.jpg',
      'numberTotalEvent': 'Nbre Max Evenements/mois : 2',
      'maxPlace': 'Nbre Max place : 200',
    },
    {
      "title": "MASTER CLASS",
      'background': 'images/masterClass.jpg',
      'numberTotalEvent': 'Nbre Max Evenements/mois : 4',
      'maxPlace': 'Nbre Max place : 500',
    },
    {
      "title": "GOLD",
      'background': 'images/gold.jpg',
      'numberTotalEvent': 'Nbre Max Evenements/mois : 8',
      'maxPlace': 'Nbre Max place : 1200',
    },
    {
      "title": "DIAMOND",
      'background': 'images/diamomd.jpg',
      'numberTotalEvent': 'Nbre Max Evenements/mois : illimité',
      'maxPlace': 'Nbre Max place : illimité',
    },
  ];
  String pin = '';
  User newClient;

  void initState() {
    super.initState();
    LoadInfo();
    getNewPin();
  }

  Future getNewPin() async {
    try {
      String pin = await getPin();
      setState(() {
        this.pin = pin;
        createPass = (this.pin.length > 0) ? false : true;
      });
    } catch (e) {
      print("Erreur $e");
    }
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
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding:
                    EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        flex: 6,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Vos Evenements', style: Style.titre(30)),
                              Text(
                                  'Maximiser vos revenus en vendant les tickets de vos propres evenements',
                                  style: Style.sousTitre(14))
                            ],
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.white,
                          iconSize: 30,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Container(
                height: 200,
                child: CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  items: displayItem.map((value) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Card(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(value['background'])),
                                borderRadius: BorderRadius.circular(4)),
                            child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                  Text(
                                    value['title'],
                                    style: value['title'] != "BASIQUE"
                                        ? Style.grandTitre(23)
                                        : Style.grandTitreBlack(23),
                                  )
                                ])),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Divider(
                        color: colorSecondary,
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Text(" CHOISISSEZ UN FORFAIT ",
                          textAlign: TextAlign.center,
                          style: Style.sousTitre(13)),
                    ),
                    Flexible(
                      flex: 1,
                      child: Divider(
                        color: colorSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      if (newClient.wallet >= 2000) {
                        setState(() {
                          forfait = [1, 0, 0, 0, 0];
                        });
                      } else {
                        _askedToInsufisanceWallet();
                      }
                    },
                    title: Text('BASIQUE', style: Style.titreEvent(20)),
                    subtitle: Column(
                      children: <Widget>[
                        Text(
                            'Pour ceux qui font uniquement des Evenements Gratuits',
                            style: Style.sousTitre(13)),
                        Text('2.000 F cfa/mois',
                            style: Style.priceDealsProduct())
                      ],
                    ),
                    selected: true,
                    isThreeLine: true,
                    trailing: Icon(Icons.check_circle_outline,
                        color:
                            (forfait[0] == 0) ? Colors.grey[700] : colorText),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      if (newClient.wallet >= 10000) {
                        setState(() {
                          forfait = [0, 1, 0, 0, 0];
                        });
                      } else {
                        _askedToInsufisanceWallet();
                      }
                    },
                    title: GradientText(
                      'PREMIUM',
                      textAlign: TextAlign.left,
                      gradient: LinearGradient(
                          colors: [Color(0xFF9708CC), Color(0xFF43CBFF)]),
                      style: Style.titreEvent(20),
                    ),
                    subtitle: Column(
                      children: <Widget>[
                        Text('Pour des Evenements de maximun 200 personnes',
                            style: Style.sousTitre(13)),
                        Text('10.000 F cfa/mois',
                            style: Style.priceDealsProduct())
                      ],
                    ),
                    selected: true,
                    isThreeLine: true,
                    trailing: Icon(Icons.check_circle_outline,
                        color:
                            (forfait[1] == 0) ? Colors.grey[700] : colorText),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      if (newClient.wallet >= 25000) {
                        setState(() {
                          forfait = [0, 0, 1, 0, 0];
                        });
                      } else {
                        _askedToInsufisanceWallet();
                      }
                    },
                    title: GradientText(
                      'MASTER CLASS',
                      textAlign: TextAlign.left,
                      gradient: LinearGradient(
                          colors: [Color(0xFFE57373), Color(0xFFFF1744)]),
                      style: Style.titreEvent(20),
                    ),
                    subtitle: Column(
                      children: <Widget>[
                        Text('Pour des Evenements de maximun 500 personnes',
                            style: Style.sousTitre(13)),
                        Text('25.000 F cfa/mois',
                            style: Style.priceDealsProduct())
                      ],
                    ),
                    selected: true,
                    isThreeLine: true,
                    trailing: Icon(Icons.check_circle_outline,
                        color:
                            (forfait[2] == 0) ? Colors.grey[700] : colorText),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      if (newClient.wallet >= 80000) {
                        setState(() {
                          forfait = [0, 0, 0, 1, 0];
                        });
                      } else {
                        _askedToInsufisanceWallet();
                      }
                    },
                    title: GradientText(
                      'GOLD',
                      textAlign: TextAlign.left,
                      gradient: LinearGradient(
                          colors: [Color(0xFFFFEA00), Color(0xFFFF0000)]),
                      style: Style.titreEvent(20),
                    ),
                    subtitle: Column(
                      children: <Widget>[
                        Text('Pour des Evenements de maximun 1200 personnes',
                            style: Style.sousTitre(13)),
                        Text('80.000 F cfa/mois',
                            style: Style.priceDealsProduct())
                      ],
                    ),
                    selected: true,
                    isThreeLine: true,
                    trailing: Icon(Icons.check_circle_outline,
                        color:
                            (forfait[3] == 0) ? Colors.grey[700] : colorText),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      if (newClient.wallet >= 200000) {
                        setState(() {
                          forfait = [0, 0, 0, 0, 1];
                        });
                      } else {
                        _askedToInsufisanceWallet();
                      }
                    },
                    title: GradientText(
                      'DIAMOND',
                      textAlign: TextAlign.left,
                      gradient: LinearGradient(
                          colors: [Color(0xFFE0E0E0), Color(0xFF424242)]),
                      style: Style.titreEvent(20),
                    ),
                    subtitle: Column(
                      children: <Widget>[
                        Text(
                            'Votre limite c\'est votre imagination, c\'est à vous de jouer',
                            style: Style.sousTitre(13)),
                        Text('200.000 F cfa/mois',
                            style: Style.priceDealsProduct())
                      ],
                    ),
                    selected: true,
                    isThreeLine: true,
                    trailing: Icon(Icons.check_circle_outline,
                        color:
                            (forfait[4] == 0) ? Colors.grey[700] : colorText),
                  ),
                ),
              ),
              SizedBox(height: 25)
            ],
          ),
        ),
        floatingActionButton: (forfait.indexOf(1) == -1)
            ? SizedBox(width: 30)
            : FloatingActionButton(
                onPressed: () async {
                  await _askedToLead();
                },
                backgroundColor: colorText,
                child: Icon(Icons.check),
              ));
  }

  Future<Null> _askedToLead() async {
    var forfaitName = '';
    switch (forfait.indexOf(1)) {
      case 0:
        forfaitName = 'BASIQUE';
        appState.setForfaitEventEnum(forfaitName, displayItem[0]['background']);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => VerifyUser(
                redirect: ResultSubscribeForfait.rootName)));
        break;
      case 1:
        forfaitName = 'PREMIUM';
        appState.setForfaitEventEnum(forfaitName, displayItem[1]['background']);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => VerifyUser(
                redirect: ResultSubscribeForfait.rootName)));
        break;
      case 2:
        forfaitName = 'MASTER_CLASS';
        appState.setForfaitEventEnum(forfaitName, displayItem[2]['background']);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => VerifyUser(
                redirect: ResultSubscribeForfait.rootName)));
        break;
      case 3:
        forfaitName = 'GOLD';
        appState.setForfaitEventEnum(forfaitName, displayItem[3]['background']);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => VerifyUser(
                redirect: ResultSubscribeForfait.rootName)));
        break;
      case 4:
        forfaitName = 'DIAMOND';
        appState.setForfaitEventEnum(forfaitName, displayItem[4]['background']);
        break;
    }
  }

  _askedToInsufisanceWallet() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              "CREDIT INSUFISANT VEUILLEZ RECHARGER VOTRE COMPTE",
              textAlign: TextAlign.center,
              style: Style.sousTitre(13),
            ),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(children: [
                  RaisedButton(
                      child: Text('Ok'),
                      color: colorError,
                      onPressed: () {
                        Navigator.pop(context);
                        //Navigator.pushNamed(context, '/checkout');
                      }),
                ]),
              )
            ],
          );
        });
  }
}
