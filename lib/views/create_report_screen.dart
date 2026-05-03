import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'package:sentinelle_ci/viewmodels/auth_viewmodel.dart';
import 'package:sentinelle_ci/viewmodels/report_viewmodel.dart';

class CreateReportScreen extends StatefulWidget {
  final ReportCategory? initialCategory;
  final bool isPushed;
  const CreateReportScreen({super.key, this.initialCategory, this.isPushed = false});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late ReportCategory _selectedCategory;
  
  final List<String> _villes = ['Abidjan', 'Bouaké', 'Yamoussoukro', 'Korhogo', 'San-Pédro', 'Daloa', 'Man', 'Gagnoa', 'Agboville'];
  final Map<String, List<double>> _cityCoords = {
    'Abidjan': [5.3484, -4.0305],
    'Bouaké': [7.6897, -5.0303],
    'Yamoussoukro': [6.8276, -5.2767],
    'Korhogo': [9.4580, -5.6295],
    'San-Pédro': [4.7485, -6.6363],
    'Daloa': [6.8773, -6.4502],
    'Man': [7.4125, -7.5538],
    'Gagnoa': [6.1319, -5.9507],
    'Agboville': [5.9280, -4.2131],
  };
  
  String _selectedCity = 'Abidjan';
  String _detailedLocation = 'Position par ville (Défaut)';
  double _latitude = 5.3484;
  double _longitude = -4.0305;
  
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? ReportCategory.routes;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _detailedLocation = "Désactivé (Ville par défaut)");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Le GPS est désactivé. Veuillez l\'activer.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            )
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _detailedLocation = "Permission refusée");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La permission GPS est nécessaire pour localiser le problème.'))
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _detailedLocation = "GPS bloqué");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission GPS bloquée. Activez-la dans les paramètres.'))
          );
        }
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        setState(() => _detailedLocation = "Recherche satellite...");
        
        // Essayer d'abord la dernière position connue pour la rapidité
        Position? lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null && mounted) {
          setState(() {
            _latitude = lastPos.latitude;
            _longitude = lastPos.longitude;
            _detailedLocation = "Position mémorisée ✅";
          });
        }

        // Demander une position fraîche avec un timeout
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        ).catchError((e) {
          debugPrint("Timeout ou erreur getCurrentPosition: $e");
          return lastPos ?? Position(longitude: _longitude, latitude: _latitude, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
        });

        if (mounted) {
          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
            _detailedLocation = "GPS : Position précise ✅";
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur localisation globale: $e");
      if (mounted) {
        setState(() => _detailedLocation = "Localisation auto échouée");
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportVm = context.watch<ReportViewModel>();
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouveau Signalement', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PHOTO DU PROBLÈME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                  image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                ),
                child: _imageFile == null 
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 50, color: AppColors.primaryOrange),
                        Text('Prendre une photo pour preuve', style: TextStyle(color: AppColors.textLight)),
                      ],
                    )
                  : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 25),
            
            const Text('LOCALISATION (VILLE)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  items: _villes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCity = val!;
                      _latitude = _cityCoords[val]![0];
                      _longitude = _cityCoords[val]![1];
                      _detailedLocation = "Ville : $val";
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Position GPS : $_detailedLocation', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            
            const SizedBox(height: 25),
            const Text('CATÉGORIE & DÉTAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            _buildCategorySelector(),
            const SizedBox(height: 15),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Titre du signalement',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Description du problème...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 35),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: reportVm.isLoading ? null : () async {
                  // Validation stricte
                  if (_imageFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez prendre une photo du problème'), backgroundColor: Colors.orange)
                    );
                    return;
                  }
                  
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez donner un titre au signalement'), backgroundColor: Colors.orange)
                    );
                    return;
                  }

                  final success = await reportVm.createReport(
                    title: _titleController.text.trim(),
                    description: _descriptionController.text.trim(),
                    category: _selectedCategory,
                    location: "$_selectedCity, Côte d'Ivoire",
                    latitude: _latitude,
                    longitude: _longitude,
                    userId: authVm.currentUser?.id ?? 'anonyme',
                    userName: authVm.currentUser?.name ?? 'Citoyen',
                    isAnonymous: authVm.currentUser?.isAnonymous ?? false,
                    isUrgent: false,
                    imageFile: _imageFile,
                  );
                  
                  if (!mounted) return;

                  if (success) {
                    final messenger = ScaffoldMessenger.of(context);
                    FocusScope.of(context).unfocus();
                    
                    // FIX ÉCRAN NOIR : Utilisation du flag isPushed
                    if (widget.isPushed) {
                      Navigator.pop(context);
                    } else {
                      // Si on est dans l'onglet "Signaler", on réinitialise juste l'interface
                      _titleController.clear();
                      _descriptionController.clear();
                      setState(() {
                        _imageFile = null;
                        _detailedLocation = "Signalement envoyé ✅";
                      });
                    }
                    
                    authVm.addPoints(15);
                    
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('✅ Signalement certifié sur la Blockchain ! (+15 pts)'),
                        backgroundColor: AppColors.primaryGreen,
                        duration: Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      )
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Erreur lors de l\'envoi. Vérifiez votre connexion.'),
                        backgroundColor: Colors.redAccent,
                      )
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: reportVm.isLoading
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text('ENVOYER AU REGISTRE PUBLIC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReportCategory.values.map((cat) {
        final isSelected = _selectedCategory == cat;
        String label;
        IconData icon;
        
        switch (cat) {
          case ReportCategory.routes:
            label = "Routes";
            icon = Icons.edit_road;
            break;
          case ReportCategory.lighting:
            label = "Éclairage";
            icon = Icons.lightbulb;
            break;
          case ReportCategory.water:
            label = "Eau/Assainissement";
            icon = Icons.water_drop;
            break;
          case ReportCategory.schools:
            label = "Écoles";
            icon = Icons.school;
            break;
          case ReportCategory.waste:
            label = "Déchets";
            icon = Icons.delete_outline;
            break;
          case ReportCategory.health:
            label = "Santé";
            icon = Icons.local_hospital;
            break;
          case ReportCategory.transport:
            label = "Transport";
            icon = Icons.bus_alert;
            break;
          case ReportCategory.pollution:
            label = "Pollution";
            icon = Icons.eco;
            break;
          case ReportCategory.other:
            label = "Autre";
            icon = Icons.more_horiz;
            break;
        }

        return FilterChip(
          label: Text(label),
          avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.primaryGreen),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedCategory = cat),
          selectedColor: AppColors.primaryOrange,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isSelected ? AppColors.primaryOrange : Colors.grey.shade300),
          ),
        );
      }).toList(),
    );
  }
}
