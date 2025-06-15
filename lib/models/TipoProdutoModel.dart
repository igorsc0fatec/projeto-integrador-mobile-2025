class TipoProdutoModel {
  final int? id;
  final String descricao;
  final int? idConfeitaria;

  TipoProdutoModel({
    this.id,
    required this.descricao,
    this.idConfeitaria,
  });

  // Método para criar objeto a partir de um mapa (vindo da API)
  factory TipoProdutoModel.fromMap(Map<String, dynamic> map) {
    return TipoProdutoModel(
      id: map['id_tipo_produto'],
      descricao: map['desc_tipo_produto'] ?? '',
      idConfeitaria: map['id_confeitaria'],
    );
  }

  // Método para converter para mapa (enviar para API)
  Map<String, dynamic> toMap() {
    return {
      'id_tipo_produto': id,
      'desc_tipo_produto': descricao,
      'id_confeitaria': idConfeitaria,
    };
  }

  // Método para facilitar a exibição em dropdowns e listas
  @override
  String toString() {
    return descricao;
  }

  // Método para comparar se dois tipos de produto são iguais
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TipoProdutoModel &&
        other.id == id &&
        other.descricao == descricao;
  }

  @override
  int get hashCode => id.hashCode ^ descricao.hashCode;
}