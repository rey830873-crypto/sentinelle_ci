import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/viewmodels/auth_viewmodel.dart';
import 'leaderboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Langues disponibles', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Choisissez votre langue préférée (CI & Inter)', style: TextStyle(color: Colors.grey)),
              const Divider(height: 30),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    const Text('International', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    _LanguageTile(title: 'Français', isSelected: true),
                    _LanguageTile(title: 'English'),
                    const SizedBox(height: 15),
                    const Text('Côte d\'Ivoire', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                    _LanguageTile(title: 'Dioula (Malinké)'),
                    _LanguageTile(title: 'Baoulé'),
                    _LanguageTile(title: 'Bété'),
                    _LanguageTile(title: 'Sénoufo'),
                    _LanguageTile(title: 'Yacouba'),
                    _LanguageTile(title: 'Guéré'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    if (user == null) return const Center(child: Text('Veuillez vous connecter'));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryGreen,
                child: Text('EH', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('@${user.name.toLowerCase().replaceAll(' ', '')}', style: const TextStyle(color: AppColors.textLight)),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProfileStat(value: '${user.points}', label: 'Points'),
                  _ProfileStat(value: '${user.reportCount}', label: 'Signalements'),
                  _ProfileStat(value: '${user.resolvedCount}', label: 'Résolus'),
                ],
              ),
              const SizedBox(height: 30),

              const _SectionTitle(title: 'Confidentialité'),
              _SettingToggle(
                icon: Icons.visibility_outlined,
                title: 'Signalement anonyme',
                subtitle: 'Vos signaux affichent votre pseudo public.',
                value: false,
                onChanged: (v) {},
              ),
              
              const SizedBox(height: 20),
              const _SectionTitle(title: 'Réglages'),
              _SettingToggle(
                icon: Icons.dark_mode_outlined,
                title: 'Mode sombre',
                subtitle: 'Économie d\'énergie',
                value: false,
                onChanged: (v) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le mode sombre sera disponible dans la version finale !'))
                  );
                },
              ),
              _SettingToggle(
                icon: Icons.notifications_none,
                title: 'Notifications push',
                subtitle: 'Actives',
                value: true,
                onChanged: (v) {},
              ),
              _SettingItem(
                icon: Icons.language, 
                title: 'Langue de l\'application', 
                value: 'Français',
                onTap: () => _showLanguagePicker(context),
              ),
              _SettingItem(
                icon: Icons.emoji_events_outlined, 
                title: 'Classement des communes', 
                value: 'Voir',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
              ),
              const _SettingItem(icon: Icons.link, title: 'Données blockchain', value: 'Polygon'),

              const SizedBox(height: 20),
              const _SectionTitle(title: 'Vos badges'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _BadgeItem(
                      title: 'Signalisation de premier ordre',
                      subtitle: 'Vous avez fait entendre votre voix.',
                      icon: Icons.military_tech,
                      color: Colors.orange,
                      earned: user.badges.contains('first_report'),
                    ),
                    const Divider(height: 1),
                    _BadgeItem(
                      title: 'Témoin fiable',
                      subtitle: 'Vos signaux sont confirmés.',
                      icon: Icons.verified_user,
                      color: Colors.green,
                      earned: user.badges.contains('reliable_witness'),
                    ),
                    const Divider(height: 1),
                    _BadgeItem(
                      title: 'Vigie de quartier',
                      subtitle: '500 points atteints.',
                      icon: Icons.home_work,
                      color: AppColors.primaryGreen,
                      earned: user.badges.contains('neighborhood_watch'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    authViewModel.logout();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Se déconnecter', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const _ReputationInfo(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
        Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _SettingToggle({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primaryGreen),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _SettingItem({required this.icon, required this.title, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(value, style: const TextStyle(color: AppColors.textLight)),
              const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool earned;

  const _BadgeItem({required this.title, required this.subtitle, required this.icon, required this.color, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: earned ? color : Colors.grey.shade300, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: earned ? AppColors.textDark : Colors.grey)),
                Text(subtitle, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
              ],
            ),
          ),
          if (earned) const Icon(Icons.check, color: AppColors.primaryGreen, size: 16),
        ],
      ),
    );
  }
}

class _ReputationInfo extends StatelessWidget {
  const _ReputationInfo();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('À propos de la réputation', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'Votre score augmente lorsque vos signaux sont validés et résolus. Il diminue en cas de faux signalement. Un score élevé donne plus de poids à vos alertes auprès de la commune.',
            style: TextStyle(fontSize: 12, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  const _LanguageTile({required this.title, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryGreen) : null,
      onTap: () => Navigator.pop(context),
    );
  }
}
