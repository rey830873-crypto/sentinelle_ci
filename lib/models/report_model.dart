enum ReportStatus { submitted, validated, inProgress, resolved, rejected }

enum ReportCategory { routes, lighting, water, schools, waste, health, transport, pollution, other }

class ReportModel {
  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final ReportStatus status;
  final String? imageUrl;
  final String userId;
  final String userName;
  final bool isAnonymous;
  final String? blockchainHash;
  final int votes;
  final bool isUrgent;
  final List<String> upvotedBy;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.status = ReportStatus.submitted,
    this.imageUrl,
    required this.userId,
    this.userName = "Citoyen",
    this.isAnonymous = false,
    this.blockchainHash,
    this.votes = 0,
    this.isUrgent = false,
    this.upvotedBy = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'status': status.index,
      'imageUrl': imageUrl,
      'userId': userId,
      'userName': userName,
      'isAnonymous': isAnonymous,
      'blockchainHash': blockchainHash,
      'votes': votes,
      'isUrgent': isUrgent,
      'upvotedBy': upvotedBy,
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: ReportCategory.values[json['category']],
      location: json['location'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      status: ReportStatus.values[json['status']],
      imageUrl: json['imageUrl'],
      userId: json['userId'],
      userName: json['userName'] ?? "Citoyen",
      isAnonymous: json['isAnonymous'] ?? false,
      blockchainHash: json['blockchainHash'],
      votes: json['votes'] ?? 0,
      isUrgent: json['isUrgent'] ?? false,
      upvotedBy: List<String>.from(json['upvotedBy'] ?? []),
    );
  }
}
