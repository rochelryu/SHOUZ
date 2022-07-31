import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/VerifyUser.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/result_buy_covoiturage.dart';
import 'package:shouz/Pages/ticket_travel_details.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';

import 'Login.dart';
import 'Profil.dart';
import 'choice_method_payement.dart';



class CovoiturageChoicePlace extends StatefulWidget {
  String id;
  String beginCity;
  String endCity;
  String lieuRencontre;
  String authorId;
  String travelDate;
  bool iAmAuthor;
  int price;
  int state;
  List<dynamic> placePosition;
  List<dynamic> commentPayCheck;
  List<dynamic> userPayCheck;
  Map<dynamic, dynamic> infoAuthor;
  int comeBack;
  CovoiturageChoicePlace(this.id, this.comeBack, this.beginCity, this.endCity, this.lieuRencontre, this.price, this.travelDate, this.authorId, this.placePosition, this.userPayCheck, this.infoAuthor, this.commentPayCheck, this.iAmAuthor, this.state);
  @override
  _CovoiturageChoicePlaceState createState() => _CovoiturageChoicePlaceState();
}

class _CovoiturageChoicePlaceState extends State<CovoiturageChoicePlace> {
  List<dynamic> choice = [];
  List<dynamic> myTickets = [];
  ConsumeAPI consumeAPI = new ConsumeAPI();
  bool isLoading = false;
  late AppState appState;
  User? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    choice = widget.placePosition;
    appState = Provider.of<AppState>(context, listen: false);
    LoadInfo();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();

  }
  LoadInfo() async {
    User user = await DBProvider.db.getClient();
    final ticket = await consumeAPI.verifyIfIamTicket(widget.id);
    setState(() {
      this.user = user;
      myTickets = ticket['result'];
    });


  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: backgroundColor,
        centerTitle: false,
        leading: IconButton(onPressed: (){
          if(widget.comeBack == 0) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamed(context, MenuDrawler.rootName);
          }
        }, icon: Icon(Icons.arrow_back)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.beginCity.toUpperCase()} -> ${widget.endCity.toUpperCase()}", maxLines:1, overflow: TextOverflow.ellipsis),
            Text(
                DateTime.parse(widget.travelDate).day.toString() +
                    '/' +
                    DateTime.parse(widget.travelDate)
                        .month
                        .toString() +
                    '/' +
                    DateTime.parse(widget.travelDate)
                        .year
                        .toString() + '   ' +
                    DateTime.parse(widget.travelDate).hour.toString() +
                    'h ' +
                    DateTime.parse(widget.travelDate)
                        .minute
                        .toString(),
                style: Style.sousTitre(14))
          ],
        ),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 5),
              child: Text("${widget.price.toString()} ${widget.infoAuthor['currencies']}"),
            ),
          )
        ],
      ),
      body:SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              elevation: 6.0,
              child: Container(
                height: MediaQuery.of(context).size.height/3,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage("${ConsumeAPI.AssetTravelServer}${widget.authorId}/${widget.infoAuthor['vehiculeCover']}"),
                      fit: BoxFit.cover
                  ),
                ),
              ),
            ),
            Container(
              height: 100,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          image: DecorationImage(
                              image: NetworkImage("${ConsumeAPI.AssetTravelServer}${widget.authorId}/${widget.infoAuthor['profilConducteurCover']}"),
                              fit: BoxFit.cover
                          ),
                        ),

                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Container(
                        height: 90,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.infoAuthor['name'], style: Style.titre(14)),
                            Text("Contact : ${widget.infoAuthor['contact']}", style: Style.sousTitre(12)),
                            Row(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              children: [
                                Icon(MyFlutterAppSecond.pin,
                                    color: Colors.white, size: 10.0),
                                Container(
                                  height: 35,
                                  width: 220,
                                  child: Text("Rencontre : ${widget.lieuRencontre}", maxLines: 2, style: Style.sousTitre(10)),
                                )
                              ],
                            ),

                            Text("Critère du conducteur :", style: Style.sousTitre(12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: widget.infoAuthor['hobiesCovoiturage'].length % 2 == 0 ? 50.0 * (widget.infoAuthor['hobiesCovoiturage'].length / 2) : 25.0 * (widget.infoAuthor['hobiesCovoiturage'].length - 1) + (widget.infoAuthor['hobiesCovoiturage'].length == 1 ? 50.0: 25.0),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                //direction: Axis.vertical,
                alignment: WrapAlignment.spaceEvenly,
                runSpacing: 0.0,
                spacing: 0.0,
                children: reformatHobbies(),
              ),
            ),
            if(myTickets.length >0) componentForDisplayTicketByEvent(myTickets),
            Padding(
              padding: EdgeInsets.only(top: 2.0,left: 10.0, bottom: 5.0),
              child: Text(widget.iAmAuthor ? "Liste des passagers" :"Veuillez choisir votre place pour le voyage", style: Style.sousTitre(12)),
            ),
            widget.iAmAuthor ? Container(
              height: 120,
                child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.userPayCheck.length,
                itemBuilder: (context, index) {
                  if(widget.userPayCheck.length == 0) {
                    return Container(
                      width: 300,
                      child: ListTile(
                        title: Text('Aucun passager pour le moment', overflow: TextOverflow.ellipsis, style: Style.titre(17)),
                      ),
                    );
                  } else {
                    return Container(
                      width: 300,
                      child: ListTile(
                        title: Text(widget.userPayCheck[index]['name'], overflow: TextOverflow.ellipsis, style: Style.titre(14)),
                        subtitle: Text(widget.userPayCheck[index]['contact'], style: Style.sousTitre(14)),
                        leading: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              image: DecorationImage(
                                  image: AssetImage(
                                      "images/boss.png"),
                                  fit: BoxFit.cover
                              )
                          ),
                        ),
                      ),
                    );
                  }

                })) : Container(
              height: ((widget.infoAuthor['placeTotalVehicule'] - 1) % 3 == 0) ? 300:400,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 5.0,mainAxisSpacing: 5.0),
                  itemCount: widget.infoAuthor['placeTotalVehicule'] + 2,
                  itemBuilder: (context, index){
                    if(index == 0){
                      return new Container(
                        height: double.infinity,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 15.0),
                        decoration: BoxDecoration(
                          color: backgroundColorSec,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            /*Container(
                            height: 30,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Icon(Icons.blur_circular,size: 30, color: Colors.grey)
                              ],
                            ),
                          ),*/
                            Padding(
                                padding: EdgeInsets.only(left: 10.0,bottom: 10.0),
                                child: Icon(MyFlutterAppSecond.driver, size: 40, color: Colors.white)
                            ),
                            Text('Conducteur', style: Style.titre(12))
                          ],
                        ),
                      );
                    }
                    else if(index == 1 || (index == 4 && (widget.infoAuthor['placeTotalVehicule'] - 1) % 3 != 0)){
                      return new Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                      );
                    }
                    else{
                      return (choice[index - 2] == 0 || choice[index - 2] == 2) ?
                      new InkWell(
                        onTap: (){
                          setState(() {
                            choice[index - 2] = (choice[index - 2] == 0) ? 2 : 0;
                          });
                        },
                        child: new Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
/*
                        (widget.voyage.placeDisponible[index - 2] == 0)
*/
                            color: backgroundColorSec,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 30,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    (choice[index - 2] == 0) ? Icon(Icons.blur_circular,size: 30, color: Colors.grey): Icon(Icons.check_circle,size: 30, color: Colors.green)
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 10.0,bottom: 10.0),
                                  child: Icon(MyFlutterAppSecond.car_seat_with_seatbelt, size: 40, color: Colors.white)),
                              Text('  Place Libre', style: Style.titre(12))
                            ],
                          ),
                        ),
                      ): new Container(
                        height: double.infinity,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 15.0),
                        decoration: BoxDecoration(
/*
                        (widget.voyage.placeDisponible[index - 2] == 0)
*/
                          color: backgroundColorSec,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(left: 10.0,bottom: 10.0),
                                child: Icon(MyFlutterAppSecond.passenger, size: 40, color: Colors.white)),
                            Text('Place occupée', style: Style.titre(12))
                          ],
                        ),
                      );
                    }
                  }),
            ),
            widget.iAmAuthor ? widget.state == 1 ? Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading ? LoadingIndicator(indicatorType: Indicator.ballScale,colors: [colorText], strokeWidth: 2) : ElevatedButton(
                    onPressed:  () async {
                      setState(() {
                        isLoading = true;
                      });
                      final stopTravel = await consumeAPI.stopTravel(widget.id);
                      setState(() {
                        isLoading = false;
                      });
                      if(stopTravel["etat"] == 'found') {
                        Fluttertoast.showToast(
                            msg: "Ce voyage vient d'arrêter de vendre des tickets",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: colorSuccess,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );

                        Navigator.pushNamed(context, Profil.rootName);
                      } else if(stopTravel["etat"] == 'notFound') {
                        showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
              barrierDismissible: false);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => Login()));

                      } else {
                        Fluttertoast.showToast(
                            msg: stopTravel["error"],
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.stop_circle_outlined, color: Colors.white,),
                        Text("Stopper la vente de ticket")
                      ],
                    ),
                  )
                ],
              )
            ) : Padding(
                padding: EdgeInsets.all(15),
                child: Text("On ne peut plus acheter de ticket pour ce voyage", style: Style.titre(16), textAlign: TextAlign.center,),
            ): SizedBox(width: 100),
          ],
        ),
      ),
      floatingActionButton: widget.state == 1 ? FloatingActionButton(
        onPressed: (){
          if(choice.contains(2) && widget.state != 0) {
            final data = choice.where((element) => element == 2).toList();
            if(user!.wallet >= data.length * widget.price) {
              appState.setChoiceForTravel(choice);
              appState.setTravelId(widget.id);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) => VerifyUser(
                    redirect: ResultBuyCovoiturage.rootName, key: UniqueKey(),)));
            } else {
              Fluttertoast.showToast(
                  msg: "Votre solde est inssufisant pour cet achat",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: colorError,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              Timer(const Duration(seconds: 2), () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (builder) => ChoiceMethodPayement(key: UniqueKey(), isRetrait: false,)));
              });
            }
          } else {
            Share.share("${ConsumeAPI.TravelLink}${widget.id}");
          }

        },
        backgroundColor: colorText,
        child: Icon(choice.contains(2) && widget.state != 0 ? Icons.payment : Icons.share, color: Colors.white),
      ):null,
    );
  }

  Widget iconLevel(dynamic numberTravel) {
    if (numberTravel >= 40) {
      return Icon(Icons.stars, size: 22.0, color: Colors.redAccent);
    }
    else if (numberTravel >= 20 && numberTravel < 40) {
      return Icon(Icons.star, size: 22.0, color: Colors.yellowAccent);
    }
    else if (numberTravel >= 13 && numberTravel < 20) {
      return Icon(Icons.star_half, size: 22.0, color: Colors.yellowAccent);
    }
    else if (numberTravel >= 5 && numberTravel < 13) {
      return Icon(Icons.star_border, size: 22.0, color: Colors.yellowAccent);
    }
    else {
      return Icon(Icons.star_border, size: 22.0, color: Colors.tealAccent);
    }
  }

  List<Widget> reformatHobbies() {
    List<Widget> hobbies = [];
    for(int index = 0; index < widget.infoAuthor['hobiesCovoiturage'].length; index++) {
      hobbies.add(
          Chip(
            label: Text(widget.infoAuthor['hobiesCovoiturage'][index]),
            labelStyle: Style.titleInSegment(8),
            backgroundColor: colorText,
          )
      );
    }
    return hobbies;
  }

  Widget  componentForDisplayTicketByEvent(List<dynamic> tickets) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 12),
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Vos tickets déjà achetés : ", style: Style.sousTitreEvent(15),),
          SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
                itemCount: tickets.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final numberPlace = tickets[index]['imageTicket'].toString().split('_')[2];
                  final networkImageWithConsumeApi = "${ConsumeAPI.AssetTravelBuyerServer}${widget.id}/${tickets[index]['imageTicket']}";
                  final substile = "$numberPlace place${int.parse(numberPlace) > 1 ? 's': ''} achetée${int.parse(numberPlace) > 1 ? 's': ''}";
                  return Container(
                    width: 170,
                    margin: EdgeInsets.only(right: 15),
                    child: Column(
                      children: [
                        Card(
                          elevation: 7.0,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                                return new TicketTravelDetails(tickets[index]['imageTicket'], networkImageWithConsumeApi, substile);
                              }));
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),

                              ),
                              child: Hero(
                                tag: tickets[index]['imageTicket'],
                                child: Image.network(
                                    networkImageWithConsumeApi,
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                        Text(substile, style: Style.simpleTextOnNews(), textAlign: TextAlign.center,)
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
