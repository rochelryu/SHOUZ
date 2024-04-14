import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Constant/Style.dart';
import '../Constant/helper.dart';
import '../Constant/widget_common.dart';
import '../ServicesWorker/ConsumeAPI.dart';

class ListFilleul extends StatefulWidget {
  const ListFilleul({required Key key}) : super(key: key);

  @override
  _ListFilleulState createState() => _ListFilleulState();
}

class _ListFilleulState extends State<ListFilleul> {
  List<dynamic> listFilleul = [];
  int walletSponsor = -1;
  String codeSponsor = "";
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Future getInfo() async {
    final getAllFilleul = await consumeAPI.getViewFilleul();
    if(getAllFilleul['etat'] == 'found') {
      setState(() {
        listFilleul = getAllFilleul['result']['arrayProductAvailable'];
        walletSponsor = getAllFilleul['result']['walletSponsor'];
        codeSponsor = getAllFilleul['result']['myCodeParrain'];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Style.white,)
        ),
        title: Text("Liste Filleul", style: Style.titleNews(),),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Text(
            "Gagnez 500 Frs sur les 2 premiers achats des personnes que vous inviterez ! 🎁",
            style: Style.sousTitre(15),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  flex:3,
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5
                    ),
                    decoration: BoxDecoration(
                        color: backgroundColorSec,
                        borderRadius: BorderRadius.circular(18)
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 10,),
                        Icon(Icons.wallet_outlined, color: colorPrimary,),
                        SizedBox(width: 5,),
                        if (walletSponsor >= 0) Text("${reformatNumberForDisplayOnPrice(walletSponsor)}", style: Style.titre(15)),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                          },
                          child: Text("Retirer"),
                          style: raisedButtonStyleSuccess,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5
                    ),
                    decoration: BoxDecoration(
                        color: backgroundColorSec,
                        borderRadius: BorderRadius.circular(18)
                    ),
                    child: InkWell(
                      onTap: (){
                        Clipboard.setData(ClipboardData(text: codeSponsor))
                            .then((value) { //only if ->
                          displaySnackBar(context, "Code copié avec succès");
                        });
                      },
                      child: Row(
                        children: [
                          SizedBox(width: 10,),
                          Icon(Icons.local_activity_outlined, color: colorPrimary,),
                          SizedBox(width: 5,),
                          if (codeSponsor != "") Text(codeSponsor, style: Style.titre(15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Expanded(child: ListView.builder(
              itemCount: listFilleul.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        image: DecorationImage(image: NetworkImage("${ConsumeAPI.AssetProfilServer}${listFilleul[index]['profil']}"), fit: BoxFit.cover)
                    ),
                  ),
                  title: Text(listFilleul[index]['name'], style: Style.titre(15)),
                  subtitle: Text("Nbre Transaction : ${listFilleul[index]['numberUsedByParrain']}", style: Style.simpleTextOnBoard(15)),
                );
              }))
        ],
      ),
    );
  }
}
