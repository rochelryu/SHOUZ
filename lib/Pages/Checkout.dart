import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:url_launcher/url_launcher.dart';

class Checkout extends StatefulWidget {
  static String rootName = '/checkout';
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  AppState appState;

  bool verifyUser = false;

  TypePayement _character = TypePayement.trovaExchange;

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
            title: Text("Rechargement ShouzPay"),
            backgroundColor: backgroundColor,
            elevation: 0.0,
          ),
          body: GestureDetector(
            onTap: ()=>FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height/3 - 40,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Card(
                          elevation: (_character == TypePayement.trovaExchange) ? 15.0:1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0)
                          ),
                          color: backgroundColorSec,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsets.only(right: 20, left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Radio(
                                  activeColor: Colors.white,
                                  value: TypePayement.trovaExchange,
                                  groupValue: _character,
                                  onChanged: (TypePayement value) {
                                    setState(() { _character = value; });
                                  },
                                ),
                                Text("Trova Exchange", style: Style.titre(18)),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage("https://trova.vip/Inter/admin/images/favicon.png"),
                                      fit: BoxFit.cover
                                    )
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),

                        Card(
                          elevation: (_character == TypePayement.bitcoin) ? 15.0:1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0)
                          ),
                          color: backgroundColorSec,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsets.only(right: 20, left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Radio(
                                  activeColor: Colors.orange,
                                  value: TypePayement.bitcoin,
                                  groupValue: _character,
                                  onChanged: (TypePayement value) {
                                    setState(() { _character = value; });
                                  },
                                ),
                                Text("Bitcoin", style: Style.titre(18)),
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: SvgPicture.asset(
                                    "images/bitcoin.svg",
                                    semanticsLabel: 'Recharge Bitcoin',
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                        Card(
                          elevation: (_character == TypePayement.ethereum) ? 15.0:1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0)
                          ),
                          color: backgroundColorSec,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsets.only(right: 20, left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Radio(
                                  activeColor: Colors.blue,
                                  value: TypePayement.ethereum,
                                  groupValue: _character,
                                  onChanged: (TypePayement value) {
                                    setState(() { _character = value; });
                                  },
                                ),
                                Text("Ethereum", style: Style.titre(18)),
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: SvgPicture.asset(
                                    "images/ethereum.svg",
                                    semanticsLabel: 'Recharge Ethereum',
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height/1.5 - 60,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Blockus(context,_character),
                    ),
                  ),
                ],
              ),
            ),
          ),

        );    
  
    }

  Widget Blockus(BuildContext context,TypePayement type){
    switch(type){
      case TypePayement.trovaExchange:
        return Container(
          height: MediaQuery.of(context).size.height/2,
          width: MediaQuery.of(context).size.width/1.2,
          child: Column(
            children: [
              SvgPicture.asset(
                  "images/trova_exchange_illustration.svg",
                  semanticsLabel: 'Trova Exchange',
                width: 380,
              ),
              SizedBox(height: 15),
              Text('Grâce à Trova Exchange vous pouvez vous recharger par mobile money 🥳', style: Style.sousTitre(14), textAlign: TextAlign.center,),
              SizedBox(height: 15),
              ElevatedButton(
            onPressed: () async {
              //update d'abord recovery avant de lancer le launch pour plus de securité.
              await launch('https://www.trova.vip/exchange/buyByShouz?credential=...&recovery=...');
            },
            child: new Text(
              "Envoyer le produit",
              //style: Style.sousTitreEvent(15),
            ),
            style: raisedButtonStyle,
          )
            ],
          )
        );
        break;
      case TypePayement.bitcoin:
        return Container(
          height: MediaQuery.of(context).size.height/2.4,
          width: MediaQuery.of(context).size.width/1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              Container(
                  height: MediaQuery.of(context).size.height/4,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("1. Faite une transaction bitcoin du montant que vous voulez pour le rechargement à l'addresse suivante :", style: Style.sousTitre(11)),
                      SelectableText('1Fp1JtyeVWGH95diPG5oe4TcuipbwE3boR', style: Style.addressCrypto(),
                        toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
                        showCursor: true,
                        cursorWidth: 2,
                        cursorColor: Colors.red,
                        cursorRadius: const Radius.circular(5),

                      ),
                      Text("2. Une fois que vous avez fait la transaction du montant voulu, veuillez recupérer le code de reference de cette transaction (TxHash ou TxId) puis la coller dans le champ ci-dessous 👇", style: Style.sousTitre(11)),
                    ],
                  )
              ),
              Container(
                height: MediaQuery.of(context).size.height/8,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 10.0, right: 3.0),
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "xxxxxxxxxxxxxxxxxxxxxxxxxx",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (text){
                            print(text);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 15.0),
                    FloatingActionButton(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.check,color: Colors.white),
                      onPressed: (){
                        print("Conf");
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case TypePayement.ethereum:
        return Container(
          height: MediaQuery.of(context).size.height/2.4,
          width: MediaQuery.of(context).size.width/1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              Container(
                  height: MediaQuery.of(context).size.height/6,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("1. Acceptez la notification reçue sur votre téléphone en entrant le chiffre 1 pour vous identifier", style: Style.sousTitre(11)),
                      Text("2. *133# pour approuver la demande de paiement.", style: Style.sousTitre(12)),
                      Text("3. Confirmer le paiement en saisissant votre code secret MTN Mobile Money.", style: Style.sousTitre(12)),
                    ],
                  )
              ),
              Container(
                height: MediaQuery.of(context).size.height/8,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 45,
                        width: double.infinity,
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
                            hintText: "+225 XX XX XX XX",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[200]),
                          ),
                          onChanged: (text){
                            print(text);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 15.0),
                    FloatingActionButton(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.check,color: Colors.white),
                      onPressed: (){
                        print("Conf");
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      default:
        return Container(
          height: 50,
          width: 50,
        );
        break;
    }
  }
}
