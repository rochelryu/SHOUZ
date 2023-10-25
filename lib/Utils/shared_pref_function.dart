import 'package:shared_preferences/shared_preferences.dart';

saveVoteIdToShared(String voteId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('saveVoteIdToShared', voteId);
}

dropVoteIdToShared() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('saveVoteIdToShared');
}

getVoteIdToShared() async {
  final prefs = await SharedPreferences.getInstance();
  return await prefs.getString('saveVoteIdToShared') ?? '';
}