import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delicias_online/models/FormatoModel.dart';
import 'package:delicias_online/models/session.dart';

class FormatoService {
  static const String baseUrl = "http://11.111.11.111/api/Formato"; // Substitua pelo seu IP real
  static const Duration timeout = Duration(seconds: 30);

  static Future<List<FormatoModel>> getFormatosPorConfeitaria(int idConfeitaria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/formatos.php?id_confeitaria=$idConfeitaria'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => FormatoModel.fromMap(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar formatos');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao listar formatos: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> cadastrarFormato({
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
        Uri.parse('$baseUrl/formatos.php'),
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
          'data': FormatoModel.fromMap(responseData['data']),
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Erro ao cadastrar formato',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erro: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> atualizarFormato({
    required int id,
    required String descricao,
    required double valorPorGrama,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/editar_formato.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_formato': id,
          'desc_formato': descricao,
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

  static Future<Map<String, dynamic>> excluirFormato(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/excluir_formato.php?id=$id'),
        headers: {'Accept': 'application/json'},
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': data['message'],
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Erro ao excluir formato',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erro: ${e.toString()}',
      };
    }
  }
}
