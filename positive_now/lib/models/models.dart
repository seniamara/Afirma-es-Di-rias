import 'package:cloud_firestore/cloud_firestore.dart';

class Afirmacao {
  final String id;
  final String texto;
  final String categoria;
  final bool isFavorita;
  final DateTime dataCriacao;
  final String? autor;

  Afirmacao({
    required this.id,
    required this.texto,
    required this.categoria,
    this.isFavorita = false,
    required this.dataCriacao,
    this.autor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'texto': texto,
      'categoria': categoria,
      'isFavorita': isFavorita,
      'dataCriacao': dataCriacao,
    };
  }

  factory Afirmacao.fromMap(Map<String, dynamic> map) {
    return Afirmacao(
      id: map['id'] ?? '',
      texto: map['texto'] ?? '',
      categoria: map['categoria'] ?? '',
      isFavorita: map['isFavorita'] ?? false,
      dataCriacao: (map['dataCriacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class RegistroHumor {
  final String id;
  final int humor;
  final DateTime data;
  final String? nota;

  RegistroHumor({
    required this.id,
    required this.humor,
    required this.data,
    this.nota,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'humor': humor,
      'data': data,
      'nota': nota,
    };
  }

  factory RegistroHumor.fromMap(Map<String, dynamic> map) {
    return RegistroHumor(
      id: map['id'] ?? '',
      humor: map['humor'] ?? 3,
      data: (map['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nota: map['nota'],
    );
  }
}

class HistoricoItem {
  final Afirmacao afirmacao;
  final DateTime dataVista;

  HistoricoItem({
    required this.afirmacao,
    required this.dataVista,
  });
}