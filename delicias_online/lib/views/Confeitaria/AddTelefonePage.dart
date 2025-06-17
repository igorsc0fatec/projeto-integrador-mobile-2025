import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:delicias_online/models/TelefoneModel.dart';
import 'package:delicias_online/models/DddModel.dart';
import 'package:delicias_online/models/TipoTelefoneModel.dart'; // Adicione esta linha
import 'package:delicias_online/services/api_confeitaria.dart';
import 'package:delicias_online/models/session.dart';
import 'package:delicias_online/views/Confeitaria/EditarTelefonePage.dart';
import 'package:delicias_online/views/login_page.dart';
import 'package:delicias_online/views/HomePage.dart';
import 'package:delicias_online/views/AddPage.dart';
import 'package:delicias_online/views/Confeitaria/AddPageConfeitaria.dart';

class AddTelefonePage extends StatefulWidget {
  const AddTelefonePage({Key? key}) : super(key: key);

  @override
  State<AddTelefonePage> createState() => _AddTelefonePageState();
}

class _AddTelefonePageState extends State<AddTelefonePage> {
  
  final _telefoneMask = MaskTextInputFormatter(mask: '#####-####', filter: {"#": RegExp(r'[0-9]')});
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _dddController = TextEditingController(); // Remova o valor padrão
  final _tipoTelefoneController = TextEditingController(text: '4'); 
  bool _isLoading = false;
  List<TelefoneModel> _telefones = [];
  bool _loadingList = true;
  int _selectedIndex = 0;
  List<DddModel> _ddds = []; // Lista para armazenar os DDDs
  int? _selectedDddId; // ID do DDD selecionado
  List<TipoTelefoneModel> _tiposTelefone = [];
  int? _selectedTipoTelefoneId;

  @override
  void initState() {
    super.initState();
    _carregarTelefones();
    _carregarDdds(); // Carrega os DDDs ao iniciar
    _carregarTiposTelefone();
  }

  Future<void> _carregarDdds() async {
    try {
      final ddds = await ConfeitariaService.getDdds();
      setState(() {
        _ddds = ddds;
        // Define o primeiro DDD como selecionado por padrão (opcional)
        if (_ddds.isNotEmpty) {
          _selectedDddId = _ddds.first.id;
          _dddController.text = _ddds.first.ddd;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar DDDs: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      debugPrint('Erro ao carregar DDDs: $e');
    }
  }

  

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) {
      _logout();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddPageConfeitaria()),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddPage()),
      );
    }
  }

  Future<void> _logout() async {
    Session().clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _carregarTelefones() async {
    setState(() => _loadingList = true);
    try {
      final session = Session();
      if (session.idUsuario == null) {
        throw Exception('ID do usuário não disponível na sessão');
      }

      final telefones = await ConfeitariaService.getTelefones(session.idUsuario!);
      setState(() => _telefones = telefones);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar telefones: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      debugPrint('Erro detalhado: $e');
    } finally {
      setState(() => _loadingList = false);
    }
  }

  Future<void> _carregarTiposTelefone() async {
    setState(() => _loadingList = true);
    
    try {
      final tipos = await ConfeitariaService.getTiposTelefone();
      
      if (tipos.isNotEmpty) {
        setState(() {
          _tiposTelefone = tipos;
          _selectedTipoTelefoneId = _tiposTelefone.first.id;
          _tipoTelefoneController.text = _selectedTipoTelefoneId.toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum tipo de telefone disponível'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar tipos de telefone: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      debugPrint('Erro detalhado ao carregar tipos de telefone: $e');
    } finally {
      setState(() => _loadingList = false);
    }
  }

  Future<void> _salvarTelefone() async {
    if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final novoTelefone = TelefoneModel(
      id: 0,
      numero: _numeroController.text,
      idDdd: _selectedDddId!, // ← Aqui usamos o ID selecionado diretamente
      idTipoTelefone: _selectedTipoTelefoneId!, // ← Mesmo para o tipo
      ufDdd: 'SP', // Será obtido do backend
      ddd: 'leu',
      tipoTelefone: 'Celular', // Será obtido do backend
    );

    final response = await ConfeitariaService.adicionarTelefone(
      idUsuario: Session().idUsuario ?? 0,
      telefone: novoTelefone,
    );

    if (response['status'] == 'success') {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sucesso!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 20),
                const Text('Telefone cadastrado com sucesso!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _numeroController.clear();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        await _carregarTelefones();
      } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Erro ao cadastrar telefone'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro inesperado: ${e.toString()}')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  Future<void> _excluirTelefone(int id) async {
    final confirmarExclusao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 50),
            SizedBox(height: 20),
            Text('Tem certeza que deseja excluir este telefone?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmarExclusao != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await ConfeitariaService.excluirTelefone(id);

      if (response['status'] == 'success') {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sucesso!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 20),
                Text(response['message'] ?? 'Telefone excluído com sucesso!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _carregarTelefones();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erro ao excluir telefone'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na requisição: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navegarParaEdicao(TelefoneModel telefone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarTelefonePage(
          telefone: telefone,
          onTelefoneAtualizado: _carregarTelefones,
        ),
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Telefones'),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
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
                          'Adicionar Novo Telefone',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedDddId,
                          decoration: InputDecoration(
                            labelText: 'DDD',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          items: _ddds.map((ddd) {
                            return DropdownMenuItem<int>(
                              value: ddd.id, // ← Este é o valor que será armazenado em _selectedDddId
                              child: Text('${ddd.ddd} (${ddd.uf})'),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            setState(() {
                              _selectedDddId = value; // ← Aqui só atualizamos o ID, não o texto
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
                        TextFormField(
                          controller: _numeroController,inputFormatters: [_telefoneMask],
                          decoration: InputDecoration(
                            labelText: 'Número',
                            border: OutlineInputBorder(),
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
                          disabledHint: _loadingList
                              ? const Text('Carregando tipos...')
                              : const Text('Nenhum tipo disponível'),
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : FilledButton(
                                onPressed: _salvarTelefone,
                                child: const Text('Salvar Telefone'),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Telefones Cadastrados',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: _loadingList
                ? SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _telefones.isEmpty
                    ? SliverToBoxAdapter(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Nenhum telefone cadastrado',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final telefone = _telefones[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ID: ${telefone.id} | (${telefone.ufDdd}) ${telefone.ddd} ${telefone.numeroFormatado}',
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          Text(
                                            telefone.tipoTelefone,
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: theme.primaryColor),
                                      onPressed: () => _navegarParaEdicao(telefone),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                      onPressed: () => _excluirTelefone(telefone.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: _telefones.length,
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Adicionar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Sair'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}