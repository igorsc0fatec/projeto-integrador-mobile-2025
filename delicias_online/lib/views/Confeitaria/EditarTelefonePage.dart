import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:delicias_online/models/TelefoneModel.dart';
import 'package:delicias_online/models/DddModel.dart';
import 'package:delicias_online/models/TipoTelefoneModel.dart';
import 'package:delicias_online/services/api_confeitaria.dart';
import 'package:delicias_online/models/session.dart';
// ignore: unused_import
import 'package:delicias_online/views/Confeitaria/AddTelefonePage.dart';

class EditarTelefonePage extends StatefulWidget {
  final TelefoneModel telefone;
  final Function() onTelefoneAtualizado;

  const EditarTelefonePage({
    Key? key,
    required this.telefone,
    required this.onTelefoneAtualizado,
  }) : super(key: key);

  @override
  State<EditarTelefonePage> createState() => _EditarTelefonePageState();
}

class _EditarTelefonePageState extends State<EditarTelefonePage> {
  
  final _telefoneMask = MaskTextInputFormatter(mask: '#####-####', filter: {"#": RegExp(r'[0-9]')});  
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _dddController = TextEditingController();
  final _tipoTelefoneController = TextEditingController();
  
  bool _isLoading = false;
  List<DddModel> _ddds = [];
  List<TipoTelefoneModel> _tiposTelefone = [];
  
  int? _selectedDddId;
  int? _selectedTipoTelefoneId;

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
    _carregarDdds();
    _carregarTiposTelefone();
  }

  void _carregarDadosIniciais() {
    _numeroController.text = widget.telefone.numero;
    _dddController.text = widget.telefone.idDdd.toString();
    _tipoTelefoneController.text = widget.telefone.idTipoTelefone.toString();
    
    _selectedDddId = widget.telefone.idDdd;
    _selectedTipoTelefoneId = widget.telefone.idTipoTelefone;
  }

  Future<void> _carregarDdds() async {
    try {
      final ddds = await ConfeitariaService.getDdds();
      setState(() {
        _ddds = ddds;
        // Mantém o DDD selecionado atual se ainda não tiver sido definido
        _selectedDddId ??= widget.telefone.idDdd;
      });
    } catch (e) {
      _mostrarErro('Erro ao carregar DDDs: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _carregarTiposTelefone() async {
    try {
      final tipos = await ConfeitariaService.getTiposTelefone();
      setState(() {
        _tiposTelefone = tipos;
        // Mantém o tipo selecionado atual se ainda não tiver sido definido
        _selectedTipoTelefoneId ??= widget.telefone.idTipoTelefone;
      });
    } catch (e) {
      _mostrarErro('Erro ao carregar tipos de telefone: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _atualizarTelefone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final telefoneAtualizado = TelefoneModel(
        id: widget.telefone.id,
        numero: _numeroController.text,
        idDdd: _selectedDddId!,
        ddd:'leu',
        idTipoTelefone: _selectedTipoTelefoneId!,
        ufDdd: widget.telefone.ufDdd, // Mantém o original (será atualizado pelo backend)
        tipoTelefone: widget.telefone.tipoTelefone, // Mantém o original
      );

      final response = await ConfeitariaService.editarTelefone(
        idTelefone: widget.telefone.id,
        telefone: telefoneAtualizado,
        idUsuario: Session().idUsuario ?? 0,
      );

      if (response['status'] == 'success') {
        await _mostrarSucesso('Telefone atualizado com sucesso!');
        widget.onTelefoneAtualizado();
        Navigator.pop(context);
      } else {
        _mostrarErro(response['message'] ?? 'Erro ao atualizar telefone');
      }
    } catch (e) {
      _mostrarErro('Erro inesperado: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _mostrarSucesso(String mensagem) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sucesso!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 20),
            Text(mensagem),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Telefone'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Editar Telefone',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown DDD
                  DropdownButtonFormField<int>(
                    value: _selectedDddId,
                    decoration: InputDecoration(
                      labelText: 'DDD',
                      border: const OutlineInputBorder(),
                      filled: true,
                    ),
                    items: _ddds.map((ddd) {
                      return DropdownMenuItem<int>(
                        value: ddd.id,
                        child: Text('${ddd.ddd} (${ddd.uf})'),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        _selectedDddId = value;
                        if (value != null) {
                          final selectedDdd = _ddds.firstWhere((ddd) => ddd.id == value);
                          _dddController.text = selectedDdd.ddd;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione um DDD';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo Número
                  TextFormField(
                    controller: _numeroController,inputFormatters: [_telefoneMask],
                    decoration: InputDecoration(
                      labelText: 'Número',
                      border: const OutlineInputBorder(),
                      filled: true,
                    ),
                    keyboardType: TextInputType.phone,
                    
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o número';
                      }
                      if (value.length < 8) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown Tipo de Telefone
                  DropdownButtonFormField<int>(
                    value: _selectedTipoTelefoneId,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Telefone',
                      border: const OutlineInputBorder(),
                      filled: true,
                    ),
                    items: _tiposTelefone.map((tipo) {
                      return DropdownMenuItem<int>(
                        value: tipo.id,
                        child: Text(tipo.tipo),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        _selectedTipoTelefoneId = value;
                        if (value != null) {
                          _tipoTelefoneController.text = value.toString();
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione o tipo de telefone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Botão Salvar
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton(
                          onPressed: _atualizarTelefone,
                          child: const Text('Salvar Alterações'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _dddController.dispose();
    _tipoTelefoneController.dispose();
    super.dispose();
  }
}