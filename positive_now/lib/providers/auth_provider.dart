import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:positive_now/app/shared_preferences.dart';
import 'package:positive_now/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? _user;
  bool _isOnboardingComplete = false;
  List<String> _selectedAreas = [];
  String? _preferredTime;
  String? _userName;
  String? _userEmail;

  User? get user => _user;
  bool get isOnboardingComplete => _isOnboardingComplete;
  List<String> get selectedAreas => _selectedAreas;
  String? get preferredTime => _preferredTime;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isAnonymous => _user?.isAnonymous ?? false;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _user = _auth.currentUser;
    
    // Primeiro tenta carregar preferências locais
    await _loadLocalPreferences();
    
    // Depois tenta carregar do Firebase (se estiver online)
    if (_user != null) {
      await _loadUserPreferences();
    }
    
    notifyListeners();
  }

  // Carregar preferências locais
  Future<void> _loadLocalPreferences() async {
    try {
      final localPrefs = await PreferencesService.loadPreferences();
      _isOnboardingComplete = localPrefs['onboardingComplete'] ?? false;
      _selectedAreas = List<String>.from(localPrefs['selectedAreas'] ?? []);
      _preferredTime = localPrefs['preferredTime'];
      _userName = localPrefs['userName'];
      _userEmail = localPrefs['userEmail'];
      
      debugPrint('📱 Preferências locais carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar preferências locais: $e');
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await _firebaseService.getUserPreferences();
      _isOnboardingComplete = prefs['onboardingComplete'] ?? _isOnboardingComplete;
      _selectedAreas = List<String>.from(prefs['selectedAreas'] ?? _selectedAreas);
      _preferredTime = prefs['preferredTime'] ?? _preferredTime;
      _userName = prefs['name'] ?? _userName;
      _userEmail = prefs['email'] ?? _userEmail;
      
      // Atualiza preferências locais
      await PreferencesService.savePreferences(
        onboardingComplete: _isOnboardingComplete,
        selectedAreas: _selectedAreas,
        preferredTime: _preferredTime,
        userName: _userName,
        userEmail: _userEmail,
        isAnonymous: isAnonymous,
        userId: _user?.uid,
      );
      
      debugPrint('☁️ Preferências do Firebase carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar preferências: $e');
    }
  }

  // Login com email e senha
  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      await _loadUserPreferences();
      
      // Salva localmente
      await PreferencesService.savePreferences(
        onboardingComplete: _isOnboardingComplete,
        selectedAreas: _selectedAreas,
        preferredTime: _preferredTime,
        userName: _userName,
        userEmail: _userEmail,
        isAnonymous: false,
        userId: _user?.uid,
      );
      
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro no login: $e');
      return false;
    }
  }

  // Registro de novo usuário
  Future<bool> register(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      
      await _user?.updateDisplayName(name);
      
      _userName = name;
      _userEmail = email;
      
      await _firebaseService.saveUserPreferences({
        'name': name,
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      // Salva localmente
      await PreferencesService.savePreferences(
        onboardingComplete: _isOnboardingComplete,
        selectedAreas: _selectedAreas,
        preferredTime: _preferredTime,
        userName: name,
        userEmail: email,
        isAnonymous: false,
        userId: _user?.uid,
      );
      
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro no registro: $e');
      return false;
    }
  }

  // Login anônimo
  Future<bool> loginAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      _user = userCredential.user;
      
      await _firebaseService.saveUserPreferences({
        'isAnonymous': true,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      // Salva localmente
      await PreferencesService.savePreferences(
        onboardingComplete: _isOnboardingComplete,
        selectedAreas: _selectedAreas,
        preferredTime: _preferredTime,
        userName: 'Usuário Anônimo',
        userEmail: null,
        isAnonymous: true,
        userId: _user?.uid,
      );
      
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro no login anônimo: $e');
      return false;
    }
  }

  Future<void> completeOnboarding({
    required List<String> selectedAreas,
    required String preferredTime,
  }) async {
    _selectedAreas = selectedAreas;
    _preferredTime = preferredTime;
    _isOnboardingComplete = true;

    final Map<String, dynamic> preferences = {
      'onboardingComplete': true,
      'selectedAreas': selectedAreas,
      'preferredTime': preferredTime,
    };

    if (!isAnonymous) {
      preferences['name'] = _userName;
      preferences['email'] = _userEmail;
    }

    // Salva no Firebase
    await _firebaseService.saveUserPreferences(preferences);
    
    // Salva localmente
    await PreferencesService.savePreferences(
      onboardingComplete: true,
      selectedAreas: selectedAreas,
      preferredTime: preferredTime,
      userName: _userName,
      userEmail: _userEmail,
      isAnonymous: isAnonymous,
      userId: _user?.uid,
    );

    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    
    // Limpa preferências locais
    await PreferencesService.clearPreferences();
    
    _user = null;
    _isOnboardingComplete = false;
    _selectedAreas = [];
    _preferredTime = null;
    _userName = null;
    _userEmail = null;
    
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      if (name != null) {
        await user.updateDisplayName(name);
        _userName = name;
      }

      await _firebaseService.saveUserPreferences({
        'name': _userName,
        'email': _userEmail,
      });

      // Atualiza localmente
      await PreferencesService.savePreferences(
        onboardingComplete: _isOnboardingComplete,
        selectedAreas: _selectedAreas,
        preferredTime: _preferredTime,
        userName: _userName,
        userEmail: _userEmail,
        isAnonymous: isAnonymous,
        userId: user.uid,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
    }
  }

  // Verificar se usuário deve ir direto para Home
  Future<bool> shouldGoToHome() async {
    final localCompleted = await PreferencesService.hasCompletedOnboarding();
    return localCompleted || _isOnboardingComplete;
  }
}