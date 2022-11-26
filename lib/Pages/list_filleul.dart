import 'package:flutter/material.dart';

import '../Constant/Style.dart';
import '../Constant/helper.dart';
import '../ServicesWorker/ConsumeAPI.dart';

class ListFilleul extends StatefulWidget {
  const ListFilleul({required Key key}) : super(key: key);

  @override
  _ListFilleulState createState() => _ListFilleulState();
}

class _ListFilleulState extends State<ListFilleul> {
  List<dynamic> listFilleul = [];
  int walletSponsor = -1;
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
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Liste Filleul"),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
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
                if (walletSponsor >= 0) Text("${reformatNumberForDisplayOnPrice(walletSponsor)} XOF", style: Style.titre(15)),
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
