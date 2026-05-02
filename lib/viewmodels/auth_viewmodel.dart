import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
      final directory = await getApplicationDocumentsPlatformDirectory();
      final file = File('${directory.path}/session.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        _currentUser = UserModel.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Pas de session active");
    }
  }

  Future<void> _saveSession(UserModel user) async {
    final directory = await getApplicationDocumentsPlatformDirectory();
    final file = File('${directory.path}/session.json');
    await file.writeAsString(jsonEncode(user.toJson()));
  }

  Future<void> _loadUsersFromDisk() async {
    try {
      final directory = await getApplicationDocumentsPlatformDirectory();
      final file = File('${directory.path}/users_db.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        _localDb.addAll(data);
      }
    } catch (e) {
      debugPrint("Erreur chargement DB");
    }
  }

  Future<void> _saveUsersToDisk() async {
    final directory = await getApplicationDocumentsPlatformDirectory();
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
      _errorMessage = "Compte inexistant. Veuillez vous inscrire.";
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

    // SÉCURITÉ : Validation réelle
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      _errorMessage = "Format d'email invalide";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = "Le mot de passe doit contenir au moins 6 caractères";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (_localDb.containsKey(email)) {
      _errorMessage = "Cet email est déjà utilisé";
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
      points: 0,
      reportCount: 0,
      resolvedCount: 0,
      badges: [],
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
    final directory = await getApplicationDocumentsPlatformDirectory();
    final file = File('${directory.path}/session.json');
    if (await file.exists()) await file.delete();
    notifyListeners();
  }

  Future<Directory> getApplicationDocumentsPlatformDirectory() async {
    final dir = Directory('/data/data/com.example.sentinelle_ci/files');
    if (!Platform.isAndroid) {
      // Pour le test sur Windows/Mac
      return Directory.current;
    }
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
