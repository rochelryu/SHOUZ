import 'dart:async';
import 'dart:ui' as ui;

import 'package:shouz/Models/Categorie.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Utils/network_util.dart';

class ConsumeAPI {
  NetworkUtil _netUtil = new NetworkUtil();
  static final BASE_URL =
      "http://192.168.1.180:8000"; // 192.168.1.100 127.0.0.1 172.20.10.4 // ngboador 192.168.1.27 // unknow mobile 192.168.43.4
  static final SIGIN_URL = BASE_URL + "/client/initialise";
  static final PREFERENCE_URL = BASE_URL + "/client/preference";
  static final SIGINSECONDSTEP_URL = BASE_URL + "/client/secondStep";
  static final UPDATEHOBIE_URL = BASE_URL + "/client/updateHobbies";
  static final UPDATEPOSITION_URL = BASE_URL + "/client/updateCurentPosition";
  static final SETTINGS_URL = BASE_URL + "/client/settings";
  static final ADD_COMMENT_ON_ACTUALITY_URL = BASE_URL + "/client/addComment";
  static final GET_PROFIL_URL = BASE_URL + "/client/getProfil";
  static final UPDATE_PROFIL_PICTURE_URL = BASE_URL + "/client/changeProfil";
  static final UPDATE_PROFIL_PIN_URL = BASE_URL + "/client/updatePin";
  static final VIDE_NOTIFICATION_URL = BASE_URL + "/client/videNotif";
  static final ALL_NOTIFICATION_URL = BASE_URL + "/client/getAllNotif";
  static final ALL_CATEGIRES_URL = BASE_URL + "/categorie/all";
  static final SET_EVENT_URL = BASE_URL + "/event/inside";
  static final SET_SUBSCRIBE_EVENT_URL = BASE_URL + "/client/subscribeEvent";
  static final SET_BUY_EVENT_URL = BASE_URL + "/event/buyTicket";

  static final ALL_CATEGIRES_WITHOUT_FILTER_URL =
      BASE_URL + "/categorie/display";
  static final VERIFY_CATEGIRES = BASE_URL + "/categorie/verify";
  static final SERVICE_METEO_URL = BASE_URL + "/other-service/getMeteo";
  static final ADD_VIEW_AERTICLE_URL = BASE_URL + "/actualite/addView";
  static final GET_ACTUALITE_URL = BASE_URL + "/actualite/getActualite";
  static final GET_COMMENT_ACTUALITE_URL = BASE_URL + "/client/getCommentAllInfo";
  static final GET_VERIFY_ITEM_IN_FAVOR_URL = BASE_URL + "/client/verifyIfExistItemInFavor";
  static final SET_DEALS_URL = BASE_URL + "/products/inside";
  static final GET_DETAILS_URL = BASE_URL + "/products/getDetailsOfProduct";
  static final GET_PRODUCT_URL = BASE_URL + "/products/getProduct";
  static final GET_TRAVEL_URL = BASE_URL + "/travel/getTravel";
  static final GET_EVENT_URL = BASE_URL + "/event/getEvent";

  // Assets File URL
  static final AssetProfilServer = BASE_URL + "/profil/";
  static final AssetProductServer = BASE_URL + "/store/";
  static final AssetEventServer = BASE_URL + "/event/";
  static final AssetBuyEventServer = BASE_URL + "/event/buy/";
  static final AssetCovoiturageServer = BASE_URL + "/covoiturage/";
  static final AssetPublicServer = BASE_URL + "/public/";
  static final AssetConversationServer = BASE_URL + "/public/conversation/";
  //static final _API_KEY = "somerandomkey";

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

  Future<List<dynamic>> getAllCategrieWithoutFilter(
      [String category = "all"]) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get(
        '$ALL_CATEGIRES_WITHOUT_FILTER_URL/${newClient.ident}?categorie=$category');
    return res['result'];
  }

  Future<bool> verifyCategorieExist(String categorie) async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil
        .get('$VERIFY_CATEGIRES/${newClient.ident}/$categorie');
    return (res['etat'] == 'already') ? true : false;
  }

  // For client
  Future<Map<String, dynamic>> getProfil() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get(
        '$GET_PROFIL_URL/${newClient.ident}?credentials=${newClient.recovery}');
    final user = User.fromJson(res['info']);
    await DBProvider.db.delClient();
    await DBProvider.db.delAllHobies();
    await DBProvider.db.newClient(user);
    return res['info'];
  }

  Future<List<dynamic>> getAllPreference() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$PREFERENCE_URL/${newClient.ident}');
    List<dynamic> allCategorie = res['result'];
    return allCategorie;
  }

  setSettings() async {
    User newClient = await DBProvider.db.getClient();
    final body = {'id': newClient.ident, 'credentials': newClient.recovery};
    print(body);

    return _netUtil.post(SETTINGS_URL, body: body).then((dynamic res) async {
      if (res['etat'] == 'found') {
        await DBProvider.db
            .updateClient(res['result']['recovery'], newClient.ident);
      }
      print(res);
      return res;
    });
  }

  addComment(String user, String idActualite, String content ) async {
    final body = {'user': user, 'id_Actualite': idActualite, 'content': content};

    return _netUtil.post(ADD_COMMENT_ON_ACTUALITY_URL, body: body).then((dynamic res) async {
      return res['etat'];
    });
  }

  changeProfilPicture({String imageName, String base64}) async {
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
        await DBProvider.db.delAllHobies();
        await DBProvider.db.newClient(user);
      }
      return res['etat'];
    });
  }

  changePin({String pin}) async {
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

  subscribeEvent({String pin, String forfait}) async {
    User newClient = await DBProvider.db.getClient();
    final jsonData = {"pin": pin, "id": newClient.ident, "forfait": forfait};

    return _netUtil
        .post(SET_SUBSCRIBE_EVENT_URL, body: jsonData)
        .then((dynamic res) async {
      if (res['etat'] == 'found') {
        await DBProvider.db
            .updateClientWallet(res['result']['wallet'], newClient.ident);
      }
      return res['etat'];
    });
  }

  Future<String> videNotif() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get(
        '$VIDE_NOTIFICATION_URL/${newClient.ident}');
    return res['etat'];
  }

  Future<Map<dynamic, dynamic>> getAllNotif() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$ALL_NOTIFICATION_URL/${newClient.ident}');
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

    return _netUtil.post(SET_DEALS_URL, body: body).then((dynamic res) {
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
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'speedAccuracy': speedAccuracy.toString(),
          }
        : {
            'id': newClient.ident,
            'position': position,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'speedAccuracy': speedAccuracy.toString(),
          };

    return _netUtil.post(UPDATEPOSITION_URL, body: body).then((dynamic res) {
      if (res["etat"] == "found") {
        return {'user': User.fromJson(res["result"]), 'etat': res["etat"]};
      } else {
        return {'etat': res["etat"]};
      }
    });
  }

  // For Event
  Future<Map<String, dynamic>> getEvents() async {
    User newClient = await DBProvider.db.getClient();
    final res = await _netUtil.get('$GET_EVENT_URL/${newClient.ident}');
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
      [String videoPub = "",
      String videoPubBase64 = '']) async {
    User newClient = await DBProvider.db.getClient();
    final body = {
      'id': newClient.ident,
      'authorName': newClient.name,
      'title': title,
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

    return _netUtil.post(SET_EVENT_URL, body: body).then((dynamic res) {
      return res["etat"];
    });
  }

  buyEvent(String idEvent, String priceTotal, String numberTicket) async {
    User newClient = await DBProvider.db.getClient();
    final body = {
      'id': newClient.ident,
      'credentials': newClient.recovery,
      'idEvent': idEvent,
      'priceTotal': priceTotal,
      'numberTicket': numberTicket,
    };

    return _netUtil.post(SET_BUY_EVENT_URL, body: body).then((dynamic res) {
      return {
        'user': User.fromJson(res["user"]),
        'etat': res["etat"],
        'error': res["error"],
        'result': res["result"],
      };
    });
  }

  // For Covoiturage
  Future<Map<String, dynamic>> getCovoiturage(
      String origin, String destinate) async {
    User newClient = await DBProvider.db.getClient();
    print('Fabrication');
    final res = await _netUtil.get(
        '$GET_TRAVEL_URL/${newClient.ident}?origin=$origin&destinate=$destinate');
    print(res);
    return res;
  }

  // For communication

}
