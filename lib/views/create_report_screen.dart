import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'package:sentinelle_ci/services/ai_service.dart';
import 'package:sentinelle_ci/viewmodels/auth_viewmodel.dart';
import 'package:sentinelle_ci/viewmodels/report_viewmodel.dart';

class CreateReportScreen extends StatefulWidget {
  final ReportCategory? initialCategory;
  const CreateReportScreen({super.key, this.initialCategory});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late ReportCategory _selectedCategory;
  String _location = 'Recherche de localisation...';
  double _latitude = 5.3484;
  double _longitude = -3.9745;
  File? _imageFile;
  final _picker = ImagePicker();
  final _aiService = AIService();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? ReportCategory.routes;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        
        if (mounted) {
          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              _location = "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _location = "Abidjan, Côte d'Ivoire";
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('IA : Analyse de l\'image par Gemini...'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
      
      try {
        final analysis = await _aiService.analyzeImage(_imageFile!);
        
        if (!mounted) return;
        
        setState(() {
          _selectedCategory = analysis['category'] as ReportCategory;
          _titleController.text = analysis['title'] as String;
          if (_descriptionController.text.isEmpty) {
            _descriptionController.text = analysis['description'] as String;
          }
        });
      } catch (e) {
        debugPrint("Erreur IA: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportViewModel = context.watch<ReportViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

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
            const Text('CATÉGORIE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
            const SizedBox(height: 10),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            
            const Text('LOCALISATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primaryOrange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_location, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
                ),
                IconButton(
                  icon: const Icon(Icons.my_location, color: AppColors.primaryGreen, size: 20),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            const Text('TITRE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Ex: Nid de poule sur la voie principale'),
            ),
            const SizedBox(height: 24),

            const Text('DESCRIPTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Décrivez le problème...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Micro activé... Parlez.')),
                    );
                    // Simulation transcription
                    Future.delayed(const Duration(seconds: 2), () {
                      if (!mounted) return;
                      setState(() {
                        _descriptionController.text = "Grosse fuite d'eau sur le trottoir depuis ce matin.";
                        _selectedCategory = ReportCategory.water;
                      });
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
                    child: const Icon(Icons.mic, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text('PHOTO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                  image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                ),
                child: _imageFile == null 
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.primaryOrange),
                        Text('Prendre une photo réelle', style: TextStyle(color: AppColors.textLight)),
                      ],
                    )
                  : null,
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: reportViewModel.isLoading 
                  ? null 
                  : () async {
                    if (_titleController.text.isNotEmpty) {
                      final success = await reportViewModel.createReport(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        category: _selectedCategory,
                        location: _location,
                        latitude: _latitude,
                        longitude: _longitude,
                        userId: authViewModel.currentUser?.id ?? 'anonymous',
                        imageFile: _imageFile,
                      );
                      if (success) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Signalement enregistré !')),
                          );
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: reportViewModel.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Envoyer le signalement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ReportCategory.values.map((cat) {
        final isSelected = _selectedCategory == cat;
        return ChoiceChip(
          label: Text(_getCategoryName(cat)),
          selected: isSelected,
          onSelected: (selected) => setState(() => _selectedCategory = cat),
          selectedColor: AppColors.primaryGreen,
          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark),
        );
      }).toList(),
    );
  }

  String _getCategoryName(ReportCategory cat) {
    switch (cat) {
      case ReportCategory.routes: return 'Routes';
      case ReportCategory.lighting: return 'Éclairage';
      case ReportCategory.water: return 'Eau';
      case ReportCategory.waste: return 'Déchets';
      case ReportCategory.health: return 'Santé';
      default: return 'Autre';
    }
  }
}
