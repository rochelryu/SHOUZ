
import 'package:flutter/material.dart';

import '../Constant/Style.dart';

class TicketTravelDetails extends StatelessWidget {
  String imageTitle;
  String subtitle;
  String networkImageWithConsumeApi;

  TicketTravelDetails(this.imageTitle, this.networkImageWithConsumeApi ,this.subtitle);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Style.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Ticket Voyage Detail', style: Style.titleNews(),),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          Icon(Icons.qr_code_scanner),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
            height: 300,
            child: Card(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(subtitle, style: Style.chatOutMe(14), textAlign: TextAlign.center),
                    ),
                    Container(
                        height: 200,
                        width: 200,
                        child: Hero(
                          tag: imageTitle,
                          child: Image(
                            image:  NetworkImage(networkImageWithConsumeApi),
                          ),
                        )),
                    SizedBox(height: 15),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
