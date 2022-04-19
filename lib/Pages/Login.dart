import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/Opt.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

class Login extends StatefulWidget {
  static String rootName = '/login';
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('Format de Numero incorrecte'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  late User user;
  String numero = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
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
                      color: backgroundColorSec,
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
                      child: Text("Vous devez vous enregistrer par votre numero, un code de confirmation vous sera envoyé pour confirmer votre identité", style: Style.titre(13.0), textAlign: TextAlign.center,),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("+225", style: Style.titre(20)),
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
                                hintText: "XXXXXXXXXX",
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
                    ElevatedButton(
                      style: raisedButtonStyle,
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width/1.45,
                        child: Center(
                          child: Text("S'enregistrer", style: Style.titre(18)),
                        ),
                      ),
                      onPressed: () async {
                        if(numero.length == 10) {
                            final res = await ConsumeAPI().signin(numero, '+225');
                            setState(() {
                              user = res['user'];
                            });
                            await DBProvider.db.delClient();
                            await DBProvider.db.newClient(user);
                            setLevel(2);
                              Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (builder) => Otp(key: UniqueKey(),)
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
                            height: 85,
                            width: 85,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              image: DecorationImage(
                                image: AssetImage("images/userBoy18.png"),
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
                          left: 130,
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
                                  image: AssetImage("images/userGirl07.jpg"),
                                  fit: BoxFit.cover,
                                )
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 120,
                          right: 110,
                          child: Container(
                            height: 95,
                            width: 95,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                                image: DecorationImage(
                                  image: AssetImage("images/userGirl09.jpg"),
                                  fit: BoxFit.cover,
                                )
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          right: 10,
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
