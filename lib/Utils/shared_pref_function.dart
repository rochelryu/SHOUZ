import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

saveVoteIdToShared(String voteId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('saveVoteIdToShared', voteId);
}

saveAnonymousUser(dynamic userInfo) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('anonymousUser', jsonEncode(userInfo));
}

dropVoteIdToShared() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('saveVoteIdToShared');
}

getVoteIdToShared() async {
  final prefs = await SharedPreferences.getInstance();
  return await prefs.getString('saveVoteIdToShared') ?? '';
}

getAnonymousUser() async {
  final prefs = await SharedPreferences.getInstance();
  String data = await prefs.getString('anonymousUser') ?? '{}';
  return jsonDecode(data);
}

getAllVoteByIdToShared(String voteId) async {
  final prefs = await SharedPreferences.getInstance();
  String data = await prefs.getString(voteId) ?? '{}';
  return jsonDecode(data);
}

verifyAndCreateIfNoteExisteVoteByIdToShared(String voteId, String categorieId, String actorId, {bool toCreate = false}) async {
  final prefs = await SharedPreferences.getInstance();
  String data = await prefs.getString(voteId) ?? '';
  bool found = false;
  final actualy = DateTime.now();
  final registerDate = DateTime(actualy.year, actualy.month, actualy.day, 0,0,0);
  if(data != '') {
    List<dynamic> dataFormated = jsonDecode(data);


    for (var element in dataFormated) {
      if (element['categorieId'].toString().trim() == categorieId.trim()) {
        for (var vote in element['votes']) {
          final actualy = DateTime.now();
          if (DateTime(actualy.year, actualy.month, actualy.day, 0,0,0).difference(DateTime.parse(vote['registerDate'])).inMinutes == 0) {
            found = true;
            break;
          }
        }
      }
    }
    if(toCreate && !found) {
      bool categorieFind = false;

      for (var element in dataFormated) {
        if (element['categorieId'].toString().trim() == categorieId.trim()) {
          categorieFind = true;

          element['votes'].add({
            'actorId':actorId.trim(),
            'registerDate': registerDate.toIso8601String(),
          });
          break;
        }
      }
      if(!categorieFind) {
        dataFormated.add({
          'categorieId': categorieId.trim(),
          'votes': [
            {
              'actorId':actorId.trim(),
              'registerDate': registerDate.toIso8601String(),
            }
          ],
        });
      }
      await prefs.setString(voteId, jsonEncode(dataFormated));
    }
  } else {
    if(toCreate) {
      List<dynamic> dataFormated = [];
      dataFormated.add({
        'categorieId': categorieId.trim(),
        'votes': [
          {
            'actorId':actorId.trim(),
            'registerDate': registerDate.toIso8601String(),
          }
        ],
      });
      await prefs.setString(voteId, jsonEncode(dataFormated));
    }
  }
  return  toCreate || found;
  //return
}

clearSharedPrefAllStorage() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.clear();
}