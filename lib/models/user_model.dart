enum UserRole { citizen, administrator }

class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final UserRole role;
  final int points;
  final int reportCount;
  final int resolvedCount;
  final List<String> badges;
  final bool isAnonymous;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    required this.role,
    this.points = 0,
    this.reportCount = 0,
    this.resolvedCount = 0,
    this.badges = const [],
    this.isAnonymous = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.index,
      'points': points,
      'reportCount': reportCount,
      'resolvedCount': resolvedCount,
      'badges': badges,
      'isAnonymous': isAnonymous,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: UserRole.values[json['role']],
      points: json['points'] ?? 0,
      reportCount: json['reportCount'] ?? 0,
      resolvedCount: json['resolvedCount'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      isAnonymous: json['isAnonymous'] ?? false,
    );
  }
}
