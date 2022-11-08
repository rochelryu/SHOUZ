import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/VerifyUser.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/ResultSubscribeForfait.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../Constant/helper.dart';
import 'choice_method_payement.dart';

class ExplainEvent extends StatefulWidget {
  static String rootName = '/explainEvent';
  @override
  _ExplainEventState createState() => _ExplainEventState();
}

class _ExplainEventState extends State<ExplainEvent> {
  late AppState appState;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  late List<dynamic> displayItem;
  List<Map<dynamic, dynamic>> displayItemCarousel = [{'img': '${ConsumeAPI.AssetPublicServer}free.jpeg', 'title': 'FREE'},{'img': '${ConsumeAPI.AssetPublicServer}none.jpeg', 'title': 'BASIC'}, {'img': '${ConsumeAPI.AssetPublicServer}premiumCard.jpeg', 'title': 'PREMIUM'}, {'img': '${ConsumeAPI.AssetPublicServer}masterClass.jpeg', 'title': 'MASTER CLASS'}, {'img': '${ConsumeAPI.AssetPublicServer}gold.jpeg', 'title': 'GOLD'},{'img': '${ConsumeAPI.AssetPublicServer}platine.jpeg', 'title': 'PLATINE'}, {'img': '${ConsumeAPI.AssetPublicServer}diamomd.jpg', 'title': 'DIAMOND'}];
  bool isFinishLoad = false;
  User? newClient;
  late NavigatorState _navigator;
  CarouselController carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    LoadInfo();
  }

  @override
  void didChangeDependencies() {
    _navigator = Navigator.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    carouselController.stopAutoPlay();
    super.dispose();
  }


  LoadInfo() async {
    User user = await DBProvider.db.getClient();
    final data = await consumeAPI.getAllTypeEvents(user.ident);
    setState(() {
      newClient = user;
      displayItem = data;
      isFinishLoad = true;
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
                  carouselController: carouselController,
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
                  items: displayItemCarousel.map((value) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Card(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(value['img'])),
                                borderRadius: BorderRadius.circular(4)),
                                child: Center(
                                        child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            Text(
                                            value['title'],
                                            style: value['title'] != "FREE" && value['title'] != "GOLD"
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: isFinishLoad ?
                    Container(
                      width: double.infinity,

                      child: Column(
                        children: reformatForPackage(),
                      ),
                    )
                    : LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2)
                ,
              ),

              SizedBox(height: 25)
            ],
          ),
        ),
    );
  }

  Future askedToLead(String forfaitName, int maxPlace) async {
    appState.setForfaitEventEnum(forfaitName, maxPlace);
    Timer(const Duration(milliseconds: 1000), () {
      _navigator.push(MaterialPageRoute(
          builder: (builder) => VerifyUser(
            redirect: ResultSubscribeForfait.rootName, key: UniqueKey(),)));
    });

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
                  ElevatedButton(
                      child: Text('Ok'),
                      style: raisedButtonStyleError,
                      onPressed: () {
                        Navigator.pop(context);
                        Timer(const Duration(milliseconds: 1000), () {
                          _navigator.push(MaterialPageRoute(
                              builder: (builder) => ChoiceMethodPayement(key: UniqueKey(), isRetrait: false,)));
                        });
                      }),
                ]),
              )
            ],
          );
        });
  }

  Widget titleOfPackage(String title) {
    if(title == 'BASIC') {
      return GradientText(
        'BASIC',
        textAlign: TextAlign.left,
        colors: [Color(0xFF8D6E63), Color(0xFF3E2723)],
        style: Style.titreEvent(20),
      );
    } else if (title == 'PREMIUM') {
      return GradientText(
        'PREMIUM',
        textAlign: TextAlign.left,
        colors: [Color(0xFF9708CC), Color(0xFF43CBFF)],
        style: Style.titreEvent(20),
      );
    } else if (title == 'MASTER_CLASS') {
      return GradientText(
        'MASTER CLASS',
        textAlign: TextAlign.left,
        colors: [Color(0xFFE57373), Color(0xFFFF1744)],
        style: Style.titreEvent(20),
      );
    } else if (title == 'GOLD') {
      return GradientText(
        'GOLD',
        textAlign: TextAlign.left,
        colors: [Color(0xFFFFEA00), Color(0xFFFF0000)],
        style: Style.titreEvent(20),
      );
    } else if (title == 'PLATINE') {
      return GradientText(
        'PLATINE',
        textAlign: TextAlign.left,
        colors: [Color(0xFF004D40), Color(0xFF80CBC4)],
        style: Style.titreEvent(20),
      );
    } else if (title == 'DIAMOND') {
      return GradientText(
        'DIAMOND',
        textAlign: TextAlign.left,
        colors: [Color(0xFFE0E0E0), Color(0xFF424242)],
        style: Style.titreEvent(20),
      );
    } else {
      return Text(title, style: Style.titreEvent(20));
    }
  }

  List<Widget> reformatForPackage() {
    List<Widget> widgets = displayItem.map(
            (element) =>
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: Colors.black26,borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      if (newClient!.wallet >= element['priceLocalCurrencies']) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => dialogCustomForValidateAction('FORFAIT ${element['title'].toString().replaceAll(',', ' ')}', "Votre compte SHOUZPAY sera débité de ${reformatNumberForDisplayOnPrice(element['priceLocalCurrencies'])} ${newClient!.currencies}.\nÊtes vous d'accord ?", 'Oui', () async {
                              await askedToLead(element['title'], element['maxPlace']);
                            }, context),
                            barrierDismissible: false);

                      } else {
                        _askedToInsufisanceWallet();
                      }
                    },
                    title: titleOfPackage(element['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            "${element['describe']}.\nMax place: ${element['maxPlace'].toString()}",
                            style: Style.sousTitre(13)),
                        Container(
                          height: 30,
                          width: double.infinity,
                          child: Center(
                          child: Text("${reformatNumberForDisplayOnPrice(element['priceLocalCurrencies'])} ${newClient!.currencies}",
                              style: Style.titre(15)),
                          ),
                        )
                      ],
                    ),
                    selected: true,
                    isThreeLine: true,
                   ),
                )).toList();
    return widgets;
  }

}
