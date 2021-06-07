import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:loading/indicator/ball_scale_indicator.dart';
import 'package:loading/loading.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
/*import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/indicator/ball_grid_pulse_indicator.dart';
import 'package:loading/indicator/line_scale_indicator.dart';
import 'package:loading/indicator/ball_scale_multiple_indicator.dart';
import 'package:loading/indicator/line_scale_party_indicator.dart';
import 'package:loading/indicator/ball_beat_indicator.dart';
import 'package:loading/indicator/line_scale_pulse_out_indicator.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';*/

class ResultSubscribeForfait extends StatefulWidget {
  @override
  _ResultSubscribeForfaitState createState() => _ResultSubscribeForfaitState();
}

class _ResultSubscribeForfaitState extends State<ResultSubscribeForfait> {
  AppState appState;
  int inWait = 0;
  int size = 0;
  int sizeReverse = 199;
  bool buildDone = false;
  User newClient;
  String pin = '';
  Future<dynamic> subscribeCallback;

  void initState() {
    super.initState();
    LoadInfo();
    getNewPin();
  }

  LoadInfo() async {
//    User user = await DBProvider.db.getClient();
//    setState(() {
//      newClient = user;
//    });
  }
  Future getNewPin() async {
    try {
      String pin = await getPin();
      setState(() {
        this.pin = pin;
        size = 199;
        sizeReverse = 150;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    subscribeCallback = new ConsumeAPI()
        .subscribeEvent(pin: this.pin, forfait: appState.getForfaitEventEnum);

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
                  child: Loading(indicator: BallScaleIndicator(), size: 200.0),
                );

              case ConnectionState.active:
                return Center(
                  child: Loading(indicator: BallScaleIndicator(), size: 200.0),
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
                  await Navigator.pushNamed(context, '/menuDrawler');
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
                    image: AssetImage(appState.getAssestTorfait))),
          ),
          SizedBox(height: 15),
          AnimatedContainer(
            duration: transitionLong,
            height: 1 + sizeReverse - 100.0,
            width: 1 + size + 50.0,
            child: GradientAppropriate(
                forfaitEventEnum: appState.getForfaitEventEnum),
          ),
          SizedBox(height: 25),
          AnimatedContainer(
              duration: transitionSuperLong,
              height: 1 + sizeReverse - 10.0,
              width: 1 + size + 70.0,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "lorem ipsum de malade et de ouf beta a dis aque je suis ainsi mais bon je te regarde seulement car c'est ça",
                      style: Style.menuStyleItem(13),
                      textAlign: TextAlign.center,
                    ),
                    RaisedButton(
                        child: Icon(Icons.check_circle_outline,
                            color: Colors.white),
                        color: colorText,
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/menuDrawler');
                        }),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget GradientAppropriate({String forfaitEventEnum}) {
    switch (forfaitEventEnum) {
      case "BASIQUE":
        return Text('FORFAIT BASIQUE',
            textAlign: TextAlign.center, style: Style.titreEvent(20));
      case "PREMIUM":
        return GradientText(
          'FORFAIT PREMIUM',
          textAlign: TextAlign.center,
          gradient:
              LinearGradient(colors: [Color(0xFF9708CC), Color(0xFF43CBFF)]),
          style: Style.titreEvent(20),
        );
      case "MASTER_CLASS":
        return GradientText(
          'FORFAIT MASTER CLASS',
          textAlign: TextAlign.center,
          gradient:
              LinearGradient(colors: [Color(0xFFE57373), Color(0xFFFF1744)]),
          style: Style.titreEvent(20),
        );
      case "GOLD":
        return GradientText(
          'FORFAIT GOLD',
          textAlign: TextAlign.center,
          gradient:
              LinearGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF0000)]),
          style: Style.titreEvent(20),
        );
      case "DIAMOND":
        return GradientText(
          'FORFAIT DIAMOND',
          textAlign: TextAlign.center,
          gradient:
              LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFF424242)]),
          style: Style.titreEvent(20),
        );
    }
  }
}
