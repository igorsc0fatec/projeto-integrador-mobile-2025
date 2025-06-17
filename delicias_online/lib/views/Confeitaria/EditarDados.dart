import 'package:flutter/material.dart';
import 'package:delicias_online/models/ConfeitariaModel.dart';
import 'package:delicias_online/models/session.dart';
import 'package:delicias_online/services/api_confeitaria.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarDados extends StatefulWidget {
  const EditarDados({Key? key}) : super(key: key);

  @override
  _EditarDadosState createState() => _EditarDadosState();
}

class _EditarDadosState extends State<EditarDados> {
  final _formKey = GlobalKey<FormState>();
  late ConfeitariaModel _confeitaria;
  bool _isLoading = true;
  bool _cepLoading = false;
  bool _isSaving = false;

  // Controladores
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

  // Máscaras
  final _cnpjMask = MaskTextInputFormatter(mask: '##.###.###/####-##');
  final _cepMask = MaskTextInputFormatter(mask: '#####-###');
  final _horaMask = MaskTextInputFormatter(mask: '##:##');

  @override
  void initState() {
    super.initState();
    _carregarDadosConfeitaria();
  }

  Future<void> _carregarDadosConfeitaria() async {
    try {
      final session = Session();
      final confeitaria = await ConfeitariaService.getConfeitaria(
        int.parse(session.confeitariaCodigo!),
      );
      
      setState(() {
        _confeitaria = confeitaria;
        _nomeController.text = confeitaria.nome;
        _cnpjController.text = confeitaria.cnpj;
        _cepController.text = confeitaria.cep;
        _logradouroController.text = confeitaria.logradouro;
        _numeroController.text = confeitaria.numero;
        _complementoController.text = confeitaria.complemento ?? '';
        _bairroController.text = confeitaria.bairro;
        _cidadeController.text = confeitaria.cidade;
        _ufController.text = confeitaria.uf;
        _horaAberturaController.text = confeitaria.horaAbertura;
        _horaFechamentoController.text = confeitaria.horaFechamento;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar dados: $e');
    }
  }

  Future<void> _buscarCEP() async {
    if (_cepController.text.length != 9) {
      _showErrorSnackBar('Por favor, insira um CEP válido');
      return;
    }

    setState(() => _cepLoading = true);

    try {
      final cep = _cepController.text.replaceAll('-', '');
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('erro')) {
          throw Exception('CEP não encontrado');
        }

        final geoResponse = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=${data['logradouro']},${data['bairro']},${data['localidade']},${data['uf']}'),
        ).timeout(const Duration(seconds: 10));

        double? lat, lng;
        if (geoResponse.statusCode == 200) {
          final geoData = jsonDecode(geoResponse.body);
          if (geoData.isNotEmpty) {
            lat = double.tryParse(geoData[0]['lat']);
            lng = double.tryParse(geoData[0]['lon']);
          }
        }

        setState(() {
          _logradouroController.text = data['logradouro'] ?? '';
          _bairroController.text = data['bairro'] ?? '';
          _cidadeController.text = data['localidade'] ?? '';
          _ufController.text = data['uf'] ?? '';
          
          _confeitaria = _confeitaria.copyWith(
            logradouro: data['logradouro'] ?? '',
            bairro: data['bairro'] ?? '',
            cidade: data['localidade'] ?? '',
            uf: data['uf'] ?? '',
            latitude: lat?.toString() ?? '',
            longitude: lng?.toString() ?? '',
          );
        });
      } else {
        throw Exception('Falha ao buscar CEP');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao buscar CEP: ${e.toString()}');
    } finally {
      setState(() => _cepLoading = false);
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Alterações'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, color: Colors.blue, size: 50),
            const SizedBox(height: 20),
            const Text('Deseja salvar as alterações nos dados da confeitaria?'),
            if (_isSaving) const SizedBox(height: 20),
            if (_isSaving) const CircularProgressIndicator(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      setState(() => _isSaving = true);
      
      final confeitariaAtualizada = ConfeitariaModel(
        id: _confeitaria.id,
        nome: _nomeController.text,
        cnpj: _cnpjController.text,
        cep: _cepController.text,
        logradouro: _logradouroController.text,
        numero: _numeroController.text,
        complemento: _complementoController.text.isEmpty ? null : _complementoController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        uf: _ufController.text,
        horaAbertura: _horaAberturaController.text,
        horaFechamento: _horaFechamentoController.text,
        idUsuario: _confeitaria.idUsuario,
        latitude: _confeitaria.latitude,
        longitude: _confeitaria.longitude,
      );

      final resultado = await ConfeitariaService.atualizarConfeitaria(
        confeitaria: confeitariaAtualizada,
      );

      if (resultado['status'] == 'success') {
        await _showSuccessDialog('Dados atualizados com sucesso!');
        Navigator.pop(context);
      } else {
        _showErrorSnackBar(resultado['message'] ?? 'Erro ao atualizar dados');
      }
    } catch (e) {
      _showErrorSnackBar('Erro inesperado: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sucesso!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Fechar',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Dados da Confeitaria'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _salvarAlteracoes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Informações Básicas',
                                style: textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nomeController,
                                decoration: InputDecoration(
                                  labelText: 'Nome da Confeitaria*',
                                  prefixIcon: const Icon(Icons.store_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) =>
                                    value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cnpjController,
                                decoration: InputDecoration(
                                  labelText: 'CNPJ*',
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [_cnpjMask],
                                validator: (value) =>
                                    value?.length != 18 ? 'CNPJ inválido' : null,
                                enabled: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Endereço',
                                style: textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _cepController,
                                      decoration: InputDecoration(
                                        labelText: 'CEP*',
                                        prefixIcon: const Icon(Icons.location_on_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [_cepMask],
                                      validator: (value) =>
                                          value?.length != 9 ? 'CEP inválido' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: colorScheme.primary,
                                    ),
                                    child: IconButton(
                                      icon: _cepLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.search, color: Colors.white),
                                      onPressed: _cepLoading ? null : _buscarCEP,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _logradouroController,
                                decoration: InputDecoration(
                                  labelText: 'Logradouro*',
                                  prefixIcon: const Icon(Icons.alt_route),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                                enabled: false,
                              ),
                              const SizedBox(height: 16),
                              Row(
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
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) =>
                                          value?.isEmpty ?? true ? 'Campo obrigatório' : null,
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
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _bairroController,
                                decoration: InputDecoration(
                                  labelText: 'Bairro*',
                                  prefixIcon: const Icon(Icons.location_city_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                                enabled: false,
                              ),
                              const SizedBox(height: 16),
                              Row(
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
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                      ),
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
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                      ),
                                      enabled: false,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Horário de Funcionamento',
                                style: textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _horaAberturaController,
                                      decoration: InputDecoration(
                                        labelText: 'Abertura* (HH:MM)',
                                        prefixIcon: const Icon(Icons.access_time_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [_horaMask],
                                      validator: (value) =>
                                          value?.length != 5 ? 'Hora inválida' : null,
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
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [_horaMask],
                                      validator: (value) =>
                                          value?.length != 5 ? 'Hora inválida' : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _salvarAlteracoes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text(
                                  'SALVAR ALTERAÇÕES',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
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