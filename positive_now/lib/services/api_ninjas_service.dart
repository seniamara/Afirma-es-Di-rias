import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'package:flutter/material.dart';

class ApiNinjasService {
  static const String _baseUrl = 'https://api.api-ninjas.com/v2';
  static const String _apiKey = 'ZyC2xvd4smcuntzt3sfH6DjNYSY4E02HDuFxTBe3';
  
  // Categorias disponíveis na API
  static const List<String> categoriasDisponiveis = [
    'wisdom',
    'philosophy',
    'life',
    'truth',
    'inspirational',
    'relationships',
    'love',
    'faith',
    'humor',
    'success',
    'courage',
    'happiness',
    'art',
    'writing',
    'fear',
    'nature',
    'time',
    'freedom',
    'death',
    'leadership',
  ];

  // Mapeamento das categorias da API para português
  static const Map<String, String> mapaCategorias = {
    'wisdom': 'Sabedoria',
    'philosophy': 'Filosofia',
    'life': 'Vida',
    'truth': 'Verdade',
    'inspirational': 'Motivação',
    'relationships': 'Relacionamentos',
    'love': 'Amor',
    'faith': 'Fé',
    'humor': 'Humor',
    'success': 'Sucesso',
    'courage': 'Coragem',
    'happiness': 'Felicidade',
    'art': 'Arte',
    'writing': 'Escrita',
    'fear': 'Medo',
    'nature': 'Natureza',
    'time': 'Tempo',
    'freedom': 'Liberdade',
    'death': 'Morte',
    'leadership': 'Liderança',
  };

  // Mapeamento reverso (português para API)
  static const Map<String, String> mapaCategoriasReverso = {
    'Ansiedade': 'fear',
    'Autoestima': 'inspirational',
    'Gratidão': 'happiness',
    'Motivação': 'inspirational',
    'Paz Interior': 'peace',
    'Amor Próprio': 'love',
    'Sabedoria': 'wisdom',
    'Filosofia': 'philosophy',
    'Vida': 'life',
    'Verdade': 'truth',
    'Relacionamentos': 'relationships',
    'Amor': 'love',
    'Fé': 'faith',
    'Humor': 'humor',
    'Sucesso': 'success',
    'Coragem': 'courage',
    'Felicidade': 'happiness',
    'Arte': 'art',
    'Escrita': 'writing',
    'Medo': 'fear',
    'Natureza': 'nature',
    'Tempo': 'time',
    'Liberdade': 'freedom',
    'Morte': 'death',
    'Liderança': 'leadership',
  };

  // Buscar quotes por categoria específica (vai até a API)
  Future<List<Afirmacao>> getQuotesByCategory(String categoriaApp) async {
    debugPrint('🔍 Buscando na API por categoria: $categoriaApp');
    
    final apiCategory = mapaCategoriasReverso[categoriaApp];
    
    try {
      String url = '$_baseUrl/randomquotes';
      
      if (apiCategory != null) {
        url += '?category=$apiCategory';
        debugPrint('📡 API Request (categoria): $url');
      } else {
        debugPrint('📡 API Request (geral): $url');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
      );
      
      debugPrint('📡 API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('📡 API Retornou ${data.length} quotes');
        
        return data.map((item) {
          // Pega a categoria da API e traduz
          String categoriaTraduzida = categoriaApp; // Fallback para a categoria original
          
          if (item['category'] != null) {
            final apiCat = item['category'].toString().toLowerCase();
            categoriaTraduzida = mapaCategorias[apiCat] ?? 
                                _categorizarPorTexto(item['quote'] ?? '');
            debugPrint('🏷️ Categoria API: $apiCat -> Traduzida: $categoriaTraduzida');
          } else {
            categoriaTraduzida = _categorizarPorTexto(item['quote'] ?? '');
          }
          
          return Afirmacao(
            id: 'api_${DateTime.now().millisecondsSinceEpoch}_${item['author'] ?? 'unknown'}',
            texto: item['quote'] ?? 'Citação não disponível',
            categoria: categoriaTraduzida,
            dataCriacao: DateTime.now(),
          );
        }).toList();
      } else {
        debugPrint('❌ API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ API Exception: $e');
      return [];
    }
  }

  // Buscar quote do dia
  Future<Afirmacao> getQuoteOfTheDay() async {
    try {
      final url = '$_baseUrl/quoteoftheday';
      
      debugPrint('📡 API Request: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
      );
      
      debugPrint('📡 API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final item = data.first;
          
          String categoriaApp = 'Geral';
          if (item['category'] != null) {
            final apiCategory = item['category'].toString().toLowerCase();
            categoriaApp = mapaCategorias[apiCategory] ?? 
                          _categorizarPorTexto(item['quote'] ?? '');
          } else {
            categoriaApp = _categorizarPorTexto(item['quote'] ?? '');
          }
          
          return Afirmacao(
            id: 'quote_of_day_${DateTime.now().toIso8601String()}',
            texto: item['quote'] ?? 'Citação não disponível',
            categoria: categoriaApp,
            dataCriacao: DateTime.now(),
          );
        }
      }
      
      debugPrint('❌ Erro ao carregar quote do dia, usando mock');
      return _getMockAfirmacaoDoDia();
      
    } catch (e) {
      debugPrint('❌ API Exception: $e');
      return _getMockAfirmacaoDoDia();
    }
  }

  // Buscar quotes aleatórios
  Future<List<Afirmacao>> getRandomQuotes() async {
    try {
      final url = '$_baseUrl/randomquotes';
      
      debugPrint('📡 API Request: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
      );
      
      debugPrint('📡 API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('📡 API Retornou ${data.length} quotes');
        
        return data.map((item) {
          String categoriaApp = 'Geral';
          if (item['category'] != null) {
            final apiCategory = item['category'].toString().toLowerCase();
            categoriaApp = mapaCategorias[apiCategory] ?? 
                          _categorizarPorTexto(item['quote'] ?? '');
          } else {
            categoriaApp = _categorizarPorTexto(item['quote'] ?? '');
          }
          
          return Afirmacao(
            id: 'api_${DateTime.now().millisecondsSinceEpoch}_${item['author'] ?? 'unknown'}',
            texto: item['quote'] ?? 'Citação não disponível',
            categoria: categoriaApp,
            dataCriacao: DateTime.now(),
          );
        }).toList();
      } else {
        debugPrint('❌ API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ API Exception: $e');
      return [];
    }
  }

  // Mock data para fallback
  Afirmacao _getMockAfirmacaoDoDia() {
    return Afirmacao(
      id: 'mock_daily',
      texto: 'Acredite em você e todo o resto virá naturalmente.',
      categoria: 'Motivação',
      dataCriacao: DateTime.now(),
    );
  }

  String _categorizarPorTexto(String texto) {
    final textoLower = texto.toLowerCase();
    
    if (textoLower.contains('fear') || textoLower.contains('anxiety')) {
      return 'Ansiedade';
    } else if (textoLower.contains('love') || textoLower.contains('self')) {
      return 'Autoestima';
    } else if (textoLower.contains('thank') || textoLower.contains('grateful')) {
      return 'Gratidão';
    } else if (textoLower.contains('success') || textoLower.contains('achieve')) {
      return 'Motivação';
    } else if (textoLower.contains('peace') || textoLower.contains('calm')) {
      return 'Paz Interior';
    } else {
      return 'Geral';
    }
  }
}