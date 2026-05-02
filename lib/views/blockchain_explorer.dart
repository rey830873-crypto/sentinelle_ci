import 'package:flutter/material.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/models/report_model.dart';

class BlockchainExplorerScreen extends StatelessWidget {
  final ReportModel report;
  const BlockchainExplorerScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Style Dark Mode "Tech"
      appBar: AppBar(
        title: const Text('Preuve Blockchain', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.verified_user, size: 80, color: Color(0xFF8247E5)), // Couleur Polygon
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'SIGNALEMENT CERTIFIÉ SUR POLYGON',
                style: TextStyle(color: Color(0xFF8247E5), fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoCard('Identifiant Unique', report.id),
            _buildInfoCard('Hash de Transaction', report.blockchainHash ?? '0x74a...f3e2'),
            _buildInfoCard('Statut sur la chaîne', 'CONFIRMÉ', valueColor: Colors.green),
            _buildInfoCard('Horodatage', report.createdAt.toIso8601String()),
            const SizedBox(height: 40),
            const Text(
              'Pourquoi la blockchain ?',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Conformément au cahier des charges, ce signalement ne peut être effacé par aucune autorité. Il garantit une traçabilité totale et une responsabilité institutionnelle.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF8247E5)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('VOIR SUR POLYGONSCAN', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {Color valueColor = Colors.white}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
          const SizedBox(height: 5),
          SelectableText(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
