import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/VerifyUser.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/ResultSubscribeForfait.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class ExplainEvent extends StatefulWidget {
  static String rootName = '/explainEvent';
  @override
  _ExplainEventState createState() => _ExplainEventState();
}

class _ExplainEventState extends State<ExplainEvent> {
  late AppState appState;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  String forfaitName = '';
  int maxPlace = 0;
  late List<dynamic> displayItem;
  List<Map<dynamic, dynamic>> displayItemCarousel = [{'img': 'images/none.jpg', 'title': 'BASIC'}, {'img': 'images/premiumCard.jpg', 'title': 'PREMIUM'}, {'img': 'images/masterClass.jpg', 'title': 'MASTER CLASS'}, {'img': 'images/gold.jpg', 'title': 'GOLD'}, {'img': 'images/diamomd.jpg', 'title': 'DIAMOND'}];
  bool isFinishLoad = false;
  User? newClient;

  void initState() {
    super.initState();
    LoadInfo();
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
                                    image: AssetImage(value['img'])),
                                borderRadius: BorderRadius.circular(4)),
                                child: Center(
                                        child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            Text(
                                            value['title'],
                                            style: value['title'] != "BASIC"
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
        floatingActionButton: forfaitName == ''
            ? SizedBox(width: 30)
            : FloatingActionButton(
                onPressed: () async {
                  await _askedToLead();
                },
                backgroundColor: colorText,
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(Icons.check),
                  Text(forfaitName.substring(0, 1), style: Style.chatIsMe(25),)
                ],),
              ));
  }

  Future<Null> _askedToLead() async {
    appState.setForfaitEventEnum(forfaitName, maxPlace);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => VerifyUser(
          redirect: ResultSubscribeForfait.rootName, key: UniqueKey(),)));
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

  Widget titleOfPackage(String title) {
    if(title == 'BASIC') {
      return Text(title, style: Style.titreEvent(20));
    } else if (title == 'PREMIUM') {
      return GradientText(
        'PREMIUM',
        textAlign: TextAlign.left,
        colors: [Color(0xFF9708CC), Color(0xFF43CBFF)],
        style: Style.titreEvent(20),
      );
    } else if (title == 'MASTER_CLASS') {
      return GradientText(
        'MASTER_CLASS',
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
                        setState(() {
                          forfaitName = element['title'];
                          maxPlace = element['maxPlace'];
                        });
                      } else {
                        _askedToInsufisanceWallet();
                      }
                    },
                    title: titleOfPackage(element['title']),
                    subtitle: Column(
                      children: <Widget>[
                        Text(
                            "${element['describe']}. \nMax place : ${element['maxPlace'].toString()}",
                            style: Style.sousTitre(13)),
                        Text("${element['priceLocalCurrencies'].toString()} ${newClient!.currencies}",
                            style: Style.priceDealsProduct())
                      ],
                    ),
                    selected: true,
                    isThreeLine: true,
                   ),
                )).toList();
    return widgets;
  }

}
