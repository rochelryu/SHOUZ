import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Pages/share_ticket.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

import '../Constant/Style.dart';
import '../Constant/widget_common.dart';
import '../MenuDrawler.dart';
import '../Models/User.dart';

class TicketDetail extends StatelessWidget {
  String eventTitle;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  User user;
  String eventId;
  var eventDate;
  String ticketId;
  String ticketImg;
  int placeTotal;
  int priceTicket;
  String typeTicket;
  TicketDetail(this.eventTitle, this.eventId, this.ticketId, this.ticketImg, this.placeTotal, this.priceTicket, this.typeTicket, this.eventDate, this.user);
  @override
  Widget build(BuildContext context) {
    final register = DateTime.parse(eventDate);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Ticket Detail'),
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
            height: MediaQuery.of(context).size.height * 0.75,
            child: Card(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(eventTitle, style: Style.grandTitreBlue(17), textAlign: TextAlign.center),

                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("${placeTotal.toString()} Ticket${placeTotal > 1 ? 's': ''} de ${typeTicket.toUpperCase() == 'GRATUIT' ? 'type': '' } $typeTicket ${typeTicket.toUpperCase() == 'GRATUIT' ? '': user.currencies }\npris le ${register.day.toString()}/${register.month.toString()}/${register.year.toString()} à ${register.hour.toString()}h ${register.minute.toString()}", style: Style.chatOutMe(14), textAlign: TextAlign.center),
                    ),
                    Container(
                      height: 200,
                      width: 200,
                      child: Hero(
                        tag: ticketId,
                        child: CachedNetworkImage(
                          imageUrl: "${ConsumeAPI.AssetBuyEventServer}$eventId/$ticketImg",
                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              Center(
                                  child: CircularProgressIndicator(value: downloadProgress.progress)),
                          errorWidget: (context, url, error) => notSignal(),
                          fit: BoxFit.cover,
                          height: 400,
                          width: double.infinity,
                        )
                    )),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38.0)),
                        ),
                        onPressed: () {
                          Navigator.of(context).push((MaterialPageRoute(
                              builder: (context) => ShareTicket(key: UniqueKey(), ticketId: ticketId, placeTotal: placeTotal, typeTicket: typeTicket))));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share_outlined),
                            SizedBox(width: 10),
                            Text('Partager Ticket')
                          ],
                        ),
                      ),
                    ),
                    placeTotal < 3 ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          primary: colorError,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38.0)),
                        ),
                        onPressed: () async {
                          final shareTicket = await consumeAPI.dropEventTicket(ticketId);
                          if(shareTicket['etat'] == 'found') {
                            await askedToLead(
                                "Ticket Annulé votre compte vient de recevoir 90% du montant total du ticket",
                                true, context);
                              Timer(Duration(seconds: 3), () {
                                Navigator.pushNamed(context, MenuDrawler.rootName);
                              });

                          }
                          else {
                            await askedToLead(shareTicket['error'], false, context);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 10),
                            Text('Annuler Ticket')
                          ],
                        ),
                      ),
                    ): SizedBox(width: 10,),
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
