import 'package:flutter/material.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

import '../Constant/Style.dart';
import '../Constant/widget_common.dart';
import '../Models/User.dart';

class TicketDetail extends StatelessWidget {
  String eventTitle;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  User user;
  String eventId;
  String registerDate;
  String ticketId;
  String ticketImg;
  int placeTotal;
  int priceTicket;
  int durationEventByDay;
  String typeTicket;
  List<dynamic> timesDecode;
  TicketDetail(this.eventTitle, this.eventId, this.ticketId, this.ticketImg, this.placeTotal, this.priceTicket, this.typeTicket, this.registerDate, this.user, this.timesDecode, this.durationEventByDay);
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
        title: Text('Ticket Detail', style: Style.titleNews(),),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          Icon(Icons.qr_code_scanner),
          SizedBox(width: 10),
        ],
      ),
      body: detailTicket(
        ticketId,
        eventId,
        ticketImg,
        placeTotal,
        typeTicket,
        priceTicket,
        timesDecode,
        registerDate,
        durationEventByDay,
        eventTitle,
        context,
        true
      ),
    );
  }
}

