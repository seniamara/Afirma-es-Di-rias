import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keySelectedAreas = 'selected_areas';
  static const String _keyPreferredTime = 'preferred_time';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsAnonymous = 'is_anonymous';
  static const String _keyUserId = 'user_id';

  // Salvar preferências localmente
  static Future<void> savePreferences({
    required bool onboardingComplete,
    List<String>? selectedAreas,
    String? preferredTime,
    String? userName,
    String? userEmail,
    bool? isAnonymous,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_keyOnboardingComplete, onboardingComplete);
    
    if (selectedAreas != null) {
      await prefs.setStringList(_keySelectedAreas, selectedAreas);
    }
    
    if (preferredTime != null) {
      await prefs.setString(_keyPreferredTime, preferredTime);
    }
    
    if (userName != null) {
      await prefs.setString(_keyUserName, userName);
    }
    
    if (userEmail != null) {
      await prefs.setString(_keyUserEmail, userEmail);
    }
    
    if (isAnonymous != null) {
      await prefs.setBool(_keyIsAnonymous, isAnonymous);
    }
    
    if (userId != null) {
      await prefs.setString(_keyUserId, userId);
    }
    
    debugPrint('✅ Preferências salvas localmente');
  }

  // Carregar preferências locais
  static Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'onboardingComplete': prefs.getBool(_keyOnboardingComplete) ?? false,
      'selectedAreas': prefs.getStringList(_keySelectedAreas) ?? [],
      'preferredTime': prefs.getString(_keyPreferredTime),
      'userName': prefs.getString(_keyUserName),
      'userEmail': prefs.getString(_keyUserEmail),
      'isAnonymous': prefs.getBool(_keyIsAnonymous) ?? false,
      'userId': prefs.getString(_keyUserId),
    };
  }

  // Limpar preferências
  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('🗑️ Preferências locais removidas');
  }

  // Verificar se usuário já fez onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // Salvar apenas áreas selecionadas
  static Future<void> saveSelectedAreas(List<String> areas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySelectedAreas, areas);
  }

  // Carregar áreas selecionadas
  static Future<List<String>> loadSelectedAreas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySelectedAreas) ?? [];
  }
}