import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/viewmodels/report_viewmodel.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'package:sentinelle_ci/widgets/report_card.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final reportViewModel = context.watch<ReportViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tableau de Bord Communal', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
            onPressed: () => reportViewModel.fetchReports(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryRibbon(reportViewModel),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('SIGNALEMENTS À TRAITER', 
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
            ),
          ),
          Expanded(
            child: reportViewModel.reports.isEmpty && reportViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : reportViewModel.reports.isEmpty
                    ? const Center(child: Text('Aucun signalement à traiter.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: reportViewModel.reports.length,
                        itemBuilder: (context, index) {
                          final report = reportViewModel.reports[index];
                          return InkWell(
                            onTap: () => _showActionDialog(context, report),
                            child: ReportCard(report: report),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRibbon(ReportViewModel viewModel) {
    final submittedCount = viewModel.reports.where((r) => r.status == ReportStatus.submitted).length;
    final inProgressCount = viewModel.reports.where((r) => r.status == ReportStatus.inProgress || r.status == ReportStatus.validated).length;
    final resolvedCount = viewModel.reports.where((r) => r.status == ReportStatus.resolved).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      color: AppColors.primaryGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AdminStat(label: 'Nouveaux', value: submittedCount.toString(), color: Colors.white),
          _AdminStat(label: 'En cours', value: inProgressCount.toString(), color: Colors.orange),
          _AdminStat(label: 'Résolus', value: resolvedCount.toString(), color: Colors.greenAccent),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, ReportModel report) {
    final reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(report.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _ActionButton(
              label: 'Valider le signalement', 
              icon: Icons.check_circle, 
              color: Colors.blue, 
              onTap: () {
                reportViewModel.updateStatus(report.id, ReportStatus.validated);
                Navigator.pop(context);
              }
            ),
            _ActionButton(
              label: 'Lancer l\'intervention', 
              icon: Icons.engineering, 
              color: Colors.orange, 
              onTap: () {
                reportViewModel.updateStatus(report.id, ReportStatus.inProgress);
                Navigator.pop(context);
              }
            ),
            _ActionButton(
              label: 'Marquer comme Résolu', 
              icon: Icons.task_alt, 
              color: Colors.green, 
              onTap: () {
                reportViewModel.updateStatus(report.id, ReportStatus.resolved);
                Navigator.pop(context);
              }
            ),
            _ActionButton(
              label: 'Rejeter le signalement', 
              icon: Icons.cancel_outlined, 
              color: Colors.red, 
              onTap: () {
                reportViewModel.updateStatus(report.id, ReportStatus.rejected);
                Navigator.pop(context);
              }
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Annuler', style: TextStyle(color: Colors.grey))
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AdminStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}
