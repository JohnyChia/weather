import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SolarScreen extends StatelessWidget {
  final DateTime? peakStart;
  final DateTime? peakEnd;
  final List<double>? score;

  const SolarScreen({
    super.key,
    this.peakStart,
    this.peakEnd,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Solar Energy'
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSolarInfoCard(
              title: 'Peak Period Start',
              time: peakStart,
              icon: Icons.wb_sunny_outlined,
              gradientColors: [Colors.orange.shade100, Colors.yellow.shade200],
            ),
            const SizedBox(height: 12),
            _buildSolarInfoCard(
              title: 'Peak Period End',
              time: peakEnd,
              icon: Icons.nightlight_outlined,
              gradientColors: [Colors.purple.shade100, Colors.pink.shade100],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A47),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Solar Energy Score',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarInfoCard({
    required String title,
    required DateTime? time,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    final formattedTime = time != null ? DateFormat('h:mm a').format(time.toLocal()) : '--:--';
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children:
          [Icon(
              icon,
              size: 20,
              color: Colors.black54
          ),
            const SizedBox(width: 8),
            Text(
                title.toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54
                )
            )
          ]),
          Text(
              formattedTime,
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87
              )
          ),
        ],
      ),
    );
  }

}

