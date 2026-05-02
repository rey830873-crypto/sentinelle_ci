import 'package:flutter/material.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rankings = [
      {'commune': 'Cocody', 'points': 12500, 'reports': 450, 'trend': Icons.trending_up, 'color': Colors.amber},
      {'commune': 'Yopougon', 'points': 11200, 'reports': 890, 'trend': Icons.trending_up, 'color': Colors.grey.shade400},
      {'commune': 'Marcory', 'points': 9800, 'reports': 320, 'trend': Icons.trending_down, 'color': Colors.brown.shade300},
      {'commune': 'Treichville', 'points': 8500, 'reports': 210, 'trend': Icons.trending_flat, 'color': Colors.blueGrey},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Classement Citoyen', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.primaryGreen,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VOTRE COMMUNE', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('Cocody', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.emoji_events, color: Colors.amber, size: 50),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                final item = rankings[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item['color'],
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(item['commune'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['reports']} signalements résolus'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item['points']} pts', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                        Icon(item['trend'] as IconData, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
