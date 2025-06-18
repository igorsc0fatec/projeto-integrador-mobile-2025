import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delicias_online/models/ConfeitariaModel.dart';
import 'package:delicias_online/models/product_type.dart';
import 'package:intl/intl.dart';

class ApiService {
  static const String baseUrl = "http://11.111.11.111/api"; // Substitua pelo seu IP
  static const Duration timeout = Duration(seconds: 30);

    static Future<Map<String, dynamic>> login(String email, String senha) async {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      ).timeout(timeout);

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Falha ao fazer login');
      }
    }

    static Future<Map<String, dynamic>> updateConfeitaria({
      required int idConfeitaria,
      required int idUsuario,
      required String email,
      required String nome,
      required String cnpj,
      required String cep,
      required String logradouro,
      required String numero,
      required String complemento,
      required String bairro,
      required String cidade,
      required String uf,
      required double latitude,
      required double longitude,
      required String horaAbertura,
      required String horaFechamento,
    }) async {
      final response = await http.put(
        Uri.parse('$baseUrl/confeitaria/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_confeitaria': idConfeitaria,
          'id_usuario': idUsuario,
          'email_usuario': email,
          'nome_confeitaria': nome,
          'cnpj_confeitaria': cnpj,
          'cep_confeitaria': cep,
          'log_confeitaria': logradouro,
          'num_local': numero,
          'complemento': complemento,
          'bairro_confeitaria': bairro,
          'cidade_confeitaria': cidade,
          'uf_confeitaria': uf,
          'latitude': latitude,
          'longitude': longitude,
          'hora_entrada': horaAbertura,
          'hora_saida': horaFechamento,
        }),
      );

      return jsonDecode(response.body);
    }
  
    static Future<Map<String, dynamic>> register(String email, String senha) async {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': senha,
          'tipoUsuario': 2 // Cliente
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao registrar');
      }
    }

    static Future<Map<String, dynamic>> registerConfeitaria({
    required String email,
    required String senha,
    required String nome,
    required String cnpj,
    required String cep,
    required String logradouro,
    required String numero,
    String? complemento,
    required String bairro,
    required String cidade,
    required String uf,
    required double latitude,
    required double longitude,
    required String horaAbertura,
    required String horaFechamento,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/register_confeitaria.php');
      final headers = {'Content-Type': 'application/json'};
      
      final body = jsonEncode({
        'email': email,
        'senha': senha,
        'nomeConfeitaria': nome,
        'cnpj': cnpj,
        'cep': cep,
        'logradouro': logradouro,
        'numero': numero,
        'complemento': complemento,
        'bairro': bairro,
        'cidade': cidade,
        'uf': uf,
        'latitude': latitude,
        'longitude': longitude,
        'horaAbertura': horaAbertura,
        'horaFechamento': horaFechamento,
      });



      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro no cadastro');
      } else {
        throw Exception('Falha na comunicação com o servidor: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erro de conexão: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Erro no formato da resposta: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido: ${e.toString()}');
    }
  }

  // Obter dados da confeitaria por ID do usuário
    static Future<ConfeitariaModel> getConfeitaria(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_confeitaria.php?userId=$userId'),
    );

    if (response.statusCode == 200) {
      return ConfeitariaModel.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar dados da confeitaria');
    }
  }

    static Future<Map<String, dynamic>> getDashboardData({
    required String period,
    required DateTime date,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard.php?period=$period&date=$formattedDate'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar dados da dashboard');
    }
  }

  // Método para verificar se o usuário está autenticado
    static Future<bool> isAuthenticated(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/check_auth.php'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

    Future<List<ProductType>> getProductTypes(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_product_types.php?id_usuario=$userId'),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      List list = data['data'];
      return list.map((e) => ProductType.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Erro ao buscar tipos de produto');
    }
}

    Future<void> addProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_product.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(productData),
    );

    if (response.statusCode != 200 || response.body != 'success') {
      throw Exception('Erro ao cadastrar produto: ${response.body}');
    }
  }
}
