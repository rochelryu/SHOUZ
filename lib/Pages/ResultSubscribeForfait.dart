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

import 'Login.dart';

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
        size = 259;
        sizeReverse = 200;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(Icons.close, color: Style.white,),
            onPressed: () {
              Navigator.pushNamed(context, MenuDrawler.rootName);
            }),
      ),
      body: FutureBuilder(
          future: subscribeCallback,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return isErrorSubscribe('error');
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
                  return isErrorSubscribe('error');
                }
                var info = snapshot.data;
                return info == "found"
                    ? IsSuccessSubscribe()
                    : isErrorSubscribe(info);

              // return new CardTopNewActu()
            }
          }),
    );
  }

  Widget isErrorSubscribe(String etat) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              "images/notconnection.svg",
              semanticsLabel: 'Not Connection',
              height: MediaQuery.of(context).size.height * 0.39,
            ),
            Text(
                etat == 'notFound' ? "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte" : "Un problème de connexion avec le serveur, veuillez ressayer plutard.\n Ne vous inquiétez pas aucun prélèvement n'a été fait",
                textAlign: TextAlign.center,
                style: Style.sousTitreEvent(15)),
            SizedBox(height: 35),
            ElevatedButton(
                child: Icon(Icons.block, color: Colors.white),
                style: raisedButtonStyleError,
                onPressed: () async {
                  etat == 'notFound' ? Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => Login())) : Navigator.pushNamed(context,  MenuDrawler.rootName);
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
            height: 1.0 + size -70,
            width: 1.0 + size -70,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorText, width: 1.0),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('images/letsgoevent.gif'))),
          ),
          SizedBox(height: 45),
          AnimatedContainer(
            duration: transitionLong,
            height: 60,

            width: 1 + size + 50.0,
            child: gradientAppropriate(
                forfaitEventEnum: appState.getForfaitEventEnum),
          ),
          AnimatedContainer(
              duration: transitionSuperLong,
              height: 1.0 + sizeReverse,
              width: 1 + size + 70.0,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Vous avez souscrit avec succès à ce forfait. Le nombre de place maximum pour votre prochain évènement est ${appState.getMaxPlace.toString()}" ,
                      style: Style.menuStyleItem(13),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
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
