import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delicias_online/services/api_produto.dart';
import 'package:delicias_online/models/ProdutoModel.dart';
import 'package:delicias_online/models/session.dart';
import 'package:delicias_online/views/Produto/EditarProdutoPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delicias_online/views/login_page.dart';
import 'package:delicias_online/views/HomePage.dart';
import 'package:delicias_online/views/AddPage.dart';
import 'package:delicias_online/views/UnderConstructionPage.dart';

class AddProdutoPage extends StatefulWidget {
  const AddProdutoPage({Key? key}) : super(key: key);

  @override
  State<AddProdutoPage> createState() => _AddProdutoPageState();
}

class _AddProdutoPageState extends State<AddProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _freteController = TextEditingController();
  final _limiteEntregaController = TextEditingController();
  bool _isLoading = false;
  List<ProdutoModel> _produtos = [];
  bool _loadingList = true;
  int _selectedIndex = 1; // Índice 1 para a página "Adicionar"
  int? _selectedTipoProduto;
  List<Map<String, dynamic>> _tiposProduto = [];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    _carregarTiposProduto();
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
        MaterialPageRoute(builder: (context) => const UnderConstructionPage()),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index != _selectedIndex) {
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
      default:
        return Container();
    }
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _carregarTiposProduto() async {
    try {
      final session = Session();
      final confeitariaId = session.confeitariaCodigo;
      
      if (confeitariaId != null) {
        final response = await http.get(
          Uri.parse('http://26.145.22.183/api/TiposProduto/tipos_produto.php?id_confeitaria=$confeitariaId'),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              _tiposProduto = List<Map<String, dynamic>>.from(data['data']);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar tipos de produto: $e');
    }
  }

  Future<void> _carregarProdutos() async {
    setState(() => _loadingList = true);
    try {
      final session = Session();
      final confeitariaId = session.confeitariaCodigo;

      if (confeitariaId != null) {
        final produtos = await ProdutoService.getProdutosPorConfeitaria(int.parse(confeitariaId));
        setState(() => _produtos = produtos);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar produtos: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _loadingList = false);
    }
  }

  Future<void> _salvarProduto() async {
    if (_formKey.currentState!.validate() && _selectedTipoProduto != null) {
      setState(() => _isLoading = true);

      try {
        final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
        final frete = _freteController.text.isNotEmpty 
            ? double.tryParse(_freteController.text.replaceAll(',', '.')) 
            : null;
        final limiteEntrega = _limiteEntregaController.text.isNotEmpty
            ? int.tryParse(_limiteEntregaController.text)
            : null;

        final response = await ProdutoService.cadastrarProduto(
          nome: _nomeController.text,
          descricao: _descricaoController.text,
          valor: valor,
          frete: frete,
          idTipoProduto: _selectedTipoProduto!,
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto cadastrado com sucesso!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _nomeController.clear();
          _descricaoController.clear();
          _valorController.clear();
          _freteController.clear();
          _limiteEntregaController.clear();
          setState(() => _selectedTipoProduto = null);
          await _carregarProdutos();
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
    } else if (_selectedTipoProduto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um tipo de produto'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _excluirProduto(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://26.145.22.183/api/Produto/excluir_produto.php?id=$id'),
        headers: {'Accept': 'application/json'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _carregarProdutos();
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

  void _navegarParaEdicao(ProdutoModel produto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarProdutoPage(
          produto: produto,
          onProdutoAtualizado: _carregarProdutos,
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
        title: const Text('Gerenciar Produtos'),
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
                          'Adicionar Novo Produto',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome do Produto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceVariant,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o nome';
                            }
                            return null;
                          },
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
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe a descrição';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedTipoProduto,
                          decoration: InputDecoration(
                            labelText: 'Tipo de Produto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceVariant,
                          ),
                          items: _tiposProduto.map((tipo) {
                            return DropdownMenuItem<int>(
                              value: tipo['id_tipo_produto'],
                              child: Text(tipo['desc_tipo_produto']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTipoProduto = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Selecione um tipo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _valorController,
                          decoration: InputDecoration(
                            labelText: 'Valor (R\$)',
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _freteController,
                          decoration: InputDecoration(
                            labelText: 'Frete (R\$) - Opcional',
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
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _limiteEntregaController,
                          decoration: InputDecoration(
                            labelText: 'Limite de Entrega (dias) - Opcional',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceVariant,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : FilledButton(
                                onPressed: _salvarProduto,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Salvar Produto'),
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
                'Produtos Cadastrados',
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
                : _produtos.isEmpty
                    ? SliverToBoxAdapter(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Nenhum produto cadastrado',
                              style: textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final produto = _produtos[index];
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
                                            produto.nome,
                                            style: textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            produto.descricao,
                                            style: textTheme.bodyMedium,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Valor: ${produto.valorFormatado}',
                                            style: textTheme.bodyLarge?.copyWith(
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                          if (produto.frete != null)
                                            Text(
                                              'Frete: ${produto.freteFormatado}',
                                              style: textTheme.bodySmall,
                                            ),
                                          if (produto.id != null)
                                            Text(
                                              'ID: ${produto.id}',
                                              style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.outline,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: colorScheme.primary),
                                      onPressed: () => _navegarParaEdicao(produto),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: colorScheme.error),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmar Exclusão'),
                                            content: Text('Excluir "${produto.nome}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await _excluirProduto(produto.id!);
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
                          childCount: _produtos.length,
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