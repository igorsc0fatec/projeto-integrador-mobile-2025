class PedidoModel {
  final int? id;
  final double valorTotal;
  final double desconto;
  final DateTime dataPedido;
  final String status;
  final double frete;
  final ClienteModel cliente;
  final String formaPagamento;
  final List<String> itens;
  final String tipo; // 'normal' or 'personalizado'
  final double? peso; // Only for personalizado
  final ItemPersonalizado? itemPersonalizado; // Only for personalizado
  final List<double> precos; // Preços dos itens
  final List<int> quantidades; // Quantidades dos itens

  PedidoModel({
    this.id,
    required this.valorTotal,
    required this.desconto,
    required this.dataPedido,
    required this.status,
    required this.frete,
    required this.cliente,
    required this.formaPagamento,
    required this.itens,
    required this.tipo,
    this.peso,
    this.itemPersonalizado,
    required this.precos,
    required this.quantidades,
  });

  factory PedidoModel.fromMap(Map<String, dynamic> map) {
    // Helper function to convert dynamic to double
    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    // Parse cliente data
    final cliente = ClienteModel.fromMap({
      'nome_cliente': map['cliente']['nome'],
      'cpf_cliente': map['cliente']['cpf'],
      'endereco': map['cliente']['endereco'],
    });

    // Parse item personalizado if exists
    ItemPersonalizado? itemPersonalizado;
    if (map['tipo'] == 'personalizado' && map['item'] != null) {
      itemPersonalizado = ItemPersonalizado.fromMap(map['item']);
    }

    // Parse itens, preços e quantidades
    List<String> itens = [];
    List<double> precos = [];
    List<int> quantidades = [];
    
    if (map['tipo'] == 'normal') {
    // Itens
      itens = map['itens'] != null ? (map['itens'] as String).split(', ') : [];
      
      if (map['precos'] != null) {
      try {
        precos = (map['precos'] as String).split(', ')
          .map((e) => double.tryParse(e.replaceAll('R\$', '').trim()) ?? 0.0)
          .toList();
      } catch (e) {
        precos = [];
      }
    }
      if (map['quantidades'] != null) {
        try {
          quantidades = (map['quantidades'] as String).split(', ')
            .map((e) => int.tryParse(e) ?? 0)
            .toList();
        } catch (e) {
          // Alternativa: extrair quantidades dos nomes dos itens
          quantidades = itens.map((item) {
            final match = RegExp(r'\((\d+)\s*un\)').firstMatch(item);
            return match != null ? int.tryParse(match.group(1)!) ?? 1 : 1;
          }).toList();
        }
      } else {
        // Se não houver array de quantidades, extrair dos nomes dos itens
        quantidades = itens.map((item) {
          final match = RegExp(r'\((\d+)\s*un\)').firstMatch(item);
          return match != null ? int.tryParse(match.group(1)!) ?? 1 : 1;
        }).toList();
      }
    }

    return PedidoModel(
      id: map['id_pedido'],
      valorTotal: toDouble(map['valor_total']),
      desconto: toDouble(map['desconto']),
      dataPedido: DateTime.parse(map['data_pedido']),
      status: map['status'] ?? '',
      frete: toDouble(map['frete']),
      cliente: cliente,
      formaPagamento: map['forma_pagamento'] ?? '',
      itens: itens,
      tipo: map['tipo'] ?? 'normal',
      peso: map['peso'] != null ? toDouble(map['peso']) : null,
      itemPersonalizado: itemPersonalizado,
      precos: precos,
      quantidades: quantidades,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_pedido': id,
      'valor_total': valorTotal,
      'desconto': desconto,
      'data_pedido': dataPedido.toIso8601String(),
      'status': status,
      'frete': frete,
      'cliente': cliente.toMap(),
      'forma_pagamento': formaPagamento,
      'itens': itens.join(', '),
      'precos': precos.join(', '),
      'quantidades': quantidades.join(', '),
      'tipo': tipo,
      'peso': peso,
      'item': itemPersonalizado?.toMap(),
    };
  }

  String get valorTotalFormatado {
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get descontoFormatado {
    return 'R\$ ${desconto.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get freteFormatado {
    return 'R\$ ${frete.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}


class ClienteModel {
  final String nome;
  final String cpf;
  final String endereco;

  ClienteModel({
    required this.nome,
    required this.cpf,
    required this.endereco,
  });

  factory ClienteModel.fromMap(Map<String, dynamic> map) {
    return ClienteModel(
      nome: map['nome_cliente'] ?? '',
      cpf: map['cpf_cliente'] ?? '',
      endereco: map['endereco'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome_cliente': nome,
      'cpf_cliente': cpf,
      'endereco': endereco,
    };
  }
}

class ItemPersonalizado {
  final String nome;
  final String? massa;
  final String? recheio;
  final String? cobertura;
  final String? formato;
  final String? decoracao;

  ItemPersonalizado({
    required this.nome,
    this.massa,
    this.recheio,
    this.cobertura,
    this.formato,
    this.decoracao,
  });

  factory ItemPersonalizado.fromMap(Map<String, dynamic> map) {
    return ItemPersonalizado(
      nome: map['nome'] ?? '',
      massa: map['massa'],
      recheio: map['recheio'],
      cobertura: map['cobertura'],
      formato: map['formato'],
      decoracao: map['decoracao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'massa': massa,
      'recheio': recheio,
      'cobertura': cobertura,
      'formato': formato,
      'decoracao': decoracao,
    };
  }
}