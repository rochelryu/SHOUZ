import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Constant/Style.dart';
import '../Constant/helper.dart';
import '../ServicesWorker/ConsumeAPI.dart';

class StatsEvent extends StatefulWidget {
  String eventId;
  String imageUrl;
  String title;
  StatsEvent({required Key key, required this.eventId, required this.imageUrl, required this.title}) : super(key: key);

  @override
  _StatsEventState createState() => _StatsEventState();
}

class _StatsEventState extends State<StatsEvent> {
  final List<SalesData> chartData = [
    SalesData(DateTime(2010), [35,54]),
    SalesData(DateTime(2011), [28,15]),
    SalesData(DateTime(2012), [30, 28]),
    SalesData(DateTime(2013), [32,40]),
    SalesData(DateTime(2014), [40,34])
  ];

  final data = [
    ChartDataForDonut('Ticket 4000', 12, colorText),
    ChartDataForDonut('Ticket 10000', 3, colorError),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: NetworkImage(
                      "${ConsumeAPI.AssetEventServer}${widget.imageUrl}"),
                  fit: BoxFit.cover
                )
              ),
            ),
            SizedBox(width: 5),
            Flexible(
              child: Container(
                height: 55,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(widget.title.toUpperCase(),style: Style.titre(13.0), maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(
                      "Statistiques",
                      style: Style.sousTitre(12.0),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Material(
              elevation: 5,
              child: Container(
                padding: EdgeInsets.all(10),
                color: backgroundColor,
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Vue d'ensemble", style: Style.titleDealsProduct(),),
                          Text("31 juil. 2022 - 7 août 2022", style: Style.titleDealsProduct(10),),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      height: 60,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("534",style: Style.titre(18.0)),
                                Text(
                                  "Tickets vendus",
                                  style: Style.sousTitre(12.0),
                                )
                              ],
                            ),
                          ),),
                          Expanded(child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("95000",style: Style.titre(18.0)),
                                Text(
                                  "Gains",
                                  style: Style.sousTitre(12.0),
                                )
                              ],
                            ),
                          ),),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Material(
              elevation: 5,
              child: Container(
                width: double.infinity,
                color: backgroundColor,
                height: 400,
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Fréquence d'Achat", style: Style.titleDealsProduct(),),
                    SizedBox(height: 10,),
                    Expanded(
                        child: SfCartesianChart(
                            primaryXAxis: DateTimeAxis(edgeLabelPlacement: EdgeLabelPlacement.shift,
                                interval: 2,
                                majorGridLines: const MajorGridLines(width: 0)),
                            plotAreaBorderWidth: 0,
                            primaryYAxis: NumericAxis(
                                labelFormat: '{value}',
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(color: Colors.transparent)),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <ChartSeries>[
                              // Renders line chart
                              LineSeries<SalesData, DateTime>(
                                  animationDuration: 2500,
                                  color: colorText,
                                  dataSource: chartData,
                                  name: "Ticket 4000",
                                  width: 2,
                                  markerSettings: const MarkerSettings(isVisible: true),
                                  xValueMapper: (SalesData sales, _) => sales.year,
                                  yValueMapper: (SalesData sales, _) => sales.sales[0]
                              ),
                              LineSeries<SalesData, DateTime>(
                                  animationDuration: 4500,
                                  color: colorError,
                                  dataSource: chartData,
                                  name: "Ticket 10000",
                                  width: 2,
                                  markerSettings: const MarkerSettings(isVisible: true),
                                  xValueMapper: (SalesData sales, _) => sales.year,
                                  yValueMapper: (SalesData sales, _) => sales.sales[1],
                                  pointColorMapper: (SalesData sales, _) => colorError.withOpacity(0.5),
                                  dataLabelMapper: (SalesData sales, _) => "${sales.sales[1]} Ticket de 10000",
                              ),
                            ]
                        )
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Material(
              elevation: 5,
              child: Container(
                width: double.infinity,
                color: backgroundColor,
                height: 350,
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pourcentage cumulé", style: Style.titleDealsProduct(),),
                    SizedBox(height: 10,),
                    Expanded(
                        child: SfCircularChart(
                            series: <CircularSeries>[
                              // Render pie chart
                              PieSeries<ChartDataForDonut, String>(
                                  dataSource: data,
                                  pointColorMapper:(ChartDataForDonut data, _) => data.color,
                                  xValueMapper: (ChartDataForDonut data, _) => data.x,
                                  yValueMapper: (ChartDataForDonut data, _) => data.y
                              )
                            ]
                        )
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
