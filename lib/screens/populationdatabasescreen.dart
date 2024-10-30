import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PopulateDatabaseScreen extends StatefulWidget {
  @override
  _PopulateDatabaseScreenState createState() => _PopulateDatabaseScreenState();
}

class _PopulateDatabaseScreenState extends State<PopulateDatabaseScreen> {
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  String? _selectedCategoria;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Popular Banco de Dados"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo para a marca
              TextFormField(
                controller: _marcaController,
                decoration: InputDecoration(
                  labelText: "Marca",
                ),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return "Digite o nome da marca";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo para o modelo
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(
                  labelText: "Modelo",
                ),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return "Digite o nome do modelo";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Dropdown para selecionar a categoria
              DropdownButtonFormField<String>(
                value: _selectedCategoria,
                decoration: InputDecoration(
                  labelText: "Categoria",
                ),
                items: [
                  DropdownMenuItem(child: Text('Baixo (Hatch, Sedan)'), value: 'baixo'),
                  DropdownMenuItem(child: Text('Médio (SUV)'), value: 'medio'),
                  DropdownMenuItem(child: Text('Alto (Caminhonete)'), value: 'alto'),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoria = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione uma categoria';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Botão para enviar os dados
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveToDatabase();
                  }
                },
                child: Text("Salvar no Banco de Dados"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função para salvar os dados no Firestore
  void _saveToDatabase() {
    String marca = _marcaController.text;
    String modelo = _modeloController.text;
    String categoria = _selectedCategoria!;

    // Criar a marca no Firestore se ela não existir
    FirebaseFirestore.instance.collection('cars').doc(marca).set({});

    // Adicionar o modelo dentro da marca
    FirebaseFirestore.instance
        .collection('cars')
        .doc(marca)
        .collection('modelos')
        .doc(modelo)
        .set({
      'categoria': categoria,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Modelo adicionado com sucesso!')),
      );
      _clearFields();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar o modelo: $error')),
      );
    });
  }

  // Função para limpar os campos após salvar
  void _clearFields() {
    _marcaController.clear();
    _modeloController.clear();
    setState(() {
      _selectedCategoria = null;
    });
  }
}
