import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Pages/create_travel.dart';
import 'package:shouz/Pages/vtc_driver_home.dart';

import '../Constant/CircularClipper.dart';
import '../Constant/Style.dart';

class ChoiceTypeCreateTravel extends StatelessWidget {
  ChoiceTypeCreateTravel({required Key key}) : super(key: key);
  CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: null,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            Container(
              transform: Matrix4.translationValues(0.0, -50.0, 0.0),
              child: Container(
                height: MediaQuery.of(context).size.height *0.7,
                child: ClipShadowPath(
                    clipper: CircularClipper(),
                    shadow: Shadow(blurRadius: 25.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: colorText,
                      child: Center(
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                                "Monétisez vos voyages intra ou extra villes.",
                                textStyle: Style.titre(42),
                                speed: const Duration(milliseconds: 100)
                            ),
                          ],
                          totalRepeatCount: 1,
                          pause: const Duration(milliseconds: 1500),
                          displayFullTextOnTap: false,
                          stopPauseOnTap: true,
                        ),
                      ),
                    )),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10.0, top: 60),
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

              ],
            ),
            Positioned(
                bottom: 60,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.43,
                  child: CarouselSlider(
                    carouselController: carouselController,
                    options: CarouselOptions(
                      aspectRatio: 1.1,
                      viewportFraction: 0.75,
                      initialPage: 0,
                      enableInfiniteScroll: false,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 25),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    ),
                    items: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => VtcDriverHome(key: UniqueKey())));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Container(
                            margin: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: colorPrimary,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.23,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage("images/taxi_image.webp"),
                                          fit: BoxFit.cover
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  Text("VTC", style: Style.grandTitreBlack(23)),
                                  Text("Laissez nous vous donnez le maximum de client pour augmenter vos profits. Fiable, sécurisé, versement automatique, disponible pour tous.", style: Style.simpleTextOnBoard(13)),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => CreateTravel(key: UniqueKey())));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Container(
                            margin: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: colorPrimary,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.23,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage("images/travel.jpg"),
                                        fit: BoxFit.cover
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  Text("COVOITURAGE", style: Style.grandTitreBlack(23)),
                                  Text("Vendez les places disponibles pour vos voyages à votre prix pour les voyages de ville en ville. Vous allez décoder les tickets des passagers à deux reprises (pendant embarquement et à l'arrivé).", style: Style.simpleTextOnBoard(13)),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),),
          ],
        ),
      ),
    );
  }
}
