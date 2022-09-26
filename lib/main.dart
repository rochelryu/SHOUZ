import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'Constant/helper.dart';
import 'firebase_options.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:huawei_push/huawei_push.dart' as huawei;
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/route.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uni_links/uni_links.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:intl/date_symbol_data_local.dart';
import './MenuDrawler.dart';
import './OnBoarding.dart';
import './Pages/ChoiceHobie.dart';
import './Pages/CreateProfil.dart';
import './Pages/LoadHide.dart';
import './Pages/Login.dart';
import './Pages/Opt.dart';
import './ServicesWorker/WebSocketHelper.dart';
import 'Provider/AppState.dart';
import 'Provider/Notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var body = message.data['bodyNotif'].toString().trim() == "images" ? "${Emojis.art_framed_picture} Une image a été envoyé..." : message.data['bodyNotif'].toString().trim();
  body = message.data['bodyNotif'].toString().trim() == "audio" ? "${Emojis.person_symbol_speaking_head} Une note vocale a été envoyé..." : body;
  Map<String, String> data = message.data.map((key, value) => MapEntry(key, value.toString()));
  createShouzNotification(message.data['titreNotif'].toString().trim(), body, data);
}



void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  AwesomeNotifications().initialize(
      'resource://drawable/icon_notif',
      [NotificationChannel(
          icon: 'resource://drawable/icon_notif',
          channelKey: channelKey,
          channelName: channelName,
          channelDescription: channelDescription,
          defaultColor: backgroundColor,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          vibrationPattern: lowVibrationPattern
        ),
      ]);
  Intl.defaultLocale = 'fr_FR';
  initializeDateFormatting();


  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  final _messaging = FirebaseMessaging.instance;

  // 3. On iOS, this helps to take the user permissions
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
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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
        home: MyHomePage(title: 'Shouz', key: UniqueKey(), navigatorKey: navigatorKey,)
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  GlobalKey<NavigatorState> navigatorKey;
  MyHomePage({required Key key, required this.title, required this.navigatorKey}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AppState appState;
  IO.Socket? socket;
  int level = 15;
  User? client;
  ConsumeAPI consumeAPI = new ConsumeAPI();

  void _onHmsMessageReceived(huawei.RemoteMessage remoteMessage) async {
    // Called when a data message is received
    String? data = remoteMessage.data;
    final notification = remoteMessage.notification;
    print(data);
    print(notification);
    //String result = await huawei.Push.turnOnPush();
  }

  void _onHmsMessageReceiveError(Object error) {
    print(error);
    // Called when an error occurs while receiving the data message
  }

  @override
  void initState() {
    super.initState();
    //configOneSignal();
    FlutterNativeSplash.remove();
    initMessageStream();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if(!isAllowed) {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialogCustomForValidatePermissionNotification(
                    'Permission de Notifications',
                    "Shouz a besoin que vous lui accordiez la permission d'afficher vos notifications que vous alliez recevoir dans l'application.",
                    "D'accord",
                    ()=> AwesomeNotifications().requestPermissionToSendNotifications(),
                    context),
            barrierDismissible: false);
      }
    });
    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );


    getNewLevel();
    initializeSocket();
  }

  Future<void> initMessageStream() async {
    if (!mounted) {
      return;
    } else {
      if(Platform.isAndroid){
        if(await isHms()) {
          User user = await DBProvider.db.getClient();
          setState(() {
            client = user;
          });
          if(user.numero != "null") {
            getTokenForNotificationProvider();
          }
          await huawei.Push.registerBackgroundMessageHandler(_onHmsMessageReceived);
          huawei.Push.onMessageReceivedStream.listen(_onHmsMessageReceived, onError: _onHmsMessageReceiveError);
        } else {
          listenFirebase();
        }
      }
      else {
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
    if(mounted) {
      appState = Provider.of<AppState>(context, listen: false);

      if(message.data['room'] != null) {
        if(appState.getIdOldConversation != message.data['_id'] || appState.getIdOldConversation == '') {
          appState.setNumberNotif(appState.getNumberNotif + 1);
          _firebaseMessagingBackgroundHandler(message);
        }
      } else {
        appState.setNumberNotif(appState.getNumberNotif + 1);
        _firebaseMessagingBackgroundHandler(message);
      }
    }


  }



  void initializeSocket() async {
    socket = IO.io("$SERVER_ADDRESS/$NAME_SPACE", IO.OptionBuilder().setTransports(['websocket']).build());

    socket!.onConnect((data) async {
      if(mounted) {
        appState = Provider.of<AppState>(context, listen: false);
        appState.setSocket(socket!);


        final User getClient = await DBProvider.db.getClient();
        if(getClient.ident != "") {
          appState.setJoinConnected(getClient.ident);
        }
      }
    });
    socket!.on("reponseChangeProfil", (data) async {
      Fluttertoast.showToast(
          msg: 'Changé avec succès',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: colorSuccess,
          textColor: Colors.white,
          fontSize: 16.0
      );
    });



    socket!.on("MsToClient", (data) async {

      appState.updateLoadingToSend(false);
      if (appState.getIdOldConversation == data['_id']) {
        appState.setConversation(data);
        final User getClient = await DBProvider.db.getClient();
        if(getClient.name.trim() != data['author'].trim()) {
          appState.ackReadMessage(data['room']);
        }
      } else {
        // ici c'est incrémenté les notif uniquement quand c'est huawei car il ne reçoit pas les notif incrémenté de firebase
        if(Platform.isAndroid){
          if(await isHms()) {
            appState.setNumberNotif(appState.getNumberNotif + 1);
          }
        }
      }
    });

    socket!.on("ackReadMessageComeBack", (data) async {

      if (appState.getIdOldConversation == data['_id']) {
        appState.setConversation(data);
      }
    });

    socket!.on("receivedConversation", (data) async {
      //sample event

      if (data['etat'] == 'found') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        appState.setConversation(data['result']);
        appState.setIdOldConversation(data['result']['_id']);
        appState.ackReadMessage(data['result']['room']);
        await prefs.setString(data['result']['room'], jsonEncode(data['result']));
        if(client == null) {
          final User getClient = await DBProvider.db.getClient();
          setState(() {
            client = getClient;
          });
        }
      } else {
        appState.setConversation({});
        appState.setIdOldConversation('');
      }
    });
    socket!.on("receivedNotification", (data) async {
      if(data['withWallet']) {
        User newClient = await DBProvider.db.getClient();
        await DBProvider.db.updateClientWallet(data['wallet'], newClient.ident);
      }
      appState.setNumberNotif(data['totalNotif']);

    });

    socket!.on("agreePaiement", (data) async {
      await DBProvider.db.updateClient(data['recovery'], data['ident']);
      await DBProvider.db.updateClientWallet(data['wallet'], data['ident']);
    });

    socket!.on("insufficient balance", (data) {
      
      showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Insufficient balance', data, context),
              barrierDismissible: false);

    });

    socket!.on("roomCreated", (data) async {
        appState.updateLoadingToSend(false);
        appState.setConversation(data);
        appState.setIdOldConversation(data['_id']);

    });
    socket!.on("roomCreatedForNotification", (data) async {

      if(Platform.isAndroid){
        if(await isHms()) {
          appState.setNumberNotif(appState.getNumberNotif + 1);
        }
      }
    });
    socket!.on("typingResponse", (data) async {

      if (appState.getIdOldConversation == data['id']) {
        appState.updateTyping(data['typing'] as bool);
      }
    });

    socket!.on('disconnect', (_) {

      appState.deleteSocket();
    });

  }



  Future getNewLevel() async {
    try {
      int levelLocal = await getLevel();
      setState(() {
        level = levelLocal;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  void dispose() {
    AwesomeNotifications().dispose();
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
            }
            else {
              return FutureBuilder<String?>(
                  future: getInitialLink(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadHide(key: UniqueKey());
                    }
                    final linkInitial = snapshot.data ?? '';
                    if(linkInitial.isEmpty) {
                      return (socket != null) ? levelUser(level) : LoadHide(key: UniqueKey(),);
                    } else {
                      final arrayInfo = linkInitial.split('/');
                      final idElement = arrayInfo.last;
                      final categorie = arrayInfo[arrayInfo.length - 2];
                      return loadDeepLink(categorie, idElement);
                    }
                  });
            }
          }),
    );
    //return (socket != null) ? levelUser(level) : LoadHide(key: UniqueKey(),);
  }

  Widget levelUser(int level) {
    switch (level) {
      case 0:
        return OnBoarding();
      case 1:
        return Login();
      case 2:
        return Otp(key: UniqueKey());
      case 3:
        return CreateProfil();
      case 4:
        return ChoiceHobie();
      case 5:
        return MenuDrawler();
      default:
        return LoadHide(key: UniqueKey());
    }
  }

  Widget loadDeepLink(String categorie, String id) {

    switch (categorie) {
      case 'deals':
        return LoadProduct(key: UniqueKey(), productId: id);
      case 'event':
        return LoadEvent(key: UniqueKey(), eventId: id);
      case 'new':
        return LoadNew(key: UniqueKey(), actualityId: id);
      case 'travel':
        return LoadTravel(key: UniqueKey(), travelId: id);
      default:
        return LoadHide(key: UniqueKey());
    }
  }
}
