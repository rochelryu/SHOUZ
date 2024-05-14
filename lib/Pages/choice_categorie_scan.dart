import 'package:flutter/material.dart';
import 'package:shouz/Constant/CodeScanner.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/event_decode.dart';

class ChoiceCategorieScan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: backgroundColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Style.white,),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text("Décodage Ticket", style: Style.titleNews(),),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                    elevation: 8.0,
                    color: Style.white,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                          color: Style.white,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),

                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.security_rounded, size: 27, color: colorText,),
                            SizedBox(width: 5),
                            Text("SECURISÉ", style: Style.grandTitreBlue(27),)
                          ],),
                          Text("Nous assurons la securité", style: Style.simpleTextBlack(),),
                          Text("et la confidentialité", style: Style.simpleTextBlack(),),
                          Text("des données", style: Style.simpleTextBlack(),),
                          Expanded(child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/QR_Code.gif'),
                                fit: BoxFit.contain
                              )
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.14,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: colorSecondary,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Un Problème ?", style: Style.sousTitreBlack(15),),
                        Text("Si un client rencontre des difficultés pour la présentation de son ticket vous pouvez vérifier le ticket en utilisant son numéro SHOUZ à la place du décodage", style: Style.sousTitreBlackOpacity(12),),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 25), child: Divider(color: Colors.grey),),
                  Container(padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 105,
                            width: MediaQuery.of(context).size.width * 0.35,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: colorText,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => CodeScanner(key: UniqueKey(), type: 1)));
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('images/qrdecode.png', height:55, width: 55,),
                                  Text("Décoder ticket évènement par scan", style: Style.sousTitreBlack(8), textAlign: TextAlign.center,)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          if(1 != 1 )Container(
                            height: 105,
                            width: MediaQuery.of(context).size.width * 0.25,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: colorText,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => CodeScanner(key: UniqueKey(), type: 0)));
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('images/qrdecode.png', height:55, width: 55,),
                                  Text("Décoder ticket voyage par scan", style: Style.sousTitreBlack(8), textAlign: TextAlign.center,)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: 105,
                            width: MediaQuery.of(context).size.width * 0.35,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: colorText,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, EventDecode.rootName);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('images/smartphone.png', height:55, width: 55,),
                                  Text("Décoder ticket évènement par numero", style: Style.sousTitreBlack(8), textAlign: TextAlign.center,)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),)
                ],
              ),
              
            ),
          ],
        ),
      ),
    );
  }
}
