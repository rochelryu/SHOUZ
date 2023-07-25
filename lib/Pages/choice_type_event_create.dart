import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';

import 'CreateEvent.dart';
import 'ExplainEvent.dart';
import 'create_vote.dart';
import 'explication_event.dart';

class ChoiceTypeEventCreate extends StatefulWidget {
  bool isActivateForfait;
  int level;
  ChoiceTypeEventCreate({Key? key, required this.isActivateForfait, required this.level}) : super(key: key);

  @override
  State<ChoiceTypeEventCreate> createState() => _ChoiceTypeEventCreateState();
}

class _ChoiceTypeEventCreateState extends State<ChoiceTypeEventCreate> with TickerProviderStateMixin {
  List<String> images = [
    'images/slide_event.jpeg',
    'images/slide_event_2.jpeg',
    'images/slide_event_3.png',
  ];
  int currentIndex = 0;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      reverseDuration: const Duration(seconds: 0),
      lowerBound: 0.5
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
        parent: _controller, curve: Curves.easeIn
    );
    // Démarrer l'animation au démarrage de l'écran
    startImageAnimation();
  }

  void startImageAnimation() {
    // Utilisez une boucle avec un intervalle pour changer d'image à intervalles réguliers
    if(mounted) {
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          currentIndex = (currentIndex + 1) % images.length;
        });
        startImageAnimation(); // Répéter l'animation
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _animation,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(images[currentIndex]), // Image de fond changeante
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height*0.25,
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        const Color(0x00000000),
                        const Color(0xFF111100),
                      ],
                      begin:
                      FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(
                          0.0, 1.0))),
              child: Column(
                children: <Widget>[
                  Text("Qu'est-ce que vous voulez créer".toUpperCase(),
                      style: Style.titreEvent(20),
                      textAlign: TextAlign.center),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          onPressed: (){
                            if(widget.isActivateForfait) {
                              Navigator.pushNamed(context, CreateEvent.rootName);
                            } else {
                              if(widget.level == 0){
                                setExplain(2, "event");
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (builder) => ExplicationEvent(key: UniqueKey(), typeRedirect: 1)));
                              } else {
                                Navigator.pushNamed(context, ExplainEvent.rootName);
                              }
                            }
                          },
                          child: Text(
                            "Événement",
                            style: Style.sousTitreEvent(15),
                          ),
                          style: raisedButtonStyle,
                        ),
                      ),
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: OutlinedButton(
                          onPressed: (){
                            Navigator.pushNamed(context, CreateVote.rootName);
                          },
                          child: Text(
                            "Vôte",
                            style: Style.sousTitreEvent(15),
                          ),
                          style: raisedButtonOutlineStyle,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: (){
                      },
                      child: Text(
                        "Événement + Vôte",
                        style: Style.sousTitreEvent(15),
                      ),
                      style: raisedButtonStyleSuccess,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: Container(
            margin: EdgeInsets.only(left: 10.0),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                  colors: [Color(0x00000000), tint],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 22.0),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          ),
        ],
      ),
    );
  }
}
