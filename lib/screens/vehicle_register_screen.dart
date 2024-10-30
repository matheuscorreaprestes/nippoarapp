import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nippoarapp/models/vehicle_model.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/widgets/vehicle_card.dart';

class VehicleRegisterScreen extends StatefulWidget {
  const VehicleRegisterScreen({super.key});

  @override
  State<VehicleRegisterScreen> createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends State<VehicleRegisterScreen> {
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _corController = TextEditingController();
  final _placaController = TextEditingController();
  final _outroModeloController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedMarca;
  String? _selectedModelo;
  bool _isOutroModelo = false; // Para controlar se "Outro" foi selecionado
  String? _selectedCategoria;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Veículos"),
        centerTitle: true,
      ),
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, userModel) {
          return ScopedModelDescendant<VehicleModel>(
            builder: (context, child, vehicleModel) {
              if (vehicleModel.isLoading) return Center(child: CircularProgressIndicator());

              return FutureBuilder<QuerySnapshot>(
                future: vehicleModel.getVehicles(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Gerando a lista de VehicleCard
                  List<Widget> vehicleCards = snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> vehicleData = doc.data() as Map<String, dynamic>;

                    return VehicleCard(
                      marca: vehicleData['marca'],
                      modelo: vehicleData['modelo'],
                      cor: vehicleData['cor'],
                      placa: vehicleData['placa'],
                      vehicleId: doc.id,
                    );
                  }).toList();

                  return Stack(
                    children: [
                      ListView(
                        padding: EdgeInsets.all(16.0),
                        children: vehicleCards, // Passando a lista de VehicleCard aqui
                      ),
                      Positioned(
                        bottom: 16.0,
                        left: 16.0,
                        right: 16.0,
                        child: ElevatedButton(
                          child: Text(
                            "Cadastrar Veículo",
                            style: TextStyle(fontSize: 18.0, color: Colors.black),
                          ),
                          onPressed: () {
                            _showVehicleRegistrationForm(context, vehicleModel);
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showVehicleRegistrationForm(BuildContext context, VehicleModel model) {
    _marcaController.clear();
    _modeloController.clear();
    _corController.clear();
    _placaController.clear();
    _outroModeloController.clear();
    _isOutroModelo = false; // Resetar estado
    _selectedCategoria = null; // Resetar categoria

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Campo Marca
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('cars').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  List<DropdownMenuItem<String>> marcas = snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc.id),
                    );
                  }).toList();

                  return DropdownButtonFormField<String>(
                    value: _selectedMarca,
                    items: marcas,
                    hint: Text('Selecione a Marca'),
                    onChanged: (marca) {
                      setState(() {
                        _selectedMarca = marca;
                        _selectedModelo = null; // Resetar o modelo
                        _isOutroModelo = false;
                        _selectedCategoria = null; // Resetar a categoria
                      });
                    },
                    validator: (value) => value == null ? 'Selecione uma marca' : null,
                  );
                },
              ),

              // Campo Modelo
              if (_selectedMarca != null)
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('cars')
                      .doc(_selectedMarca)
                      .collection('modelos')
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    List<DropdownMenuItem<String>> modelos = snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc.id),
                      );
                    }).toList();

                    // Adiciona opção "Outro"
                    modelos.add(
                      DropdownMenuItem<String>(
                        value: 'Outro',
                        child: Text('Outro'),
                      ),
                    );

                    return DropdownButtonFormField<String>(
                      value: _selectedModelo,
                      items: modelos,
                      hint: Text('Selecione o Modelo'),
                      onChanged: (modelo) {
                        setState(() {
                          _selectedModelo = modelo;
                          _isOutroModelo = modelo == 'Outro'; // Verificar se "Outro" foi selecionado
                          if (!_isOutroModelo) {
                            // Se não for "Outro", puxar a categoria do modelo selecionado
                            _fetchCategoryForSelectedModel();
                          } else {
                            _selectedCategoria = null; // Limpar categoria se "Outro" for selecionado
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Selecione um modelo' : null,
                    );
                  },
                ),

              // Campos adicionais se "Outro" for selecionado
              if (_isOutroModelo) ...[
                TextFormField(
                  controller: _outroModeloController,
                  decoration: InputDecoration(hintText: "Digite o Modelo"),
                  validator: (text) => text!.isEmpty ? "Campo Vazio" : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategoria,
                  items: [
                    DropdownMenuItem(child: Text('Hatch'), value: 'Hatch'),
                    DropdownMenuItem(child: Text('Sedan'), value: 'Sedan'),
                    DropdownMenuItem(child: Text('SUV'), value: 'SUV'),
                    DropdownMenuItem(child: Text('Caminhonete'), value: 'Caminhonete'),
                  ],
                  hint: Text('Selecione a Categoria'),
                  onChanged: (categoria) {
                    setState(() {
                      _selectedCategoria = categoria;
                    });
                  },
                  validator: (value) => value == null ? 'Selecione uma categoria' : null,
                ),
              ],

              // Demais campos (cor, placa)
              TextFormField(
                controller: _corController,
                decoration: InputDecoration(hintText: "Cor do Veículo"),
                validator: (text) => text!.isEmpty ? "Campo Vazio" : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _placaController,
                decoration: InputDecoration(hintText: "Placa do Veículo"),
                validator: (text) => text!.isEmpty ? "Campo Vazio" : null,
              ),

              SizedBox(height: 16.0),
              ElevatedButton(
                child: Text(
                  "Cadastrar Veículo",
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Monta o dado do veículo com ou sem o campo "Outro"
                    Map<String, dynamic> vehicleData = {
                      "marca": _selectedMarca,
                      "modelo": _isOutroModelo ? _outroModeloController.text : _selectedModelo,
                      "cor": _corController.text,
                      "placa": _placaController.text,
                      "categoria": _selectedCategoria, // Adicionar a categoria aqui
                    };

                    model.createVehicle(
                      vehicleData: vehicleData,
                      onSuccess: _onSuccess,
                      onFail: _onFail,
                    );

                    Navigator.pop(context);
                  }
                },
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  // Função para buscar a categoria ao selecionar um modelo
  void _fetchCategoryForSelectedModel() async {
    if (_selectedMarca != null && _selectedModelo != null) {
      DocumentSnapshot modelDoc = await FirebaseFirestore.instance
          .collection('cars')
          .doc(_selectedMarca)
          .collection('modelos')
          .doc(_selectedModelo)
          .get();

      setState(() {
        _selectedCategoria = modelDoc['categoria']; // Atualiza a categoria com o valor do banco de dados
      });
    }
  }

  void _onSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Veículo Cadastrado com Sucesso!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onFail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Falha ao Cadastrar Veículo"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
