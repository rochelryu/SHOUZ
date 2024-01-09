import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../Constant/Style.dart';
import '../Constant/helper.dart';
import '../Constant/widget_common.dart';
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
  bool isLoading = true, error = false;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  List<dynamic> itemTypeTicketForFrequence = [];
  List<ChartDataLine> chartDataLines = [];
  DateTime registerDateOfEvent = DateTime.now();
  DateTime eventExpireDate = DateTime.now();
  List<PieSeriesData> pieSeriesData = [];
  List<dynamic> allPrices = [];
  List<dynamic> tableDataStats = [];
  List<dynamic> tableDataStatsForRemoved = [];
  int totalTicketBuy = 0, totalTicketDecode = 0, cumulGain = 0;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Future getInfo() async {
    try {
      final data = await consumeAPI.getStatsOfEvent(widget.eventId);
      if(data['etat'] == "found") {
        final frequenceBuyTicketWithFilter = data['result']['frequenceBuyTicketWithFilter'] as List<dynamic>;
        if(frequenceBuyTicketWithFilter.length > 0) {
          setState(() {
            for(int index = 0; index < data['result']['globalTicketBuyByTypeTicketPreceptFromTotalTicketRest'].length; index++) {
              final pieElementData = data['result']['globalTicketBuyByTypeTicketPreceptFromTotalTicketRest'][index];
              pieSeriesData.add(PieSeriesData(pieElementData['title'], pieElementData['value'], colorsForStats[index == 0 ? colorsForStats.length -1: index - 1]));
            }
            tableDataStats = data['result']['listAllBuyer'].map((value) {
              return TableDataStats(value['client'][0]['name'], value['client'][0]['images'], value['typeTicket'], value['priceTicket'], value['placeTotal'], value['registerDate']);
            }).toList();
            tableDataStatsForRemoved = data['result']['listAllRemover'].map((value) {
              return TableDataStatsForRemoved(value['client'][0]['name'], value['client'][0]['images'], value['typeTicket'], value['priceTicket'], value['commission'], value['registerDate']);
            }).toList();
            registerDateOfEvent = DateTime.parse(data['result']['registerDate']);
            eventExpireDate = DateTime.parse(data['result']['eventExpireDate']);
            totalTicketBuy = data['result']['totalTicketBuy'];
            cumulGain = data['result']['cumulGain'];
            allPrices = data['result']['price'];
            totalTicketDecode = data['result']['totalTicketDecode'];
            itemTypeTicketForFrequence = frequenceBuyTicketWithFilter[0]['data'];
            chartDataLines = frequenceBuyTicketWithFilter.map((item) => ChartDataLine(item['date'], item['data'])).toList();
          });
        }
        setState(() {
          error = false;
          isLoading = false;
        });
      } else {
        setState(() {
          error = true;
          isLoading = false;
        });
      }


    } catch (e) {
      print(e);
      setState(() {
        error = true;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


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
          icon: Icon(Icons.arrow_back, color: Style.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context,contraints) {
            if(isLoading) {
              return SizedBox(
                height: 700,
                width: MediaQuery.of(context).size.width,
                child: Center(child: Container(
                  height: 200,
                  width: 200,
                  child: LoadingIndicator(indicatorType: Indicator.audioEqualizer,colors: [colorText, backgroundColorSec, colorPrimary], strokeWidth: 2),
                ),),
              );
            } else if(!isLoading && error) {
              return isErrorSubscribe(context);
            }
            else {
              return Column(
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
                                Text("${formatedDateForLocalWithoutTime(registerDateOfEvent)} - ${formatedDateForLocalWithoutTime(eventExpireDate)}", style: Style.titleDealsProduct(10),),
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
                                      Text(totalTicketDecode.toString(),style: Style.titre(18.0)),
                                      Text(
                                        "Tickets décodés",
                                        style: Style.sousTitre(11.0),
                                      )
                                    ],
                                  ),
                                ),),
                                Expanded(child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(totalTicketBuy.toString(),style: Style.titre(18.0)),
                                      Text(
                                        "Tickets vendus",
                                        style: Style.sousTitre(11.0),
                                      )
                                    ],
                                  ),
                                ),),
                                Expanded(child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cumulGain.toString(),style: Style.titre(18.0)),
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
                                  series: lineChartArray()
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
                                  onTooltipRender: (TooltipArgs args) {
                                    args.text = args.dataPoints![args.pointIndex!.toInt()].x.toString() +
                                        ' : ' +
                                        args.dataPoints![args.pointIndex!.toInt()].y.toString();
                                  },
                                  tooltipBehavior: TooltipBehavior(enable: true),
                                  series: <CircularSeries>[
                                    // Render pie chart
                                    PieSeries<PieSeriesData, String>(
                                        explode: true,
                                        explodeIndex: 0,
                                        explodeOffset: '15%',
                                        dataSource: pieSeriesData,
                                        pointColorMapper:(PieSeriesData data, _) => data.color,
                                        xValueMapper: (PieSeriesData data, _) => data.x,
                                        yValueMapper: (PieSeriesData data, _) => data.y,
                                        dataLabelMapper: (PieSeriesData data, _) => data.x.replaceAll("Tickets ", "").replaceAll("Ticket(s) ", ""),
                                        startAngle: 90,
                                        endAngle: 90,
                                        dataLabelSettings: DataLabelSettings(isVisible: true,labelPosition: ChartDataLabelPosition.outside, textStyle: Style.simpleTextOnBoard(12))
                                    )
                                  ]
                              )
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  ...getAllRadialDisplay(allPrices),
                  Material(
                    elevation: 5,
                    child: Container(
                      width: double.infinity,
                      color: backgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PaginatedDataTable(
                            columns: [
                              DataColumn(label: Text("Profil", style: Style.sousTitreBlack(15),)),
                              DataColumn(label: Text("Nom & Prénom", style: Style.sousTitreBlack(15),)),
                              DataColumn(label: Text("Payé", style: Style.sousTitreBlack(15),)),
                              DataColumn(label: Text("Ticket(s)", style: Style.sousTitreBlack(15),)),
                              DataColumn(label: Text("Type", style: Style.sousTitreBlack(15),)),
                              DataColumn(label: Text("Date achat", style: Style.sousTitreBlack(15),)),
                            ],
                            source: DataSourceBuyer(data: tableDataStats),
                            header: Text("Liste de tickets achetés", style: Style.grandTitreBlack(18),),
                            columnSpacing: 100,
                            arrowHeadColor: backgroundColorSec,
                            horizontalMargin: 30,
                            rowsPerPage: tableDataStats.length < 10 ? tableDataStats.length == 0 ? 1: tableDataStats.length: 10,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          PaginatedDataTable(
                            columns: [
                              DataColumn(label: Text("Profil", style: Style.sousTitreBlack(15),)),
                              DataColumn(label: Text("Nom & Prénom", style: Style.sousTitreBlack(15),)),
                              DataColumn(label: Text("Ticket Annulé", style: Style.sousTitreBlack(15),)),
                              DataColumn(label: Text("Commission", style: Style.sousTitreBlack(15),)),
                              DataColumn(label: Text("Type", style: Style.sousTitreBlack(15),)),
                              DataColumn(label: Text("Date achat", style: Style.sousTitreBlack(15),)),
                            ],
                            source: new DataSourceRemover(data: tableDataStatsForRemoved),
                            header: Text("Liste de tickets annulés", style: Style.grandTitreBlack(18),),
                            columnSpacing: 100,
                            arrowHeadColor: backgroundColorSec,
                            horizontalMargin: 30,
                            rowsPerPage: tableDataStatsForRemoved.length < 10 ? tableDataStatsForRemoved.length == 0 ? 1: tableDataStatsForRemoved.length: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  List<ChartSeries> lineChartArray() {
    List<ChartSeries> data = [];
    for(int index = 0; index < itemTypeTicketForFrequence.length; index++) {
      data.add(LineSeries<ChartDataLine, DateTime>(
          animationDuration: 2500,
          color: colorsForStats[index],
          dataSource: chartDataLines,
          name: "Ticket ${itemTypeTicketForFrequence[index]['typeTicket']}",
          width: 2,
          markerSettings: const MarkerSettings(isVisible: true),
          xValueMapper: (ChartDataLine item, _) => item.dateTime,
          yValueMapper: (ChartDataLine item, _) => item.data[index],
      ));
    }
    return data;
  }



  List<Widget> getAllRadialDisplay(List<dynamic> prices) {
    List<Widget> allWidget = [];
    for(int index = 0; index < prices.length; index++) {
      final price = prices[index];
      allWidget.add(Material(
        elevation: 5,
        child: Container(
          width: double.infinity,
          color: backgroundColor,
          height: 350,
          padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Vente ticket ${price["price"]}", style: Style.titleDealsProduct(),),
              SizedBox(height: 10,),
              Expanded(
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                          startAngle: 180,
                          endAngle: 360,
                          canScaleToFit: true,
                          showLastLabel: true,
                          interval: 10,
                          labelFormat: '{value}%',
                          labelsPosition: ElementsPosition.outside,
                          minorTickStyle: MinorTickStyle(
                              color: colorWelcome,
                              length: 0.05, lengthUnit: GaugeSizeUnit.factor),
                          majorTickStyle: MajorTickStyle(
                              color: colorsForStats[index],
                              length: 0.1, lengthUnit: GaugeSizeUnit.factor),
                          minorTicksPerInterval: 5,
                          pointers: <GaugePointer>[
                            NeedlePointer(
                                value: ((price['numberPlaceTotal'] - price['numberPlace'])/ price['numberPlaceTotal'])*100,
                                needleEndWidth: 3,
                                needleLength: 0.8,
                                needleColor: backgroundColorSec,
                                knobStyle: KnobStyle(
                                  color: colorPrimary,
                                  knobRadius: 8,
                                  sizeUnit: GaugeSizeUnit.logicalPixel,
                                ),
                                tailStyle: TailStyle(
                                    color: colorPrimary,
                                    width: 3,
                                    lengthUnit: GaugeSizeUnit.logicalPixel,
                                    length: 20))
                          ],
                          axisLabelStyle: const GaugeTextStyle(fontWeight: FontWeight.w500, color: colorPrimary,),
                          axisLineStyle: AxisLineStyle(thickness: 3, color: colorsForStats[index])),
                    ],
                  )
              )
            ],
          ),
        ),
      ));
      allWidget.add(SizedBox(height: 10));
    }

    return allWidget;

  }

  List<DataRow> getRowsForRemoved(List<dynamic> data) => data.map((tableDataStatsForRemoved) {
    return DataRow(cells: [
      DataCell(Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                image: NetworkImage(tableDataStatsForRemoved.images),
                fit: BoxFit.cover
            )
        ),
      )),
      DataCell(Text(tableDataStatsForRemoved.name, style: Style.sousTitre(12),)),
      DataCell(Text(tableDataStatsForRemoved.priceTicket.toString(), style: Style.priceDealsProduct(),)),
      DataCell(Text(tableDataStatsForRemoved.commission.toString(), style: Style.priceDealsProduct(),)),
      DataCell(Text("Ticket ${tableDataStatsForRemoved.typeTicket}", style: Style.sousTitre(12),)),
      DataCell(Text(tableDataStatsForRemoved.registerDate, style: Style.sousTitre(12),)),
    ]);
  }).toList();
}
