import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/shared/defines.dart';
import 'package:smartgridapp/view/shared/theme_constants.dart';
import 'package:smartgridapp/view/shared/title_data.dart';

/// Graph widget for displaying lists of doubles.
class DoubleLineGraph extends StatefulWidget {
  final List lineData;
  const DoubleLineGraph({super.key, required this.lineData});

  @override
  State<DoubleLineGraph> createState() => _DoubleLineGraphState();
}

class _DoubleLineGraphState extends State<DoubleLineGraph> {
  @override
  Widget build(BuildContext context) {
    // In short, this widget contains a linegraph view.
    // This is for a single line graph.
    //
    // The precision of the y-axis is determined by the
    // max precision of the list of values.
    //
    // The widget has the following structure:
    //
    //    Center
    //    ---LineChart
    //    ------LineChartData

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              return LineTooltipItem(
                  touchedSpot.y.toStringAsFixed(LineTitles.getMaxPrecision(widget.lineData, 8)),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ));
            }).toList();
          }),
        ),
        borderData: FlBorderData(
          show: true,
        ),
        titlesData: LineTitles.getTitleData(widget.lineData.length, LineTitles.getMaxPrecision(widget.lineData, 8)),
        lineBarsData: [
          LineChartBarData(
              spots: List.generate(
                widget.lineData.length,
                (index) => FlSpot(index.toDouble(), widget.lineData[index].toDouble()),
              ),
              isCurved: false,
              gradient: const LinearGradient(colors: [
                Global.primary,
                Global.secondary,
              ]),
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(colors: [
                  Global.primary.withOpacity(0.2),
                  Global.secondary.withOpacity(0.2),
                ]),
              )),
        ],
      ),
    );
  }
}

/// Graph widget suitable for multiple graphs.
/// Contains utility for enabling and disabling graphs.
class MultiDoubleLineGraph extends StatefulWidget {
  final List lineDatas;
  final List<bool> lineStatuses;
  final List lineTitles;
  const MultiDoubleLineGraph({super.key, required this.lineDatas, required this.lineStatuses, required this.lineTitles});

  @override
  State<MultiDoubleLineGraph> createState() => _MultiDoubleLineGraphState();
}

class _MultiDoubleLineGraphState extends State<MultiDoubleLineGraph> {
  @override
  Widget build(BuildContext context) {
    // In short, this widget contains a linegraph view.
    //
    // The precision of the y-axis is determined by the
    // max precision of the first variable.
    //
    // Every line graph is assigned to a unique color.
    //
    // Depending on the value of [lineStatuses],
    // A graph can be visible or invisible.
    //
    // The widget has the following structure:
    //
    //    Center
    //    ---LineChart
    //    ------LineChartData

    int precision = LineTitles.getMaxPrecision(widget.lineDatas[0], 8);

    return widget.lineDatas.isEmpty
        ? const Center(child: Text('No data for plotting provided...'))
        : LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  fitInsideVertically: true,
                  fitInsideHorizontally: true,
                  tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      return LineTooltipItem(
                        '${touchedSpot.y.toStringAsFixed(precision)}   ',
                        const TextStyle(color: Colors.white),
                        children: [
                          TextSpan(text: '___', style: TextStyle(color: uniqueColors[touchedSpot.barIndex], backgroundColor: uniqueColors[touchedSpot.barIndex], fontSize: 14))
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              borderData: FlBorderData(
                show: true,
              ),
              titlesData: LineTitles.getTitleData(widget.lineDatas[0].length, precision),
              lineBarsData: List.generate(widget.lineDatas.length, (index) {
                return widget.lineStatuses[index]
                    ? LineChartBarData(
                        spots: List.generate(
                          widget.lineDatas[index].length,
                          (idx) => FlSpot(
                            idx.toDouble(),
                            widget.lineDatas[index][idx].toDouble(),
                          ),
                        ),
                        color: uniqueColors[index],
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: uniqueColors[index].withOpacity(0.4),
                        ),
                      )
                    : LineChartBarData();
              }),
            ),
          );
  }
}

/// Bar Graph widget suitable for multiple graphs.
/// Contains utility for enabling and disabling graphs.
class MultiDoubleBarGraph extends StatefulWidget {
  final List groupDatas;
  final List<bool> groupStatuses;
  final List groupTitles;
  const MultiDoubleBarGraph({super.key, required this.groupDatas, required this.groupStatuses, required this.groupTitles});

  @override
  State<MultiDoubleBarGraph> createState() => _MultiDoubleBarGraphState();
}

class _MultiDoubleBarGraphState extends State<MultiDoubleBarGraph> {
  @override
  Widget build(BuildContext context) {
    // In short, the widget contains a bargraph view with below
    // a legend containing which color belongs to which graph type.
    //
    // The precision of the y-axis is determined by the
    // max precision of the first variable.
    //
    // Every unique graph is assigned to a single color.
    // This is the same for all bar groups.
    //
    // Depending on the value of [groupStatuses],
    // A graph can be visible or invisible.
    //
    // The widget has the following structure:
    //
    //    Center
    //    ---Column
    //    ------Expanded
    //    ---------BarChart
    //    ------FittedBox
    //    ---------Row
    //    ------------RichText

    final ThemeManager themeManager = Provider.of<ThemeManager>(context);

    // List of unique plot titles.
    List uniquePlots = [];
    for (var element in widget.groupDatas) {
      element.keys.forEach((key) {
        if (!uniquePlots.contains(key)) {
          uniquePlots.add(key);
        }
      });
    }

    // Number of enabled plots.
    int bars = 0;
    int enabledPlots = 0;

    for (int i = 0; i < widget.groupStatuses.length; i++) {
      if (widget.groupStatuses[i]) {
        enabledPlots += 1;
        bars += widget.groupDatas[i].length as int;
      }
    }

    return widget.groupDatas.isEmpty
        ? const Center(child: Text('No data for plotting provided...'))
        : LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                      ),
                      borderData: FlBorderData(
                        show: true,
                      ),
                      // Determines precision of y-axis based on max precision of first elements
                      titlesData: LineTitles.getBarTitles(widget.groupTitles, LineTitles.getMaxPrecision(widget.groupDatas[0].values.toList(), 8)),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          fitInsideVertically: true,
                          fitInsideHorizontally: true,
                        ),
                      ),
                      barGroups: List.generate(
                        enabledPlots,
                        (index) {
                          // Index of first element that is enabled.
                          int ind = widget.groupStatuses.indexOf(true, index);
                          return BarChartGroupData(
                            x: index,
                            barRods: List.generate(
                              widget.groupDatas[ind].length,
                              (idx) => BarChartRodData(
                                toY: widget.groupDatas[ind].values.toList()[idx],
                                color: uniqueColors[uniquePlots.indexOf(widget.groupDatas[ind].keys.toList()[idx])],
                                width: constraints.maxWidth / (2 * bars),
                                borderRadius: BorderRadius.circular(0),
                                backDrawRodData: BackgroundBarChartRodData(show: true, color: Colors.white, toY: widget.groupDatas[ind].values.toList()[idx]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  child: Row(
                    children: List.generate(
                      uniquePlots.length,
                      (index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  Icons.rectangle,
                                  size: 18,
                                  color: uniqueColors[index],
                                ),
                              ),
                              TextSpan(
                                text: ' ${uniquePlots[index]}',
                                style: TextStyle(
                                  color: themeManager.isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          });
  }
}

/// Bar Graph widget specific for transformer capacity.
/// All values are percentage based and should be between 0 and 100%.
/// Contains utility for enabling and disabling graphs.
class CapacityBarChart extends StatefulWidget {
  final List groupDatas;
  final List<bool> groupStatuses;
  final List groupTitles;
  const CapacityBarChart({super.key, required this.groupDatas, required this.groupStatuses, required this.groupTitles});

  @override
  State<CapacityBarChart> createState() => _CapacityBarChartState();
}

class _CapacityBarChartState extends State<CapacityBarChart> {
  @override
  Widget build(BuildContext context) {
    // In short, the widget contains a bargraph view with below
    // a legend containing which color belongs to which graph type.
    //
    // The precision of the y-axis is determined by the
    // max precision of the first variable.
    //
    // Every unique graph is assigned to a single color.
    // This is the same for all bar groups.
    //
    // Depending on the value of [groupStatuses],
    // A graph can be visible or invisible.
    //
    // All values are percentage based and should be between 0 and 100.
    // If a value is greater than 100, it will be capped to 100.
    // If a value is lower than 0, it will set to 0.
    //
    // The widget has the following structure:
    //
    //    Center
    //    ---Column
    //    ------Expanded
    //    ---------BarChart
    //    ------FittedBox
    //    ---------Row
    //    ------------RichText

    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    final TableHandler tableHandler = Provider.of<TableHandler>(context);

    // List of unique plot titles.
    List uniquePlots = [];
    for (var element in widget.groupDatas) {
      element.keys.forEach((key) {
        if (!uniquePlots.contains(key)) {
          uniquePlots.add(key);
        }
      });
    }

    // Number of enabled plots.
    int bars = 0;
    int enabledPlots = 0;

    for (int i = 0; i < widget.groupStatuses.length; i++) {
      if (widget.groupStatuses[i]) {
        enabledPlots += 1;
        bars += widget.groupDatas[i].length as int;
      }
    }

    return widget.groupDatas.isEmpty
        ? const Center(child: Text('No data for plotting provided...'))
        : LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(
                        show: true,
                      ),
                      borderData: FlBorderData(
                        show: true,
                      ),
                      // Determines precision of y-axis based on max precision of first elements
                      titlesData: LineTitles.getCapacityBarTitles(widget.groupTitles, LineTitles.getMaxPrecision(widget.groupDatas[0].values.toList(), 8)),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          fitInsideVertically: true,
                          fitInsideHorizontally: true,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                            widget.groupDatas[groupIndex].values.toList()[rodIndex].toString(),
                            const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        enabledPlots,
                        (index) {
                          // Index of first element that is enabled.
                          int ind = widget.groupStatuses.indexOf(true, index);
                          return BarChartGroupData(
                            x: index,
                            barRods: List.generate(
                              widget.groupDatas[ind].length,
                              (idx) {
                                var barLevel = widget.groupDatas[ind].values.toList()[idx];

                                if (barLevel > 100) {
                                  barLevel = 100.0;

                                  tableHandler.logManager.addLog(LogEntry(
                                    LogLevels.warning,
                                    'A value within the snapshot data of the capacity charts has exceeded 100%',
                                    'Data exceeded limit.',
                                    DateTime.now().toString(),
                                  ));
                                }

                                if (barLevel < 0) {
                                  barLevel = 0.0;

                                  tableHandler.logManager.addLog(LogEntry(
                                    LogLevels.warning,
                                    'A value within the snapshot data of the capacity charts was below 0%',
                                    'Data below minimum.',
                                    DateTime.now().toString(),
                                  ));
                                }

                                return BarChartRodData(
                                  toY: 100,
                                  color: uniqueColors[uniquePlots.indexOf(widget.groupDatas[ind].keys.toList()[idx])],
                                  width: constraints.maxWidth / (2 * bars),
                                  borderRadius: BorderRadius.circular(0),
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                      0,
                                      widget.groupDatas[ind].values.toList()[idx],
                                      uniqueColors[uniquePlots.indexOf(widget.groupDatas[ind].keys.toList()[idx])],
                                    ),
                                    BarChartRodStackItem(
                                      widget.groupDatas[ind].values.toList()[idx],
                                      100,
                                      Colors.greenAccent,
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  child: Row(
                    children: List.generate(
                          uniquePlots.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.rectangle,
                                      size: 18,
                                      color: uniqueColors[index],
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${uniquePlots[index]}',
                                    style: TextStyle(
                                      color: themeManager.isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ) +
                        [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const WidgetSpan(
                                    child: Icon(
                                      Icons.rectangle,
                                      size: 18,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Remaining',
                                    style: TextStyle(
                                      color: themeManager.isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                  ),
                )
              ],
            );
          });
  }
}
