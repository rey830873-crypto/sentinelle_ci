import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/viewmodels/auth_viewmodel.dart';
import 'package:sentinelle_ci/views/leaderboard_screen.dart';
import 'package:sentinelle_ci/views/report_list_screen.dart';
import 'package:sentinelle_ci/models/user_model.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'package:sentinelle_ci/views/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;
    final isAnonymous = user?.isAnonymous ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Modification du profil bientôt disponible'))
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Profil
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primaryGreen,
                          child: Icon(Icons.person, size: 55, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
                          child: const Icon(Icons.verified, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    user?.name ?? 'Utilisateur',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? 'citoyen@sentinelle.ci',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  if (user?.role == UserRole.citizen)
                    const SizedBox(height: 5),
                  if (user?.role == UserRole.citizen)
                    Text(
                      'Membre depuis ${DateTime.now().year}',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: user?.role == UserRole.administrator 
                          ? Colors.red.withValues(alpha: 0.1) 
                          : AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role == UserRole.administrator ? 'ADMINISTRATEUR' : 'CITOYEN SENTINELLE',
                      style: TextStyle(
                        color: user?.role == UserRole.administrator ? Colors.red : AppColors.primaryOrange, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 12
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Statistiques
            if (user?.role == UserRole.citizen)
              Row(
                children: [
                  _buildStatCard('Points', '${user?.points ?? 0}', Icons.stars, Colors.amber),
                  _buildStatCard('Signalements', '${user?.reportCount ?? 0}', Icons.campaign, Colors.blue),
                  _buildStatCard('Résolus', '${user?.resolvedCount ?? 0}', Icons.check_circle, Colors.green),
                ],
              ),
            const SizedBox(height: 25),

            // Badges
            if (user?.role == UserRole.citizen) ...[
              _buildSectionTitle('MES BADGES'),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: (user?.badges ?? ['Nouveau']).map((badge) => _buildBadgeChip(badge)).toList(),
                ),
              ),
              const SizedBox(height: 25),
            ],

            // Paramètres
            if (user?.role == UserRole.citizen)
              _buildSectionTitle('PARAMÈTRES DE CONFIDENTIALITÉ'),
            if (user?.role == UserRole.citizen)
              _buildToggleTile(
                icon: Icons.visibility_off_outlined,
                title: 'Mode Anonyme',
                subtitle: 'Masquer mon nom sur les signalements publics',
                value: isAnonymous,
                onChanged: (val) => auth.updateAnonymity(val),
              ),
            _buildToggleTile(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              subtitle: 'Alertes de suivi de mes signalements',
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle('COMPTE & SÉCURITÉ'),
            _buildActionTile(
              icon: Icons.history,
              title: 'Historique de mes activités',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportListScreen()),
                );
              },
            ),
            _buildActionTile(
              icon: Icons.emoji_events_outlined,
              title: 'Classement des communes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                );
              },
            ),
            _buildActionTile(
              icon: Icons.info_outline,
              title: 'À propos de SentinelleCI',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'SentinelleCI',
                  applicationVersion: '1.0.0 (Bêta Jury)',
                  applicationIcon: const Icon(Icons.security, color: AppColors.primaryGreen, size: 50),
                  children: [
                    const Text(
                      'SentinelleCI est une plateforme citoyenne innovante utilisant '
                      'la Blockchain pour améliorer la gestion urbaine en Côte d\'Ivoire.',
                    ),
                    const SizedBox(height: 10),
                    const Text('Développé pour la soutenance de fin d\'études.'),
                  ],
                );
              },
            ),
            _buildActionTile(
              icon: Icons.logout,
              title: 'Se déconnecter',
              color: Colors.red,
              onTap: () {
                auth.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 30),
            const Text('Version 1.0.0 (Bêta Jury)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 10),
        child: Text(
          title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.1),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Row(
          children: [
            const Icon(Icons.military_tech, size: 16, color: AppColors.primaryGreen),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({required IconData icon, required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade100)),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeColor: AppColors.primaryGreen,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: (color ?? AppColors.primaryGreen).withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color ?? AppColors.primaryGreen, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
