import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/Checkout.dart';
import 'package:shouz/Pages/Setting.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import './MenuDrawler.dart';
import './OnBoarding.dart';
import './Pages/ChoiceHobie.dart';
import './Pages/CreateProfil.dart';
import './Pages/LoadHide.dart';
import './Pages/Login.dart';
import './Pages/Opt.dart';
import './ServicesWorker/WebSocketHelper.dart';
import 'Pages/ResultSubscribeForfait.dart';
import 'Provider/AppState.dart';

void main() {
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
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      lazy: false,
      child: MaterialApp(
        title: 'Shouz',
        initialRoute: '/',
        routes: {
          '/login': (context) => Login(),
          '/otp': (context) => Otp(),
          '/createProfil': (context) => CreateProfil(),
          '/menuDrawler': (context) => MenuDrawler(),
          '/choiceHobie': (context) => ChoiceHobie(),
          '/checkout': (context) => Checkout(),
          '/setting': (context) => new Setting(),
          '/resultSubscribeForfait': (context) => new ResultSubscribeForfait(),
        },
        theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: backgroundColor,
            primaryColorDark: Colors.blue),
        home: MyHomePage(title: 'Shouz'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AppState appState;
  IO.Socket socket;
  int level = 15;
  AudioPlayer audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    getNewLevel();
    initializeSocket();
  }

  initializeNotification() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.pushNamed(context, '/checkout');
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.pushNamed(context, '/checkout');
            },
          )
        ],
      ),
    );
  }

  // Future _showNotification(
  //   FlutterLocalNotificationsPlugin notification,
  // );
  void initializeSocket() async {
    socket = IO.io("$SERVER_ADDRESS/$NAME_SPACE", <String, dynamic>{
      'transports': ['websocket'],
    });
    socket.on('connect', (data) async {
      print("connected...");
      appState = Provider.of<AppState>(context, listen: false);
      appState.setSocket(socket);
      if (level == 5) {
        final client = await DBProvider.db.getClient();
        socket.emit('loadNotif', [client.ident]);
      }
    });
    socket.on("reponseChangeProfil", (data) async {
      //sample event
      print('change avec success');
    });
    socket.on("MsToClient", (data) async {
      //sample event
      print('ici hein ${appState.getIdOldConversation} == ${data['_id']}');
      if (appState.getIdOldConversation == data['_id'] ||
          appState.getIdOldConversation == '') {
        appState.setConversation(data);
      } else {
        print(
            "${data['author']} vient de vous ecrire pour un deals allez Voir");
      }
    });
    socket.on("receivedConversation", (data) {
      //sample event
      print("receivedConversation ${data['etat']}");
      if (data['etat'] == 'found') {
        appState.setConversation(data['result']);
        appState.setIdOldConversation(data['result']['_id']);
      }
    });
    socket.on("receivedNotification", (data) {
      //sample event
      print("receivedNotification ${data}");
      audioPlayer.play(
          "https://drive.google.com/file/d/1IlTjVTnsUTjGNA2jaAjm1SrXxp4VLn7K/view");
      appState.setNumberNotif(data);
    });
    socket.on("roomCreated", (data) async {
      //sample event
      User newClient = await DBProvider.db.getClient();
      if (newClient.ident == data['userIdScondary']) {
        // for user which have created the roomsConversation
        appState.setConversation(data);
        appState.setIdOldConversation(data['_id']);
      } else {
        if (appState.getIdOldConversation == '') {
          // for user which have created the roomsConversation
          appState.setConversation(data);
          appState.setIdOldConversation(data['_id']);
          appState.setNumberNotif(appState.getNumberNotif + 1);
          print(
              "${data['author']} vient de vous ecrire pour un deals allez Voir");
        } else {
          appState.setNumberNotif(appState.getNumberNotif + 1);
          print("${data['author']} vient de vous ecrire pour un deals");
        }
      }
    });
    socket.on("typingResponse", (data) async {
      //sample event
      User newClient = await DBProvider.db.getClient();
      print('${data} ok');
      if (newClient.ident != data['destinate'] &&
          appState.getIdOldConversation == data['id']) {
        // for user which have created the roomsConversation
        appState.updateTyping(data['typing'] as bool);
        // print('${data['destinate']} est entrain de write');
      }
    });
    socket.on("socket_info_connected", (data) {
      //sample event
      print("socket_info_connected $data");
    });
    socket.on('disconnect', (_) => print('disconnect'));
    //socket.connect();
  }

  Future getNewLevel() async {
    try {
      int level = await getLevel();
      setState(() {
        this.level = level;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return (socket != null) ? LevelUser(level) : LoadHide();
  }

  Widget LevelUser(int level) {
    switch (level) {
      case 0:
        return OnBoarding();
        break;
      case 1:
        return Login();
        break;
      case 2:
        return Otp();
        break;
      case 3:
        return CreateProfil();
        break;
      case 4:
        return ChoiceHobie();
        break;
      case 5:
        return MenuDrawler();
        break;
      default:
        return LoadHide();
        break;
    }
  }
}
