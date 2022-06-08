
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../Provider/Notifications.dart';

String reformatTimerForDisplayOnChrono(int time) {
  final minute = (time / 60).floor();
  final second = (time % 60);
  return "${minute.toString().length>1 ? minute.toString():'0${minute.toString()}' }:${second.toString().length>1 ? second.toString():'0${second.toString()}' }";
}
double defaultLatitude = 5.4143249;
double defaultLongitude = -3.9770197;

String descriptionShouz = '''

''';

String oneSignalAppId = "482dc96b-bccc-4945-b55d-0f22eed6fd63";
