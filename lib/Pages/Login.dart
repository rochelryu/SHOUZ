import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/Opt.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('Format de Numero incorrecte'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  User user;
  String numero = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: prefix0.backgroundColor,
      body: new GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.46,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Card(
                      elevation: 6.0,
                      color: prefix0.backgroundColorSec,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)
                      ),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0)
                        ),
                        child: Center(
                          child: Image.asset("images/logos.png", fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12.0),
                      child: Text("Vous devez vous enregistrer par votre numero, un code de confirmation vous sera envoyé pour confirmer votre identité", style: prefix0.Style.titre(13.0), textAlign: TextAlign.center,),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("+225", style: prefix0.Style.titre(20)),
                          SizedBox(width: 20.0),
                          Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width / 1.8,
                            padding: EdgeInsets.only(left: 30.0),
                            decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(30.0)
                            ),
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "01 23 45 67",
                                hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                              ),
                              onChanged: (text){
                                setState(() {
                                  numero = text;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.53,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      color: prefix0.colorText,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                      ),
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width/1.45,
                        child: Center(
                          child: Text("S'enregistrer", style: prefix0.Style.titre(18)),
                        ),
                      ),
                      onPressed: () async {
                        if(numero.length == 10) {
                            final res = await ConsumeAPI().signin(numero, '+225');
                            setState(() {
                              user = res['user'];
                            });
                            await DBProvider.db.delClient();
                            await DBProvider.db.delAllHobies();
                            await DBProvider.db.newClient(user);
                            prefix0.setLevel(2);
                              Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (builder) => Otp()
                              )
                            );
                             
                          } else _displaySnackBar(context);
                      },
                    ),
                    Expanded(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          top: 30,
                          left: 10,
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              image: DecorationImage(
                                image: AssetImage("images/evelyn.jpg"),
                                fit: BoxFit.cover,
                              )
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          left: 70,
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                                image: DecorationImage(
                                  image: AssetImage("images/userBoy09.jpg"),
                                  fit: BoxFit.cover,
                                )
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 100,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                image: DecorationImage(
                                  image: AssetImage("images/userGirl05.jpg"),
                                  fit: BoxFit.cover,
                                )
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            height: 87,
                            width: 87,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                                image: DecorationImage(
                                  image: AssetImage("images/ppt.jpeg"),
                                  fit: BoxFit.cover,
                                )
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 120,
                          right: 80,
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                                image: DecorationImage(
                                  image: AssetImage("images/nash.jpg"),
                                  fit: BoxFit.cover,
                                )
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 0,
                          child: Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                                image: DecorationImage(
                                  image: AssetImage("images/test.jpg"),
                                  fit: BoxFit.cover,
                                )
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          left: 5,
                          child: Text("+ 100K utilisateurs", style: prefix0.Style.sousTitre(14),),
                        ),
                      ],
                    ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
