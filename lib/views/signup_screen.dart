import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/models/user_model.dart';
import 'package:sentinelle_ci/viewmodels/auth_viewmodel.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final UserRole role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isCitizen = widget.role == UserRole.citizen;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryGreen),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_outlined, size: 60, color: AppColors.primaryGreen),
                  const SizedBox(height: 16),
                  const Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Text(
                    isCitizen ? 'Rejoignez la communauté SentinelleCI' : 'Administration communale',
                    style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 32),
                  _buildInputField(
                    label: 'NOM COMPLET',
                    hint: 'Jean Dupont',
                    icon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'ADRESSE EMAIL',
                    hint: 'votre@email.com',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'NUMÉRO DE TÉLÉPHONE',
                    hint: '07 XX XX XX XX',
                    icon: Icons.phone_android,
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'MOT DE PASSE',
                    hint: '********',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'CONFIRMER LE MOT DE PASSE',
                    hint: '********',
                    icon: Icons.lock_reset,
                    isPassword: true,
                    controller: _confirmPasswordController,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: authViewModel.isLoading
                          ? null
                          : () async {
                              if (_passwordController.text != _confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
                                );
                                return;
                              }
                              
                              final success = await authViewModel.register(
                                name: _nameController.text,
                                email: _emailController.text,
                                phoneNumber: _phoneController.text,
                                password: _passwordController.text,
                                role: widget.role,
                              );

                              if (!mounted) return;

                              if (success) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  (route) => false,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authViewModel.errorMessage ?? 'Erreur lors de l\'inscription'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: authViewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "S'inscrire",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Déjà un compte ? "),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen(role: widget.role)),
                        ),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textLight),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.cardBackground.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
