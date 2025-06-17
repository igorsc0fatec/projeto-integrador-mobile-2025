import 'package:flutter/material.dart';
import 'package:delicias_online/views/login_page.dart';
import 'package:delicias_online/views/AddPage.dart';
import 'package:delicias_online/views/Confeitaria/AddPageConfeitaria.dart';
import 'package:delicias_online/models/session.dart';
import 'package:delicias_online/services/api_pedido.dart';
import 'package:delicias_online/models/PedidoModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTimeRange? _selectedDateRange;
  String _selectedFilter = 'dia'; // 'dia', 'mês' ou 'ano'
  int _selectedIndex = 0;
  late Future<List<PedidoModel>> _pedidosFuture;
  // ignore: unused_field
  late Future<Map<String, List<PedidoModel>>> _pedidosPorPeriodoFuture;
  late Future<Map<String, Map<String, dynamic>>> _produtosMaisVendidosFuture;


    @override
    void initState() {
      super.initState();
      final session = Session();
      if (session.idConfeitaria != null) {
        _loadData(session.idConfeitaria!);
      } else {
        // Se não houver idConfeitaria, force o logout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _logout();
        });
      }
    }

  

  void _loadData(int idConfeitaria) {
    setState(() {
      _pedidosFuture = PedidoService.getPedidosPorConfeitaria(idConfeitaria);
      _pedidosPorPeriodoFuture = PedidoService.getPedidosPorPeriodo(idConfeitaria);
      _produtosMaisVendidosFuture = PedidoService.getProdutosMaisVendidos(idConfeitaria);
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      _logout();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPage()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPageConfeitaria()),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final session = Session();
    if (session.idConfeitaria == null) {
      return const Scaffold(
        body: Center(child: Text('Nenhuma confeitaria selecionada')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delícias Online'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho e filtros
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedFilter,
                      items: ['dia', 'mês', 'ano'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.capitalize()),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFilter = newValue!;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDateRange(context),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Cards de resumo
            FutureBuilder<List<PedidoModel>>(
                future: _pedidosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Nenhum pedido encontrado');
                  }

                  final pedidos = snapshot.data!;
                  final totalSales = pedidos.fold(0.0, (sum, pedido) => 
                    pedido.status.toLowerCase() == 'entregue!' ? sum + pedido.valorTotal : sum
                  );
                  
                  final avgTicket = pedidos.isNotEmpty ? totalSales / pedidos.length : 0.0;

                  return Row(
                    children: [
                      _buildSummaryCard('Total Vendas', 'R\$${totalSales.toStringAsFixed(2)}', Icons.attach_money),
                      const SizedBox(width: 10),
                      _buildSummaryCard('Total de Pedidos', pedidos.length.toString(), Icons.shopping_bag),
                      const SizedBox(width: 10),
                      _buildSummaryCard('Ticket Médio', 'R\$${avgTicket.toStringAsFixed(2)}', Icons.bar_chart),
                    ],
                  );
                },
              ),

            const SizedBox(height: 20),

            // Produtos mais vendidos
            const Text(
              'Produtos Mais Vendidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<Map<String, Map<String, dynamic>>>(
              future: _produtosMaisVendidosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum produto vendido');
                }

                final produtos = snapshot.data!;
                final topProducts = produtos.entries.toList();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: topProducts.map((product) {
                        final info = product.value;
                        return ListTile(
                          leading: const Icon(Icons.cake, color: Colors.pink),
                          title: Text(product.key),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${info['quantidade']} vendas'),
                              Text('Total: R\$${info['valorTotal'].toStringAsFixed(2)}'),
                            ],
                          ),
                          trailing: Text(
                            'R\$${info['precoUnitario'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Últimas solicitações
            const Text(
              'Últimas Solicitações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<PedidoModel>>(
              future: _pedidosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum pedido encontrado');
                }

                final pedidos = snapshot.data!
                  ..sort((a, b) => b.dataPedido.compareTo(a.dataPedido));
                final recentRequests = pedidos.take(5).toList();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: recentRequests.map((pedido) {
                        return ListTile(
                          leading: const Icon(Icons.shopping_cart, color: Colors.blue),
                          title: Text(pedido.cliente.nome),
                          subtitle: Text('${pedido.dataPedido.toLocal().toString().split(' ')[0]} - ${pedido.valorTotalFormatado}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(pedido.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              pedido.status,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'Entregue!':
        return Colors.green;
      case 'preparando':
        return Colors.orange;
      case 'Cancelado':
        return Colors.red;
      case 'Cancelado pelo Cliente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}