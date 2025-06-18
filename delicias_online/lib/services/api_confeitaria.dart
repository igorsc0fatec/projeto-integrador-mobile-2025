// api_confeitaria.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delicias_online/models/ConfeitariaModel.dart';
import 'package:delicias_online/models/UsuarioModel.dart';
import 'package:delicias_online/models/TelefoneModel.dart';
import 'package:delicias_online/models/DddModel.dart';
import 'package:delicias_online/models/TipoTelefoneModel.dart';
// ignore: unused_import
import 'package:delicias_online/models/session.dart';

class ConfeitariaService {
  static const String baseUrl = "http://11.111.11.111/api/Confeitaria";
  static const Duration timeout = Duration(seconds: 30);

  // Buscar dados da confeitaria
   static Future<ConfeitariaModel> getConfeitaria(int idConfeitaria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/confeitaria.php?id_confeitaria=$idConfeitaria'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return ConfeitariaModel.fromMap(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar dados');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar confeitaria: ${e.toString()}');
    }
  }

  // Atualizar dados da confeitaria
  static Future<Map<String, dynamic>> atualizarConfeitaria({
    required ConfeitariaModel confeitaria,
  }) async {
    try {
      if (confeitaria.id == null) {
        return {
          'status': 'error',
          'message': 'ID da confeitaria não está disponível'
        };
      }

      // Dados no formato esperado pelo PHP
      final Map<String, dynamic> requestData = {
        'id_confeitaria': confeitaria.id,
        'nome_confeitaria': confeitaria.nome,
        'cnpj_confeitaria': confeitaria.cnpj,
        'cep_confeitaria': confeitaria.cep,
        'log_confeitaria': confeitaria.logradouro,
        'num_local': confeitaria.numero,
        'complemento': confeitaria.complemento ?? '', // Evita null
        'bairro_confeitaria': confeitaria.bairro,
        'cidade_confeitaria': confeitaria.cidade,
        'uf_confeitaria': confeitaria.uf,
        'hora_entrada': confeitaria.horaAbertura,
        'hora_saida': confeitaria.horaFechamento,
        'latitude': confeitaria.latitude,
        'longitude': confeitaria.longitude,
      };

      print('Dados enviados para a API: $requestData'); // Debug

      final response = await http.put(
        Uri.parse('$baseUrl/editar_confeitaria.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      ).timeout(timeout);

      print('Resposta da API: ${response.body}'); // Debug

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': responseData['message'],
          'data': ConfeitariaModel.fromMap(responseData['data']),
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Erro ao atualizar',
        };
      }
    } catch (e) {
      print('Erro durante a requisição: $e'); // Debug
      return {
        'status': 'error',
        'message': 'Erro: ${e.toString()}',
      };
    }
  }

  // Buscar dados do usuário
  static Future<UsuarioModel> getUsuario(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuario.php?id_confeitaria=$idUsuario'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          return UsuarioModel.fromMap(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar usuário');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar usuário: ${e.toString()}');
    }
  }
  
  // Atualizar dados do usuário
    static Future<Map<String, dynamic>> atualizarUsuario({
        required int idUsuario,
        required String email,
        String? senhaAtual,
        String? novaSenha,
      }) async {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/editar_usuario.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id_usuario': idUsuario,
              'email_usuario': email,
              if (senhaAtual != null) 'senha_atual': senhaAtual,
              if (novaSenha != null) 'nova_senha': novaSenha,
            }),
          );

          final responseData = jsonDecode(response.body);
          
          if (response.statusCode == 200) {
            return responseData;
          } else {
            return {
              'status': 'error',
              'message': responseData['message'] ?? 'Erro ao atualizar (${response.statusCode})'
            };
          }
        } catch (e) {
          return {
            'status': 'error',
            'message': 'Falha na conexão: ${e.toString()}'
          };
        }
      }

// Buscar telefones da confeitaria
static Future<List<TelefoneModel>> getTelefones(int idUsuario) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/telefones.php?id_usuario=$idUsuario'),
    ).timeout(timeout);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((e) => TelefoneModel.fromMap(e))
            .toList();
      } else {
        throw Exception(responseData['message'] ?? 'Erro ao carregar telefones');
      }
    } else {
      throw Exception('Erro na requisição: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro ao buscar telefones: ${e.toString()}');
  }
}

// Adicionar telefone
// Adicionar telefone com verificações
static Future<Map<String, dynamic>> adicionarTelefone({
  required int idUsuario,
  required TelefoneModel telefone,
}) async {
  try {
    // Verifica se já existem 3 telefones
    final telefonesAtuais = await getTelefones(idUsuario);
    if (telefonesAtuais.length >= 3) {
      return {
        'status': 'error',
        'message': 'Limite de 3 telefones atingido'
      };
    }

    // Verifica se o número já existe
    final numeroExistente = telefonesAtuais.any((t) => 
        t.numero == telefone.numero && t.idDdd == telefone.idDdd);
    
    if (numeroExistente) {
      return {
        'status': 'error',
        'message': 'Este número já está cadastrado'
      };
    }

    // Se passou nas verificações, procede com a adição
    final response = await http.post(
      Uri.parse('$baseUrl/adicionar_telefone.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_usuario': idUsuario,
        'telefone': telefone.toMap(),
      }),
    ).timeout(timeout);

    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return responseData;
    } else {
      return {
        'status': 'error',
        'message': responseData['message'] ?? 'Erro ao adicionar telefone'
      };
    }
  } catch (e) {
    return {
      'status': 'error',
      'message': 'Falha na conexão: ${e.toString()}'
    };
  }
}

// Editar telefone com verificações
static Future<Map<String, dynamic>> editarTelefone({
  required int idTelefone,
  required TelefoneModel telefone,
  required int idUsuario, // Adicionado para verificação
}) async {
  try {
    // Busca telefones existentes
    final telefonesAtuais = await getTelefones(idUsuario);
    
    // Verifica se o novo número já existe em OUTRO telefone
    final numeroExistente = telefonesAtuais.any((t) => 
        t.id != idTelefone && // Não compara com o próprio telefone que está sendo editado
        t.numero == telefone.numero && 
        t.idDdd == telefone.idDdd);
    
    if (numeroExistente) {
      return {
        'status': 'error',
        'message': 'Este número já está cadastrado em outro telefone'
      };
    }

    // Se passou na verificação, procede com a edição
    final response = await http.post(
      Uri.parse('$baseUrl/editar_telefone.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_telefone': idTelefone,
        'num_telefone': telefone.numero,
        'id_ddd': telefone.idDdd,
        'id_tipo_telefone': telefone.idTipoTelefone,
      }),
    ).timeout(timeout);

    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return responseData;
    } else {
      return {
        'status': 'error',
        'message': responseData['message'] ?? 'Erro ao editar telefone'
      };
    }
  } catch (e) {
    return {
      'status': 'error',
      'message': 'Falha na conexão: ${e.toString()}'
    };
  }
}

// Excluir telefone
static Future<Map<String, dynamic>> excluirTelefone(int idTelefone) async {
  try {
    // Opção 1: Enviar via POST/JSON (preferível para operações de exclusão)
    final response = await http.post(
      Uri.parse('$baseUrl/excluir_telefone.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_telefone': idTelefone}),
    ).timeout(timeout);

    // Opção 2: Manter via GET (funciona mas menos ideal)
    // final response = await http.delete(
    //   Uri.parse('$baseUrl/excluir_telefone.php?id_telefone=$idTelefone'),
    // ).timeout(timeout);

    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return responseData;
    } else {
      return {
        'status': 'error',
        'message': responseData['message'] ?? 'Erro ao excluir telefone'
      };
    }
  } catch (e) {
    return {
      'status': 'error',
      'message': 'Falha na conexão: ${e.toString()}'
    };
  }
}

static Future<List<DddModel>> getDdds() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/ddds.php'),
    ).timeout(timeout);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((e) => DddModel.fromMap({
                  'id_ddd': int.parse(e['id_ddd'].toString()), // Garante que é int
                  'ddd': e['ddd'],
                  'uf_ddd': e['uf_ddd']
                }))
            .toList();
      } else {
        throw Exception(responseData['message'] ?? 'Erro ao carregar DDDs');
      }
    } else {
      throw Exception('Erro na requisição: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro ao buscar DDDs: ${e.toString()}');
  }
}

// api_confeitaria.dart
static Future<List<TipoTelefoneModel>> getTiposTelefone() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/tipos_telefone.php'),
    ).timeout(timeout);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((e) => TipoTelefoneModel.fromMap(e))
            .toList();
      } else {
        throw Exception(responseData['message'] ?? 'Erro ao carregar tipos de telefone');
      }
    } else {
      throw Exception('Erro na requisição: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro ao buscar tipos de telefone: ${e.toString()}');
  }
}

}
