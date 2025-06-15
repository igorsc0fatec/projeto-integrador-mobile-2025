import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delicias_online/models/ProdutoModel.dart';
import 'package:delicias_online/services/api_produto.dart';
import 'package:delicias_online/views/login_page.dart';
import 'package:delicias_online/views/HomePage.dart';
import 'package:delicias_online/views/AddPage.dart';
import 'package:delicias_online/views/UnderConstructionPage.dart';
import 'package:http/http.dart' as http;
import 'package:delicias_online/models/session.dart';
import 'dart:convert';

class EditarProdutoPage extends StatefulWidget {
  final ProdutoModel produto;
  final VoidCallback onProdutoAtualizado;

  const EditarProdutoPage({
    Key? key,
    required this.produto,
    required this.onProdutoAtualizado,
  }) : super(key: key);

  @override
  State<EditarProdutoPage> createState() => _EditarProdutoPageState();
}

class _EditarProdutoPageState extends State<EditarProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _valorController;
  late TextEditingController _freteController;
  late TextEditingController _limiteEntregaController;
  bool _isLoading = false;
  int _selectedIndex = 1; // Índice 1 para a página "Adicionar"
  int? _selectedTipoProduto;
  List<Map<String, dynamic>> _tiposProduto = [];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.produto.nome);
    _descricaoController = TextEditingController(text: widget.produto.descricao);
    _valorController = TextEditingController(
      text: widget.produto.valor.toStringAsFixed(2).replaceAll('.', ','),
    );
    _freteController = TextEditingController(
      text: widget.produto.frete?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    _limiteEntregaController = TextEditingController(
      text: widget.produto.limiteEntrega?.toString() ?? '',
    );
    _selectedTipoProduto = widget.produto.idTipoProduto;
    _carregarTiposProduto();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    _freteController.dispose();
    _limiteEntregaController.dispose();
    super.dispose();
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

  Future<void> _atualizarProduto() async {
    if (_formKey.currentState!.validate() && _selectedTipoProduto != null) {
      setState(() => _isLoading = true);
      try {
        final valor = double.tryParse(
          _valorController.text.replaceAll(',', '.'),
        ) ?? 0.0;
        
        final frete = _freteController.text.isNotEmpty 
            ? double.tryParse(_freteController.text.replaceAll(',', '.')) 
            : null;
            
        final limiteEntrega = _limiteEntregaController.text.isNotEmpty
            ? int.tryParse(_limiteEntregaController.text)
            : null;

        final response = await ProdutoService.atualizarProduto(
          id: widget.produto.id!,
          nome: _nomeController.text,
          descricao: _descricaoController.text,
          valor: valor,
          frete: frete,
          ativo: true, // Mantém o produto ativo ao editar
          limiteEntrega: limiteEntrega,
          idTipoProduto: _selectedTipoProduto!,
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto atualizado com sucesso!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onProdutoAtualizado();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Erro ao atualizar'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Produto'),
        elevation: 0,
        scrolledUnderElevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _atualizarProduto,
          ),
        ],
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
                          'Editar Produto',
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
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+[,|.]?\d{0,2}')),
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
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+[,|.]?\d{0,2}')),
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
                                onPressed: _atualizarProduto,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Salvar Alterações'),
                              ),
                      ],
                    ),
                  ),
                ),
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