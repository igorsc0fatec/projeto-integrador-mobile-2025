import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delicias_online/models/PedidoModel.dart';
// ignore: unused_import
import 'package:delicias_online/models/session.dart';

class PedidoService {
  static const String baseUrl = "http://26.145.22.183/api/Pedido"; // Substitua pelo seu IP
  static const Duration timeout = Duration(seconds: 30);

  // Método para buscar todos os pedidos de uma confeitaria
  static Future<List<PedidoModel>> getPedidosPorConfeitaria(int idConfeitaria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Pedidos.php?id_confeitaria=$idConfeitaria'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => PedidoModel.fromMap(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar pedidos');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao listar pedidos: ${e.toString()}');
    }
  }

  // Método para calcular o valor total de todos os pedidos
  static Future<double> getValorTotalPedidos(int idConfeitaria) async {
    final pedidos = await getPedidosPorConfeitaria(idConfeitaria);

    double total = 0.0;
    for (var pedido in pedidos) {
      // Verifica se o status do pedido é "entregue" (case insensitive)
      if (pedido.status.toLowerCase() == 'Entregue!') {
        final valor = await pedido.valorTotal; // aguarda cada valor se for Future<double>
        total += valor;
      }
    }
    return total;
  }


  // Método para agrupar pedidos por período (semana, mês, ano)
  static Future<Map<String, List<PedidoModel>>> getPedidosPorPeriodo(int idConfeitaria) async {
    final pedidos = await getPedidosPorConfeitaria(idConfeitaria);
    final now = DateTime.now();
    
    // Filtra pedidos da última semana
    final semanaPassada = now.subtract(const Duration(days: 7));
    final pedidosSemana = pedidos.where((p) => p.dataPedido.isAfter(semanaPassada)).toList();
    
    // Filtra pedidos do último mês
    final mesPassado = DateTime(now.year, now.month - 1, now.day);
    final pedidosMes = pedidos.where((p) => p.dataPedido.isAfter(mesPassado)).toList();
    
    // Filtra pedidos do último ano
    final anoPassado = DateTime(now.year - 1, now.month, now.day);
    final pedidosAno = pedidos.where((p) => p.dataPedido.isAfter(anoPassado)).toList();
    
    return {
      'semana': pedidosSemana,
      'mes': pedidosMes,
      'ano': pedidosAno,
    };
  }

  // Método para contar os 5 produtos mais vendidos
    static Future<Map<String, Map<String, dynamic>>> getProdutosMaisVendidos(int idConfeitaria) async {
      final pedidos = await getPedidosPorConfeitaria(idConfeitaria);
      final produtosInfo = <String, Map<String, dynamic>>{};
      
      for (final pedido in pedidos) {
        if (pedido.tipo == 'normal') {
          for (int i = 0; i < pedido.itens.length; i++) {
            // Extrai o nome base do produto (remove a parte da quantidade)
            final nomeProduto = pedido.itens[i].replaceAll(RegExp(r'\s*\(\d+\s*un\)'), '').trim();
            
            // Obtém quantidade - prioriza o array de quantidades, depois extrai do nome
            int quantidade = 1;
            if (i < pedido.quantidades.length && pedido.quantidades[i] > 0) {
              quantidade = pedido.quantidades[i];
            } else {
              final match = RegExp(r'\((\d+)\s*un\)').firstMatch(pedido.itens[i]);
              if (match != null) {
                quantidade = int.tryParse(match.group(1)!) ?? 1;
              }
            }
            
            // Obtém preço unitário
            double precoUnitario = 0.0;
            if (i < pedido.precos.length) {
              precoUnitario = pedido.precos[i];
            } else if (pedido.valorTotal > 0 && quantidade > 0) {
              precoUnitario = pedido.valorTotal / quantidade;
            }
            
            // Atualiza as estatísticas do produto
            if (produtosInfo.containsKey(nomeProduto)) {
              produtosInfo[nomeProduto]!['quantidade'] += quantidade;
              produtosInfo[nomeProduto]!['valorTotal'] += precoUnitario * quantidade;
            } else {
              produtosInfo[nomeProduto] = {
                'quantidade': quantidade,
                'valorTotal': precoUnitario * quantidade,
                'precoUnitario': precoUnitario,
              };
            }
          }
        } else if (pedido.tipo == 'personalizado' && pedido.itemPersonalizado != null) {
          final nomeProduto = pedido.itemPersonalizado!.nome;
          final quantidade = 1; // Cada pedido personalizado conta como 1 unidade
          final precoUnitario = pedido.valorTotal;
          
          if (produtosInfo.containsKey(nomeProduto)) {
            produtosInfo[nomeProduto]!['quantidade'] += quantidade;
            produtosInfo[nomeProduto]!['valorTotal'] += precoUnitario;
          } else {
            produtosInfo[nomeProduto] = {
              'quantidade': quantidade,
              'valorTotal': precoUnitario,
              'precoUnitario': precoUnitario,
            };
          }
        }
      }
      
      // Ordena por quantidade e pega os top 5
      final sortedEntries = produtosInfo.entries.toList()
        ..sort((a, b) => b.value['quantidade'].compareTo(a.value['quantidade']));
      
      return Map.fromEntries(sortedEntries.take(5));
    }

  // Método para buscar pedidos com filtro de status
  static Future<List<PedidoModel>> getPedidosPorStatus(int idConfeitaria, String status) async {
    final pedidos = await getPedidosPorConfeitaria(idConfeitaria);
    return pedidos.where((p) => p.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Método para buscar pedidos em um intervalo de datas
  static Future<List<PedidoModel>> getPedidosPorData(int idConfeitaria, DateTime inicio, DateTime fim) async {
    final pedidos = await getPedidosPorConfeitaria(idConfeitaria);
    return pedidos.where((p) => 
      p.dataPedido.isAfter(inicio) && p.dataPedido.isBefore(fim)
    ).toList();
  }
}