import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delicias_online/services/api_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ConfeitariaRegisterPage extends StatefulWidget {
  const ConfeitariaRegisterPage({Key? key}) : super(key: key);

  @override
  _ConfeitariaRegisterPageState createState() => _ConfeitariaRegisterPageState();
}

class _ConfeitariaRegisterPageState extends State<ConfeitariaRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _horaAberturaController = TextEditingController();
  final _horaFechamentoController = TextEditingController();
  
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Máscaras
  final cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  final cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Confeitaria'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader('Dados de Acesso'),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Dados da Confeitaria'),
                _buildNomeField(),
                const SizedBox(height: 16),
                _buildCnpjField(),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Endereço'),
                _buildCepField(),
                const SizedBox(height: 16),
                _buildLogradouroField(),
                const SizedBox(height: 16),
                _buildNumeroComplementoFields(),
                const SizedBox(height: 16),
                _buildBairroField(),
                const SizedBox(height: 16),
                _buildCidadeUfFields(),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Horário de Funcionamento'),
                _buildHorarioFields(),
                const SizedBox(height: 32),
                
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email*',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) => value!.isEmpty 
          ? 'Campo obrigatório' 
          : !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value) 
              ? 'Email inválido' 
              : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _senhaController,
      decoration: InputDecoration(
        labelText: 'Senha*',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: _obscurePassword,
      validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmarSenhaController,
      decoration: InputDecoration(
        labelText: 'Confirmar Senha*',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: _obscureConfirmPassword,
      validator: (value) => value != _senhaController.text ? 'Senhas não coincidem' : null,
    );
  }

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeController,
      decoration: InputDecoration(
        labelText: 'Nome da Confeitaria*',
        prefixIcon: const Icon(Icons.store_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildCnpjField() {
    return TextFormField(
      controller: _cnpjController,
      decoration: InputDecoration(
        labelText: 'CNPJ*',
        prefixIcon: const Icon(Icons.badge_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [cnpjFormatter],
      validator: (value) => cnpjFormatter.getUnmaskedText().length != 14 ? 'CNPJ inválido' : null,
    );
  }

  Widget _buildCepField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _cepController,
            decoration: InputDecoration(
              labelText: 'CEP*',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [cepFormatter],
            validator: (value) => cepFormatter.getUnmaskedText().length != 8 ? 'CEP inválido' : null,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).primaryColor,
          ),
          child: IconButton(
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.search, color: Colors.white),
            onPressed: _isLoading ? null : _buscarCep,
          ),
        ),
      ],
    );
  }

  Widget _buildLogradouroField() {
    return TextFormField(
      controller: _logradouroController,
      decoration: InputDecoration(
        labelText: 'Logradouro*',
        prefixIcon: const Icon(Icons.route),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
      enabled: false,
    );
  }

  Widget _buildNumeroComplementoFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _numeroController,
            decoration: InputDecoration(
              labelText: 'Número*',
              prefixIcon: const Icon(Icons.numbers_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: _complementoController,
            decoration: InputDecoration(
              labelText: 'Complemento',
              prefixIcon: const Icon(Icons.home_work_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBairroField() {
    return TextFormField(
      controller: _bairroController,
      decoration: InputDecoration(
        labelText: 'Bairro*',
        prefixIcon: const Icon(Icons.location_city_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
      enabled: false,
    );
  }

  Widget _buildCidadeUfFields() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: _cidadeController,
            decoration: InputDecoration(
              labelText: 'Cidade*',
              prefixIcon: const Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
            enabled: false,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: _ufController,
            decoration: InputDecoration(
              labelText: 'UF*',
              prefixIcon: const Icon(Icons.flag_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
            enabled: false,
          ),
        ),
      ],
    );
  }

  Widget _buildHorarioFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _horaAberturaController,
            decoration: InputDecoration(
              labelText: 'Abertura* (HH:MM)',
              prefixIcon: const Icon(Icons.access_time_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.datetime,
            validator: (value) => _validateTime(value) ? null : 'Formato inválido (HH:MM)',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _horaFechamentoController,
            decoration: InputDecoration(
              labelText: 'Fechamento* (HH:MM)',
              prefixIcon: const Icon(Icons.access_time_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.datetime,
            validator: (value) => _validateTime(value) ? null : 'Formato inválido (HH:MM)',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : const Text(
              'Cadastrar Confeitaria',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // 👈 isso resolve o problema
              ),
            ),
      ),
    );
  }
  Future<void> _buscarCep() async {
    final cep = cepFormatter.getUnmaskedText();

    if (cep.length != 8) {
      _showSnackBar('CEP inválido');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Primeiro busca o endereço no ViaCEP
      final viaCepResponse = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

      if (viaCepResponse.statusCode == 200) {
        final data = jsonDecode(viaCepResponse.body);

        if (data['erro'] == true) {
          _showSnackBar('CEP não encontrado');
        } else {
          setState(() {
            _logradouroController.text = data['logradouro'] ?? '';
            _bairroController.text = data['bairro'] ?? '';
            _cidadeController.text = data['localidade'] ?? '';
            _ufController.text = data['uf'] ?? '';
          });

          // Agora busca as coordenadas
          await _obterCoordenadasPorEndereco();
        }
      } else {
        _showSnackBar('Erro ao buscar CEP: ${viaCepResponse.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Erro ao buscar CEP: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _obterCoordenadasPorEndereco() async {
    try {
      final enderecoCompleto = '${_logradouroController.text}, ${_numeroController.text}, ${_bairroController.text}, ${_cidadeController.text}, ${_ufController.text}, Brasil';
      
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(enderecoCompleto)}&format=json')
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          setState(() {
            _latitude = double.parse(data[0]['lat']);
            _longitude = double.parse(data[0]['lon']);
          });
          _showSnackBar('Localização obtida com sucesso!');
        } else {
          _showSnackBar('Não foi possível obter a localização para este endereço');
        }
      } else {
        _showSnackBar('Erro ao buscar coordenadas: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Erro ao obter coordenadas: ${e.toString()}');
    }
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_senhaController.text != _confirmarSenhaController.text) {
      _showSnackBar('As senhas não coincidem');
      return;
    }

    if (_latitude == null || _longitude == null) {
      _showSnackBar('Por favor, busque o CEP para obter a localização');
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final response = await ApiService.registerConfeitaria(
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        nome: _nomeController.text.trim(),
        cnpj: _cnpjController.text,
        cep: _cepController.text,
        logradouro: _logradouroController.text.trim(),
        numero: _numeroController.text.trim(),
        complemento: _complementoController.text.trim(),
        bairro: _bairroController.text.trim(),
        cidade: _cidadeController.text.trim(),
        uf: _ufController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        horaAbertura: _horaAberturaController.text.trim(),
        horaFechamento: _horaFechamentoController.text.trim(),
      );

      if (response['status'] == 'success') {
        _showSnackBar('Confeitaria cadastrada com sucesso!');
        Navigator.pop(context);
      } else {
        _showSnackBar(response['message'] ?? 'Erro desconhecido');
      }
    } catch (e) {
      _showSnackBar('Erro ao conectar com o servidor: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  bool _validateTime(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _nomeController.dispose();
    _cnpjController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    _horaAberturaController.dispose();
    _horaFechamentoController.dispose();
    super.dispose();
  }
}