import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentinelle_ci/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, dynamic> _localDb = {};

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthViewModel() {
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    await _loadUsersFromDisk();
    await _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/session.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        _currentUser = UserModel.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Session expirée");
    }
  }

  Future<void> _saveSession(UserModel user) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/session.json');
    await file.writeAsString(jsonEncode(user.toJson()));
  }

  Future<void> _loadUsersFromDisk() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/users_db.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        _localDb.addAll(data);
      }
    } catch (e) {
      debugPrint("Init local DB");
    }
  }

  Future<void> _saveUsersToDisk() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/users_db.json');
    await file.writeAsString(jsonEncode(_localDb));
  }

  Future<bool> login(String email, String password, UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (_localDb.containsKey(email)) {
      final userData = _localDb[email];
      if (userData['password'] == password) {
        _currentUser = UserModel.fromJson(userData['profile']);
        await _saveSession(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Mot de passe incorrect";
      }
    } else {
      _errorMessage = "Compte inexistant. Inscrivez-vous.";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_localDb.containsKey(email)) {
      _errorMessage = "Email déjà utilisé";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    await Future.delayed(const Duration(seconds: 1));

    final newUser = UserModel(
      id: "user_${DateTime.now().millisecondsSinceEpoch}",
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      points: 10,
      reportCount: 0,
      resolvedCount: 0,
      badges: ['Citoyen Débutant'],
      isAnonymous: false,
    );

    _localDb[email] = {
      'password': password,
      'profile': newUser.toJson(),
    };
    
    await _saveUsersToDisk();
    _currentUser = newUser;
    await _saveSession(newUser);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() async {
    _currentUser = null;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/session.json');
    if (await file.exists()) await file.delete();
    notifyListeners();
  }

  Future<void> updateAnonymity(bool isAnonymous) async {
    if (_currentUser == null) return;
    
    _currentUser = UserModel(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      phoneNumber: _currentUser!.phoneNumber,
      role: _currentUser!.role,
      points: _currentUser!.points,
      reportCount: _currentUser!.reportCount,
      resolvedCount: _currentUser!.resolvedCount,
      badges: _currentUser!.badges,
      isAnonymous: isAnonymous,
    );
    
    if (_currentUser!.email != null && _localDb.containsKey(_currentUser!.email!)) {
      _localDb[_currentUser!.email!]['profile'] = _currentUser!.toJson();
      await _saveUsersToDisk();
    }
    
    await _saveSession(_currentUser!);
    notifyListeners();
  }

  Future<void> addPoints(int points) async {
    if (_currentUser == null) return;
    
    _currentUser = UserModel(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      phoneNumber: _currentUser!.phoneNumber,
      role: _currentUser!.role,
      points: _currentUser!.points + points,
      reportCount: _currentUser!.reportCount + (points == 15 ? 1 : 0),
      resolvedCount: _currentUser!.resolvedCount + (points == 50 ? 1 : 0),
      badges: List<String>.from(_currentUser!.badges),
      isAnonymous: _currentUser!.isAnonymous,
    );
    
    // Update badges based on points
    if (_currentUser!.points >= 50 && !_currentUser!.badges.contains('Citoyen Actif')) {
      _currentUser!.badges.add('Citoyen Actif');
    }
    if (_currentUser!.points >= 100 && !_currentUser!.badges.contains('Sentinelle d\'Élite')) {
      _currentUser!.badges.add('Sentinelle d\'Élite');
    }

    if (_currentUser!.email != null && _localDb.containsKey(_currentUser!.email!)) {
      _localDb[_currentUser!.email!]['profile'] = _currentUser!.toJson();
      await _saveUsersToDisk();
    }
    
    await _saveSession(_currentUser!);
    notifyListeners();
  }
}
