import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineTitles {
  static String getTimestamp(double value, int intervals) {
    // Using the index and the number of intervals
    // the timestamp is determined in decimals.
    double time = value != 0 ? value * (24 / intervals) : 0.0;
    // Timestamp is converted from decimals to hour
    // by removing the remainder.
    int hour = time.floor();
    // Remaining minutes are calculated
    // by multiplying the remainder with 60s.
    int minute = ((time - hour) * 60).ceil();
    // Timestamp are converted to hh:ss format.
    String displayHour = hour.toString().length == 1 ? '0$hour' : hour.toString();
    String displayMinute = minute.toString().length == 1 ? '0$minute' : minute.toString();
    return '$displayHour:$displayMinute';
  }

  static getTitleData(int intervals, int precision) => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              String timestamp = getTimestamp(value, intervals);
              // Calculates font size of axis values
              // Overlap can occur right before the axes are changed.
              double fontResizerCoeff = pow(meta.appliedInterval, 1.75) * 0.5;
              double axisSize = intervals / meta.appliedInterval * 34;
              double fontSize = axisSize >= meta.parentAxisSize ? 14 - ((axisSize - meta.parentAxisSize) / ((intervals) * meta.appliedInterval) * fontResizerCoeff) : 14;
              // Returned axis value with the corresponding font size. Min and max values are excluded since they are not layouted properly
              return value == meta.max || value == meta.min ? const Text('') : Text(timestamp, style: TextStyle(fontSize: fontSize));
            },
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            // Axis size depends on precision of number
            reservedSize: (precision * 8) + 16,
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return !(value == meta.max || value == meta.min)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(value.toStringAsPrecision(value >= 1 || value <= -1 ? precision : precision - 1)),
                    )
                  : const Text('');
            },
          ),
        ),
      );

  static getBarTitles(List titles, int precision) => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(titles[value.toInt()]);
            },
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            // Axis size depends on precision of number
            reservedSize: (precision * 8) + 16,
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return !(value == meta.max || value == meta.min)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(value.toStringAsPrecision(precision)),
                    )
                  : const Text('');
            },
          ),
        ),
      );

  static getCapacityBarTitles(List titles, int precision) => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(titles[value.toInt()]);
            },
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: const Text('Capacity'),
          axisNameSize: 32,
          sideTitles: SideTitles(
            // Axis size depends on precision of number
            reservedSize: (precision * 8) + 24,
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return !(value == meta.max || value == meta.min)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text('${value.toStringAsPrecision(precision)}%'),
                    )
                  : const Text('');
            },
          ),
        ),
      );

  static int getMaxPrecision(List array, int? maxPrecision) {
    int precision = 0;
    for (var val in array) {
      precision = max(precision, val.toString().length - 1);
    }
    return maxPrecision != null
        ? precision > maxPrecision
            ? maxPrecision
            : precision
        : precision;
  }
}
