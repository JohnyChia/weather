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
          _buildSelectorOption(ChartView.hourlyForecast, 'Multi-Hourly Forecast'),
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
                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)]
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
    final xLabels = _selectedView == ChartView.hourlyForecast
        ? widget.hourlyData.map((e) => e.weatherTime).toList()
        : widget.hourlyData.map((e) => e.weatherDate).toList();

    final tempValues = widget.hourlyData.map((e) => e.temp).toList();
    final humidityValues = widget.hourlyData.map((e) => e.humidity.toDouble()).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: xLabels.length * 50.0,
        height: 300,
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
                    final index = value.toInt();
                    if (index < 0 || index >= xLabels.length) return const SizedBox();
                    return Text(xLabels[index], style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  getTitlesWidget: (value, meta) => Text('${value.toInt()}°C', style: const TextStyle(color: Colors.red)),
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(color: Colors.blue)),
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(tempValues.length, (i) => FlSpot(i.toDouble(), tempValues[i])),
                isCurved: true,
                color: Colors.red,
                barWidth: 3,
              ),
              LineChartBarData(
                spots: List.generate(humidityValues.length, (i) => FlSpot(i.toDouble(), humidityValues[i])),
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



