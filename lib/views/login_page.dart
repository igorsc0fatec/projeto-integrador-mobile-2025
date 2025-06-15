import 'package:flutter/material.dart';
import 'package:delicias_online/services/api_service.dart';
import 'package:delicias_online/views/confeitaria_register_page.dart'; 
import 'package:delicias_online/views/HomePage.dart'; 
import 'package:delicias_online/models/session.dart';
import 'package:delicias_online/models/user.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
      if (_formKey.currentState!.validate()) {
        setState(() => _isLoading = true);
        
        try {
          final response = await ApiService.login(
            _emailController.text.trim(),
            _senhaController.text.trim(),
          );

          if (response['status'] == 'success') { // Mude de 'success' para 'status'
            final userData = response['user'];
            final user = User.fromJson(userData);
            
            // Se for confeitaria, armazena o ID
            if (user.tipoUsuario == 3 && user.idConfeitaria != null) {
              Session().confeitariaCodigo = user.idConfeitaria.toString();
            }

            // Navega para a tela principal
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'])),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao conectar com o servidor: ${e.toString()}')),
          );
        } finally {
          setState(() => _isLoading = false);
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Entrar'),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConfeitariaRegisterPage()),
                  );
                },
                child: const Text('Não tem uma conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}