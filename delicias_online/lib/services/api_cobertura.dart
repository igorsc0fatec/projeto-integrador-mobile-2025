import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delicias_online/models/CoberturaModel.dart';
import 'package:delicias_online/models/session.dart';

class CoberturaService {
  static const String baseUrl = "http://11.111.11.111/api/Coberturas"; // Substitua pelo seu IP
  static const Duration timeout = Duration(seconds: 30);

  // Método para buscar coberturas de uma confeitaria
  static Future<List<CoberturaModel>> getCoberturasPorConfeitaria(int idConfeitaria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coberturas.php?id_confeitaria=$idConfeitaria'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => CoberturaModel.fromMap(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar coberturas');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao listar coberturas: ${e.toString()}');
    }
  }

  // Método para cadastrar nova cobertura
  static Future<Map<String, dynamic>> cadastrarCobertura({
    required String descricao,
    required double valorPorGrama,
  }) async {
    try {
      final session = Session();
      final confeitariaId = session.confeitariaCodigo;
      
      if (confeitariaId == null) {
        throw Exception('ID da confeitaria não encontrado');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/coberturas.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'descricao': descricao,
          'valorPorGrama': valorPorGrama,
          'idConfeitaria': int.parse(confeitariaId),
        }),
      ).timeout(timeout);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': 'success',
          'message': responseData['message'],
          'data': CoberturaModel.fromMap(responseData['data']),
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Erro ao cadastrar cobertura',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erro: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> excluirCobertura(int id) async {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/excluir_cobertura.php?id=$id'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          return {'status': 'success', 'message': 'Cobertura excluída com sucesso'};
        } else {
          return {'status': 'error', 'message': 'Erro ao excluir cobertura'};
        }
      } catch (e) {
        return {'status': 'error', 'message': 'Erro de conexão: $e'};
      }
    }
  
  
  static Future<Map<String, dynamic>> atualizarCobertura({
    required int id,
    required String descricao,
    required double valorPorGrama,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('http://26.145.22.183/api/Coberturas/editar_cobertura.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_cobertura': id,
          'desc_cobertura': descricao,
          'valor_por_peso': valorPorGrama,
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
