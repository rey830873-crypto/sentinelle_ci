import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'package:sentinelle_ci/services/api_service.dart';

class ReportViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ReportModel> _reports = [];
  bool _isLoading = false;
  ReportModel? _lastCreatedReport;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  ReportModel? get lastCreatedReport => _lastCreatedReport;

  int get submittedCount => _reports.where((r) => r.status == ReportStatus.submitted).length;
  int get inProgressCount => _reports.where((r) => r.status == ReportStatus.inProgress || r.status == ReportStatus.validated).length;
  int get resolvedCount => _reports.where((r) => r.status == ReportStatus.resolved).length;
  int get urgentCount => _reports.where((r) => r.isUrgent).length;

  ReportViewModel() {
    _listenToReports();
  }

  void _listenToReports() {
    _apiService.getReports().listen((updatedReports) {
      _reports = updatedReports;
      notifyListeners();
    });
  }

  Future<bool> createReport({
    required String title,
    required String description,
    required ReportCategory category,
    required String location,
    required double latitude,
    required double longitude,
    required String userId,
    String userName = "Citoyen",
    bool isAnonymous = false,
    bool isUrgent = false,
    File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;
      if (imageFile != null) {
        // Simulation d'upload ou traitement d'image
        imageUrl = await _apiService.uploadImage(imageFile);
      }

      final newReport = ReportModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        category: category,
        location: location,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
        status: ReportStatus.submitted,
        userId: userId,
        userName: userName,
        isAnonymous: isAnonymous,
        imageUrl: imageUrl,
        blockchainHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
        isUrgent: isUrgent || description.toLowerCase().contains('danger') || description.toLowerCase().contains('urgent'),
      );

      await _apiService.postReport(newReport);
      _lastCreatedReport = newReport;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Erreur lors de la création du rapport: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStatus(String reportId, ReportStatus status, {VoidCallback? onResolved}) async {
    await _apiService.updateReportStatus(reportId, status);
    if (status == ReportStatus.resolved && onResolved != null) {
      onResolved();
    }
  }

  Future<void> fetchReports() async {
    notifyListeners();
  }

  Future<void> vote(String reportId, String userId) async {
    await _apiService.voteForReport(reportId, userId);
  }

  void clearLastReport() {
    _lastCreatedReport = null;
  }
}
