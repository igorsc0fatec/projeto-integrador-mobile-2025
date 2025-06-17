class ProdutoModel {
  final int? id;
  final String nome;
  final String descricao;
  final double valor;
  final double? frete;
  final bool ativo;
  final int? limiteEntrega;
  final String? imagemUrl;
  final int? idTipoProduto;
  final int? idConfeitaria;

  ProdutoModel({
    this.id,
    required this.nome,
    required this.descricao,
    required this.valor,
    this.frete,
    this.ativo = true,
    this.limiteEntrega,
    this.imagemUrl,
    this.idTipoProduto,
    this.idConfeitaria,
  });

  // Método para criar objeto a partir de um mapa (vindo da API)
  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
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

    return ProdutoModel(
      id: map['id_produto'],
      nome: map['nome_produto'] ?? '',
      descricao: map['desc_produto'] ?? '',
      valor: converterValor(map['valor_produto']),
      frete: converterValor(map['frete']),
      ativo: map['produto_ativo'] == 1,
      limiteEntrega: map['limite_entrega'],
      imagemUrl: map['img_produto'],
      idTipoProduto: map['id_tipo_produto'],
      idConfeitaria: map['id_confeitaria'],
    );
  }

  // Método para formatar o valor para exibição (R$ 0,00)
  String get valorFormatado {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Método para formatar o frete para exibição (R$ 0,00)
  String? get freteFormatado {
    return frete != null 
      ? 'R\$ ${frete!.toStringAsFixed(2).replaceAll('.', ',')}' 
      : null;
  }

  // Método para converter para mapa (enviar para API)
  Map<String, dynamic> toMap() {
    return {
      'id_produto': id,
      'nome_produto': nome,
      'desc_produto': descricao,
      'valor_produto': valor,
      'frete': frete,
      'produto_ativo': ativo ? 1 : 0,
      'limite_entrega': limiteEntrega,
      'img_produto': imagemUrl,
      'id_tipo_produto': idTipoProduto,
      'id_confeitaria': idConfeitaria,
    };
  }
}