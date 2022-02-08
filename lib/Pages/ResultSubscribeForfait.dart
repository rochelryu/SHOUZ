import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/CreateEvent.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class ResultSubscribeForfait extends StatefulWidget {
  static String rootName = '/resultSubscribeForfait';
  @override
  _ResultSubscribeForfaitState createState() => _ResultSubscribeForfaitState();
}

class _ResultSubscribeForfaitState extends State<ResultSubscribeForfait> {
  late AppState appState;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  int size = 0;
  int sizeReverse = 199;
  Future<dynamic>? subscribeCallback;

  void initState() {
    super.initState();
    LoadInfo();
  }
  Future LoadInfo() async {
    try {
      User user = await DBProvider.db.getClient();
      appState = Provider.of<AppState>(context, listen: false);
      final data = consumeAPI.subscribeEvent(forfait: appState.getForfaitEventEnum, ident: user.ident, recovery:user.recovery );
      setState(() {
        subscribeCallback = data;
        size = 299;
        sizeReverse = 250;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  Widget build(BuildContext context) {


    //print(' $subscribeIt ${appState.getForfaitEventEnum}');

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder(
          future: subscribeCallback,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return IsErrorSubscribe();
              case ConnectionState.waiting:
                return Center(
                  child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2),
                );

              case ConnectionState.active:
                return Center(
                  child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2),
                );

              case ConnectionState.done:
                if (snapshot.hasError) {
                  return IsErrorSubscribe();
                }
                var info = snapshot.data;
                return info == "found"
                    ? IsSuccessSubscribe()
                    : IsErrorSubscribe();

              // return new CardTopNewActu()
            }
          }),
    );
  }

  Widget IsErrorSubscribe() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new SvgPicture.asset(
              "images/notconnection.svg",
              semanticsLabel: 'Not Connection',
              height: MediaQuery.of(context).size.height * 0.39,
            ),
            Text(
                "Un problème de connexion avec le serveur, veuillez ressayer plutard.\n Ne vous inquiétez pas aucun prélèvement n'a été fait",
                textAlign: TextAlign.center,
                style: Style.sousTitreEvent(15)),
            SizedBox(height: 35),
            RaisedButton(
                child: Icon(Icons.block, color: Colors.white),
                color: colorError,
                onPressed: () async {
                  await Navigator.pushNamed(context, MenuDrawler.rootName);
                }),
          ]),
    );
  }

  Widget IsSuccessSubscribe() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: transitionMedium,
            height: 1.0 + size,
            width: 1.0 + size,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorText, width: 1.0),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('images/letsgoevent.gif'))),
          ),
          SizedBox(height: 15),
          AnimatedContainer(
            duration: transitionLong,
            height: 1 + sizeReverse - 100.0,
            width: 1 + size + 50.0,
            child: gradientAppropriate(
                forfaitEventEnum: appState.getForfaitEventEnum),
          ),
          AnimatedContainer(
              duration: transitionSuperLong,
              height: 1 + sizeReverse - 10.0,
              width: 1 + size + 70.0,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "Vous avez souscrit avec succès à ce forfait. Le nombre de place maximum pour votre prochain évènement est ${appState.getMaxPlace.toString()}" ,
                      style: Style.menuStyleItem(13),
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                        style: raisedButtonStyle,
                        child: Text('Créer votre évenement maintenant', textAlign: TextAlign.center,),
                        onPressed: () async {
                          await Navigator.pushNamed(context, CreateEvent.rootName);
                        }),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget gradientAppropriate({required String forfaitEventEnum}) {
    switch (forfaitEventEnum) {
      case "BASIC":
        return Text('FORFAIT BASIC',
            textAlign: TextAlign.center, style: Style.titreEvent(20));
      case "PREMIUM":
        return GradientText(
          'FORFAIT PREMIUM',
          textAlign: TextAlign.center,
          colors: [Color(0xFF9708CC), Color(0xFF43CBFF)],
          style: Style.titreEvent(20),
        );
      case "MASTER_CLASS":
        return GradientText(
          'FORFAIT MASTER CLASS',
          textAlign: TextAlign.center,
          colors: [Color(0xFFE57373), Color(0xFFFF1744)],
          style: Style.titreEvent(20),
        );
      case "GOLD":
        return GradientText(
          'FORFAIT GOLD',
          textAlign: TextAlign.center,
          colors: [Color(0xFFFFEA00), Color(0xFFFF0000)],
          style: Style.titreEvent(20),
        );
      case "DIAMOND":
        return GradientText(
          'FORFAIT DIAMOND',
          textAlign: TextAlign.center,
          colors: [Color(0xFFE0E0E0), Color(0xFF424242)],
          style: Style.titreEvent(20),
        );
     default :
        return SizedBox(width: 12);
    }
  }
}
