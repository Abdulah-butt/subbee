import 'dart:async';
import 'dart:math';
import 'package:code/model/GraphModel.dart';
import 'package:code/model/subscription_model.dart';
import 'package:code/util/app_color.dart';
import 'package:code/widgets/custom_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingGraph extends StatefulWidget {
  final List<Color> availableColors = const [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

  const SpendingGraph({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BarChartSample1State();
}

class BarChartSample1State extends State<SpendingGraph> {
  final Color barBackgroundColor = Colors.white;
  final Duration animDuration = const Duration(milliseconds: 250);



  int touchedIndex = -1;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SubscriptionModel.getLastSixMonthRecord();

  }

  List<String> monthNames=[];
  List<double> amountSpent=[];


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GraphModel>>(
      future: SubscriptionModel.getLastSixMonthRecord(),
      builder: (context,graphModelList) {
        if(!graphModelList.hasData){
          return Center(child: loadingIndicator(),);
        }

        List<GraphModel>? list=graphModelList.data;
        monthNames.clear();
        amountSpent.clear();

        for(var model in list!){
          monthNames.add(model.monthName!);
          amountSpent.add(model.spendAmount!);
        }

        return AspectRatio(
          aspectRatio: 1,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            color: AppColors.yellowColor,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      const Text(
                        'Statistics',
                        style: TextStyle(
                            color: Color(0xff0f4a3c),
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      const Text(
                        'Monthly overview',
                        style: TextStyle(
                            color: Color(0xff379982),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 38,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: BarChart(
                            mainBarData(),
                            swapAnimationDuration: animDuration,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  BarChartGroupData makeGroupData(
      int x,
      double y, {
        bool isTouched = false,
        Color barColor = Colors.white,
        double width = 22,
        List<int> showTooltips = const [],
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          width: width,

          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,

          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(6, (i) {
    switch (i) {
      case 0:
        return makeGroupData(0, amountSpent[0], isTouched: i == touchedIndex);
      case 1:
        return makeGroupData(1, amountSpent[1], isTouched: i == touchedIndex);
      case 2:
        return makeGroupData(2, amountSpent[2], isTouched: i == touchedIndex);
      case 3:
        return makeGroupData(3,amountSpent[3], isTouched: i == touchedIndex);
      case 4:
        return makeGroupData(4,amountSpent[4], isTouched: i == touchedIndex);
      case 5:
        return makeGroupData(5,amountSpent[5], isTouched: i == touchedIndex);

      default:
        return throw Error();
    }
  });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 0:
                  weekDay = monthNames[0];
                  break;
                case 1:
                  weekDay = monthNames[1];
                  break;
                case 2:
                  weekDay = monthNames[2];
                  break;
                case 3:
                  weekDay =monthNames[3];
                  break;
                case 4:
                  weekDay =monthNames[4];
                  break;
                case 5:
                  weekDay =monthNames[5];
                  break;
                default:
                  throw Error();
              }
              return BarTooltipItem(
                weekDay + '\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.toY - 1).toString(),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),

      // x axis data
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return monthNames[0].substring(0,3);
              case 1:
                return monthNames[1].substring(0,3);
              case 2:
                return monthNames[2].substring(0,3);
              case 3:
                return monthNames[3].substring(0,3);
              case 4:
                return monthNames[4].substring(0,3);
              case 5:
                return monthNames[5].substring(0,3);
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }

}