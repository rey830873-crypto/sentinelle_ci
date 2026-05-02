import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/viewmodels/auth_viewmodel.dart';
import 'package:sentinelle_ci/viewmodels/report_viewmodel.dart';
import 'package:sentinelle_ci/views/blockchain_explorer.dart';
import 'package:sentinelle_ci/views/report_detail_screen.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final reportViewModel = context.read<ReportViewModel>();
    final userId = authViewModel.currentUser?.id;
    final hasVoted = userId != null && report.upvotedBy.contains(userId);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReportDetailScreen(report: report)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(10)),
                child: Icon(_getCategoryIcon(report.category), color: AppColors.primaryGreen),
              ),
              title: Text(
                '${report.title} • ${report.location}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${_formatDate(report.createdAt)} • ${report.isAnonymous ? "Anonyme" : report.userName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: _StatusBadge(status: report.status),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (userId != null && !hasVoted) {
                        reportViewModel.vote(report.id, userId);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasVoted ? Icons.thumb_up : Icons.thumb_up_off_alt,
                          size: 18,
                          color: hasVoted ? AppColors.primaryOrange : AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${report.votes} soutiens',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: hasVoted ? FontWeight.bold : FontWeight.normal,
                            color: hasVoted ? AppColors.primaryOrange : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (report.isUrgent)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text('IA URGENT', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlockchainExplorerScreen(report: report))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF8247E5).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link, size: 14, color: Color(0xFF8247E5)),
                              SizedBox(width: 4),
                              Text('Blockchain', style: TextStyle(fontSize: 10, color: Color(0xFF8247E5), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ReportCategory category) {
    switch (category) {
      case ReportCategory.routes: return Icons.edit_road;
      case ReportCategory.lighting: return Icons.lightbulb_outline;
      case ReportCategory.pollution: return Icons.factory_outlined;
      case ReportCategory.waste: return Icons.delete_outline;
      case ReportCategory.water: return Icons.water_drop_outlined;
      case ReportCategory.health: return Icons.health_and_safety_outlined;
      default: return Icons.report_problem_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inDays > 0) return 'il y a ${duration.inDays}j';
    if (duration.inHours > 0) return 'il y a ${duration.inHours}h';
    if (duration.inMinutes > 0) return 'il y a ${duration.inMinutes}m';
    return "À l'instant";
  }
}

class _StatusBadge extends StatelessWidget {
  final ReportStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    
    switch (status) {
      case ReportStatus.submitted:
        color = Colors.blue;
        label = 'Soumis';
        break;
      case ReportStatus.validated:
        color = Colors.orange;
        label = 'Validé';
        break;
      case ReportStatus.inProgress:
        color = Colors.purple;
        label = 'En cours';
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        label = 'Résolu';
        break;
      case ReportStatus.rejected:
        color = Colors.red;
        label = 'Rejeté';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(8)
      ),
      child: Text(
        label, 
        style: TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.bold,
          color: color,
        )
      ),
    );
  }
}
