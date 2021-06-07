import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/PageTransition.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Utils/Database.dart';

import './CreateProfil.dart';
import '../MenuDrawler.dart';

class Otp extends StatefulWidget {
  final String email;
  final bool isGuestCheckOut;

  const Otp({
    Key key,
    /*@required */ this.email,
    this.isGuestCheckOut,
  }) : super(key: key);

  @override
  _OtpState createState() => new _OtpState();
}

class _OtpState extends State<Otp> with SingleTickerProviderStateMixin {
  // Constants
  final int time = 60;
  AnimationController _controller;

  // Variables
  Size _screenSize;
  int _currentDigit;
  int _firstDigit;
  int _secondDigit;
  int _thirdDigit;
  int _fourthDigit;

  Timer timer;
  int totalTimeInSeconds;
  bool _hideResendButton;

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
          // if(){
          //   exit(0);
          // } else {
          //   Navigator.pop(context);
          // }
        },
      ),
      centerTitle: true,
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
        "Veuillez entrer le code de confirmation qui a été envoyé à votre numero",
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
      ],
    );
  }

// Returns "OTP" input part
  get _getInputPart {
    return new Column(
      mainAxisSize: MainAxisSize.max,
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
    return new RaisedButton(
      color: colorText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
        User newClient = await DBProvider.db.getClient();
        print(newClient.recovery);
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
                      label: new Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 32.0,
                      ),
                      onPressed: () async {
                        List<int> beta = [
                          _firstDigit,
                          _secondDigit,
                          _thirdDigit,
                          _fourthDigit
                        ];
                        if (beta.join("").indexOf('null') == -1) {
                          User newClient = await DBProvider.db.getClient();
                          if (newClient.recovery == beta.join("")) {
                            if (newClient.name == '' ||
                                newClient.inscriptionIsDone == 0) {
                              setLevel(3);
                              Navigator.push(
                                  context, ScaleRoute(widget: CreateProfil()));
                            } else {
                              setLevel(5);
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      DialogCustomError(
                                          'De retour',
                                          'Nous sommes heureux de vous revoir ${newClient.name}',
                                          context),
                                  barrierDismissible: false);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (builder) => MenuDrawler()));
                            }
                          } else {
                            print(newClient.recovery);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    DialogCustomError(
                                        'Erreur',
                                        'Ce code ne correspond pas à celui donné par SHOUZ',
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
                          if (_fourthDigit != null) {
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

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: _getAppbar,
      backgroundColor: backgroundColor,
      body: new Container(
        width: _screenSize.width,
//        padding: new EdgeInsets.only(bottom: 16.0),
        child: _getInputPart,
      ),
    );
  }

  Widget DialogCustomError(String title, String message, BuildContext context) {
    bool isIos = Platform.isIOS;
    return isIos
        ? new CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          )
        : new AlertDialog(
            title: Text(title),
            content: Text(message),
            elevation: 20.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            actions: <Widget>[
              FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          );
  }

// Returns "Otp custom text field"
  Widget _otpTextField(int digit) {
    return new Container(
      width: 35.0,
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
  Widget _otpKeyboardInputButton({String label, VoidCallback onPressed}) {
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
  _otpKeyboardActionButton({Widget label, VoidCallback onPressed}) {
    return new InkWell(
      onTap: onPressed,
      borderRadius: new BorderRadius.circular(40.0),
      child: new Container(
        height: 80.0,
        width: 80.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: new Center(
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

        var otp = _firstDigit.toString() +
            _secondDigit.toString() +
            _thirdDigit.toString() +
            _fourthDigit.toString();
        // Verify your otp by here. API call
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
    Duration duration = controller.duration * controller.value;
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Duration get duration {
    Duration duration = controller.duration;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) {
          return new Text(
            timerString,
            style: new TextStyle(
                fontSize: fontSize,
                color: timeColor,
                fontWeight: FontWeight.w600),
          );
        });
  }
}
