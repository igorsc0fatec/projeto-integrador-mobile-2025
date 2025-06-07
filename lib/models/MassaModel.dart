class MassaModel {
  final int? id;
  final String descricao;
  final double valorPorPeso;
  final int? idConfeitaria;

  MassaModel({
    this.id,
    required this.descricao,
    required this.valorPorPeso,
    this.idConfeitaria,
  });

  // Método para criar objeto a partir de um mapa (vindo da API)
  factory MassaModel.fromMap(Map<String, dynamic> map) {
    // Função para converter o valor para double
    double converterValor(dynamic valor) {
      if (valor is double) return valor;
      if (valor is int) return valor.toDouble();
      if (valor is String) {
        // Remove R$, pontos e troca vírgula por ponto
        final valorLimpo = valor
            .replaceAll('R\$', '')
            .replaceAll('.', '')
            .replaceAll(',', '.')
            .trim();
        return double.tryParse(valorLimpo) ?? 0.0;
      }
      return 0.0;
    }

    return MassaModel(
      id: map['id_massa'],
      descricao: map['desc_massa'] ?? '',
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
      'id_massa': id,
      'desc_massa': descricao,
      'valor_por_peso': valorPorPeso,
      'id_confeitaria': idConfeitaria,
    };
  }
}