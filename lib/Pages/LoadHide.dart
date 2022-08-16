import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/CovoiturageChoicePlace.dart';
import 'package:shouz/Pages/DetailsDeals.dart';
import 'package:shouz/Pages/EventDetails.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

import 'ChatDetails.dart';
import 'DetailsActu.dart';


class LoadHide extends StatelessWidget {
  const LoadHide({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
  }
}

class LoadChat extends StatefulWidget {
  String room;
  LoadChat({required Key key, required this.room}) : super(key: key);

  @override
  _LoadChatState createState() => _LoadChatState();
}

class _LoadChatState extends State<LoadChat> {
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    super.initState();
    loadInfo();

  }

  @override
  void dispose(){
    super.dispose();
  }

  Future loadInfo() async {
    User user = await DBProvider.db.getClient();
    final appState = Provider.of<AppState>(context, listen: false);
    try {
      appState.setJoinConnected(user.ident);
    } catch (e) {
      print(e);
    }
    final arrayRoom = widget.room.split('_');
    final data = await consumeAPI.getDetailsDealsForChat(arrayRoom);
    if(data['etat'] == 'found') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (builder) => ChatDetails(
                  newClient: user,
                  comeBack: 1,
                  room: widget.room,
                  productId: arrayRoom[2],
                  name: data['result']['name'],
                  onLine: data['result']['onLine'],
                  profil: data['result']['images'],
                  //authorId prend la valeur de idOtherUser
                  authorId: arrayRoom[0])), (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
  }
}

class LoadTravel extends StatefulWidget {
  String travelId;
  LoadTravel({required Key key, required this.travelId}) : super(key: key);

  @override
  _LoadTravelState createState() => _LoadTravelState();
}

class _LoadTravelState extends State<LoadTravel> {
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  @override
  void dispose(){
    super.dispose();
  }

  Future loadInfo() async {
    User newClient = await DBProvider.db.getClient();
    final data = await consumeAPI.getDetailsForTravel(widget.travelId);
    if(data['etat'] == 'found') {
      final item = data['result'];
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
              builder: (builder)=> CovoiturageChoicePlace(
                item['id'],
                1,
                item['beginCity'],
                item['endCity'],
                item['lieuRencontre'],
                item['price'],
                item['travelDate'],
                item['authorId'],
                item['placePosition'],
                item['userPayCheck'],
                item['infoAuthor'],
                item['commentPayCheck'],
                item['authorId'] == newClient.ident,
                item['state'],
              )
          ),(Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
  }
}

class LoadEvent extends StatefulWidget {
  String eventId;
  LoadEvent({required Key key, required this.eventId}) : super(key: key);

  @override
  _LoadEventState createState() => _LoadEventState();
}

class _LoadEventState extends State<LoadEvent> {
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    super.initState();
    loadInfo();
  }
  @override
  void dispose(){
    super.dispose();
  }

  Future loadInfo() async {
    User newClient = await DBProvider.db.getClient();
    final data = await consumeAPI.getDetailsForEvent(widget.eventId);
    if(data['etat'] == 'found') {
      final item = data['result'];
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (builder) => EventDetails(
            1,
            item['imageCover'],
            item['_id'],
            item['price'],
            item['numberFavorite'],
            item['authorName'],
            item['describe'],
            item['_id'],
            item['numberTicket'],
            item['position'],
            item['registerDate'],
            item['title'],
            item['positionRecently'],
            item['videoPub'],
            item['allTicket'],
            item['authorId'],
            item['cumulGain'],
            item['authorId'] == newClient.ident,
            item['state'],
            item['favorie'],
          )), (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
  }
}

class LoadNew extends StatefulWidget {
  String actualityId;
  LoadNew({required Key key, required this.actualityId}) : super(key: key);

  @override
  _LoadNewState createState() => _LoadNewState();
}

class _LoadNewState extends State<LoadNew> {
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    super.initState();
    loadInfo();
  }
  @override
  void dispose(){
    super.dispose();
  }

  Future loadInfo() async {
    final data = await consumeAPI.getActualitiesDetailsById(widget.actualityId);
    if(data['etat'] == 'found') {
      final item = data['result'];
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (BuildContext context) => DetailsActu(
            comeBack: 1,
              title: item['title'],
              id: item['_id'],
              content: item['content'],
              autherName: item['autherName'],
              authorProfil: item['authorProfil'],
              imageCover: item['imageCover'],
              comment: item['comment'],
              numberVue: item['numberVue'])),(Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
  }
}

class LoadProduct extends StatefulWidget {
  String productId;
  LoadProduct({required Key key, required this.productId}) : super(key: key);

  @override
  _LoadProductState createState() => _LoadProductState();
}

class _LoadProductState extends State<LoadProduct> {
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    super.initState();
    loadInfo();
  }
  @override
  void dispose(){
    super.dispose();
  }


  Future loadInfo() async {
    User user = await DBProvider.db.getClient();
    final appState = Provider.of<AppState>(context, listen: false);
    try {
      appState.setJoinConnected(user.ident);
    } catch (e) {
      print(e);
    }
    final productInfo = await consumeAPI.getDetailsForProductLink(widget.productId);
    if(productInfo['etat'] == 'found') {
      Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
        DealsSkeletonData item = DealsSkeletonData(
          video: productInfo['result']['video'],
          level: productInfo['result']['level'],
          quantity: productInfo['result']['quantity'],
          numberFavorite: productInfo['result']['numberFavorite'],
          lieu: productInfo['result']['lieu'],
          id: productInfo['result']['_id'],
          registerDate: productInfo['result']['registerDate'],
          profil: productInfo['result']['profil'],
          imageUrl: productInfo['result']['images'],
          title: productInfo['result']['name'],
          price: productInfo['result']['price'],
          autor: productInfo['result']['author'],
          numero: productInfo['result']['numero'],
          describe: productInfo['result']['describe'],
          onLine: productInfo['result']['onLine'],
          authorName: productInfo['result']['authorName'],
          archive: productInfo['result']['archive'],
          categorieName: productInfo['result']['categorieName'],
        );
        return DetailsDeals(dealsDetailsSkeleton: item, comeBack: 1);
      }), (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
  }
}


