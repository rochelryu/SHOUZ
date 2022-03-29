import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/route.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uni_links/uni_links.dart';
import 'package:shouz/Constant/widget_common.dart';

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
      'resource://drawable/logo_notification',
      [NotificationChannel(
          channelKey: channelKey,
          channelName: channelName,
          channelDescription: channelDescription,
          defaultColor: backgroundColor,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          soundSource: 'resource://raw/filling'
        ),
      ]);
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
    return ChangeNotifierProvider<AppState>(
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
  @override
  void initState() {
    super.initState();
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

  void initializeSocket() async {
    socket = IO.io("$SERVER_ADDRESS/$NAME_SPACE", IO.OptionBuilder().setTransports(['websocket']).build());

    socket!.onConnect((data) async {
      appState = Provider.of<AppState>(context, listen: false);

      appState.setSocket(socket!);

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
      //sample event
      if (appState.getIdOldConversation == data['_id']) {
        appState.setConversation(data);
        if(client != null && client!.name.trim() != data['author'].trim()) {

          appState.ackReadMessage(data['room']);
        }
      } else if(appState.getIdOldConversation == '') {
        appState.setConversation(data);
        appState.setNumberNotif(appState.getNumberNotif + 1);
        final title = "${data['author']} vient de vous ecrire pour un deals";
        final content = data['content'][data['content'].length - 1];
        var body = content['image'] != '' && content['content'] == "" ? "${Emojis.art_framed_picture} Une image a été envoyé..." : content['content'];
        body = content['image'] != '' && content['image'].indexOf('.wav') != -1 ? "${Emojis.person_symbol_speaking_head} Une note vocale a été envoyé..." : body;
        createShouzNotification(title,body, {'room': data['room']});
      } else {
        appState.setNumberNotif(appState.getNumberNotif + 1);
        final title = "${data['author']} vient de vous ecrire pour un deals";
        final content = data['content'][data['content'].length - 1];
        var body = content['image'] != '' && content['content'] == "" ? "${Emojis.art_framed_picture} Une image a été envoyé..." : content['content'];
        body = content['image'] != '' && content['image'].indexOf('.wav') != -1 ? "${Emojis.person_symbol_speaking_head} Une note vocale a été envoyé..." : body;
        createShouzNotification(title,body, {'room': data['room']});
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
        appState.setConversation(data['result']);
        appState.setIdOldConversation(data['result']['_id']);
        if(client == null) {
          final getClient = await DBProvider.db.getClient();
          setState(() {
            client = getClient;
          });
        }

        appState.ackReadMessage(data['result']['room']);
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
      //sample event
      User newClient = await DBProvider.db.getClient();
      if (newClient.ident == data['userIdScondary']) {
        // for user which have created the roomsConversation
        appState.setConversation(data);
        appState.setIdOldConversation(data['_id']);
      } else {
        appState.setNumberNotif(appState.getNumberNotif + 1);
        final title = "${data['author']} vient de vous ecrire pour un deals";
        final content = data['content'][data['content'].length - 1];
        var body = content['image'] != '' && content['content'] == "" ? "${Emojis.art_framed_picture} Une image a été envoyé..." : content['content'];
        body = content['image'] != '' && content['image'].indexOf('.wav') != -1 ? "${Emojis.person_symbol_speaking_head} Une note vocale a été envoyé..." : body;
        createShouzNotification(title,body, {'room': data['room']});
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


    //For AwesomeNotification
    socket!.on("innerdeals", (data) async {
      createShouzNotification(data['title'],data['content'], {'room': data['room']});
    });

    socket!.on("innernotifications", (data) async {
      createShouzNotification(data['title'],data['content'], {'roomAtReceive': data['roomAtReceive'], });
    });

    socket!.on("innerevent", (data) async {
      createShouzNotification(data['title'],data['content'], {'roomAtReceive': data['roomAtReceive'], 'eventId': data['eventId'] });
    });
    socket!.on("innerprofil", (data) async {
      createShouzNotification(data['title'],data['content'], {'roomAtReceive': data['roomAtReceive'], });
    });
    socket!.on("innertravel", (data) async {
      createShouzNotification(data['title'],data['content'], {'roomAtReceive': data['roomAtReceive'], 'travelId': data['travelId'] });
    });
    socket!.on("innerhomepage", (data) async {
      createShouzNotification(data['title'],data['content'], {'roomAtReceive': data['roomAtReceive'], });
    });
    socket!.on("createvoyage", (data) async {

      createShouzNotification(data['title'],data['content'], {'roomAtReceive': data['roomAtReceive'], });
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
    AwesomeNotifications().actionSink.close();
    AwesomeNotifications().createdSink.close();
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
