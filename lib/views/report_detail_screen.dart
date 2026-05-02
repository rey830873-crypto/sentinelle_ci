import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/views/blockchain_explorer.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détails du signalement', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageHeader(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.title, 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)
                  )
                ),
                _buildStatusChip(report.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 16),
                const SizedBox(width: 4),
                Text(
                  report.location, 
                  style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w500)
                ),
              ],
            ),
            const Divider(height: 40),
            const Text(
              'DESCRIPTION', 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 1.2)
            ),
            const SizedBox(height: 12),
            Text(
              report.description, 
              style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.textDark)
            ),
            const SizedBox(height: 30),
            
            const Text(
              'SUIVI DU DOSSIER', 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 1.2)
            ),
            const SizedBox(height: 20),
            _buildTimelineItem('Signalement reçu', 'Enregistré sur le registre immuable', report.createdAt, true),
            _buildTimelineItem('Analyse technique', 'Vérification par les services compétents', null, report.status != ReportStatus.submitted),
            _buildTimelineItem('Résolution', 'Intervention sur le terrain', null, report.status == ReportStatus.resolved),
            
            const SizedBox(height: 40),
            _buildBlockchainCard(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return Hero(
      tag: 'report_image_${report.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey.shade200),
          child: report.imageUrl != null && report.imageUrl!.isNotEmpty
              ? (report.imageUrl!.startsWith('http')
                  ? Image.network(report.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
                  : Image.file(File(report.imageUrl!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder()))
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 60, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text('Aucune image disponible', style: TextStyle(color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    Color color;
    switch (status) {
      case ReportStatus.submitted: color = Colors.blue; break;
      case ReportStatus.validated: color = Colors.orange; break;
      case ReportStatus.inProgress: color = Colors.purple; break;
      case ReportStatus.resolved: color = Colors.green; break;
      case ReportStatus.rejected: color = Colors.red; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.name.toUpperCase(), 
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, DateTime? date, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                isDone ? Icons.check_circle : Icons.circle_outlined, 
                color: isDone ? AppColors.primaryGreen : Colors.grey.shade300, 
                size: 20
              ),
              if (title != 'Résolution') 
                Container(width: 2, height: 30, color: Colors.grey.shade200),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? AppColors.textDark : Colors.grey)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (date != null)
            Text(
              '${date.day}/${date.month}', 
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400)
            ),
        ],
      ),
    );
  }

  Widget _buildBlockchainCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8247E5), Color(0xFF5E2AB2)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8247E5).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => BlockchainExplorerScreen(report: report))
          ),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.security, color: Colors.white),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Certification Blockchain', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                      Text(
                        'Preuve d\'intégrité Polygon POS', 
                        style: TextStyle(color: Colors.white70, fontSize: 12)
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
