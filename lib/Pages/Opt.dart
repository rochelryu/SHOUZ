import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shouz/Constant/PageTransition.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/Login.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';

import './CreateProfil.dart';
import '../MenuDrawler.dart';

class Otp extends StatefulWidget {
  static String rootName = '/otp';

  const Otp({
    required Key key,
  }) : super(key: key);

  @override
  _OtpState createState() => new _OtpState();
}

class _OtpState extends State<Otp> with SingleTickerProviderStateMixin {
  ConsumeAPI consumeAPI = new ConsumeAPI();
  User? newClient;
  // Constants
  final int time = 60;
  late AnimationController _controller;

  // Variables
  late Size _screenSize;
  int? _currentDigit;
  int? _firstDigit;
  int? _secondDigit;
  int? _thirdDigit;
  int? _fourthDigit;
  int? _fiveDigit;
  int? _sixDigit;

  late Timer timer;
  late int totalTimeInSeconds;
  late bool _hideResendButton;
  bool loadVerification =false;
  bool loadRequest = false;

  String userName = "";
  bool didReadNotifications = false;
  int unReadNotificationsCount = 0;

// Returns "Appbar"
  get _getAppbar {
    return new AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: new InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: new Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

// Return "Verification Code" label
  get _getVerificationCodeLabel {
    return new Text(
      "Verification Code",
      textAlign: TextAlign.center,
      style: new TextStyle(
          fontSize: 28.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: "Montserrat"),
    );
  }

// Return "Email" label
  get _getEmailLabel {
    return new Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: new Text(
        "Veuillez entrer le code de confirmation qui a été envoyé au ${newClient == null ? '': newClient!.numero}",
        textAlign: TextAlign.center,
        style: new TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat"),
      ),
    );
  }

// Return "OTP" input field
  get _getInputField {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _otpTextField(_firstDigit),
        _otpTextField(_secondDigit),
        _otpTextField(_thirdDigit),
        _otpTextField(_fourthDigit),
        _otpTextField(_fiveDigit),
        _otpTextField(_sixDigit),
      ],
    );
  }

// Returns "OTP" input part
  get _getInputPart {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _getVerificationCodeLabel,
        _getEmailLabel,
        _getInputField,
        _hideResendButton ? _getTimerText : _getResendButton,
        _getOtpKeyboard
      ],
    );
  }

// Returns "Timer" label
  get _getTimerText {
    return Container(
      height: 32,
      child: new Offstage(
        offstage: !_hideResendButton,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(Icons.access_time, color: Colors.white),
            new SizedBox(
              width: 5.0,
            ),
            OtpTimer(_controller, 15.0, Colors.white)
          ],
        ),
      ),
    );
  }

// Returns "Resend" button
  get _getResendButton {
    return new ElevatedButton(
      style: raisedButtonStyle,
      child: new Container(
        height: 42,
        width: 150,
        alignment: Alignment.center,
        child: new Text(
          "Renvoyer le code",
          style:
              new TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      onPressed: () async {
        setState(() {
          _hideResendButton = true;
          totalTimeInSeconds = time;
        });
        _startCountdown();
        final user = await consumeAPI.resendRecovery();
        if (user['etat'] == 'found') {
          await DBProvider.db.delClient();
          await DBProvider.db.newClient(user['user']);
          Fluttertoast.showToast(
              msg: "Code renvoyé veuillez verifier",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: colorSuccess,
              textColor: Colors.white,
              fontSize: 16.0
          );

        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
              barrierDismissible: false);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (builder) => Login()));
        }
        // Resend you OTP via API or anything
      },
    );
  }

// Returns "Otp" keyboard
  get _getOtpKeyboard {
    return new Container(
        height: _screenSize.width - 80,
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                      }),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "4",
                      onPressed: () {
                        _setCurrentDigit(4);
                      }),
                  _otpKeyboardInputButton(
                      label: "5",
                      onPressed: () {
                        _setCurrentDigit(5);
                      }),
                  _otpKeyboardInputButton(
                      label: "6",
                      onPressed: () {
                        _setCurrentDigit(6);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "7",
                      onPressed: () {
                        _setCurrentDigit(7);
                      }),
                  _otpKeyboardInputButton(
                      label: "8",
                      onPressed: () {
                        _setCurrentDigit(8);
                      }),
                  _otpKeyboardInputButton(
                      label: "9",
                      onPressed: () {
                        _setCurrentDigit(9);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardActionButton(
                      label: loadRequest ? LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2) :Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 32.0,
                      ),
                      onPressed: () async {
                        List<int> beta = [
                          _firstDigit!,
                          _secondDigit!,
                          _thirdDigit!,
                          _fourthDigit!,
                          _fiveDigit!,
                          _sixDigit!,
                        ];
                        if (beta.join("").indexOf('null') == -1 && !loadRequest) {
                          setState(() {
                            loadRequest = true;
                          });
                          final verify = await consumeAPI.verifyOtp(beta.join(""));
                          setState(() {
                            loadRequest = false;
                          });
                          if (verify['etat'] == 'found') {
                            if (newClient!.name == '' ||
                                newClient!.inscriptionIsDone == 0) {
                              setLevel(3);
                              Navigator.push(
                                  context, ScaleRoute(widget: CreateProfil()));
                            } else {
                              setLevel(5);
                              final user = await consumeAPI.updateRecovery();
                              if (user['etat'] == 'found') {
                                await DBProvider.db.delClient();
                                await DBProvider.db.newClient(user['user']);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        dialogCustomError(
                                            'De retour',
                                            'Nous sommes heureux de vous revoir ${newClient!.name}',
                                            context),
                                    barrierDismissible: false);
                                Navigator.of(context).pushNamedAndRemoveUntil(MenuDrawler.rootName, (Route<dynamic> route) => false);
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) => dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
                                    barrierDismissible: false);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (builder) => Login()));
                              }

                            }
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    dialogCustomError(
                                        'Erreur',
                                        verify['error'],
                                        context),
                                barrierDismissible: false);
                          }
                        }
                      }),
                  /*new SizedBox(
                  width: 80.0,
                ),*/
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  _otpKeyboardActionButton(
                      label: new Icon(
                        Icons.backspace,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_sixDigit != null) {
                            _sixDigit = null;
                          } else if (_fiveDigit != null) {
                            _fiveDigit = null;
                          } else if (_fourthDigit != null) {
                            _fourthDigit = null;
                          } else if (_thirdDigit != null) {
                            _thirdDigit = null;
                          } else if (_secondDigit != null) {
                            _secondDigit = null;
                          } else if (_firstDigit != null) {
                            _firstDigit = null;
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
  }

// Overridden methods
  @override
  void initState() {
    totalTimeInSeconds = time;

    super.initState();
    loadInfo();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: time))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              setState(() {
                _hideResendButton = !_hideResendButton;
              });
            }
          });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
    _startCountdown();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  loadInfo() async {
    final user = await DBProvider.db.getClient();
    setState(() {
      newClient = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _getAppbar,
      backgroundColor: backgroundColor,
      body: Container(
        width: _screenSize.width,
//        padding: new EdgeInsets.only(bottom: 16.0),
        child: _getInputPart,
      ),
    );
  }

// Returns "Otp custom text field"
  Widget _otpTextField(int? digit) {
    return new Container(
      width: 25.0,
      height: 45.0,
      alignment: Alignment.center,
      child: new Text(
        digit != null ? digit.toString() : "",
        style: new TextStyle(
          fontSize: 30.0,
          color: Colors.white,
        ),
      ),
      decoration: BoxDecoration(
//            color: Colors.grey.withOpacity(0.4),
          border: Border(
              bottom: BorderSide(
        width: 2.0,
        color: Colors.white,
      ))),
    );
  }

// Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton({required String label, required VoidCallback onPressed}) {
    return new Material(
      color: Colors.transparent,
      child: new InkWell(
        onTap: onPressed,
        borderRadius: new BorderRadius.circular(40.0),
        child: new Container(
          height: 80.0,
          width: 80.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: new Center(
            child: new Text(
              label,
              style: new TextStyle(
                fontSize: 30.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

// Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({required Widget label, required VoidCallback onPressed}) {
    return new InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40.0),
      child: Container(
        height: 80.0,
        width: 80.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: label,
        ),
      ),
    );
  }

// Current digit
  void _setCurrentDigit(int i) {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;
      } else if (_fiveDigit == null) {
        _fiveDigit = _currentDigit;
      } else if (_sixDigit == null) {
        _sixDigit = _currentDigit;
      }
    });
  }

  Future<Null> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  void clearOtp() {
    _sixDigit = null;
    _fiveDigit = null;
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;
    setState(() {});
  }
}

class OtpTimer extends StatelessWidget {
  final AnimationController controller;
  double fontSize;
  Color timeColor = Colors.black;

  OtpTimer(this.controller, this.fontSize, this.timeColor);

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Duration get duration {
    Duration duration = controller.duration!;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, child) {
          return Text(
            timerString,
            style: TextStyle(
                fontSize: fontSize,
                color: timeColor,
                fontWeight: FontWeight.w600),
          );
        });
  }
}
