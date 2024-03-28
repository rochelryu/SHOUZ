import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../Constant/helper.dart';
import '../Constant/widget_common.dart';
import '../Models/User.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import '../Utils/Database.dart';
import '../Utils/shared_pref_function.dart';

class VoteEventDetail extends StatefulWidget {
  final voteItem;
  final List<Color> gradiant;
  VoteEventDetail({Key? key, required this.voteItem, required this.gradiant}) : super(key: key);

  @override
  _VoteEventDetailState createState() => _VoteEventDetailState();
}

class _VoteEventDetailState extends State<VoteEventDetail>  with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  dynamic voteItem;
  bool isVoting = false;
  int currentActorVoted = -1;
  late SharedPreferences prefs;
  User? newClient;

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
    setState(() {
      voteItem = widget.voteItem;
    });
    LoadInfo();
    // Démarrer l'animation au démarrage de l'écran
  }

  Future LoadInfo() async {
    try {
      prefs = await SharedPreferences.getInstance();
      User user = await DBProvider.db.getClient();
      setState(() {
        newClient = user;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _animation,
            child: Hero(
              tag: widget.voteItem['_id'],
              child: buildImageInCachedNetworkWithSizeManual(
                "${ConsumeAPI.AssetEventServer}${widget.voteItem['picture']}",
                double.infinity,
                double.infinity,
                BoxFit.cover
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
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
                  Container(
                    margin: EdgeInsets.only(left: 12.0, top: 100, bottom: 0),
                    child: GradientText(
                      widget.voteItem['name'],
                      colors: widget.gradiant,
                      style: Style.titleOnBoard(fontSize: 27),
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                        itemCount: voteItem == null ? widget.voteItem['categorie'].length : voteItem['categorie'].length,
                          itemBuilder: (context, index) {
                          final infoCategorie = voteItem == null ? widget.voteItem['categorie'][index]: voteItem['categorie'][index];
                          return categorieWidget(infoCategorie, widget.voteItem['displayResult']);
                          }
                      )
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 45,
            left: 8,
            right: 15,
            child: Row(
              children: [
                Container(
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
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.0),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                if(newClient != null && newClient!.ident == widget.voteItem['author']) ...[
                  Spacer(),
                  ElevatedButton(
                      style: raisedButtonStyle,
                      onPressed: () {

                      }, child: Text(
                    "Modifier",
                    style: Style.sousTitreEvent(12),
                  )),
                  SizedBox(width: 10,),
                  ElevatedButton(
                      style: raisedButtonStyleError,
                      onPressed: () {

                      }, child: Text(
                    "Supprimer",
                    style: Style.sousTitreEvent(12),
                  )),
                ]

              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget categorieWidget(dynamic categorie, bool displayResult) {
    return Container(
      height: 270,
      width: double.infinity,
      margin: EdgeInsets.only(left: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(categorie['name'].toString().toUpperCase(), style: Style.titre(20),),
          SizedBox(height: 10,),
          Expanded(
              child: ListView.builder(
              itemCount: categorie['allActors'].length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                final actor = categorie['allActors'][index];
                return Column(
                  children: [
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12.0)),
                      child: CachedNetworkImage(
                        imageUrl: "${ConsumeAPI.AssetEventServer}${actor['image']}",
                        imageBuilder: (context, imageProvider) => Container(
                        height: 150,
                        width: 130,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover)
                        ),
                          child: Stack(
                            children: [
                              if (displayResult) Positioned(
                                top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 70,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: colorError.withOpacity(0.8),
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                    ),
                                    child: Center(
                                      child: Text("${actor['numberVoted']} voie${ actor['numberVoted']> 1 ? 's':''}", style: Style.simpleTextOnBoard(11, Style.white)),
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Center(
                                child: CircularProgressIndicator(value: downloadProgress.progress)),
                        errorWidget: (context, url, error) => notSignal(),


                      ),
                    ),
                    Text(actor['name'].toString().toUpperCase(), style: Style.simpleTextOnBoard(15, Style.white)),
                    ElevatedButton(
                      onPressed: () async {
                        if(!isVoting){
                          setState(() {
                            isVoting = true;
                            currentActorVoted = index;
                          });
                          final actualy = DateTime.now();
                          final isAvailableOfTime = actualy.difference(DateTime.parse(widget.voteItem['beginDate'])).inMinutes > -86399 && actualy.difference(DateTime.parse(widget.voteItem['endDate'])).inMinutes < 0;
                          if(isAvailableOfTime) {
                            final verifyIsAvailaible = await verifyAndCreateIfNotExistVoteByIdToShared(widget.voteItem['_id'], categorie['_id'], actor['_id']);
                            if(!verifyIsAvailaible) {
                              final createVote = await consumeAPI.setVoteBySalior(actor['_id'], categorie['_id']);
                              if(createVote['etat'] == 'found') {
                                final dataVote = widget.voteItem['categorie'].firstWhere((c) => c['_id'] == categorie['_id']);
                                final indexCategorieVote = widget.voteItem['categorie'].indexWhere((c) => c['_id'] == categorie['_id']);
                                final index = dataVote['allActors'].indexWhere((e) => e['_id'] == actor['_id']);
                                dataVote['allActors'][index]['numberVoted'] +=10;
                                setState(() {
                                  voteItem['categorie'][indexCategorieVote] = dataVote;
                                });
                                showSnackBar(context, "Vôte pris en compte", isOk: true);
                                await verifyAndCreateIfNotExistVoteByIdToShared(widget.voteItem['_id'], categorie['_id'], actor['_id'], toCreate: true);

                              } else {
                                showSnackBar(context, createVote['error']);
                              }
                            } else {
                              showSnackBar(context, "Vous ne pouvez pas voter actuellement");
                            }
                          } else {
                            showSnackBar(context, "La date de debut des vôte n'est pas encore arrivée");
                          }
                          setState(() {
                            isVoting = false;
                            currentActorVoted = -1;
                          });
                        }

                      },
                      child: currentActorVoted == index ? CircularProgressIndicator() : Text('Voter'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isVoting ? colorBlack : colorPrimary, backgroundColor: isVoting ? colorSecondary : colorText,
                        minimumSize: Size(88, 36),
                        elevation: 4.0,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                      ),
                    ),
                  ],
                );

                  })
              )
        ],
      ),
    );
  }
}
