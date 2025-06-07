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
      appBar: AppBar(title: const Text('Cadastro Completo de Confeitaria')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDadosAcessoSection(),
              _buildDadosConfeitariaSection(),
              _buildEnderecoSection(),
              _buildHorarioSection(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDadosAcessoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dados de Acesso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email*'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value!.isEmpty ? 'Campo obrigatório' : 
              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value) ? 'Email inválido' : null,
        ),
        TextFormField(
          controller: _senhaController,
          decoration: const InputDecoration(labelText: 'Senha*'),
          obscureText: true,
          validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
        ),
        TextFormField(
          controller: _confirmarSenhaController,
          decoration: const InputDecoration(labelText: 'Confirmar Senha*'),
          obscureText: true,
          validator: (value) => value != _senhaController.text ? 'Senhas não coincidem' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDadosConfeitariaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dados da Confeitaria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextFormField(
          controller: _nomeController,
          decoration: const InputDecoration(labelText: 'Nome da Confeitaria*'),
          validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
        ),
        TextFormField(
          controller: _cnpjController,
          decoration: const InputDecoration(labelText: 'CNPJ*'),
          keyboardType: TextInputType.number,
          inputFormatters: [cnpjFormatter],
          validator: (value) => cnpjFormatter.getUnmaskedText().length != 14 ? 'CNPJ inválido' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEnderecoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Endereço', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(labelText: 'CEP*'),
                keyboardType: TextInputType.number,
                inputFormatters: [cepFormatter],
                validator: (value) => cepFormatter.getUnmaskedText().length != 8 ? 'CEP inválido' : null,
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                icon: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Icon(Icons.search),
                onPressed: _isLoading ? null : _buscarCep,
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _logradouroController,
          decoration: const InputDecoration(labelText: 'Logradouro*'),
          validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(labelText: 'Número*'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _complementoController,
                decoration: const InputDecoration(labelText: 'Complemento'),
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _bairroController,
          decoration: const InputDecoration(labelText: 'Bairro*'),
          validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade*'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _ufController,
                decoration: const InputDecoration(labelText: 'UF*'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHorarioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Horário de Funcionamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _horaAberturaController,
                decoration: const InputDecoration(labelText: 'Abertura* (HH:MM)'),
                keyboardType: TextInputType.datetime,
                validator: (value) => _validateTime(value) ? null : 'Formato inválido (HH:MM)',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _horaFechamentoController,
                decoration: const InputDecoration(labelText: 'Fechamento* (HH:MM)'),
                keyboardType: TextInputType.datetime,
                validator: (value) => _validateTime(value) ? null : 'Formato inválido (HH:MM)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return _isSubmitting
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
            onPressed: _isSubmitting ? null : _register,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('CADASTRAR CONFEITARIA'),
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