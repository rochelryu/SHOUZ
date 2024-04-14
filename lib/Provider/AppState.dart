import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../Constant/Style.dart';
import '../Constant/helper.dart';

class AppState with ChangeNotifier {
  IO.Socket? _socket;
  String priceTicketTotal = '';
  String priceUnityTicket = '';
  String idEvent = '';
  String idVoyage = '';
  int maxPlace = 0;
  double percentageRecharge = 0.0;
  int amountTvaWithdraw = 200;
  int indexBottomBar = 2;//new Random().nextInt(3);
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
  AppState() {
    initializeSocket();
  }

  initializeSocket() async {
    _socket = IO.io("${ConsumeAPI.SERVER_ADDRESS}/${ConsumeAPI.NAME_SPACE}",
        IO.OptionBuilder().setTransports(['websocket']).build());

    _socket!.onConnect((data) async {
      print("Connected to socket");
      final User? getClient = await DBProvider.db.getClient();
      if (getClient != null && getClient.numero != "null") {
        this.setJoinConnected(getClient.ident);
      }
    });

    _socket!.on("reponseChangeProfil", (data) async {
      Fluttertoast.showToast(
          msg: 'Changé avec succès',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: colorSuccess,
          textColor: Colors.white,
          fontSize: 16.0);
    });

    _socket!.on("getNewToken", (data) async {
      await setTokenForNotificationProvider(data["tokenNotification"]);
    });

    _socket!.on("MsToClient", (data) async {
      this.updateLoadingToSend(false);
      if (this.getIdOldConversation == data['_id']) {
        this.setConversation(data);
        final User getClient = await DBProvider.db.getClient();
        if (getClient.name.trim() != data['author'].trim()) {
          this.ackReadMessage(data['room']);
        }
      }
    });

    _socket!.on("ackReadMessageComeBack", (data) async {
      if (this.getIdOldConversation == data['_id']) {
        this.setConversation(data);
      }
    });

    _socket!.on("receivedConversation", (data) async {
      if (data['etat'] == 'found') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        this.setConversation(data['result']);
        this.setIdOldConversation(data['result']['_id']);
        this.ackReadMessage(data['result']['room']);
        await prefs.setString(
            data['result']['room'], jsonEncode(data['result']));
      } else {
        this.setConversation({});
        this.setIdOldConversation('');
      }
    });
    _socket!.on("receivedNotification", (data) async {
      if (data['withWallet']) {
        User newClient = await DBProvider.db.getClient();
        await DBProvider.db.updateClientWallet(data['wallet'], newClient.ident);
      }
      this.setNumberNotif(data['totalNotif']);
    });

    _socket!.on("agreePaiement", (data) async {
      await DBProvider.db.updateClient(data['recovery'], data['ident']);
      await DBProvider.db.updateClientWallet(data['wallet'], data['ident']);
    });

    _socket!.on("roomCreated", (data) async {
      this.updateLoadingToSend(false);
      this.setConversation(data);
      this.setIdOldConversation(data['_id']);
    });
    _socket!.on("roomCreatedForNotification", (data) async {});
    _socket!.on("typingResponse", (data) async {
      if (this.getIdOldConversation == data['id']) {
        this.updateTyping(data['typing'] as bool);
      }
    });

    _socket!.on('disconnect', (_) {
      this.deleteSocket();
    });
  }

  setTyping(bool typing, String id, String identUser) async {
    final jsonData = {
      "id": this.getIdOldConversation,
      "typing": typing,
      "room": id,
      "identUser": identUser,
    };
    if (_socket == null) {
      await initializeSocket();
    }
    _socket!.emit("typing", [jsonData]);
  }

  deleteMessage(int indexContent, String room, String identUser) async {
    final jsonData = {
      "id": this.getIdOldConversation,
      "indexContent": indexContent,
      "room": room,
      "identUser": identUser,
    };
    if (_socket == null) {
      await initializeSocket();
    }
    _socket!.emit("deleteMessage", [jsonData]);
  }

  ackReadMessage(String room) async {
    final jsonData = {
      "room": room,
    };
    if (_socket == null) {
      await initializeSocket();
    }
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

  setTypingUser(String id) async {
    if (_socket == null) {
      await initializeSocket();
    }
    _socket!.emit("typing", [id]);
    notifyListeners();
  }

  setJoinConnected(String id) async {
    if (_socket == null) {
      await initializeSocket();
    }
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

    if (_socket == null) {
      await initializeSocket();
    }
    _socket!.emit("message", [jsonData]);
    notifyListeners();
  }

  void refreshChatMessage(
      {required String room,
        required String id,
        String imageName = '',
        String base64 = '',
        String content = ''}) async {
    User newClient = await DBProvider.db.getClient();
    final jsonData = {
      "content": content,
      "ident": newClient.ident,
      "room": room,
      "base64": base64,
      "image": imageName,
      "id": id
    };
    if (_socket == null) {
      await initializeSocket();
    }
    _socket!.emit("refreshMessage", [jsonData]);
    notifyListeners();
  }

  void relanceDeals({
    required String destinate,
    required String id,
    String content = '',
    String imageName = '',
    String base64 = '',
  }) async {
    User newClient = await DBProvider.db.getClient();
    final jsonData = {
      "content": content,
      "ident": newClient.ident,
      "room": destinate,
      "base64": base64,
      "image": imageName,
      "id": id
    };

    if (_socket == null) {
      await initializeSocket();
    }

    _socket!.emit("relanceDeals", [jsonData]);
    notifyListeners();
  }

  void changeProfilPicture(
      {required String imageName, required String base64}) async {
    User newClient = await DBProvider.db.getClient();
    final jsonData = {
      "image": imageName,
      "id": newClient.ident,
      "base64": base64,
      "recovery": newClient.recovery
    };

    if (_socket == null) {
      await initializeSocket();
    }

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

    if (_socket == null) {
      await initializeSocket();
    }
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

    if (_socket == null) {
      await initializeSocket();
    }

    _socket!.emit("sendPropositionForDealsByAuteur", [jsonData]);
    notifyListeners();
  }

  void notAgreeForPropositionForDeals(
      {required String id, required String room}) async {
    final jsonData = {
      "room": room,
      "id": id,
    };

    if (_socket == null) {
      await initializeSocket();
    }

    _socket!.emit("notAgreeForPropositionForDeals", [jsonData]);
    notifyListeners();
  }

  void agreeForPropositionForDeals(
      {required String id, required String room,required String methodPayement, bool? finalityPayement}) async {
    dynamic jsonData = {
      "room": room,
      "id": id,
      "methodPayement": methodPayement
    };
    if(finalityPayement != null) {
      jsonData['finalityPayement'] = "true";
    }

    if (_socket == null) {
      await initializeSocket();
    }

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

  getConversation(String foreign) async {
    if (_socket == null) {
      await initializeSocket();
    }

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
