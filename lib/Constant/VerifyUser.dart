import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

class VerifyUser extends StatefulWidget {
  bool createPass;
  var redirect;
  VerifyUser({Key key, this.redirect, this.createPass}) : super(key: key);

  @override
  _VerifyUserState createState() => _VerifyUserState();
}

class _VerifyUserState extends State<VerifyUser> {
  bool createPass;
  bool isError = false;
  List<int> keyTouch = [1, 2, 3, 4, 5, 6, 7, 8, 9, 22, 0, 33];
  List<bool> keyContainer = [false, false, false, false];
  String password = '';
  String message = '';
  String passwordSave = '';
  String pin = '';

  Future getNewPin() async {
    try {
      String pin = await prefix0.getPin();
      setState(() {
        this.pin = pin;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewPin();
    setState(() {
      createPass = widget.createPass;
      if (createPass) {
        message = "Créer un mot de passe pour securiser tout vos achats";
      } else {
        message = "Veuillez entrer votre mot de passe pour finaliser l'achat";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prefix0.backgroundColor,
      appBar: AppBar(
        backgroundColor: prefix0.backgroundColor,
        elevation: 0,
        title: Text('Vérification'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 8,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("images/logos.png"),
                          fit: BoxFit.contain)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    message,
                    style: (!isError)
                        ? prefix0.Style.titleInSegment()
                        : prefix0.Style.titleInSegmentInTypeError(),
                    textAlign: TextAlign.center,
                  ),
                ),
                // createPass ? SizedBox(width: 10):Icon(Icons.fingerprint, color: Colors.white, size: 30),
                Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: keyContainer[0]
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(color: Colors.white, width: 1.0),
                            boxShadow: keyContainer[0]
                                ? [
                                    BoxShadow(
                                        blurRadius: 10.0,
                                        offset: Offset(3.0, 6.0),
                                        color: Colors.black12)
                                  ]
                                : [
                                    BoxShadow(
                                        blurRadius: 0.0,
                                        offset: Offset(0.0, 0.0),
                                        color: Colors.black12)
                                  ]),
                      ),
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: keyContainer[1]
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(color: Colors.white, width: 1.0),
                            boxShadow: keyContainer[1]
                                ? [
                                    BoxShadow(
                                        blurRadius: 10.0,
                                        offset: Offset(3.0, 6.0),
                                        color: Colors.black12)
                                  ]
                                : [
                                    BoxShadow(
                                        blurRadius: 0.0,
                                        offset: Offset(0.0, 0.0),
                                        color: Colors.black12)
                                  ]),
                      ),
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: keyContainer[2]
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(color: Colors.white, width: 1.0),
                            boxShadow: keyContainer[2]
                                ? [
                                    BoxShadow(
                                        blurRadius: 10.0,
                                        offset: Offset(3.0, 6.0),
                                        color: Colors.black12)
                                  ]
                                : [
                                    BoxShadow(
                                        blurRadius: 0.0,
                                        offset: Offset(0.0, 0.0),
                                        color: Colors.black12)
                                  ]),
                      ),
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: keyContainer[3]
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(color: Colors.white, width: 1.0),
                            boxShadow: keyContainer[3]
                                ? [
                                    BoxShadow(
                                        blurRadius: 10.0,
                                        offset: Offset(3.0, 6.0),
                                        color: Colors.black12)
                                  ]
                                : [
                                    BoxShadow(
                                        blurRadius: 0.0,
                                        offset: Offset(0.0, 0.0),
                                        color: Colors.black12)
                                  ]),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 5.0,
                  childAspectRatio: 1.3),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemCount: keyTouch.length,
              itemBuilder: (context, index) {
                if (index != 9 && index != 11) {
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide.none,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          (password.length < 4)
                              ? password += keyTouch[index].toString()
                              : password = password;
                        });
                        switch (password.length) {
                          case 1:
                            setState(() {
                              keyContainer[0] = true;
                            });
                            break;
                          case 2:
                            setState(() {
                              keyContainer[1] = true;
                            });
                            break;
                          case 3:
                            setState(() {
                              keyContainer[2] = true;
                            });
                            break;
                          case 4:
                            setState(() {
                              keyContainer[3] = true;
                            });
                            break;
                          default:
                            setState(() {
                              keyContainer = [false, false, false, false];
                              password = '';
                            });
                            break;
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border:
                                Border.all(color: Colors.white, width: 1.0)),
                        child: Center(
                            child: Text(keyTouch[index].toString(),
                                style: prefix0.Style.titre(25))),
                      ),
                    ),
                  );
                } else if (index == 9) {
                  if (password.length == 4) {
                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () async {
                          if (createPass) {
                            print(password);
                            setState(() {
                              passwordSave = password;
                              keyContainer = [false, false, false, false];
                              password = '';
                              createPass = false;
                              message = "Veuillez confirmer votre mot de passe";
                              isError = false;
                            });
                          } else {
                            if (passwordSave != '') {
                              if (password == passwordSave) {
                                prefix0.setPin(passwordSave);
                                //update server-side
                                final info = await new ConsumeAPI()
                                    .changePin(pin: passwordSave);
                                User newClient =
                                    await DBProvider.db.getClient();
                                Navigator.pushNamed(context, widget.redirect);
                              } else {
                                HapticFeedback.vibrate();
                                setState(() {
                                  keyContainer = [false, false, false, false];
                                  password = '';
                                  message =
                                      "Erreur du mot de passe de confirmation";
                                  isError = true;
                                });
                              }
                            } else {
                              if (password == pin) {
                                Navigator.pushNamed(context, widget.redirect);
                              } else {
                                HapticFeedback.vibrate();
                                setState(() {
                                  keyContainer = [false, false, false, false];
                                  password = '';
                                  message = "Mot de passe incorrect";
                                  isError = true;
                                });
                              }
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  Border.all(color: Colors.white, width: 1.0)),
                          child: Center(
                              child: Icon(Icons.check,
                                  color: Colors.white, size: 25)),
                        ),
                      ),
                    );
                  }
                  return SizedBox(width: 10);
                } else {
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide.none,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          (password.isEmpty)
                              ? password = password
                              : password =
                                  password.substring(0, password.length - 1);
                        });
                        switch (password.length) {
                          case 0:
                            setState(() {
                              keyContainer[0] = false;
                            });
                            break;
                          case 1:
                            setState(() {
                              keyContainer[1] = false;
                            });
                            break;
                          case 2:
                            setState(() {
                              keyContainer[2] = false;
                            });
                            break;
                          case 3:
                            setState(() {
                              keyContainer[3] = false;
                            });
                            break;
                          default:
                            setState(() {
                              keyContainer = [false, false, false, false];
                              password = '';
                            });
                            break;
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border:
                                Border.all(color: Colors.white, width: 1.0)),
                        child: Center(
                            child: Icon(Icons.backspace,
                                color: Colors.white, size: 25)),
                      ),
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
