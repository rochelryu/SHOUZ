
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/main.dart';

import '../MenuDrawler.dart';
import '../Pages/LoadHide.dart';
import '../Pages/Notifications.dart';
import '../Pages/create_travel.dart';
import '../Pages/wallet_page.dart';

Future<void> createShouzNotification(String title, String body, Map<String, String> payload) async {
  var random = Random();
  if(payload['pictureNotification'] == null) {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: random.nextInt(225),
          channelKey: channelKey,
          title:title,
          body:body,
          notificationLayout: body.length > 25 ? NotificationLayout.BigText: NotificationLayout.Default,
          payload: payload,
          displayOnBackground: true,
          backgroundColor: backgroundColor,
        )
    );
  } else {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: random.nextInt(225),
          channelKey: channelKey,
          title:title,
          body:body,
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: payload['pictureNotification'],
          largeIcon: payload['pictureNotification'],
          payload: payload,
          displayOnBackground: true,
          backgroundColor: backgroundColor,
        )
    );
  }

}


Future<void> cancelAllAwesomeNotification() async {
  await AwesomeNotifications().cancelAll();
  await AwesomeNotifications().setGlobalBadgeCounter(0);
}

class NotificationController {


  /// Use this method to detect when a new notification or a schedule is created
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    AwesomeNotifications().getGlobalBadgeCounter()
        .then((value) => AwesomeNotifications().setGlobalBadgeCounter(value - 1));
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future <void> onActionReceivedMethod(ReceivedAction notification) async {
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    AwesomeNotifications().getGlobalBadgeCounter()
        .then((value) => AwesomeNotifications().setGlobalBadgeCounter(value - 1));
    runApp(MyApp());
    if(notification.channelKey == channelKey && notification.payload!['room'] != null) {
      MyApp.navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) => LoadChat(key: UniqueKey(), room: notification.payload!['room'] ?? '')), (route) => route.isFirst);
    }
    else if(notification.channelKey == channelKey && notification.payload!['emitName'] == "innerhomepage") {
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(MenuDrawler.rootName, (route) => route.isFirst);
    }
    else if(notification.channelKey == channelKey && notification.payload!['emitName'] == "createvoyage") {
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(CreateTravel.rootName, (route) => route.isFirst);
    }
    else if(notification.channelKey == channelKey && notification.payload!['emitName'] == "innernotifications") {
      MyApp.navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) => Notifications()), (route) => route.isFirst);
    }
    else if(notification.channelKey == channelKey && notification.payload!['emitName'] == "innerwallet") {
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(WalletPage.rootName, (route) => route.isFirst);
    }
    else if(notification.channelKey == channelKey && notification.payload!['emitName'] == "innertravel") {
      MyApp.navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) => LoadTravel(key: UniqueKey(), travelId: notification.payload!['travelId'] ?? '')), (route) => route.isFirst);
    }
    else if(notification.channelKey == channelKey && notification.payload!['emitName'] == "innerevent") {
      MyApp.navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) => LoadEvent(key: UniqueKey(), eventId: notification.payload!['eventId'] ?? '')), (route) => route.isFirst);
    }
    else if(notification.channelKey == channelKey && notification.payload!['emitName'] == "innerdeals" && notification.payload!['room'] == null) {
      MyApp.navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) => LoadProduct(key: UniqueKey(), productId: notification.payload!['productId'] ?? '')), (route) => route.isFirst);
    }
  }
}