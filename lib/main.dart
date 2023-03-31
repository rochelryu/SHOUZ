import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Pages/Login.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'Constant/helper.dart';
import 'Provider/AppState.dart';
import 'Utils/Database.dart';
import 'Utils/network_util.dart';
import 'firebase_options.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huawei_push/huawei_push.dart' as huawei;
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/route.dart';
import 'package:shouz/Models/User.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uni_links/uni_links.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:intl/date_symbol_data_local.dart';
import './MenuDrawler.dart';
import './OnBoarding.dart';

import './Pages/LoadHide.dart';
import 'Provider/Notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (message.data['bodyNotif'] != null) {
    var body = message.data['bodyNotif'].toString().trim() == "images"
        ? "${Emojis.art_framed_picture} Une image a été envoyé..."
        : message.data['bodyNotif'].toString().trim();
    body = message.data['bodyNotif'].toString().trim() == "audio"
        ? "${Emojis.person_symbol_speaking_head} Une note vocale a été envoyé..."
        : body;
    Map<String, String> data =
        message.data.map((key, value) => MapEntry(key, value.toString()));

    createShouzNotification(
        message.data['titreNotif'].toString().trim(), body, data);
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  AwesomeNotifications().initialize('resource://drawable/icon_notif', [
    NotificationChannel(
        icon: 'resource://drawable/icon_notif',
        channelKey: channelKey,
        channelName: channelName,
        channelDescription: channelDescription,
        defaultColor: backgroundColor,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        groupAlertBehavior: GroupAlertBehavior.Children,
        channelShowBadge: true,
        playSound: true,
        defaultRingtoneType: DefaultRingtoneType.Ringtone,
        vibrationPattern: lowVibrationPattern),
  ]);
  Intl.defaultLocale = 'fr_FR';
  initializeDateFormatting();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final _messaging = FirebaseMessaging.instance;

  await _messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: backgroundColor,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState?>(
      create: (_) => AppState(),
      lazy: false,
      child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Shouz',
          initialRoute: '/',
          routes: routes,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: backgroundColor,
              primaryColorDark: Colors.blue),
          home: MyHomePage(
            title: 'Shouz',
            key: UniqueKey(),
            navigatorKey: navigatorKey,
          )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  GlobalKey<NavigatorState> navigatorKey;
  MyHomePage(
      {required Key key, required this.title, required this.navigatorKey})
      : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  AppState? appState;
  IO.Socket? socket;
  SharedPreferences? prefs;
  int level = 15;
  User? client;
  String idOldConversation = "";
  ConsumeAPI consumeAPI = new ConsumeAPI();

  void _onHmsMessageReceived(huawei.RemoteMessage remoteMessage) async {
    final dataString = remoteMessage.data ?? "";
    final data = jsonDecode(dataString);
    if (data['room'] != null) {
      if (appState?.getIdOldConversation != data['_id'] ||
          appState?.getIdOldConversation == '') {
        appState?.setNumberNotif(appState?.getNumberNotif ?? 0 + 1);
        huaweiMessagingBackgroundHandler(data);
      }
    } else {
      appState?.setNumberNotif(appState?.getNumberNotif ?? 0 + 1);
      huaweiMessagingBackgroundHandler(data);
    }
  }

  void _onHmsMessageReceiveError(Object error) {
    print(error);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) {
      switch (state) {
        case AppLifecycleState.resumed:
          if (client?.ident != "" && appState != null) {
            appState?.setJoinConnected(client?.ident ?? "");
          }
          if (appState != null &&
              idOldConversation != "" &&
              appState?.getConversationGetter['room'] != null &&
              appState?.getConversationGetter['author'] != null &&
              client?.name.trim() !=
                  appState?.getConversationGetter['author'].trim()) {
            appState?.ackReadMessage(appState?.getConversationGetter['room']);
          }
          break;
        case AppLifecycleState.inactive:
          if (appState != null && appState?.getIdOldConversation != "") {
            idOldConversation = appState?.getIdOldConversation ?? "";
            appState?.setIdOldConversation('');
          }
          break;
        default:
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    WidgetsBinding.instance.addObserver(this);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialogCustomForValidatePermissionNotification(
                    'Permission de Notifications',
                    "Shouz a besoin que vous lui accordiez la permission d'afficher vos notifications que vous alliez recevoir dans l'application.",
                    "D'accord",
                    () => AwesomeNotifications()
                        .requestPermissionToSendNotifications(),
                    context),
            barrierDismissible: false);
      }
    });
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
    initMessageStream();
    WidgetsBinding.instance.addObserver(this);
    appState = Provider.of<AppState>(context, listen: false);
    getNewLevel();
  }

  Future<void> initMessageStream() async {
    if (!mounted) {
      return;
    } else {
      if (Platform.isAndroid) {
        if (await isHms()) {
          huawei.Push.onMessageReceivedStream.listen(_onHmsMessageReceived,
              onError: _onHmsMessageReceiveError);
        } else {
          listenFirebase();
        }
      } else {
        listenFirebase();
      }
    }
  }

  void listenFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onMessage.listen((message) {
      firebaseMessagingInOpenHandler(message);
    });
  }

  Future<void> firebaseMessagingInOpenHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (mounted) {
      if (message.data['room'] != null) {
        if (appState?.getIdOldConversation != message.data['_id'] ||
            appState?.getIdOldConversation == '') {
          appState?.setNumberNotif(appState?.getNumberNotif ?? 0 + 1);
          _firebaseMessagingBackgroundHandler(message);
        }
      } else {
        appState?.setNumberNotif(appState?.getNumberNotif ?? 0 + 1);
        _firebaseMessagingBackgroundHandler(message);
      }
    }
  }

  Future getNewLevel() async {
    try {
      int levelLocal = await getLevel();
      User user = await DBProvider.db.getClient();
      await getTokenForNotificationProvider(user.numero != 'null');
      prefs = await SharedPreferences.getInstance();
      setState(() {
        level = levelLocal;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<String?>(
          stream: linkStream,
          builder: (context, streamSnapshot) {
            final link = streamSnapshot.data ?? '';
            if (link.isNotEmpty) {
              final arrayInfo = link.split('/');
              final idElement = arrayInfo.last;
              final categorie = arrayInfo[arrayInfo.length - 2];
              return loadDeepLink(categorie, idElement);
            } else {
              return FutureBuilder<String?>(
                  future: getInitialLink(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final linkInitial = snapshot.data ?? '';
                      if (linkInitial.isEmpty) {
                        return (appState?.getSocketIO != null)
                            ? levelUser(level)
                            : LoadHide(
                                key: UniqueKey(),
                              );
                      } else {
                        final arrayInfo = linkInitial.split('/');
                        final idElement = arrayInfo.last;
                        final categorie = arrayInfo[arrayInfo.length - 2];
                        return loadDeepLink(categorie, idElement);
                      }
                    } else {
                      return LoadHide(key: UniqueKey());
                    }
                  });
            }
          }),
    );
  }

  Widget levelUser(int level) {
    switch (level) {
      case 0:
        return OnBoarding();
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
        return MenuDrawler();
      default:
        return LoadHide(key: UniqueKey());
    }
  }

  Widget loadDeepLink(String categorie, String id) {
    switch (categorie) {
      case 'deals':
        return LoadProduct(
          key: UniqueKey(),
          productId: id,
          doubleComeBack: 1,
        );
      case 'event':
        return LoadEvent(key: UniqueKey(), eventId: id);
      case 'new':
        return LoadNew(key: UniqueKey(), actualityId: id);
      case 'travel':
        return LoadTravel(key: UniqueKey(), travelId: id);
      case 'follow':
        prefs!.setString("codeSponsor", id);
        return Login();
      default:
        return LoadHide(key: UniqueKey());
    }
  }
}
