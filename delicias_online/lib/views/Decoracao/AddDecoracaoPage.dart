import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delicias_online/services/api_decoracao.dart';
import 'package:delicias_online/models/DecoracaoModel.dart';
import 'package:delicias_online/models/session.dart';
import 'package:delicias_online/views/Decoracao/EditarDecoracaoPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delicias_online/views/login_page.dart';
import 'package:delicias_online/views/HomePage.dart';
import 'package:delicias_online/views/AddPage.dart';
import 'package:delicias_online/views/Confeitaria/AddPageConfeitaria.dart';


class AddDecoracaoPage extends StatefulWidget {
  const AddDecoracaoPage({Key? key}) : super(key: key);

  @override
  State<AddDecoracaoPage> createState() => _AddDecoracaoPageState();
}

class _AddDecoracaoPageState extends State<AddDecoracaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  bool _isLoading = false;
  List<DecoracaoModel> _decoracoes = [];
  bool _loadingList = true;
  int _selectedIndex = 1; // Índice 1 para a página "Adicionar"

  @override
  void initState() {
    super.initState();
    _carregarDecoracoes();
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
        MaterialPageRoute(builder: (context) => const AddPageConfeitaria()),
      );
    }
    else if (index == 0) {
      // Configurações - navega para UnderConstructionPage como uma nova rota
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddPage()),
      );
    } else if (index != _selectedIndex) {
      // Navegar para outra página apenas se não for a mesma
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _getPageForIndex(index)),
      );
    }
  }

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const AddPage();
      case 2:
        return const AddPageConfeitaria();
      default:
        return Container();
    }
  }

  Future<void> _logout() async {
    Session().clear(); // Limpa os dados da sessão
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // Remove todas as rotas anteriores
    );
  }

  Future<void> _carregarDecoracoes() async {
    setState(() => _loadingList = true);
    try {
      final session = Session();
      final confeitariaId = session.confeitariaCodigo;

      if (confeitariaId != null) {
        final decoracoes = await DecoracaoService.getDecoracoesPorConfeitaria(int.parse(confeitariaId));
        setState(() => _decoracoes = decoracoes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar decorações: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _loadingList = false);
    }
  }

  Future<void> _salvarDecoracao() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;

      final response = await DecoracaoService.cadastrarDecoracao(
        descricao: _descricaoController.text,
        valorPorGrama: valor,
      );

      if (response['status'] == 'success') {
        // Mensagem de sucesso com Dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sucesso!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 20),
                const Text('Decoração cadastrada com sucesso!')
                  
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _descricaoController.clear();
                  _valorController.clear();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        await _carregarDecoracoes();
      } else {
        // Mensagem de erro detalhada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erro ao cadastrar decoração'),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _excluirDecoracao(int id) async {
  try {
    setState(() => _isLoading = true);

    // Confirmação antes de excluir
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta decoração?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final response = await http.delete(
      Uri.parse('http://11.111.11.111/api/Decoracao/excluir_decoracao.php?id=$id'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      await _carregarDecoracoes();
      
      // Mensagem de sucesso com ícone
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(data['message'] ?? 'Decoração excluída com sucesso!')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Fechar',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } else {
      // Mensagem de erro detalhada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(data['message'] ?? 'Erro ao excluir decoração')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Detalhes',
            textColor: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Erro Detalhado'),
                  content: Text(data['error_details'] ?? 'Nenhum detalhe adicional disponível'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
  } on TimeoutException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tempo de conexão esgotado. Tente novamente.'),
        backgroundColor: Colors.orange,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro inesperado: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    debugPrint('Erro completo: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}

  void _navegarParaEdicao(DecoracaoModel decoracao) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarDecoracaoPage(
          decoracao: decoracao,
          onDecoracaoAtualizada: _carregarDecoracoes,
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
        title: const Text('Gerenciar Decorações'),
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
                          'Adicionar Nova Decoração',
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
                                onPressed: _salvarDecoracao,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Salvar Decoração'),
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
                'Decorações Cadastradas',
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
                : _decoracoes.isEmpty
                    ? SliverToBoxAdapter(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Nenhuma decoração cadastrada',
                              style: textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final decoracao = _decoracoes[index];
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
                                            decoracao.descricao,
                                            style: textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'R\$ ${decoracao.valorFormatado}',
                                            style: textTheme.bodyLarge?.copyWith(
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                          if (decoracao.id != null)
                                            Text(
                                              'ID: ${decoracao.id}',
                                              style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.outline,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: colorScheme.primary),
                                      onPressed: () => _navegarParaEdicao(decoracao),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: colorScheme.error),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmar Exclusão'),
                                            content: Text('Excluir "${decoracao.descricao}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await _excluirDecoracao(decoracao.id!);
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
                          childCount: _decoracoes.length,
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
