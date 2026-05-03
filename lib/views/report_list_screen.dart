import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/viewmodels/report_viewmodel.dart';
import 'package:sentinelle_ci/widgets/report_card.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'create_report_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  String _activeFilter = 'Tous';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Signalements', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: Consumer<ReportViewModel>(
        builder: (context, vm, child) {
          final filteredReports = _getFilteredReports(vm);
          
          return Column(
            children: [
              _buildSummaryCards(vm),
              _buildFilterTabs(vm),
              Expanded(
                child: filteredReports.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredReports.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filteredReports.length) return const _PriorityLegend();
                          return ReportCard(report: filteredReports[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<ReportModel> _getFilteredReports(ReportViewModel vm) {
    switch (_activeFilter) {
      case 'En cours':
        return vm.reports.where((r) => r.status == ReportStatus.inProgress || r.status == ReportStatus.validated).toList();
      case 'Résolus':
        return vm.reports.where((r) => r.status == ReportStatus.resolved).toList();
      case 'Urgents':
        return vm.reports.where((r) => r.isUrgent).toList();
      default:
        return vm.reports;
    }
  }

  Widget _buildSummaryCards(ReportViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _SummaryCard(count: vm.submittedCount, label: 'Soumis', icon: Icons.sync, color: Colors.teal),
          const SizedBox(width: 10),
          _SummaryCard(count: vm.inProgressCount, label: 'En cours', icon: Icons.wb_sunny_outlined, color: Colors.orange),
          const SizedBox(width: 10),
          _SummaryCard(count: vm.resolvedCount, label: 'Résolus', icon: Icons.check_circle_outline, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(ReportViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tous', 
            count: vm.reports.length, 
            isSelected: _activeFilter == 'Tous',
            onTap: () => setState(() => _activeFilter = 'Tous'),
          ),
          _FilterChip(
            label: 'En cours', 
            count: vm.inProgressCount, 
            isSelected: _activeFilter == 'En cours',
            onTap: () => setState(() => _activeFilter = 'En cours'),
          ),
          _FilterChip(
            label: 'Résolus', 
            count: vm.resolvedCount, 
            isSelected: _activeFilter == 'Résolus',
            onTap: () => setState(() => _activeFilter = 'Résolus'),
          ),
          _FilterChip(
            label: 'Urgents', 
            count: vm.urgentCount, 
            isSelected: _activeFilter == 'Urgents',
            onTap: () => setState(() => _activeFilter = 'Urgents'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun signalement pour l\'instant',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'Repérez un nid de poule, un lampadaire éteint, une fuite d\'eau ? Faites-le savoir à votre commune en deux minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReportScreen(isPushed: true)));
              },
              icon: const Icon(Icons.add),
              label: const Text('Faire mon premier signalement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.count, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.count, required this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.textDark : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityLegend extends StatelessWidget {
  const _PriorityLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Légende des priorités', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _LegendItem(color: Colors.grey.shade400, label: 'Soumis : En attente de lecture par la mairie'),
          _LegendItem(color: Colors.blue.shade400, label: 'Validé : Problème confirmé, en attente d\'équipe'),
          _LegendItem(color: Colors.orange.shade400, label: 'En cours : Équipe d\'intervention sur place'),
          _LegendItem(color: AppColors.successGreen, label: 'Résolu : Travaux terminés et vérifiés'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight))),
        ],
      ),
    );
  }
}
