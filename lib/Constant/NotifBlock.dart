import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;



class NotifBlock extends StatelessWidget {
  var block;
  NotifBlock(this.block);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: today(this.block),
      ),
    );
  }

  Widget today(List atMoment){
    var item;
    if(atMoment.length != 0){
      item = new ListView.builder(
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
