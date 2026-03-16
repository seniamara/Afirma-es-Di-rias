import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:positive_now/models/models.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeUser() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
        debugPrint('✅ Usuário anônimo criado com sucesso');
      } else {
        debugPrint('✅ Usuário já autenticado: ${_auth.currentUser?.uid}');
      }
    } catch (e) {
      debugPrint('❌ Erro na inicialização: $e');
    }
  }

  String? getUserId() {
    return _auth.currentUser?.uid;
  }

  // Preferências do usuário
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final userId = getUserId();
    if (userId == null) {
      debugPrint('❌ Erro: Usuário não autenticado');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(preferences, SetOptions(merge: true));
      debugPrint('✅ Preferências salvas para usuário: $userId');
    } catch (e) {
      debugPrint('❌ Erro ao salvar preferências: $e');
      // Não relançar o erro para não quebrar o fluxo
    }
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    final userId = getUserId();
    if (userId == null) {
      debugPrint('❌ Erro: Usuário não autenticado');
      return {};
    }

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        debugPrint('✅ Preferências carregadas para usuário: $userId');
        return doc.data() ?? {};
      } else {
        debugPrint('ℹ️ Nenhuma preferência encontrada para usuário: $userId');
        return {};
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar preferências: $e');
      return {};
    }
  }

  // Afirmações
  Future<List<Afirmacao>> getAfirmacoes() async {
    final userId = getUserId();
    if (userId == null) {
      debugPrint('❌ Erro: Usuário não autenticado - retornando mock data');
      return _getMockAfirmacoes();
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('afirmacoes_cache')
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('ℹ️ Nenhuma afirmação em cache para usuário: $userId');
        return _getMockAfirmacoes();
      }

      final afirmacoes = snapshot.docs
          .map((doc) => Afirmacao.fromMap(doc.data()))
          .toList();
      
      debugPrint('✅ ${afirmacoes.length} afirmações carregadas do cache');
      return afirmacoes;
    } catch (e) {
      debugPrint('❌ Erro ao carregar afirmações: $e - retornando mock data');
      return _getMockAfirmacoes();
    }
  }

  Future<void> saveAfirmacao(Afirmacao afirmacao) async {
    final userId = getUserId();
    if (userId == null) {
      debugPrint('❌ Erro: Usuário não autenticado');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('afirmacoes_cache')
          .doc(afirmacao.id)
          .set(afirmacao.toMap());
      debugPrint('✅ Afirmação salva em cache: ${afirmacao.id}');
    } catch (e) {
      debugPrint('❌ Erro ao salvar afirmação: $e');
    }
  }

  Future<List<Afirmacao>> getFavoritos() async {
    final userId = getUserId();
    if (userId == null) {
      debugPrint('❌ Erro: Usuário não autenticado');
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favoritos')
          .get();

      final favoritos = snapshot.docs
          .map((doc) => Afirmacao.fromMap(doc.data()))
          .toList();
      
      debugPrint('✅ ${favoritos.length} favoritos carregados');
      return favoritos;
    } catch (e) {
      debugPrint('❌ Erro ao carregar favoritos: $e');
      return [];
    }
  }

  Future<void> updateAfirmacao(Afirmacao afirmacao) async {
    final userId = getUserId();
    if (userId == null) {
      debugPrint('❌ Erro: Usuário não autenticado');
      return;
    }

    try {
      if (afirmacao.isFavorita) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favoritos')
            .doc(afirmacao.id)
            .set(afirmacao.toMap());
        debugPrint('✅ Afirmação adicionada aos favoritos: ${afirmacao.id}');
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favoritos')
            .doc(afirmacao.id)
            .delete();
        debugPrint('✅ Afirmação removida dos favoritos: ${afirmacao.id}');
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar afirmação: $e');
    }
  }

  // Registros de humor
  Future<void> saveRegistroHumor(RegistroHumor registro) async {
    final userId = getUserId();
    if (userId == null) {
      debugPrint('❌ Erro: Usuário não autenticado');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('humor')
          .doc(registro.id)
          .set(registro.toMap());
      debugPrint('✅ Registro de humor salvo: ${registro.id}');
    } catch (e) {
      debugPrint('❌ Erro ao salvar registro de humor: $e');
    }
  }

  Future<List<RegistroHumor>> getRegistrosHumor() async {
    final userId = getUserId();
    if (userId == null) {
      debugPrint('❌ Erro: Usuário não autenticado');
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('humor')
          .orderBy('data', descending: true)
          .get();

      final registros = snapshot.docs
          .map((doc) => RegistroHumor.fromMap(doc.data()))
          .toList();
      
      debugPrint('✅ ${registros.length} registros de humor carregados');
      return registros;
    } catch (e) {
      debugPrint('❌ Erro ao carregar registros de humor: $e');
      return [];
    }
  }

  // Mock data para demonstração (funciona offline)
  List<Afirmacao> _getMockAfirmacoes() {
    return [
      Afirmacao(
        id: '1',
        texto: 'Eu sou suficiente exatamente como sou',
        categoria: 'Autoestima',
        dataCriacao: DateTime.now(),
      ),
      Afirmacao(
        id: '2',
        texto: 'Hoje eu escolho a paz em meio ao caos',
        categoria: 'Ansiedade',
        dataCriacao: DateTime.now(),
      ),
      Afirmacao(
        id: '3',
        texto: 'Sou grato por todas as bênçãos da minha vida',
        categoria: 'Gratidão',
        dataCriacao: DateTime.now(),
      ),
      Afirmacao(
        id: '4',
        texto: 'Eu mereço amor, respeito e felicidade',
        categoria: 'Amor Próprio',
        dataCriacao: DateTime.now(),
      ),
      Afirmacao(
        id: '5',
        texto: 'Cada dia é uma nova oportunidade para crescer',
        categoria: 'Motivação',
        dataCriacao: DateTime.now(),
      ),
      Afirmacao(
        id: '6',
        texto: 'Minha mente está calma e meu coração está em paz',
        categoria: 'Paz Interior',
        dataCriacao: DateTime.now(),
      ),
    ];
  }
}