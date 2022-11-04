import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AppState with ChangeNotifier {
  IO.Socket? _socket;
  String priceTicketTotal = '';
  String priceUnityTicket= '';
  String idEvent = '';
  String idVoyage = '';
  int maxPlace = 0;
  double percentageRecharge = 0.0;
  int amountTvaWithdraw = 300;
  int indexBottomBar = new Random().nextInt(3);
  String idOldConversation = '';
  String priceVoyageTotal = '';
  String forfaitEventEnum = "NOT FORFAIT";
  int numberTicket = 0;
  int choiceSearch = 0;
  int choiceItemSearch = 0;
  int numberNotif = 0;
  List<int> placeOccupe = [];
  List<dynamic> choiceForTravel = [];
  String travelId = '';
  bool typing = false;
  bool loadingToSend = false;
  dynamic conversation = {};
  AppState();

  setTyping(bool typing, String id, String identUser) {
    final jsonData = {
      "id": this.getIdOldConversation,
      "typing": typing,
      "room": id,
      "identUser": identUser,
    };

    _socket!.emit("typing", [jsonData]);
  }

  ackReadMessage(String room) {
    final jsonData = {
      "room": room,
    };
    _socket!.emit("ackReadMessage", [jsonData]);
    notifyListeners();
  }

  updateTyping(bool typing) {
    this.typing = typing;
    notifyListeners();
  }

  updateLoadingToSend(bool loadingToSend) {
    this.loadingToSend = loadingToSend;
    notifyListeners();
  }

  setPriceTicketTotal(String priceTicket) {
    priceTicketTotal = priceTicket;
    notifyListeners();
  }
  setPriceUnityTicket(String priceUnityTicket) {
    this.priceUnityTicket = priceUnityTicket;
    notifyListeners();
  }

  setPriceVoyageTotal(String priceTicket) {
    priceVoyageTotal = priceTicket;
    notifyListeners();
  }

  setIdEvent(String id) {
    idEvent = id;
    notifyListeners();
  }

  // Notif action State
  setNumberNotif(int numberNotifFromServer) {
    numberNotif = numberNotifFromServer;
    notifyListeners();
  }

  setForfaitEventEnum(String forfaitEventString, int maxPlace) {
    forfaitEventEnum = forfaitEventString;
    this.maxPlace = maxPlace;
    notifyListeners();
  }

  setPercentageRecharge(double percentageRecharge) {
    this.percentageRecharge = percentageRecharge;
    notifyListeners();
  }

  setAmountTvaWithdraw(int amountTvaWithdraw) {
    this.amountTvaWithdraw = amountTvaWithdraw;
    notifyListeners();
  }

  incrementNotif() {
    numberNotif++;
    notifyListeners();
  }

  setIdVoyage(String id) {
    idVoyage = id;
    notifyListeners();
  }

  setIdOldConversation(String id) {
    idOldConversation = id;
    notifyListeners();
  }

  setTypingUser(String id) {
    _socket!.emit("typing", [id]);
    notifyListeners();
  }

  setJoinConnected(String id) {
    //if(_socket )

    _socket!.emit("joinConnected", [id]);
    _socket!.emit("loadNotif", [id]);
    //notifyListeners();
  }

  setNumberTicket(int nbrTicket) {
    numberTicket = nbrTicket;
    notifyListeners();
  }

  setChoiceSearch(int choiceSearch) {
    choiceSearch = choiceSearch;
    notifyListeners();
  }

  setChoiceItemSearch(int choiceItemSearch) {
    choiceItemSearch = choiceItemSearch;
    notifyListeners();
  }

  setPlaceOccupe(List<int> plce) {
    placeOccupe = plce;
    notifyListeners();
  }

  setChoiceForTravel(List<dynamic> plce) {
    choiceForTravel = plce;
    notifyListeners();
  }
  setTravelId(String travel) {
    travelId = travel;
    notifyListeners();
  }


  String _displayText = "";

  void setSocket(IO.Socket socket) {
    _socket = _socket ?? socket;
    notifyListeners();
  }

  void deleteSocket() {
    _socket = null;
    notifyListeners();
  }

//   void setMessage(String text) {
//     _displayText = text;
//     notifyListeners();
//   }
  void sendChatMessage(
      {required String destinate,
      required String id,
      String imageName = '',
      String base64 = '',
      String content = ''}) async {
    User newClient = await DBProvider.db.getClient();
    final jsonData = {
      "content": content,
      "ident": newClient.ident,
      "room": destinate,
      "base64": base64,
      "image": imageName,
      "id": id
    };
    print(imageName);
      _socket!.emit("message", [jsonData]);
      notifyListeners();
  }

  void relanceDeals(
      {required String destinate,
        required String id,
        String content = '',
        String imageName = '',
        String base64 = '',}) async {
    User newClient = await DBProvider.db.getClient();
    final jsonData = {
      "content": content,
      "ident": newClient.ident,
      "room": destinate,
      "base64": base64,
      "image": imageName,
      "id": id
    };

    _socket!.emit("relanceDeals", [jsonData]);
    notifyListeners();
  }

  void changeProfilPicture({required String imageName, required String base64}) async {
    User newClient = await DBProvider.db.getClient();
    final jsonData = {
      "image": imageName,
      "id": newClient.ident,
      "base64": base64,
      "recovery": newClient.recovery
    };

      _socket!.emit("changeProfil", [jsonData]);
      notifyListeners();
  }

  void createChatMessage(
      {required String destinate,
      String imageName = '',
      String base64 = '',
      String content = ''}) async {
    User newClient = await DBProvider.db.getClient();
    final jsonData = {
      "content": content,
      "ident": newClient.ident,
      "room": destinate,
      "base64": base64,
      "image": imageName
    };
      _socket!.emit("createRoom", [jsonData]);
      notifyListeners();
  }

  void sendPropositionForDealsByAuteur(
      {required String price,
        required String id,
        required String qte,
        required String room}) async {
    final jsonData = {
      "price": price,
      "room": room,
      "qte": qte,
      "id": id,
    };

      _socket!.emit("sendPropositionForDealsByAuteur", [jsonData]);
      notifyListeners();
  }

  void notAgreeForPropositionForDeals(
      {
        required String id,
        required String room}) async {
    final jsonData = {
      "room": room,
      "id": id,
    };

      _socket!.emit("notAgreeForPropositionForDeals", [jsonData]);
      notifyListeners();
  }

  void agreeForPropositionForDeals(
      {
        required String id,
        required String room}) async {
    final jsonData = {
      "room": room,
      "id": id,
    };

      _socket!.emit("agreeForPropositionForDeals", [jsonData]);
      notifyListeners();
  }

  clearConversation() {
    conversation = {};
    notifyListeners();
  }

  clearIdOldConversation() {
    idOldConversation = '';
    notifyListeners();
  }

  setConversation(dynamic converse) {
    conversation = converse;
    notifyListeners();
  }

  setIndexBottomBar(int index) {
    indexBottomBar = index;
    notifyListeners();
  }

  getConversation(String foreign) {
    _socket!.emit('getConversation', [foreign]);
    notifyListeners();
  }

  String get getDisplayText => _displayText;
  String get getForfaitEventEnum => forfaitEventEnum;
  int get getMaxPlace => maxPlace;
  String get getidEvent => idEvent;
  bool get getTyping => typing;
  bool get getLoadingToSend => loadingToSend;
  String get getIdOldConversation => idOldConversation;
  double get getPercentageRecharge => percentageRecharge;
  int get getAmountTvaWithdraw => amountTvaWithdraw;
  String get getNumberTicket => numberTicket.toString();
  int get getNumberNotif => numberNotif;
  int get getChoiceSearch => choiceSearch;
  int get getIndexBottomBar => indexBottomBar;
  int get getChoiceItemSearch => choiceItemSearch;
  String get getPriceTicketTotal => priceTicketTotal;
  String get getPriceUnityTicket => priceUnityTicket;
  String get getTravelId => travelId;
  List<dynamic> get getChoiceForTravel => choiceForTravel;
  List<int> get getPlaceOccupe => placeOccupe;
  dynamic get getConversationGetter => conversation;
  IO.Socket? get getSocketIO => _socket;
}
