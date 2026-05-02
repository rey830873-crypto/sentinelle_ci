import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'package:sentinelle_ci/services/api_service.dart';

class ReportViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ReportModel> _reports = [];
  bool _isLoading = false;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;

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

  Future<void> fetchReports() async {
  }

  Future<bool> createReport({
    required String title,
    required String description,
    required ReportCategory category,
    required String location,
    required double latitude,
    required double longitude,
    required String userId,
    File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    String? imageUrl;
    if (imageFile != null) {
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
      imageUrl: imageUrl,
      blockchainHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      isUrgent: description.toLowerCase().contains('danger') || description.toLowerCase().contains('urgent'),
    );

    try {
      await _apiService.postReport(newReport);

      await _apiService.incrementUserReportCount(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStatus(String reportId, ReportStatus status) async {
    await _apiService.updateReportStatus(reportId, status);
  }

  Future<void> vote(String reportId, String userId) async {
    await _apiService.voteForReport(reportId, userId);
  }
}
