import 'dart:math';
import 'package:flutter/material.dart';
import 'package:positive_now/models/models.dart';
import 'package:positive_now/services/firebase_service.dart';
import 'package:positive_now/services/api_ninjas_service.dart';

class AfirmacaoProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final ApiNinjasService _apiNinjasService = ApiNinjasService();
  
  List<Afirmacao> _afirmacoes = [];
  Afirmacao? _afirmacaoDoDia;
  List<Afirmacao> _favoritos = [];
  List<RegistroHumor> _registrosHumor = [];
  List<HistoricoItem> _historico = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Afirmacao> get afirmacoes => _afirmacoes;
  Afirmacao? get afirmacaoDoDia => _afirmacaoDoDia;
  List<Afirmacao> get favoritos => _favoritos;
  List<RegistroHumor> get registrosHumor => _registrosHumor;
  List<HistoricoItem> get historico => _historico;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AfirmacaoProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await carregarAfirmacoes();
    await carregarFavoritos();
    await carregarRegistrosHumor();
    await carregarAfirmacaoDoDia();
  }

  Future<void> carregarAfirmacoes() async {
    _setLoading(true);
    _clearError();
    
    try {
      _afirmacoes = await _firebaseService.getAfirmacoes();
      
      if (_afirmacoes.isEmpty) {
        await _carregarDaApi();
      }
      
      debugPrint('📚 AfirmacaoProvider - Total: ${_afirmacoes.length}');
    } catch (e) {
      _setError('Erro ao carregar afirmações: $e');
      _afirmacoes = _getMockAfirmacoes();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _carregarDaApi() async {
    try {
      final quotes = await _apiNinjasService.getRandomQuotes();
      _afirmacoes.addAll(quotes);
      
      for (var quote in quotes) {
        await _firebaseService.saveAfirmacao(quote);
      }
      
      debugPrint('🌐 API - Carregadas ${quotes.length} afirmações');
    } catch (e) {
      debugPrint('❌ Erro ao carregar da API: $e');
    }
  }

  Future<void> carregarAfirmacaoDoDia() async {
    try {
      _afirmacaoDoDia = await _apiNinjasService.getQuoteOfTheDay();
      debugPrint('📅 Afirmação do dia: ${_afirmacaoDoDia?.texto}');
    } catch (e) {
      debugPrint('❌ Erro quote do dia: $e');
      if (_afirmacoes.isNotEmpty) {
        final random = Random();
        final index = random.nextInt(_afirmacoes.length);
        _afirmacaoDoDia = _afirmacoes[index];
      } else {
        _afirmacaoDoDia = _getMockAfirmacaoDoDia();
      }
    }
    notifyListeners();
  }

  Future<void> carregarFavoritos() async {
    try {
      _favoritos = await _firebaseService.getFavoritos();
      debugPrint('❤️ Favoritos: ${_favoritos.length}');
    } catch (e) {
      debugPrint('❌ Erro favoritos: $e');
    }
    notifyListeners();
  }

  Future<void> carregarRegistrosHumor() async {
    try {
      _registrosHumor = await _firebaseService.getRegistrosHumor();
      debugPrint('😊 Registros humor: ${_registrosHumor.length}');
    } catch (e) {
      debugPrint('❌ Erro registros humor: $e');
    }
    notifyListeners();
  }

  void adicionarAoHistorico(Afirmacao afirmacao) {
    _historico.insert(0, HistoricoItem(
      afirmacao: afirmacao,
      dataVista: DateTime.now(),
    ));
    
    if (_historico.length > 50) {
      _historico = _historico.sublist(0, 50);
    }
    
    notifyListeners();
  }

  void gerarProximaAfirmacao() {
    if (_afirmacoes.isEmpty) return;
    
    final random = Random();
    int novoIndex;
    
    do {
      novoIndex = random.nextInt(_afirmacoes.length);
    } while (_afirmacoes[novoIndex].id == _afirmacaoDoDia?.id && _afirmacoes.length > 1);
    
    _afirmacaoDoDia = _afirmacoes[novoIndex];
    notifyListeners();
  }

  Future<void> refreshFromApi() async {
    _setLoading(true);
    _clearError();
    
    try {
      final novasAfirmacoes = await _apiNinjasService.getRandomQuotes();
      int novasCount = 0;
      
      for (var nova in novasAfirmacoes) {
        if (!_afirmacoes.any((a) => a.texto == nova.texto)) {
          _afirmacoes.add(nova);
          await _firebaseService.saveAfirmacao(nova);
          novasCount++;
        }
      }
      
      debugPrint('🔄 Refresh - Adicionadas $novasCount novas');
      notifyListeners();
    } catch (e) {
      _setError('Erro ao atualizar: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 🔥 CORRIGIDO: Agora busca da API de verdade
  Future<List<Afirmacao>> buscarPorCategoria(String categoria) async {
    _setLoading(true);
    debugPrint('🔍 Iniciando busca por categoria: $categoria');
    
    try {
      // Busca da API primeiro
      final resultadosApi = await _apiNinjasService.getQuotesByCategory(categoria);
      
      if (resultadosApi.isNotEmpty) {
        debugPrint('✅ API retornou ${resultadosApi.length} resultados para $categoria');
        
        // Salva os novos resultados no cache local
        for (var resultado in resultadosApi) {
          if (!_afirmacoes.any((a) => a.texto == resultado.texto)) {
            _afirmacoes.add(resultado);
            await _firebaseService.saveAfirmacao(resultado);
          }
        }
        
        // Filtra apenas os da categoria solicitada
        final resultadosFiltrados = resultadosApi
            .where((a) => a.categoria == categoria)
            .toList();
        
        debugPrint('📊 Resultados filtrados: ${resultadosFiltrados.length}');
        return resultadosFiltrados;
      }
      
      // Se API não retornou nada, busca no cache local
      debugPrint('⚠️ API sem resultados, buscando no cache local');
      final resultadosLocais = _afirmacoes
          .where((a) => a.categoria == categoria)
          .toList();
      
      debugPrint('📚 Cache local: ${resultadosLocais.length} resultados');
      return resultadosLocais;
      
    } catch (e) {
      debugPrint('❌ Erro na busca por categoria: $e');
      
      // Fallback para cache local
      final resultadosLocais = _afirmacoes
          .where((a) => a.categoria == categoria)
          .toList();
      
      debugPrint('📚 Fallback cache local: ${resultadosLocais.length} resultados');
      return resultadosLocais;
      
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleFavorito(Afirmacao afirmacao) async {
    final updatedAfirmacao = Afirmacao(
      id: afirmacao.id,
      texto: afirmacao.texto,
      categoria: afirmacao.categoria,
      isFavorita: !afirmacao.isFavorita,
      dataCriacao: afirmacao.dataCriacao,
    );

    if (updatedAfirmacao.isFavorita) {
      _favoritos.add(updatedAfirmacao);
      debugPrint('❤️ Adicionado aos favoritos');
    } else {
      _favoritos.removeWhere((a) => a.id == updatedAfirmacao.id);
      debugPrint('💔 Removido dos favoritos');
    }

    final index = _afirmacoes.indexWhere((a) => a.id == updatedAfirmacao.id);
    if (index != -1) {
      _afirmacoes[index] = updatedAfirmacao;
    }

    notifyListeners();
  }

  Future<void> registrarHumor(int humor, {String? nota}) async {
    final registro = RegistroHumor(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      humor: humor,
      data: DateTime.now(),
      nota: nota,
    );

    _registrosHumor.add(registro);
    await _firebaseService.saveRegistroHumor(registro);
    
    debugPrint('😊 Humor registrado: $humor');
    notifyListeners();
  }

  List<RegistroHumor> getRegistrosHumorDoMes() {
    final now = DateTime.now();
    final primeiroDiaMes = DateTime(now.year, now.month, 1);
    
    return _registrosHumor
        .where((r) => r.data.isAfter(primeiroDiaMes))
        .toList();
  }

  int get streakAtual {
    if (_registrosHumor.isEmpty) return 0;
    
    final registrosOrdenados = List.from(_registrosHumor)
      ..sort((a, b) => b.data.compareTo(a.data));
    
    int streak = 1;
    DateTime dataAtual = registrosOrdenados.first.data;
    
    for (int i = 1; i < registrosOrdenados.length; i++) {
      final diferenca = dataAtual.difference(registrosOrdenados[i].data).inDays;
      if (diferenca == 1) {
        streak++;
        dataAtual = registrosOrdenados[i].data;
      } else if (diferenca > 1) {
        break;
      }
    }
    
    return streak;
  }

  Map<String, int> get categoriasMaisUsadas {
    final Map<String, int> contagem = {};
    
    for (var afirmacao in _favoritos) {
      contagem[afirmacao.categoria] = (contagem[afirmacao.categoria] ?? 0) + 1;
    }
    
    var sortedEntries = contagem.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(3));
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Afirmacao _getMockAfirmacaoDoDia() {
    return Afirmacao(
      id: 'mock_daily',
      texto: 'Acredite em você e todo o resto virá naturalmente.',
      categoria: 'Motivação',
      dataCriacao: DateTime.now(),
    );
  }

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
    ];
  }
}