class DecoracaoModel {
  final int? id;
  final String descricao;
  final double valorPorGrama;
  final int? idConfeitaria;

  DecoracaoModel({
    this.id,
    required this.descricao,
    required this.valorPorGrama,
    this.idConfeitaria,
  });

  // Método para criar objeto a partir de um mapa (vindo da API)
  factory DecoracaoModel.fromMap(Map<String, dynamic> map) {
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

    return DecoracaoModel(
      id: map['id_decoracao'],
      descricao: map['desc_decoracao'] ?? '',
      valorPorGrama: converterValor(map['valor_por_peso']),
      idConfeitaria: map['id_confeitaria'],
    );
  }

  // Método para formatar o valor para exibição (R$ 0,00)
  String get valorFormatado {
    return 'R\$ ${valorPorGrama.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Método para converter para mapa (enviar para API)
  Map<String, dynamic> toMap() {
    return {
      'id_decoracao': id,
      'desc_decoracao': descricao,
      'valor_por_peso': valorPorGrama,
      'id_confeitaria': idConfeitaria,
    };
  }
}
