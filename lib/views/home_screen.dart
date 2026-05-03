import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/viewmodels/auth_viewmodel.dart';
import 'package:sentinelle_ci/viewmodels/report_viewmodel.dart';
import 'package:sentinelle_ci/models/user_model.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'package:sentinelle_ci/widgets/report_card.dart';
import 'package:sentinelle_ci/views/welcome_screen.dart';
import 'package:sentinelle_ci/views/create_report_screen.dart';
import 'package:sentinelle_ci/views/report_list_screen.dart';
import 'package:sentinelle_ci/views/profile_screen.dart';
import 'package:sentinelle_ci/views/map_screen.dart';
import 'package:sentinelle_ci/views/admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // Cache des instances d'écrans pour éviter les clignotements et pertes de focus
  final Map<UserRole, List<Widget>> _screensCache = {};

  List<Widget> _getScreens(UserRole? role) {
    final effectiveRole = role ?? UserRole.citizen;
    
    // Si déjà en cache, on retourne la liste existante
    if (_screensCache.containsKey(effectiveRole)) {
      return _screensCache[effectiveRole]!;
    }

    List<Widget> screens;
    if (effectiveRole == UserRole.administrator) {
      screens = [
        const AdminDashboard(),
        const MapScreen(),
        const ProfileScreen(),
      ];
    } else {
      screens = [
        const HomeContent(),
        const ReportListScreen(),
        const CreateReportScreen(), // Version onglet (isPushed: false par défaut)
        const MapScreen(),
        const ProfileScreen(),
      ];
    }
    
    _screensCache[effectiveRole] = screens;
    return screens;
  }

  List<BottomNavigationBarItem> _getNavItems(bool isAdmin) {
    if (isAdmin) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Carte'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ];
    }
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
      BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Suivi'),
      BottomNavigationBarItem(
        icon: CircleAvatar(
          backgroundColor: AppColors.primaryOrange,
          child: Icon(Icons.add, color: Colors.white),
        ),
        label: 'Signaler',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Carte'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final isAdmin = user?.role == UserRole.administrator;
    
    final screens = _getScreens(user?.role);
    final navItems = _getNavItems(isAdmin);

    // Sécurité renforcée sur l'index
    int safeIndex = _selectedIndex;
    if (safeIndex >= screens.length) {
      safeIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textLight,
        onTap: (index) {
          if (index < screens.length) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: navItems,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primaryGreen),
                      Text(
                        'SentinelleCI',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          authViewModel.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 30),
              Text(
                '${_getGreeting()}, ${user?.name.split(' ').first ?? ""}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text('Votre quartier compte sur vos yeux aujourd\'hui.'),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryItem(context, Icons.edit_road, 'Routes', ReportCategory.routes),
                    _buildCategoryItem(context, Icons.lightbulb_outline, 'Éclairage', ReportCategory.lighting),
                    _buildCategoryItem(context, Icons.water_drop_outlined, 'Eau', ReportCategory.water),
                    _buildCategoryItem(context, Icons.delete_outline, 'Déchets', ReportCategory.waste),
                    _buildCategoryItem(context, Icons.health_and_safety_outlined, 'Santé', ReportCategory.health),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Consumer<ReportViewModel>(
                builder: (context, reportVm, child) {
                  return Row(
                    children: [
                      _StatCard(count: reportVm.reports.where((r) => r.userId == (user?.id ?? '')).length, label: 'Mes Signalements', icon: Icons.layers_outlined),
                      const SizedBox(width: 8),
                      _StatCard(count: reportVm.inProgressCount, label: 'En cours', icon: Icons.schedule, color: Colors.orange),
                      const SizedBox(width: 8),
                      _StatCard(count: reportVm.reports.where((r) => r.userId == (user?.id ?? '') && r.status == ReportStatus.resolved).length, label: 'Mes Résolus', icon: Icons.check_circle_outline, color: Colors.green),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReportScreen(isPushed: true)));
                },
                child: _ActionBanner(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Près de chez vous',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text('Signalements récents', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
              const SizedBox(height: 10),
              Consumer<ReportViewModel>(
                builder: (context, vm, child) {
                  if (vm.reports.isEmpty && vm.isLoading) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (vm.reports.isEmpty) {
                    return const Center(child: Text('Aucun signalement pour le moment.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.reports.length > 3 ? 3 : vm.reports.length,
                    itemBuilder: (context, index) {
                      return ReportCard(report: vm.reports[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  Widget _buildCategoryItem(BuildContext context, IconData icon, String label, ReportCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateReportScreen(initialCategory: category, isPushed: true),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color? color;

  const _StatCard({required this.count, required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color ?? AppColors.primaryGreen, size: 20),
            const SizedBox(height: 8),
            Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signaler un problème',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Photo, lieu, description — 30 secondes',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }
}
