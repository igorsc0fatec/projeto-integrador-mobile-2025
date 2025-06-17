class RecheioModel {
  final int? id;
  final String descricao;
  final double valorPorPeso;
  final int? idConfeitaria;

  RecheioModel({
    this.id,
    required this.descricao,
    required this.valorPorPeso,
    this.idConfeitaria,
  });

  // Método para criar objeto a partir de um mapa (vindo da API)
  factory RecheioModel.fromMap(Map<String, dynamic> map) {
    double converterValor(dynamic valor) {
      if (valor is double) return valor;
      if (valor is int) return valor.toDouble();
      if (valor is String) {
        final valorLimpo = valor
            .replaceAll('R\$', '')
            .replaceAll('.', '')
            .replaceAll(',', '.')
            .trim();
        return double.tryParse(valorLimpo) ?? 0.0;
      }
      return 0.0;
    }

    return RecheioModel(
      id: map['id_recheio'],
      descricao: map['desc_recheio'] ?? '',
      valorPorPeso: converterValor(map['valor_por_peso']),
      idConfeitaria: map['id_confeitaria'],
    );
  }

  // Método para formatar o valor para exibição (R$ 0,00)
  String get valorFormatado {
    return 'R\$ ${valorPorPeso.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Método para converter para mapa (enviar para API)
  Map<String, dynamic> toMap() {
    return {
      'id_recheio': id,
      'desc_recheio': descricao,
      'valor_por_peso': valorPorPeso,
      'id_confeitaria': idConfeitaria,
    };
  }

  // Método para criar cópia com novos valores
  RecheioModel copyWith({
    int? id,
    String? descricao,
    double? valorPorPeso,
    int? idConfeitaria,
  }) {
    return RecheioModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valorPorPeso: valorPorPeso ?? this.valorPorPeso,
      idConfeitaria: idConfeitaria ?? this.idConfeitaria,
    );
  }
}