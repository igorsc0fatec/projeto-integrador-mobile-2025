import 'package:flutter/material.dart';
import 'package:delicias_online/models/product_type.dart';
import 'package:delicias_online/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delicias_online/models/confeitaria_provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _shippingController = TextEditingController();
  final TextEditingController _deliveryLimitController = TextEditingController();



  late SharedPreferences prefs;
  String? userId;
  List<ProductType> _productTypes = [];
  int? _selectedTypeId;
  String? _imagePath;
  bool _isLoading = false;
  bool _isLoadingTypes = false;
  int? idConfeitaria;


  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // Aqui você pode acessar o Provider com context
    final confeitariaProvider = Provider.of<ConfeitariaProvider>(context, listen: false);
    idConfeitaria = confeitariaProvider.idConfeitaria;

    prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });

    _loadProductTypes();
  }

  Future<void> _loadProductTypes() async {
      if (idConfeitaria != null) {
        print('ID da Confeitaria: $idConfeitaria');
        // Use o ID conforme necessário
      }

    setState(() => _isLoadingTypes = true);
    
    try {
      int userIdInt = int.parse(userId.toString());
      List<ProductType> types = await ApiService().getProductTypes(userIdInt);
      setState(() {
        _productTypes = types;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar tipos de produto: $e')),
      );
    } finally {
      setState(() => _isLoadingTypes = false);
    }
  }

  Future<void> _pickImage() async {
    // Implementação simplificada - você precisará adicionar o pacote image_picker
    // final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (pickedFile != null) {
    //   setState(() {
    //     _imagePath = pickedFile.path;
    //   });
    // }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de imagem será implementada')),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);
      
      try {
        Map<String, dynamic> productData = {
          'nome_produto': _nameController.text,
          'desc_produto': _descriptionController.text,
          'valor_produto': double.parse(_priceController.text),
          'frete': double.parse(_shippingController.text),
          'produto_ativo': true,
          'limite_entrega': int.parse(_deliveryLimitController.text),
          'img_produto': _imagePath ?? '',
          'id_tipo_produto': _selectedTypeId,
          'id_confeitaria': userId,
        };

        await ApiService().addProduct(productData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto cadastrado com sucesso!')),
        );
        
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar produto: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Produto'),
      ),
      body: _isLoadingTypes
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo para upload de imagem
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _imagePath == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40),
                                    Text('Adicionar Imagem'),
                                  ],
                                ),
                              )
                            : Image.network(_imagePath!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Nome do produto
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Produto',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do produto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Descrição do produto
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira uma descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Preço
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Preço (R\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o preço';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor, insira um valor válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Frete
                    TextFormField(
                      controller: _shippingController,
                      decoration: const InputDecoration(
                        labelText: 'Valor do Frete (R\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o valor do frete';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor, insira um valor válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Limite de entrega (dias)
                    TextFormField(
                      controller: _deliveryLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Limite de Entrega (dias)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o limite de entrega';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Por favor, insira um número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Tipo de produto (dropdown)
                    DropdownButtonFormField<int>(
                      value: _selectedTypeId,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Produto',
                        border: OutlineInputBorder(),
                      ),
                      items: _productTypes.map((type) {
                        return DropdownMenuItem<int>(
                          value: type.id,
                          child: Text(type.description),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTypeId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione um tipo de produto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Botão de cadastrar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Cadastrar Produto', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _shippingController.dispose();
    _deliveryLimitController.dispose();
    super.dispose();
  }
}