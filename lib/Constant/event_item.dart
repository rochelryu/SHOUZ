import 'package:flutter/material.dart';
import 'package:shouz/Models/User.dart';
import '../Pages/EventDetails.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import 'Style.dart';
import 'helper.dart';

class EventItem extends StatelessWidget {
  final dynamic infoEvent;
  final int index;
  final int comeBack;
  final User? user;
  const EventItem({Key? key,required this.infoEvent, required this.index, required this.comeBack, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => EventDetails(
              comeBack,
              infoEvent
              ['imageCover'],
              index,
              infoEvent
              ['price'],
              infoEvent
              ['numberFavorite'],
              infoEvent
              ['authorName'],
              infoEvent
              ['describe'],
              infoEvent
              ['_id'],
              infoEvent
              ['numberTicket'],
              infoEvent
              ['position'],
              infoEvent
              ['eventDate'],
              infoEvent
              ['title'],
              infoEvent
              ['positionRecently'],
              infoEvent
              ['videoPub'],
              infoEvent
              ['allTicket'],
              infoEvent
              ['authorId'],
              infoEvent
              ['cumulGain'],
              user != null ? infoEvent
              ['authorId'] == user!.ident : false,
              infoEvent
              ['state'],
              user != null ? infoEvent
              ['favorie']: false,
            )));
      },
      child: Container(
        width: double.infinity,
        height: 235,
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              child: Hero(
                tag: index,
                child: Image.network(
                    "${ConsumeAPI.AssetEventServer}${infoEvent['imageCover']}",
                    fit: BoxFit.cover),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 235,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          const Color(0x00000000),
                          const Color(0x99111100),
                        ],
                        begin:
                        FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(
                            0.0, 1.0))),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                        infoEvent
                        ['title']
                            .toString()
                            .toUpperCase(),
                        style: Style.titreEvent(20),
                        textAlign: TextAlign.center),
                    SizedBox(height: 10.0),
                    Text(
                        infoEvent
                        ['position'],
                        style: Style.sousTitreEvent(15),
                        maxLines: 2,
                        textAlign: TextAlign.center),
                    SizedBox(height: 25.0),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SizedBox(width: 10.0),
                            Icon(Icons.favorite,
                                color: Colors.redAccent,
                                size: 22.0),
                            Text(
                              infoEvent

                              ['numberFavorite']
                                  .toString(),
                              style: Style
                                  .titleInSegment(),
                            ),
                            SizedBox(width: 20.0),
                            Icon(
                                Icons
                                    .account_balance_wallet,
                                color: Colors.white,
                                size: 22.0),
                            SizedBox(width: 5.0),
                            Text(
                              infoEvent
                              ['price'][0]['price'].toString().toUpperCase() == "GRATUIT" ? infoEvent['price'][0]['price'] : reformatNumberForDisplayOnPrice(infoEvent['price'][0]['price']),
                              style: Style
                                  .titleInSegment(),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                                Icons.alarm,
                                color: Colors.white,
                                size: 22.0),
                            Text(DateTime.parse(infoEvent
                            ['eventDate']).day.toString() +
                                '/' +
                                DateTime.parse(infoEvent
                                ['eventDate'])
                                    .month
                                    .toString() +
                                '/' +
                                DateTime.parse(infoEvent
                                ['eventDate'])
                                    .year
                                    .toString()+
                                ' à ' +
                                DateTime.parse(infoEvent
                                ['eventDate'])
                                    .hour
                                    .toString() +
                                'h:' +
                                DateTime.parse(infoEvent
                                ['eventDate'])
                                    .minute
                                    .toString(),
                                style: Style
                                    .titleInSegment()),
                            SizedBox(width: 10.0)
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}