import 'dart:async';
import 'dart:ui' as ui;

import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/Categorie.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Utils/network_util.dart';

class ConsumeAPI {
  NetworkUtil _netUtil = new NetworkUtil();
  static final BASE_URL = "http://192.168.1.180:8000";//192.168.1.180"; // 192.168.1.100 127.0.0.1 172.20.10.4 // ngboador 192.168.1.27 // unknow mobile 192.168.43.4
  static final SIGIN_URL = BASE_URL + "/client/initialise";
  static final PREFERENCE_URL = BASE_URL + "/client/preference";
  static final SIGINSECONDSTEP_URL = BASE_URL + "/client/secondStep";
  static final UPDATEHOBIE_URL = BASE_URL + "/client/updateHobbies";
  static final UPDATEPOSITION_URL = BASE_URL + "/client/updateCurentPosition";
  static final SETTINGS_URL = BASE_URL + "/client/settings";
  static final RECHARGE_BYCRYPTO_URL = BASE_URL + "/client/transactionCrypto";
  static final DEMANDERETRAIT_URL = BASE_URL + "/client/demandeRetrait";
  static final RECHARGE_BYMOBILEMONEY_URL = BASE_URL + "/client/transactionMobileMoney";
  static final RESPONSE_FINAL_DEALS_URL = BASE_URL + "/client/responseProductForLastStep";
  static final ADD_COMMENT_ON_ACTUALITY_URL = BASE_URL + "/client/addComment";
  static final GET_PROFIL_URL = BASE_URL + "/client/getProfil";
  static final UPDATE_PROFIL_PICTURE_URL = BASE_URL + "/client/changeProfil";
  static final GET_USER_BY_FILTER_URL = BASE_URL + "/client/getClientByNumber";
  static final UPDATE_PROFIL_PIN_URL = BASE_URL + "/client/updatePin";
  static final VERIFY_FRIEND = BASE_URL + "/client/verify";

  static final VIDE_NOTIFICATION_URL = BASE_URL + "/client/videNotif";
  static final DEMANDE_CONDUCTEUR_URL = BASE_URL + "/client/demandeConducteur";
  static final ALL_NOTIFICATION_URL = BASE_URL + "/client/getAllNotif";
  static final PERCENTAGE_METHOD_PAYEMENT_URL = BASE_URL + "/client/getPercentageModePayement";
  static final GET_MOBILE_MONEY_AVALAIBLE_URL = BASE_URL + "/client/getMobileMoneyAvalaible";
  static final GET_MAX_PLACE_FOR_CREATE_EVENT_URL = BASE_URL + "/client/getMaxPlaceForCreateEvent";
  static final ALL_CATEGIRES_URL = BASE_URL + "/categorie/all";

  static final SET_EVENT_URL = BASE_URL + "/event/inside";
  static final SET_SUBSCRIBE_EVENT_URL = BASE_URL + "/client/subscribeEvent";
  static final SET_BUY_EVENT_URL = BASE_URL + "/event/buyTicket";
  static final SHARE_TICKET_URL = BASE_URL + "/event/shareTicket";
  static final DROP_TICKET_URL = BASE_URL + "/event/dropTicket";
  static final GET_TYPE_EVENT_URL = BASE_URL + "/event/getAllType";
  static final RECUP_CUMUL_URL = BASE_URL + "/event/recupGain";
  static final SET_DECODEUR_URL = BASE_URL + "/event/setDecodeur";
  static final GET_EVENT_URL = BASE_URL + "/event/getEvent";
  static final GET_ALL_DECODEUR_FOR_EVENT_URL = BASE_URL + "/event/getAllDecodeurForEvent";


  static final ALL_CATEGIRES_WITHOUT_FILTER_URL =
      BASE_URL + "/categorie/display";
  static final VERIFY_CATEGIRES = BASE_URL + "/categorie/verify";
  static final SERVICE_METEO_URL = BASE_URL + "/other-service/getMeteo";
  static final ADD_VIEW_AERTICLE_URL = BASE_URL + "/actualite/addView";
  static final GET_ACTUALITE_URL = BASE_URL + "/actualite/getActualite";
  static final GET_ACTUALITE_BY_CATEGORIE_URL = BASE_URL + "/actualite/getActualiteByCategorie";
  static final GET_COMMENT_ACTUALITE_URL = BASE_URL + "/client/getCommentAllInfo";
  static final GET_VERIFY_ITEM_IN_FAVOR_URL = BASE_URL + "/client/verifyIfExistItemInFavor";
  static final SET_DEALS_URL = BASE_URL + "/products/inside";
  static final GET_DETAILS_URL = BASE_URL + "/products/getDetailsOfProduct";
  static final GET_PRODUCT_URL = BASE_URL + "/products/getProduct";
  static final GET_TRAVEL_URL = BASE_URL + "/travel/getTravel";
  static final DETAILS_TRAVEL_URL = BASE_URL + "/travel/detailsTravel";
  static final SET_TRAVEL_URL = BASE_URL + "/travel/inside";
  static final SET_BUY_TRAVEL_URL = BASE_URL + "/travel/buyTravel";
  static final STOP_TRAVEL_URL = BASE_URL + "/travel/stopTravel";


  // Assets File URL
  static final AssetProfilServer = BASE_URL + "/profil/";
  static final AssetTravelServer = BASE_URL + "/travel/";
  static final AssetTravelBuyerServer = BASE_URL + "/travel/ticket/";
  static final AssetProductServer = BASE_URL + "/store/";
  static final AssetEventServer = BASE_URL + "/event/";
  static final AssetBuyEventServer = BASE_URL + "/event/buy/";
  static final AssetCovoiturageServer = BASE_URL + "/covoiturage/";
  static final AssetPublicServer = BASE_URL + "/public/";
  static final AssetConversationServer = BASE_URL + "/public/conversation/";
  //static final _API_KEY = "somerandomkey";

  ConsumeAPI() {}
  // For signin
  signin(String numero, String prefix) {
    return _netUtil.post(SIGIN_URL,
        body: {"numero": numero, "prefix": prefix}).then((dynamic res) {
      return {'user': User.fromJson(res["result"]), 'etat': res["etat"]};
    });
  }

  signinSecondStep(dynamic images, dynamic base64, List<String> choice) async {
    User newClient = await DBProvider.db.getClient();
    return _netUtil.post(SIGINSECONDSTEP_URL, body: {
      "id": newClient.ident,
      "images": images,
      "base64": base64,
      "name": newClient.name,
      "choice": choice.join(','),
      "recovery": newClient.recovery
    }).then((dynamic res) {
      if (res["etat"] == "found") {
        return {'user': User.fromJson(res["result"]), 'etat': res["etat"]};
      } else {
        return {'etat': res["etat"]};
      }
    });
  }

  updateHobie(List<dynamic> choice) async {
    User newClient = await DBProvider.db.getClient();
    return _netUtil.post(UPDATEHOBIE_URL, body: {
      "id": newClient.ident,
      "choice": choice.join(','),
      "recovery": newClient.recovery
    }).then((dynamic res) {
      if (res["etat"] == "found") {
        return {'user': User.fromJson(res["result"]), 'etat': res["etat"]};
      } else {
        return {'etat': res["etat"]};
      }
    });
  }

  // For Categorie
  Future<List<dynamic>> getAllCategrie(
      [String search = "", String sort = 'not']) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get(
        '$ALL_CATEGIRES_URL/${newClient.ident}?search=${search}&sort=$sort');
    List<dynamic> allCategorie =
        res['result'].map((c) => Categorie.fromJson(c)).toList();
    return allCategorie;
  }

  Future<Iterable<dynamic>> getAllUser(String number) async {
    if(number.length >= 8) {
      User newClient = await DBProvider.db.getClient();
      final res = await _netUtil.get(
          '$GET_USER_BY_FILTER_URL/${newClient.ident}?search=$number');
      Iterable<dynamic> allUser = res['result'];
      return allUser;
    } else {
      return [];
    }

  }

  Future<List<dynamic>> getAllCategrieWithoutFilter(
      [String category = "all"]) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get(
        '$ALL_CATEGIRES_WITHOUT_FILTER_URL/${newClient.ident}?categorie=$category');
    return res['result'];
  }

  Future<int> getMaxPlaceForCreateEvent() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get(
        '$GET_MAX_PLACE_FOR_CREATE_EVENT_URL/${newClient.ident}');
    if(res['etat'] == 'found') {
      return res['result'];
    }
    return 0;
  }

  Future<bool> verifyCategorieExist(String categorie) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil
        .get('$VERIFY_CATEGIRES/${newClient.ident}/$categorie');
    return (res['etat'] == 'already') ? true : false;
  }
  Future<bool> verifyFriendExist(String numero, String prefix) async {
    final res = await _netUtil
        .get('$VERIFY_FRIEND?numero=$numero&prefix=$prefix');
    return (res['etat'] == 'already') ? true : false;
  }

  // For client
  Future<Map<String, dynamic>> getProfil() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get(
        '$GET_PROFIL_URL/${newClient.ident}?credentials=${newClient.recovery}');
    return res['info'];
  }

  Future<List<dynamic>> getAllPreference() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$PREFERENCE_URL/${newClient.ident}');
    List<dynamic> allCategorie = res['result'];
    return allCategorie;
  }

  Future<List<dynamic>> getAllTypeEvents(String ident) async {
    return await _netUtil.get('$GET_TYPE_EVENT_URL/$ident');
  }

  setSettings() async {
    User newClient = await DBProvider.db.getClient();
    final body = {'id': newClient.ident, 'credentials': newClient.recovery};
    print(body);
    return _netUtil.post(SETTINGS_URL, body: body).then((dynamic res) async {
      /*if (res['etat'] == 'found') {
        await DBProvider.db
            .updateClient(res['result']['recovery'], newClient.ident);
      }*/
      return res;
    });
  }
  //RECHARGE_BYCRYPTO_URL

  demandeRetrait(String endpoint, String address, String amount) async {
    User newClient = await DBProvider.db.getClient();
    final body = {'id': newClient.ident, 'credentials': newClient.recovery, 'endpoint': endpoint, 'address': address,'amount': amount };

    return _netUtil.post(DEMANDERETRAIT_URL, body: body).then((dynamic res) async {
      if (res['etat'] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
      }
      return res;
    });
  }

  rechargeCrypto(String endpoint, String ref) async {
    User newClient = await DBProvider.db.getClient();
    final body = {'id': newClient.ident, 'credentials': newClient.recovery, 'endpoint': endpoint, 'ref': ref};

    return _netUtil.post(RECHARGE_BYCRYPTO_URL, body: body).then((dynamic res) async {
      if (res['etat'] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
        await DBProvider.db.updateClientWallet(res['result']['wallet'], newClient.ident);
      }
      return res;
    });
  }

  rechargeMobileMoney(String endpoint, String numero,String amount) async {
    User newClient = await DBProvider.db.getClient();
    final body = {'id': newClient.ident, 'credentials': newClient.recovery, 'endpoint': endpoint, 'numero': numero, 'amountInLocalCurrency': amount};

    return _netUtil.post(RECHARGE_BYMOBILEMONEY_URL, body: body).then((dynamic res) async {
      if (res['etat'] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
        await DBProvider.db.updateClientWallet(res['result']['wallet'], newClient.ident);
      } else if(res['etat'] == 'inWait') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
      }
      return res;
    });
  }


  responseProductForLastStep(String room, int typeDeResponse) async {
    User newClient = await DBProvider.db.getClient();
    final body = {'id': newClient.ident, 'credentials': newClient.recovery, 'room': room, 'typeDeResponse': typeDeResponse.toString()};

    return _netUtil.post(RESPONSE_FINAL_DEALS_URL, body: body).then((dynamic res) async {
      return res;
    });
  }



  addComment(String user, String idActualite, String content ) async {
    final body = {'user': user, 'id_Actualite': idActualite, 'content': content};

    return _netUtil.post(ADD_COMMENT_ON_ACTUALITY_URL, body: body).then((dynamic res) async {
      return res['etat'];
    });
  }

  changeProfilPicture({required String imageName, required String base64}) async {
    User newClient = await DBProvider.db.getClient();
    final jsonData = {
      "image": imageName,
      "id": newClient.ident,
      "base64": base64,
      "recovery": newClient.recovery
    };

    return _netUtil
        .post(UPDATE_PROFIL_PICTURE_URL, body: jsonData)
        .then((dynamic res) async {
      if (res['etat'] == 'found') {
        final user = User.fromJson(res['result']);
        await DBProvider.db.delClient();
        //await DBProvider.db.delAllHobies();
        await DBProvider.db.newClient(user);
      }
      return res['etat'];
    });
  }

  changePin({required String pin}) async {
    User newClient = await DBProvider.db.getClient();
    final jsonData = {
      "pin": pin,
      "id": newClient.ident,
      "recovery": newClient.recovery
    };

    return _netUtil
        .post(UPDATE_PROFIL_PIN_URL, body: jsonData)
        .then((dynamic res) async {
      if (res['etat'] == 'found') {
        final user = User.fromJson(res['result']);
        await DBProvider.db.delClient();
        //await DBProvider.db.delAllHobies();
        await DBProvider.db.newClient(user);
      }
      return res['etat'];
    });
  }

  subscribeEvent({required String forfait, required String ident, required String recovery}) async {
    final jsonData = {"id": ident, "forfait": forfait, "recovery": recovery};

    return _netUtil
        .post(SET_SUBSCRIBE_EVENT_URL, body: jsonData)
        .then((dynamic res) async {
          print(res);
      if (res['etat'] == 'found') {
        await DBProvider.db.updateClientWallet(res['result']['wallet'], ident);
        await DBProvider.db.updateClient(res['result']['recovery'], ident);
        await DBProvider.db.updateClientIsActivateForfait(1, ident);
      }
      return res['etat'];
    });
  }

  recupCumul(String idEvent) async {
    User newClient = await DBProvider.db.getClient();
    final body = {'id': newClient.ident, 'credentials': newClient.recovery, 'idEvent': idEvent,};

    return _netUtil.post(RECUP_CUMUL_URL, body: body).then((dynamic res) async {
      if (res['etat'] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
        await DBProvider.db.updateClientWallet(res['result']['wallet'], newClient.ident);
      }
      return res;
    });
  }

  Future<String> videNotif() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get(
        '$VIDE_NOTIFICATION_URL/${newClient.ident}?credentials=${newClient.recovery}');
    if(res['etat'] == 'found') {
      final user = User.fromJson(res['result']);
      await DBProvider.db.delClient();
      await DBProvider.db.newClient(user);
    } else {
      await DBProvider.db.delClient();
      await DBProvider.db.delAllHobies();
      setLevel(1);
    }
    return res['etat'];
  }

  Future<Map<dynamic, dynamic>> getAllNotif() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$ALL_NOTIFICATION_URL/${newClient.ident}');
    return res;
  }

  Future<Map<dynamic, dynamic>> getAllPercentage() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$PERCENTAGE_METHOD_PAYEMENT_URL/${newClient.ident}?credentials=${newClient.recovery}');
    if(res["etat"] == 'notFound') {
      await DBProvider.db.delClient();
      await DBProvider.db.delAllHobies();
      setLevel(1);
    }
    return res;
  }

  Future<Map<dynamic, dynamic>> getMobileMoneyAvalaible() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$GET_MOBILE_MONEY_AVALAIBLE_URL/${newClient.ident}?credentials=${newClient.recovery}');
    if(res["etat"] == 'notFound') {
      await DBProvider.db.delClient();
      await DBProvider.db.delAllHobies();
      setLevel(1);
    }
    return res;
  }

  // For Meteo
  Future<dynamic> getMeteo(double latitude, double longitude) async {
    User newClient = await DBProvider.db.getClient();
    final _sysLng = ui.window.locale.languageCode;
    final res = await _netUtil.get(
        '$SERVICE_METEO_URL/${newClient.ident}?latitude=${latitude.toString()}&longitude=${longitude.toString()}&local=${_sysLng.toString()}');
    return res;
  }

  // For Actualite
  Future<Map<String, dynamic>> getActualite() async {
    User newClient = await DBProvider.db.getClient();
    //final _sysLng = ui.window.locale.languageCode;
    final res = await _netUtil.get('$GET_ACTUALITE_URL/${newClient.ident}');
    //print(res);
    return res;
  }
  Future<List<dynamic>> getActualitiesByCategorieId(String idActality, int limit) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$GET_ACTUALITE_BY_CATEGORIE_URL/${newClient.ident}?idActality=$idActality&limit=$limit');
    return res['actualiteArray'];
  }

  Future<List<dynamic>> getCommentActualite(id_actualite) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$GET_COMMENT_ACTUALITE_URL/${newClient.ident}/$id_actualite');
    return res['result'];
  }

  addView(String id, String id_actualite) {
    return _netUtil.post(ADD_VIEW_AERTICLE_URL,
        body: {"id": id, "actualiteId": id_actualite}).then((dynamic res) {
      return {'etat': res["etat"]};
    });
  }

  Future<bool> verifyIfExistItemInFavor(String id_item, int domaine) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$GET_VERIFY_ITEM_IN_FAVOR_URL/${newClient.ident}/$id_item?domaine=${domaine.toString()}');
    return res;
  }

  // For Deals
  Future<List<dynamic>> getDeals() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$GET_PRODUCT_URL/${newClient.ident}');
    return res;
  }



  Future<Map<dynamic,dynamic>> getDetailsDeals(String productid) async {
    final res = await _netUtil.get('$GET_DETAILS_URL/$productid');
    return res;
  }

  Future<List<dynamic>> updateDealFullForFutur(List<dynamic> dealFullForFutur) async {

    return dealFullForFutur;
  }

  setProductDeals(
      String name,
      String describe,
      String categorie,
      String imagesTitles,
      String imagesBuffers,
      String lieu,
      int level,
      String number,
      String price,
      String quantity) async {
    User newClient = await DBProvider.db.getClient();
    final body = {
      'id': newClient.ident,
      'recovery': newClient.recovery,
      'author': newClient.ident,
      'name': name,
      'describe': describe,
      'numero': number,
      'imagesTitles': imagesTitles,
      'imagesBuffers': imagesBuffers,
      'lieu': lieu,
      'categorie': categorie,
      'price': price,
      'quantity': quantity,
      'level': level.toString()
    };

    return _netUtil.post(SET_DEALS_URL, body: body).then((dynamic res) async {
      if(res['etat'] == 'found' && res['recovery'] != '') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
        await DBProvider.db.updateClientWallet(res['result']['wallet'], newClient.ident);
      }
      return res['etat'];
    });
  }

  // For Position
  updatePosition(String position, double latitude, double longitude,
      double speedAccuracy) async {
    User newClient = await DBProvider.db.getClient();
    final body = (position == '')
        ? {
            'id': newClient.ident,
            'credentials': newClient.recovery,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'speedAccuracy': speedAccuracy.toString(),
          }
        : {
            'id': newClient.ident,
            'credentials': newClient.recovery,
            'position': position,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'speedAccuracy': speedAccuracy.toString(),
          };

    return _netUtil.post(UPDATEPOSITION_URL, body: body).then((dynamic res) async {
      if (res["etat"] == "found") {
        return {'user': User.fromJson(res["result"]), 'etat': res["etat"]};
      } else {
        await DBProvider.db.delClient();
        await DBProvider.db.delAllHobies();
        setLevel(1);
        return {'etat': res["etat"]};
      }
    });
  }

  // For decodeur
  shareDecodeur(String eventId, String listDecodeur) async {
    User newClient = await DBProvider.db.getClient();
    final body = {
      'id': newClient.ident,
      'credentials': newClient.recovery,
      'eventId': eventId,
      'listDecodeur': listDecodeur
    };
    return _netUtil.post(SET_DECODEUR_URL, body: body).then((dynamic res) async {
      if(res["etat"] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
      }
      return res;
    });
  }
  Future<Map<String, dynamic>> getEvents() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$GET_EVENT_URL/${newClient.ident}');
    return res;
  }

  Future<Map<String, dynamic>> getDecodeur(String idEvent) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$GET_ALL_DECODEUR_FOR_EVENT_URL/$idEvent?ident=${newClient.ident}&credential=${newClient.recovery}');
    return res;
  }

  setEvent(
      String title,
      String describe,
      String categorie,
      String imageCover,
      String imageCoverBase64,
      String position,
      String enventDate,
      int numberTicket,
      String prices,
      String email,
      [String videoPub = "",
      String videoPubBase64 = '']) async {
    User newClient = await DBProvider.db.getClient();
    final body = {
      'id': newClient.ident,
      'authorName': newClient.name,
      'title': title,
      'email': email,
      'describe': describe,
      'numberTicket': numberTicket.toString(),
      'imageCover': imageCover,
      'imageCoverBase64': imageCoverBase64,
      'position': position,
      'categorie': categorie,
      'prices': prices,
      'enventDate': enventDate,
      'videoPub': videoPub,
      'videoPubBase64': videoPubBase64,
    };

    return _netUtil.post(SET_EVENT_URL, body: body).then((dynamic res) async {
      if(res["etat"] == 'found') {
        final clientActive = await DBProvider.db.updateClientIsActivateForfait(0, newClient.ident);
        print(clientActive);
      }
      return res;
    });
  }

  buyEvent(String idEvent, String priceTotal, String numberTicket,String typeTicket) async {
    User newClient = await DBProvider.db.getClient();

    final body = {
      'id': newClient.ident,
      'credentials': newClient.recovery,
      'idEvent': idEvent,
      'priceTotal': priceTotal,
      'numberTicket': numberTicket,
      'priceUnity': typeTicket
    };
    return _netUtil.post(SET_BUY_EVENT_URL, body: body).then((dynamic res) async {
      print(res);
      if(res["etat"] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
        await DBProvider.db.updateClientWallet(res['result']['wallet'], newClient.ident);
      } else if(res["etat"] == 'notFound') {
        await DBProvider.db.delClient();
        await DBProvider.db.delAllHobies();
        setLevel(1);
      }
      return res;

    });
  }



  shareEventTicket(String ticketId, int place, String numero,String prefix) async {
    User newClient = await DBProvider.db.getClient();
    final body = {
      'id': newClient.ident,
      'credentials': newClient.recovery,
      'ticketId': ticketId,
      'place': place.toString(),
      'numero': numero,
      'prefix': prefix
    };
    return _netUtil.post(SHARE_TICKET_URL, body: body).then((dynamic res) async {
      if(res["etat"] == 'found') {
        await DBProvider.db.updateClient(res['recovery'], newClient.ident);
      }
      return res;

    });
  }
  dropEventTicket(String ticketId) async {
    User newClient = await DBProvider.db.getClient();
    final body = {
      'id': newClient.ident,
      'credentials': newClient.recovery,
      'ticketId': ticketId,
    };
    return _netUtil.post(DROP_TICKET_URL, body: body).then((dynamic res) async {
      print(res);
      if(res["etat"] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
        await DBProvider.db.updateClientWallet(res['result']['wallet'], newClient.ident);
      }
      return res;

    });
  }


  // For Covoiturage
  Future<Map<String, dynamic>> getCovoiturage(
      String origin, String destinate) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get(
        '$GET_TRAVEL_URL/${newClient.ident}?origin=$origin&destinate=$destinate');
    return res;
  }

  Future<Map<dynamic, dynamic>> verifyIfIamTicket(
      String travelId) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get(
        '$DETAILS_TRAVEL_URL/$travelId?idClient=${newClient.ident}&credentials=${newClient.recovery}');
    return res;
  }

  demandeConducteur(
      String hobies,
      String carteGriseRectoName,
      String carteGriseRectoBase64,
      String carteGriseVersoName,
      String carteGriseVersoBase64,
      String carteTechniqueRectoName,
      String carteTechniqueRectoBase64,
      String carteTechniqueVersoName,
      String carteTechniqueVersoBase64,
      String permisRectoName,
      String permisRectoBase64,
      String permisVersoName,
      String permisVersoBase64,
      String assurancePageOneName,
      String assurancePageOneBase64,
      String assurancePageTwoName,
      String assurancePageTwoBase64,
      String pictureVehiculeName,
      String pictureVehiculeBase64,
      String pictureProfilConducteurName,
      String pictureProfilConducteurBase64,
      int numberPlaceAvailable,
      ) async {
    User newClient = await DBProvider.db.getClient();
    final body = {
      'id': newClient.ident,
      'credentials': newClient.recovery,
      'hobies': hobies,
      'carteGriseRectoName': carteGriseRectoName,
      'carteGriseRectoBase64': carteGriseRectoBase64,
      'carteGriseVersoName': carteGriseVersoName,
      'carteGriseVersoBase64': carteGriseVersoBase64,
      'carteTechniqueRectoName': carteTechniqueRectoName,
      'carteTechniqueRectoBase64': carteTechniqueRectoBase64,
      'carteTechniqueVersoName': carteTechniqueVersoName,
      'carteTechniqueVersoBase64': carteTechniqueVersoBase64,
      'permisRectoName': permisRectoName,
      'permisRectoBase64': permisRectoBase64,
      'permisVersoName': permisVersoName,
      'permisVersoBase64': permisVersoBase64,
      'assurancePageOneName': assurancePageOneName,
      'assurancePageOneBase64': assurancePageOneBase64,
      'assurancePageTwoName': assurancePageTwoName,
      'assurancePageTwoBase64': assurancePageTwoBase64,
      'pictureVehiculeName': pictureVehiculeName,
      'pictureVehiculeBase64': pictureVehiculeBase64,
      'pictureProfilConducteurName': pictureProfilConducteurName,
      'pictureProfilConducteurBase64': pictureProfilConducteurBase64,
      'numberPlaceAvailable': numberPlaceAvailable.toString(),
    };
    print({'id': body['id'], 'credentials': newClient.recovery,});

    return _netUtil.post(DEMANDE_CONDUCTEUR_URL, body: body).then((dynamic res) async {
      if(res["etat"] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
      }
      return res;
    });
  }

  setTravel(
      String beginCity,
      String lieuRencontre,
      String dateChoice,
      String endCity,
      String price,
      ) async {
    User newClient = await DBProvider.db.getClient();
    final body = {
      'id': newClient.ident,
      'credentials': newClient.recovery,
      'beginCity': beginCity,
      'lieuRencontre': lieuRencontre,
      'travelDate': dateChoice,
      'endCity': endCity,
      'price': price,

    };

    return _netUtil.post(SET_TRAVEL_URL, body: body).then((dynamic res) async {
      if(res["etat"] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
      }
      return res;
    });
  }

  stopTravel(
      String idTravel,
      ) async {
    User newClient = await DBProvider.db.getClient();
    final body = {
      'id': newClient.ident,
      'credentials': newClient.recovery,
      'idTravel': idTravel,

    };

    return _netUtil.post(STOP_TRAVEL_URL, body: body).then((dynamic res) async {
      if(res["etat"] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
      } else if(res["etat"] == 'notFound') {
        await DBProvider.db.delClient();
        await DBProvider.db.delAllHobies();
        setLevel(1);
      }
      return res;
    });
  }

  buyTravel(String idTravel, String choicePlace) async {
    User newClient = await DBProvider.db.getClient();

    final body = {
      'id': newClient.ident,
      'credentials': newClient.recovery,
      'idTravel': idTravel,
      'choicePlace': choicePlace,
    };
    return _netUtil.post(SET_BUY_TRAVEL_URL, body: body).then((dynamic res) async {
      if(res["etat"] == 'found') {
        await DBProvider.db.updateClient(res['result']['recovery'], newClient.ident);
        await DBProvider.db.updateClientWallet(res['result']['wallet'], newClient.ident);
      }

      return res;

    });
  }

  // For communication



}
