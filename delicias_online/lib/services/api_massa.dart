import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delicias_online/models/MassaModel.dart';
import 'package:delicias_online/models/session.dart';

class MassaService {
  static const String baseUrl = "http://11.111.11.111/api/Massas"; // Substitua pelo seu IP
  static const Duration timeout = Duration(seconds: 30);

  // Método para buscar massas de uma confeitaria
  static Future<List<MassaModel>> getMassasPorConfeitaria(int idConfeitaria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/massas.php?id_confeitaria=$idConfeitaria'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => MassaModel.fromMap(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar massas');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao listar massas: ${e.toString()}');
    }
  }

  // Método para cadastrar nova massa
  static Future<Map<String, dynamic>> cadastrarMassa({
    required String descricao,
    required double valorPorPeso,
  }) async {
    try {
      final session = Session();
      final confeitariaId = session.confeitariaCodigo;
      
      if (confeitariaId == null) {
        throw Exception('ID da confeitaria não encontrado');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/massas.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'descricao': descricao,
          'valorPorPeso': valorPorPeso,
          'idConfeitaria': int.parse(confeitariaId),
        }),
      ).timeout(timeout);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': 'success',
          'message': responseData['message'],
          'data': MassaModel.fromMap(responseData['data']),
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Erro ao cadastrar massa',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erro: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> excluirMassa(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/excluir_massa.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'status': 'success', 'message': 'Massa excluída com sucesso'};
      } else {
        return {'status': 'error', 'message': 'Erro ao excluir massa'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Erro de conexão: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> atualizarMassa({
    required int id,
    required String descricao,
    required double valorPorPeso,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/editar_massa.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_massa': id,
          'desc_massa': descricao,
          'valor_por_peso': valorPorPeso,
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
