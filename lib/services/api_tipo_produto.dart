import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delicias_online/models/TipoProdutoModel.dart';
import 'package:delicias_online/models/session.dart';

class TipoProdutoService {
  static const String baseUrl = "http://26.145.22.183/api/TiposProduto"; // Substitua pelo seu IP
  static const Duration timeout = Duration(seconds: 30);

  // Método para buscar tipos de produto de uma confeitaria
  static Future<List<TipoProdutoModel>> getTiposProdutoPorConfeitaria(int idConfeitaria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tipos_produto.php?id_confeitaria=$idConfeitaria'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => TipoProdutoModel.fromMap(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar tipos de produto');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao listar tipos de produto: ${e.toString()}');
    }
  }

  // Método para cadastrar novo tipo de produto
  static Future<Map<String, dynamic>> cadastrarTipoProduto({
    required String descricao,
  }) async {
    try {
      final session = Session();
      final confeitariaId = session.confeitariaCodigo;
      
      if (confeitariaId == null) {
        throw Exception('ID da confeitaria não encontrado');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tipos_produto.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'descricao': descricao,
          'idConfeitaria': int.parse(confeitariaId),
        }),
      ).timeout(timeout);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': 'success',
          'message': responseData['message'],
          'data': TipoProdutoModel.fromMap(responseData['data']),
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Erro ao cadastrar tipo de produto',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erro: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> excluirTipoProduto(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/excluir_tipo_produto.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'status': 'success', 'message': 'Tipo de produto excluído com sucesso'};
      } else {
        return {'status': 'error', 'message': 'Erro ao excluir tipo de produto'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Erro de conexão: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> atualizarTipoProduto({
    required int id,
    required String descricao,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/editar_tipo_produto.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_tipo_produto': id,
          'desc_tipo_produto': descricao,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Erro HTTP ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Erro na requisição: $e');
      return {
        'status': 'error',
        'message': 'Falha na conexão: ${e.toString()}'
      };
    }
  }
}