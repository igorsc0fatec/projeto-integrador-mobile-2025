import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delicias_online/services/api_formato.dart';
import 'package:delicias_online/models/FormatoModel.dart';
import 'package:delicias_online/models/session.dart';
import 'package:delicias_online/views/Formato/EditarFormatoPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delicias_online/views/login_page.dart';
import 'package:delicias_online/views/HomePage.dart';
import 'package:delicias_online/views/AddPage.dart';
import 'package:delicias_online/views/UnderConstructionPage.dart';

class AddFormatoPage extends StatefulWidget {
  const AddFormatoPage({Key? key}) : super(key: key);

  @override
  State<AddFormatoPage> createState() => _AddFormatoPageState();
}

class _AddFormatoPageState extends State<AddFormatoPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  bool _isLoading = false;
  List<FormatoModel> _formatos = [];
  bool _loadingList = true;
  int _selectedIndex = 1; // Índice 1 para a página "Adicionar"

  // Páginas correspondentes a cada item do menu
  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const AddPage(),
    const SettingsPage(),
    Container(), // Placeholder para o botão de sair
  ];

  @override
  void initState() {
    super.initState();
    _carregarFormatos();
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
      // Navegar para outra página apenas se não for a mesma
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

  Future<void> _carregarFormatos() async {
    setState(() => _loadingList = true);
    try {
      final session = Session();
      final confeitariaId = session.confeitariaCodigo;

      if (confeitariaId != null) {
        final formatos = await FormatoService.getFormatosPorConfeitaria(int.parse(confeitariaId));
        setState(() => _formatos = formatos);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar formatos: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _loadingList = false);
    }
  }

  Future<void> _salvarFormato() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;

        final response = await FormatoService.cadastrarFormato(
          descricao: _descricaoController.text,
          valorPorGrama: valor,
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Formato cadastrado com sucesso!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _descricaoController.clear();
          _valorController.clear();
          await _carregarFormatos();
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

  Future<void> _excluirFormato(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://26.145.22.183/api/Formato/excluir_formato.php?id=$id'),
        headers: {'Accept': 'application/json'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _carregarFormatos();
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

  void _navegarParaEdicao(FormatoModel formato) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarFormatoPage(
          formato: formato,
          onFormatoAtualizado: _carregarFormatos,
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
        title: const Text('Gerenciar Formatos'),
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
                          'Adicionar Novo Formato',
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
                            labelText: 'Valor por grama (R\$)',
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
                                onPressed: _salvarFormato,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Salvar Formato'),
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
                'Formatos Cadastrados',
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
                : _formatos.isEmpty
                    ? SliverToBoxAdapter(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Nenhum formato cadastrado',
                              style: textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final formato = _formatos[index];
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
                                            formato.descricao,
                                            style: textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'R\$ ${formato.valorFormatado}',
                                            style: textTheme.bodyLarge?.copyWith(
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                          if (formato.id != null)
                                            Text(
                                              'ID: ${formato.id}',
                                              style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.outline,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: colorScheme.primary),
                                      onPressed: () => _navegarParaEdicao(formato),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: colorScheme.error),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmar Exclusão'),
                                            content: Text('Excluir "${formato.descricao}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await _excluirFormato(formato.id!);
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
                          childCount: _formatos.length,
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Página Configurações (copiada do arquivo original)
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