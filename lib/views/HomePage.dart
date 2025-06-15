import 'package:flutter/material.dart';
import 'package:delicias_online/views/login_page.dart';
import 'package:delicias_online/views/AddPage.dart';
import 'package:delicias_online/views/UnderConstructionPage.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTimeRange? _selectedDateRange;
  String _selectedFilter = 'dia'; // 'dia', 'mês' ou 'ano'
  int _selectedIndex = 0;

  // Dados fictícios para exemplo
  final List<Map<String, dynamic>> _topProducts = [
    {'name': 'Bolo de Chocolate', 'sales': 42, 'price': 45.00},
    {'name': 'Cupcake de Morango', 'sales': 38, 'price': 8.00},
    {'name': 'Torta de Limão', 'sales': 25, 'price': 35.00},
    {'name': 'Brigadeiro Gourmet', 'sales': 120, 'price': 2.50},
    {'name': 'Pão de Mel', 'sales': 30, 'price': 12.00},
  ];

  final List<Map<String, dynamic>> _recentRequests = [
    {'client': 'Maria Silva', 'date': '2023-05-15', 'total': 120.50, 'status': 'Entregue'},
    {'client': 'João Santos', 'date': '2023-05-14', 'total': 85.00, 'status': 'Preparando'},
    {'client': 'Ana Oliveira', 'date': '2023-05-14', 'total': 45.00, 'status': 'Entregue'},
    {'client': 'Carlos Mendes', 'date': '2023-05-13', 'total': 210.00, 'status': 'Cancelado'},
    {'client': 'Fernanda Costa', 'date': '2023-05-12', 'total': 62.00, 'status': 'Entregue'},
  ];

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
      // Botão de sair pressionado
      _logout();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      
      // Navegar para outras páginas
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPage()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UnderConstructionPage()),
        );
      }
    }
  }

  Future<void> _logout() async {
    // Navegar de volta para a tela de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSales = _topProducts.fold(0.0, (sum, item) => sum + (item['sales'] * item['price']));
    final avgTicket = totalSales / _recentRequests.length;

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
            Row(
              children: [
                _buildSummaryCard('Total Vendas', 'R\$${totalSales.toStringAsFixed(2)}', Icons.attach_money),
                const SizedBox(width: 10),
                _buildSummaryCard('Pedidos', _recentRequests.length.toString(), Icons.shopping_bag),
                const SizedBox(width: 10),
                _buildSummaryCard('Ticket Médio', 'R\$${avgTicket.toStringAsFixed(2)}', Icons.bar_chart),
              ],
            ),

            const SizedBox(height: 20),

            // Produtos mais vendidos
            const Text(
              'Produtos Mais Vendidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: _topProducts.map((product) {
                    return ListTile(
                      leading: const Icon(Icons.cake, color: Colors.pink),
                      title: Text(product['name']),
                      subtitle: Text('${product['sales']} vendas'),
                      trailing: Text('R\$${product['price'].toStringAsFixed(2)}'),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Últimas solicitações
            const Text(
              'Últimas Solicitações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: _recentRequests.map((request) {
                    return ListTile(
                      leading: const Icon(Icons.shopping_cart, color: Colors.blue),
                      title: Text(request['client']),
                      subtitle: Text('${request['date']} - R\$${request['total'].toStringAsFixed(2)}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(request['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          request['status'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
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
      case 'entregue':
        return Colors.green;
      case 'preparando':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Extensão para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}