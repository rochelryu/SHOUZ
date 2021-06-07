import 'package:flutter/material.dart';
import 'package:shouz/Constant/NotifBlock.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>  with SingleTickerProviderStateMixin{
  TabController _controller;
  @override
  void initState() {
    super.initState();
    _controller =  new TabController(length: 3, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prefix0.backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: prefix0.backgroundColor,
        title: Text('Notifications'),
        bottom: new TabBar(
          controller: _controller,
          unselectedLabelColor: Color(0xdd3c5b6d),
          labelColor: prefix0.colorText,
          indicatorColor: prefix0.colorText,
          tabs: [
            new Tab(
              text: 'Deals',
            ),
            new Tab(
              //icon: const Icon(Icons.shopping_cart),
              text: 'Events',
            ),
            new Tab(
              //icon: const Icon(Icons.shopping_cart),
              text: 'Travel',
            ),
          ],
        ),
      ),
      body:new TabBarView(
        controller: _controller,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              (prefix0.atMoment.length == 0) ? SizedBox(height: 10.0): Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[Text("Aujourd'hui", style: prefix0.Style.titre(24.0)), FlatButton(child: Text("voir plus", style: TextStyle(color: prefix0.colorText)),)],)
              ),
              Expanded(
                child: today(prefix0.atMoment),
              ),
              (prefix0.atMois.length == 0) ? SizedBox(height: 10.0): Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[Text("Ce mois", style: prefix0.Style.titre(24.0)), FlatButton(child: Text("voir plus", style: TextStyle(color: prefix0.colorText)),)],)
              ),
              Expanded(
                child: today(prefix0.atMois),
              ),

            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              (prefix0.atMoment.length == 0) ? SizedBox(height: 10.0): Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[Text("Aujourd'hui", style: prefix0.Style.titre(24.0)), FlatButton(child: Text("voir plus", style: TextStyle(color: prefix0.colorText)),)],)
                ),
              Expanded(
                child: today(prefix0.atMoment),
              ),
              (prefix0.atMois.length == 0) ? SizedBox(height: 10.0): Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[Text("Ce mois", style: prefix0.Style.titre(24.0)), FlatButton(child: Text("voir plus", style: TextStyle(color: prefix0.colorText)),)],)
              ),
              Expanded(
                child: today(prefix0.atMois),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              (prefix0.atMoment.length == 0) ? SizedBox(height: 10.0): Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[Text("Aujourd'hui", style: prefix0.Style.titre(24.0)), FlatButton(child: Text("voir plus", style: TextStyle(color: prefix0.colorText)),)],)
              ),
              Expanded(
                child: today(prefix0.atMoment),
              ),
              (prefix0.atMois.length == 0) ? SizedBox(height: 10.0): Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[Text("Ce mois", style: prefix0.Style.titre(24.0)), FlatButton(child: Text("voir plus", style: TextStyle(color: prefix0.colorText)),)],)
              ),
              Expanded(
                child: today(prefix0.atMois),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget today(List atMoment){
    var item;
    if(atMoment.length != 0){
      item = new ListView.builder(
        shrinkWrap: true,
          itemCount: atMoment.length,
          itemBuilder: (context, index){
            return InkWell(
              onTap: (){
                print("zo");
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: prefix0.colorText, width: 1.0),
                          borderRadius: BorderRadius.circular(50.0),
                          image: DecorationImage(
                            image: AssetImage(atMoment[index]['author']),
                            fit: BoxFit.cover,
                          )
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new RichText(
                          text: new TextSpan(
                              text: atMoment[index]['name'] + " ",
                              style: prefix0.Style.contextNotif(),
                              children: [
                                new TextSpan(
                                  text: atMoment[index]['verbe'] + " ",
                                  style: prefix0.Style.priceDealsProduct(),
                                ),
                                new TextSpan(
                                  text: atMoment[index]['complement'],
                                  style: prefix0.Style.contextNotif(),
                                )
                              ]),
                        ),
                        Text(atMoment[index]['product'], style: prefix0.Style.sousTitre(12.0), maxLines: 1,)
                      ],
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          image: DecorationImage(
                              image: AssetImage(atMoment[index]['productImage']),
                              fit: BoxFit.cover
                          )
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    }
    else item = new SizedBox(height: 10.0);

    return item;
  }
}

