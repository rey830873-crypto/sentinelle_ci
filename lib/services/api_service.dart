import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:sentinelle_ci/models/report_model.dart';

class ApiService {
  // Base de données en mémoire
  static final List<ReportModel> _mockReports = [];
  static final StreamController<List<ReportModel>> _controller = StreamController<List<ReportModel>>.broadcast();

  ApiService() {
    _loadReportsFromDisk();
  }

  Future<void> _loadReportsFromDisk() async {
    try {
      final file = File('${Directory.systemTemp.path}/reports_db.json');
      if (await file.exists()) {
        final List<dynamic> data = jsonDecode(await file.readAsString());
        _mockReports.clear();
        _mockReports.addAll(data.map((e) => ReportModel.fromJson(e)).toList());
      } else {
        // Données initiales si vide
        _mockReports.addAll([
          ReportModel(
            id: "1",
            title: "Nid de poule béant",
            description: "Un énorme trou sur la route principale, très dangereux pour les motos.",
            category: ReportCategory.routes,
            location: "Cocody, Rue des Jardins",
            latitude: 5.3484,
            longitude: -3.9745,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            status: ReportStatus.resolved,
            userId: "user_123",
            votes: 45,
            isUrgent: true,
            upvotedBy: ["user_1", "user_2"],
          ),
          ReportModel(
            id: "2",
            title: "Éclairage public défaillant",
            description: "Toute la rue est dans le noir depuis 3 jours.",
            category: ReportCategory.lighting,
            location: "Yopougon, Maroc",
            latitude: 5.3364,
            longitude: -4.0545,
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            status: ReportStatus.submitted,
            userId: "user_123",
            votes: 12,
            isUrgent: false,
          ),
        ]);
      }
      _controller.add(List.from(_mockReports));
    } catch (e) {
      print("Erreur chargement rapports: $e");
    }
  }

  Future<void> _saveReportsToDisk() async {
    final file = File('${Directory.systemTemp.path}/reports_db.json');
    final data = _mockReports.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Stream<List<ReportModel>> getReports() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.add(List.from(_mockReports));
    });
    return _controller.stream;
  }

  Future<void> postReport(ReportModel report) async {
    _mockReports.insert(0, report);
    await _saveReportsToDisk();
    _controller.add(List.from(_mockReports));
  }

  Future<String?> uploadImage(File imageFile) async {
    return imageFile.path;
  }

  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    final index = _mockReports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final old = _mockReports[index];
      _mockReports[index] = ReportModel(
        id: old.id, title: old.title, description: old.description,
        category: old.category, location: old.location, latitude: old.latitude,
        longitude: old.longitude, createdAt: old.createdAt, status: status,
        userId: old.userId, imageUrl: old.imageUrl, votes: old.votes,
        upvotedBy: old.upvotedBy, isUrgent: old.isUrgent,
        blockchainHash: old.blockchainHash,
      );
      await _saveReportsToDisk();
      _controller.add(List.from(_mockReports));
    }
  }

  Future<void> voteForReport(String reportId, String userId) async {
    final index = _mockReports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final old = _mockReports[index];
      if (!old.upvotedBy.contains(userId)) {
        List<String> newVotes = List.from(old.upvotedBy)..add(userId);
        _mockReports[index] = ReportModel(
          id: old.id, title: old.title, description: old.description,
          category: old.category, location: old.location, latitude: old.latitude,
          longitude: old.longitude, createdAt: old.createdAt, status: old.status,
          userId: old.userId, imageUrl: old.imageUrl, votes: old.votes + 1,
          upvotedBy: newVotes, isUrgent: old.isUrgent,
          blockchainHash: old.blockchainHash,
        );
        await _saveReportsToDisk();
        _controller.add(List.from(_mockReports));
      }
    }
  }

  Future<void> incrementUserReportCount(String userId) async {}
}
