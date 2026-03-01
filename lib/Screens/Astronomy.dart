import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AstronomyView { sun, moon }

class AstronomyScreen extends StatefulWidget {
  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? moonrise;
  final DateTime? moonset;
  final String? moonPhase;
  final double? uvIndex;

  const AstronomyScreen({
    super.key,
    this.sunrise,
    this.sunset,
    this.moonrise,
    this.moonset,
    this.moonPhase,
    this.uvIndex
  });

  @override
  State<AstronomyScreen> createState() => _AstronomyScreenState();
}

class _AstronomyScreenState extends State<AstronomyScreen> {
  AstronomyView _selectedView = AstronomyView.sun;

  @override
  Widget build(BuildContext context) {
    final isSunSelected = _selectedView == AstronomyView.sun;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Astronomy'),
        backgroundColor: isSunSelected ? Colors.white : const Color(0xFF0C1428),
        foregroundColor: isSunSelected ? Colors.black87 : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isSunSelected ? Colors.white : const Color(0xFF0C1428),
      body: Column(
        children: [
          _buildSelector(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSelectedView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector() {
    final isSunSelected = _selectedView == AstronomyView.sun;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isSunSelected ? Colors.grey.shade200 : Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSelectorOption(AstronomyView.sun, 'Sunset/Sunrise'),
          _buildSelectorOption(AstronomyView.moon, 'Moon Phase'),
        ],
      ),
    );
  }

  Widget _buildSelectorOption(AstronomyView view, String title) {
    final isSelected = _selectedView == view;
    final isSunView = _selectedView == AstronomyView.sun;
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
            color: isSelected ? (isSunView ? Colors.white : Colors.blueGrey.shade700) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected && isSunView ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)] : [],
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

  Widget _buildSelectedView() {
    switch (_selectedView) {
      case AstronomyView.sun:
        return _buildSunView();
      case AstronomyView.moon:
        return _buildMoonView();
    }
  }

  Widget _buildSunView() {
    String daylightDuration = '-- hours -- minutes';
    String peakSunRange = '--:-- - --:--';

    if (widget.sunrise != null && widget.sunset != null) {
      final duration = widget.sunset!.difference(widget.sunrise!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      daylightDuration = '$hours hours $minutes minutes';

      // Calculate the peak sun hours for solar energy & UV index
      final solarNoon = widget.sunrise!.add(duration ~/ 2);
      final peakStart = solarNoon.subtract(const Duration(hours: 2));
      final peakEnd = solarNoon.add(const Duration(hours: 2));
      peakSunRange = '${DateFormat.jm().format(peakStart)} - ${DateFormat.jm().format(peakEnd)}';
    }

    return Column(
      children: [
        _buildSunInfoCard(
          title: 'Sunrise',
          time: widget.sunrise,
          icon: Icons.wb_sunny_outlined,
          description: 'Dawn starts approximately 30 minutes before',
          gradientColors: [Colors.orange.shade100, Colors.yellow.shade200],
        ),
        const SizedBox(height: 12),
        _buildSunInfoCard(
          title: 'Sunset',
          time: widget.sunset,
          icon: Icons.nightlight_outlined,
          description: 'Dusk continues approximately 30 minutes after',
          gradientColors: [Colors.purple.shade100, Colors.pink.shade100],
        ),
        const SizedBox(height: 12),
        _buildDaylightCard('DAYLIGHT DURATION', daylightDuration, Icons.hourglass_bottom),
        const SizedBox(height: 12),

        _buildDaylightCard('PEAK SOLAR ENERGY', peakSunRange, Icons.solar_power_outlined),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMoonView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A47),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Phase', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),

          Text(widget.moonPhase ?? 'Waxing Crescent', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Row(children: [
            Icon(
                Icons.brightness_6_outlined,
                color: Colors.white70, size: 16
            ),
            SizedBox(width: 4),
          ]),
          const Divider(color: Colors.white24, height: 30),
          _buildMoonTimeRow('Moonrise', widget.moonrise),
          const SizedBox(height: 10),

          _buildMoonTimeRow('Moonset', widget.moonset),
          const Divider(color: Colors.white24, height: 30),
          Center(
            child: Icon(Icons.nightlight_round, size: 80, color: Colors.yellow.shade100),
          ),
        ],
      ),
    );
  }

  Widget _buildSunInfoCard({
    required String title,
    required DateTime? time,
    required IconData icon,
    required String description,
    required List<Color> gradientColors,
  }) {
    final formattedTime = time != null ? DateFormat('h:mm a').format(time.toLocal()) : '--:--';
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 20, color: Colors.black54), const SizedBox(width: 8), Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))]),
          const SizedBox(height: 8),
          Text(formattedTime, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w300, color: Colors.black87)),
          const SizedBox(height: 8),
          // FIX: Added the missing description text
          Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  // This helper is now more reusable for both Daylight and Solar cards
  Widget _buildDaylightCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const Spacer(), // This pushes the value to the far right
          Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMoonTimeRow(String title, DateTime? time) {
    final formattedTime = time != null ? DateFormat('h:mm a').format(time.toLocal()) : '--:--';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(formattedTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
