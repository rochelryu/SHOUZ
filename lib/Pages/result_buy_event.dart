import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:shouz/Constant/widget_common.dart';

import 'Login.dart';

class ResultBuyEvent extends StatefulWidget {
  static String rootName = '/ResultBuyTicket';
  @override
  _ResultBuyEventState createState() => _ResultBuyEventState();
}

class _ResultBuyEventState extends State<ResultBuyEvent> {
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

      final event = await consumeAPI.buyEvent(appState.getidEvent, appState.getPriceTicketTotal, appState.getNumberTicket, appState.getPriceUnityTicket);
      if(event["etat"] == "notFound"){
        showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
              barrierDismissible: false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => Login()));
      } else {
        setState(() {
          subscribeCallback = event;
          isFinishLoad = event['etat'] == 'found' ? 1:2;
          size = 190;
          sizeReverse = 150;
        });
      }
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
                child: Text("Ok"),
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
                    image: NetworkImage("${ConsumeAPI.AssetBuyEventServer}${result['infoTicket']['idEvent']}/${result['infoTicket']['nameImage']}"))),
          ),
          SizedBox(height: 15),
          AnimatedContainer(
            duration: transitionLong,
            height: 1 + sizeReverse - 100.0,
            width: 1 + size + 50.0,
            child: GradientText(
              '${result['infoTicket']['placeTotal'].toString()} TICKET${result['infoTicket']['placeTotal']>1 ? 'S':''} ACHETÉ${result['infoTicket']['placeTotal']>1 ? 'S':''}',
              textAlign: TextAlign.center,
              colors: [Color(0xFFFFEA00), Color(0xFFFF0000)],
              style: Style.titreEvent(20),
            ),
          ),
          AnimatedContainer(
              duration: transitionSuperLong,
              height: 1 + sizeReverse + 200.0,
              width: 1 + size + 100.0,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "Vous n'avez qu'à presenter cette image lors de la verification des tickets.\n🥳Aussi avec SHOUZ vous avez les possibilitées suivantes:\n    - Partager des tickets à d'autres utilisateurs SHOUZ afin qu'ils accèdent à l'evenement avant ou après vous. (Par Exemple si vous êtes indisponible)\n    - Vous pouvez annuler l'achat et recuperer votre argent si vous trouvez que vous ne pouvez plus participer à l'évènement. (Mais vous devez le faire avant le debut de l'evenement).\n Pour voir vos tickets allez dans l'onglet Profil puis Évènements et cliquez sur l'évènement concerné" ,
                      style: Style.menuStyleItem(13),
                      textAlign: TextAlign.start,
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
      return Center(child: Container(
        height: 200,
        width: 200,
        child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2),
      ),);
    } else if(isFinishLoad == 1) {
      return isSuccessSubscribe(subscribeCallback!['result']);
    } else {
      return isErrorSubscribe(subscribeCallback!['error']);
    }
  }
}
