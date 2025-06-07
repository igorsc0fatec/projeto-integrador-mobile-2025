import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delicias_online/services/api_massa.dart';
import 'package:delicias_online/models/MassaModel.dart';
import 'package:delicias_online/models/session.dart';
import 'package:delicias_online/views/Massa/EditarMassaPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delicias_online/views/login_page.dart';
import 'package:delicias_online/views/HomePage.dart';
import 'package:delicias_online/views/AddPage.dart';
import 'package:delicias_online/views/UnderConstructionPage.dart';

class AddMassaPage extends StatefulWidget {
  const AddMassaPage({Key? key}) : super(key: key);

  @override
  State<AddMassaPage> createState() => _AddMassaPageState();
}

class _AddMassaPageState extends State<AddMassaPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  bool _isLoading = false;
  List<MassaModel> _massas = [];
  bool _loadingList = true;
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const AddPage(),
    const SettingsPage(),
    Container(), // Placeholder para o botão de sair
  ];

  @override
  void initState() {
    super.initState();
    _carregarMassas();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Atualiza o índice selecionado
    });

    if (index == 3) {
      // Botão de sair pressionado
      _logout();
    } else if (index == 2) {
      // Configurações - navega para UnderConstructionPage como uma nova rota
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UnderConstructionPage()),
      );
    }
    else if (index == 0) {
      // Configurações - navega para UnderConstructionPage como uma nova rota
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index != _selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]),
      );
    }
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _carregarMassas() async {
    setState(() => _loadingList = true);
    try {
      final session = Session();
      final confeitariaId = session.confeitariaCodigo;
      
      if (confeitariaId != null) {
        final massas = await MassaService.getMassasPorConfeitaria(int.parse(confeitariaId));
        setState(() => _massas = massas);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar massas: ${e.toString()}')),
      );
    } finally {
      setState(() => _loadingList = false);
    }
  }

  Future<void> _salvarMassa() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final valor = double.tryParse(
          _valorController.text.replaceAll(',', '.'),
        ) ?? 0.0;

        final response = await MassaService.cadastrarMassa(
          descricao: _descricaoController.text,
          valorPorPeso: valor,
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Massa cadastrada com sucesso!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _descricaoController.clear();
          _valorController.clear();
          await _carregarMassas();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _excluirMassa(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://26.145.22.183/api/Massas/excluir_massa.php?id=$id'),
        headers: {'Accept': 'application/json'},
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        await _carregarMassas();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${data['message']}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (data['error_details'] != null) {
          debugPrint('Detalhes do erro: ${data['error_details']}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na requisição: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      debugPrint('Erro completo: $e');
    }
  }

  void _navegarParaEdicao(MassaModel massa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarMassaPage(
          massa: massa,
          onMassaAtualizada: _carregarMassas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Massas'),
        elevation: 0,
        scrolledUnderElevation: 4,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Adicionar Nova Massa',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descricaoController,
                          decoration: InputDecoration(
                            labelText: 'Descrição',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceVariant,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe a descrição';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _valorController,
                          decoration: InputDecoration(
                            labelText: 'Valor por peso (R\$)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceVariant,
                            prefixText: 'R\$ ',
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o valor';
                            }
                            final parsed = double.tryParse(value.replaceAll(',', '.'));
                            if (parsed == null || parsed <= 0) {
                              return 'Valor inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : FilledButton(
                                onPressed: _salvarMassa,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Salvar Massa'),
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
                'Massas Cadastradas',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: _loadingList
                ? SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  )
                : _massas.isEmpty
                    ? SliverToBoxAdapter(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Nenhuma massa cadastrada',
                              style: textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final massa = _massas[index];
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
                                            massa.descricao,
                                            style: textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'R\$ ${massa.valorFormatado}',
                                            style: textTheme.bodyLarge?.copyWith(
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                          if (massa.id != null)
                                            Text(
                                              'ID: ${massa.id}',
                                              style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.outline,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: colorScheme.primary),
                                      onPressed: () => _navegarParaEdicao(massa),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: colorScheme.error),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmar Exclusão'),
                                            content: Text('Excluir "${massa.descricao}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await _excluirMassa(massa.id!);
                                                },
                                                child: Text(
                                                  'Excluir',
                                                  style: TextStyle(color: colorScheme.error),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: _massas.length,
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'Sair',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Configurações',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}