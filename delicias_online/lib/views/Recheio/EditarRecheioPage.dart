import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delicias_online/models/RecheioModel.dart';
import 'package:delicias_online/services/api_recheio.dart';
import 'package:delicias_online/views/login_page.dart';
import 'package:delicias_online/views/HomePage.dart';
import 'package:delicias_online/views/AddPage.dart';
import 'package:delicias_online/views/Confeitaria/AddPageConfeitaria.dart';
import 'package:delicias_online/models/session.dart';

class EditarRecheioPage extends StatefulWidget {
  final RecheioModel recheio;
  final VoidCallback onRecheioAtualizado;

  const EditarRecheioPage({
    Key? key,
    required this.recheio,
    required this.onRecheioAtualizado,
  }) : super(key: key);

  @override
  State<EditarRecheioPage> createState() => _EditarRecheioPageState();
}

class _EditarRecheioPageState extends State<EditarRecheioPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  late TextEditingController _valorController;
  bool _isLoading = false;
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
    _descricaoController = TextEditingController(text: widget.recheio.descricao);
    _valorController = TextEditingController(
      text: widget.recheio.valorPorPeso.toStringAsFixed(2).replaceAll('.', ','),
    );
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
    }
    else if (index == 1) {
      // Configurações - navega para UnderConstructionPage como uma nova rota
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddPage()),
      );
    }
     else if (index != _selectedIndex) {
      // Navegar para outra página apenas se não for a mesma
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]),
      );
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

  Future<void> _atualizarRecheio() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Diálogo de confirmação
    final confirmarAtualizacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Atualização'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, color: Colors.blue, size: 50),
            const SizedBox(height: 20),
            const Text('Deseja atualizar os dados deste recheio?'),
            if (_isLoading) const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
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

    if (confirmarAtualizacao != true) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final valor = double.tryParse(
        _valorController.text.replaceAll(',', '.'),
      ) ?? 0.0;

      final response = await RecheioService.atualizarRecheio(
        id: widget.recheio.id!,
        descricao: _descricaoController.text,
        valorPorPeso: valor,
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
                const Text('Recheio atualizado com sucesso!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o dialog
                  widget.onRecheioAtualizado();
                  Navigator.pop(context); // Fecha a tela de edição
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Mensagem de erro detalhada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erro ao atualizar recheio'),
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

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Recheio'),
        elevation: 0,
        scrolledUnderElevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _atualizarRecheio,
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
                          'Editar Recheio',
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
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : FilledButton(
                                onPressed: _atualizarRecheio,
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