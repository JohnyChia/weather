import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/hourly_data.dart';

enum ChartView { dailyForecast, multidaysForecast, hourlyForecast, hourlyIndexForecast }

class ChartScreen extends StatefulWidget {
  final List<HourlyData> hourlyData;

  const ChartScreen({
    super.key,
    required this.hourlyData,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  ChartView _selectedView = ChartView.hourlyForecast;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chart')),
      body: Column(
        children: [
          _buildSelector(),
          const SizedBox(height: 20),
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildSelector() {
    final isSunSelected = _selectedView == ChartView.hourlyForecast;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isSunSelected
            ? Colors.grey.shade200
            : Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSelectorOption(ChartView.dailyForecast, 'Daily Weather Forecast'),
          _buildSelectorOption(ChartView.multidaysForecast, 'Multi 5-days Forecast'),
          _buildSelectorOption(ChartView.hourlyIndexForecast, 'Hourly UV Index Forecast'),

        ],
      ),
    );
  }

  Widget _buildSelectorOption(ChartView view, String title) {
    final isSelected = _selectedView == view;
    final isSunView = _selectedView == ChartView.hourlyForecast;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedView = view;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isSunView ? Colors.white : Colors.blueGrey.shade700)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected && isSunView
                ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1
                  )]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSunView ? Colors.black87 : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    List<String> xLabels = [];
    List<double> temperature = [];
    List<double> humidity = [];

    if (_selectedView == ChartView.dailyForecast) {
      String today = widget.hourlyData.first.weatherDate;

      for (var data in widget.hourlyData) {
        if (data.weatherDate == today) {
          xLabels.add(data.weatherTime);
          temperature.add(data.temp);
          humidity.add(data.humidity.toDouble());
        }
      }
    }
    else if (_selectedView == ChartView.multidaysForecast) {

      for(var data in widget.hourlyData) {
        xLabels.add(data.weatherDate);
        temperature.add(data.temp);
        humidity.add(data.humidity.toDouble());
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: xLabels.length * 100,
        height: 350,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 100,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index < 0 || index >= xLabels.length)
                      return const SizedBox();
                    return Text(
                      xLabels[index],
                      style: const TextStyle(fontSize: 13),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  temperature.length,
                      (i) => FlSpot(i.toDouble(), temperature[i]),
                ),
                isCurved: true,
                color: Colors.red,
                barWidth: 4,
              ),
              LineChartBarData(
                spots: List.generate(
                  humidity.length,
                      (i) => FlSpot(i.toDouble(), humidity[i]),
                ),
                isCurved: true,
                color: Colors.blue,
                barWidth: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



