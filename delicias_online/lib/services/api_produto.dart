import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delicias_online/models/ProdutoModel.dart';
import 'package:delicias_online/models/session.dart';

class ProdutoService {
  static const String baseUrl = "http://11.111.11.111/api/Produto"; // Substitua pelo seu IP
  static const Duration timeout = Duration(seconds: 30);

  // Método para buscar produtos por confeitaria
  static Future<List<ProdutoModel>> getProdutosPorConfeitaria(int idConfeitaria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produto.php?id_confeitaria=$idConfeitaria'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => ProdutoModel.fromMap(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar produtos');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao listar produtos: ${e.toString()}');
    }
  }

  // Método para cadastrar novo produto
  static Future<Map<String, dynamic>> cadastrarProduto({
    required String nome,
    required String descricao,
    required double valor,
    double? frete,
    required int idTipoProduto,
  }) async {
    try {
      final session = Session();
      final confeitariaId = session.confeitariaCodigo;

      if (confeitariaId == null) {
        throw Exception('ID da confeitaria não encontrado');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/produto.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome_produto': nome,
          'desc_produto': descricao,
          'valor_produto': valor,
          'frete': frete,
          'id_tipo_produto': idTipoProduto,
          'id_confeitaria': int.parse(confeitariaId),
        }),
      ).timeout(timeout);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': 'success',
          'message': responseData['message'],
          'data': ProdutoModel.fromMap(responseData['data']),
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Erro ao cadastrar produto',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erro: ${e.toString()}',
      };
    }
  }

  // Método para atualizar produto existente
  static Future<Map<String, dynamic>> atualizarProduto({
    required int id,
    required String nome,
    required String descricao,
    required double valor,
    double? frete,
    bool? ativo,
    int? limiteEntrega,
    required int idTipoProduto, // Adicione este parâmetro obrigatório
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/editar_produto.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_produto': id,
          'nome_produto': nome,
          'desc_produto': descricao,
          'valor_produto': valor,
          'frete': frete,
          'produto_ativo': ativo ?? true,
          'limite_entrega': limiteEntrega,
          'id_tipo_produto': idTipoProduto, // Adicione este campo
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Erro HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Erro na requisição: $e');
      return {
        'status': 'error',
        'message': 'Falha na conexão: ${e.toString()}',
      };
    }
  }

  // Método para buscar produtos por tipo
  static Future<List<ProdutoModel>> getProdutosPorTipo(int idTipoProduto) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produto.php?id_tipo_produto=$idTipoProduto'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => ProdutoModel.fromMap(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar produtos por tipo');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao listar produtos por tipo: ${e.toString()}');
    }
  }
}
