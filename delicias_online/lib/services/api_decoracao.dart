import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delicias_online/models/DecoracaoModel.dart';
import 'package:delicias_online/models/session.dart';

class DecoracaoService {
  static const String baseUrl = "http://26.145.22.183/api/Decoracao"; // Substitua pelo seu IP
  static const Duration timeout = Duration(seconds: 30);

  static Future<List<DecoracaoModel>> getDecoracoesPorConfeitaria(int idConfeitaria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/decoracao.php?id_confeitaria=$idConfeitaria'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => DecoracaoModel.fromMap(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar decorações');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao listar decorações: ${e.toString()}');
    }
  }

static Future<Map<String, dynamic>> cadastrarDecoracao({
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
      Uri.parse('$baseUrl/decoracao.php'),
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
        'data': DecoracaoModel.fromMap(responseData['data']),
      };
    } else {
      return {
        'status': 'error',
        'message': responseData['message'] ?? 'Erro ao cadastrar decoração',
      };
    }
  } catch (e) {
    return {
      'status': 'error',
      'message': 'Erro: ${e.toString()}',
    };
  }
}

static Future<Map<String, dynamic>> atualizarDecoracao({
  required int id,
  required String descricao,
  required double valorPorGrama,
}) async {
  try {
    final response = await http.put(
      Uri.parse('http://26.145.22.183/api/Decoracao/editar_decoracao.php'), // <== altere o endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_decoracao': id,
        'desc_decoracao': descricao,
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



}