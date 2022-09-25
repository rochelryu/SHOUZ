import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

class CommentActu extends StatefulWidget {
  String title;
  String id;
  var comment;
  var imageCover;
  CommentActu({required Key key, required this.id, required this.title, this.comment, this.imageCover}) : super(key: key);

  @override
  _CommentActuState createState() => _CommentActuState();
}

class _CommentActuState extends State<CommentActu> {
  TextEditingController eCtrl = new TextEditingController();
  ConsumeAPI consumeAPI = new ConsumeAPI();
  User? newClient;
  String id = '';
  int type = 0;
  bool action = false;
  bool loadisDone = false;
  late List<dynamic> comment;

  @override
  void initState() {
    super.initState();
    LoadInfo();

  }
  LoadInfo() async {
    User user = await DBProvider.db.getClient();
    setState(() {
      newClient = user;
      id = newClient!.ident;
    });
    final result = await consumeAPI.getCommentActualite(widget.id);
    setState(() {
      comment = result;
      loadisDone = true;
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            height: MediaQuery.of(context).size.height * 0.31,
            right: 0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    child:
                    Image.network(widget.imageCover, fit: BoxFit.cover),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: MediaQuery.of(context).size.height * 0.31,
                      child: Container(
                        padding: EdgeInsets.all(30.0),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0x00000000),
                                  const Color(0x99111111),
                                ],
                                begin: FractionalOffset(0.0, 0.0),
                                end: FractionalOffset(0.0, 1.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(widget.title, style: Style.titre(22.0), overflow: TextOverflow.ellipsis, maxLines: 5,),

                          ],
                        ),
                      )),
                  Positioned(
                    top: 46,
                    right: 26,
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
                        icon: Icon(Icons.close,
                            color: Colors.white, size: 22.0),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            height: MediaQuery.of(context).size.height * 0.72,
            right: 0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Commentaires', style: Style.grandTitreBlack(18))),
                    Divider(height: 1.0,),
                    Expanded(child: loadisDone ? comment.length > 0 ?
                        Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              itemCount: comment.length + 2,
                              itemBuilder: (context, index) {
                                if(index == 0) {
                                  return SizedBox(height: 10);
                                } else if(index > 0 && index < comment.length + 1) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.only(bottom: 10),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(50)),
                                          image: DecorationImage(
                                            image: NetworkImage((newClient != null)
                                                ? "${ConsumeAPI.AssetProfilServer}${comment[index - 1]['profil']}"
                                                : ''),
                                            fit: BoxFit.cover,
                                          )
                                      ),
                                    ),
                                    title: Text(comment[index - 1]['name']),
                                    subtitle: Text(comment[index - 1]['content']),

                                  );
                                } else {
                                  return SizedBox(height: 80);
                                }
                              }
                          ),
                        ),

                      ],
                    )
                        : Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 30),
                          Image.asset('images/actu.png'),
                          Text(
                              "Aucun commentaire pour cette actualité pour le moment",
                              textAlign: TextAlign.center,
                              style: Style.chatOutMe(15)),

                        ])) : Center(
                      child: Text('Chargement en cours ...'),
                    )
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            height: 70,
            right: 0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  color: colorPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            image: DecorationImage(
                              image: NetworkImage((newClient != null)
                                  ? "${ConsumeAPI.AssetProfilServer}${newClient!.images}"
                                  : ''),
                              fit: BoxFit.cover,
                            )
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        height: 70,
                        child: TextField(
                          controller: eCtrl,
                          decoration: InputDecoration(
                            hintText: 'Dites ce que vous en pensez'
                          ),
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: IconButton(
                          onPressed: () async {
                            setState(() {
                              action = true;
                            });
                            final etat = await consumeAPI.addComment(newClient!.ident, widget.id, eCtrl.text);

                            setState(() {
                              if(etat == 'found') {
                                comment.insert(0, {'name': newClient!.name, 'content': eCtrl.text, 'profil': newClient!.images, 'id': newClient!.ident});
                                eCtrl.clear();
                                type = 0;
                                action = false;
                              } else {
                                type = 1;
                                action = false;
                              }
                            });

                            Timer(const Duration(seconds: 5), () {
                              setState(() {
                                type = 0;
                              });
                            });
                          },
                          tooltip: 'Envoie de commentaire',
                          icon: IconAction(type, action),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget IconAction(int type, bool action) {
    if (action) {
      return LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2);
    } else {
        return type == 0 ? Icon(Icons.send_outlined, color: colorText): Icon(Icons.warning_amber_outlined, color: colorWarning);

    }
  }
}