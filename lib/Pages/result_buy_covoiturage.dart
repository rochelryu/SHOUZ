import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class ResultBuyCovoiturage extends StatefulWidget {
  static String rootName = '/ResultBuyCovoiturage';
  @override
  _ResultBuyCovoiturageState createState() => _ResultBuyCovoiturageState();
}

class _ResultBuyCovoiturageState extends State<ResultBuyCovoiturage> {
  late AppState appState;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  int size = 0;
  int sizeReverse = 199;
  Map<dynamic, dynamic>? subscribeCallback;
  int isFinishLoad = 0;

  void initState() {
    super.initState();
    LoadInfo();
  }
  Future LoadInfo() async {
    try {
      appState = Provider.of<AppState>(context, listen: false);


      final travel = await consumeAPI.buyTravel(appState.getTravelId,appState.getChoiceForTravel.toString());
      print(travel);
      setState(() {
        subscribeCallback = travel;
        isFinishLoad = travel['etat'] == 'found' ? 1:2;
        size = 209;
        sizeReverse = 150;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: body(isFinishLoad),
    );
  }

  Widget isErrorSubscribe([String titleError = "Un problème de connexion avec le serveur, veuillez ressayer plutard.\n Ne vous inquiétez pas aucun prélèvement n'a été fait"]) {
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
                titleError,
                textAlign: TextAlign.center,
                style: Style.sousTitreEvent(15)),
            SizedBox(height: 35),
            ElevatedButton(
                child: Icon(Icons.block, color: Colors.white),
                style: raisedButtonStyleError,
                onPressed: () async {
                  await Navigator.pushNamed(context, MenuDrawler.rootName);
                }),
          ]),
    );
  }

  Widget isSuccessSubscribe(Map<dynamic, dynamic> result) {
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
                shape: BoxShape.rectangle,
                //border: Border.all(color: colorText, width: 1.0),
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: NetworkImage("${ConsumeAPI.AssetTravelBuyerServer}${appState.getTravelId}/${result['userPayCheck']}"))),
          ),
          SizedBox(height: 15),
          AnimatedContainer(
            duration: transitionLong,
            height: 1 + sizeReverse - 30.0,
            width: 1 + size + 50.0,
            child: GradientText(
              'TICKET ACHETÉ AVEC SUCCÈS. MERCI DE NOUS FAIRE CONFIANCE',
              textAlign: TextAlign.center,
              colors: gradient[4],
              style: Style.titreEvent(20),
            ),
          ),
          AnimatedContainer(
              duration: transitionSuperLong,
              height: 50.0 + sizeReverse,
              width: 1 + size + 70.0,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "Vous n'avez qu'à presenter cette image lors de la verification des tickets pour le depart du voyage 🥳.\n. Sachez aussi que vous devez présenter ce ticket au chauffeur pour qu'il scan lorsque vous arriverai à destination afin que le conducteur soit payé.",
                      style: Style.menuStyleItem(13),
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                        style: raisedButtonStyle,
                        child: Text('OK'),
                        onPressed: () async {
                          await Navigator.pushNamed(context, MenuDrawler.rootName);
                        }),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget body(int isFinishLoad) {
    if(isFinishLoad == 0){
      return LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2);
    } else if(isFinishLoad == 1) {
      return isSuccessSubscribe(subscribeCallback!['result']);
    } else {
      return isErrorSubscribe(subscribeCallback!['error']);
    }
  }
}
