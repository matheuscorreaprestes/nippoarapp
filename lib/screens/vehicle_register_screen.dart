import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nippoarapp/models/vehicle_model.dart';
import 'package:nippoarapp/models/user_model.dart';

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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Erro ao carregar veículos"));
                  }

                  List<Widget> vehicleCards = [];

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    vehicleCards.add(
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "${userModel.userData['name'] ?? 'Usuário'}, você ainda não tem veículo cadastrado, cadastre um para agendar um horário",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    vehicleCards = snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> vehicleData = doc.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${vehicleData['marca']} ${vehicleData['modelo']}"),
                              PopupMenuButton<String>(
                                onSelected: (String value) {
                                  if (value == 'edit') {
                                    _showVehicleEditForm(context, vehicleModel, doc.id, vehicleData);
                                  } else if (value == 'delete') {
                                    _deleteVehicle(context, vehicleModel, doc.id);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return {'Editar', 'Deletar'}.map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice == 'Editar' ? 'edit' : 'delete',
                                      child: Text(choice),
                                    );
                                  }).toList();
                                },
                              ),
                            ],
                          ),
                          subtitle: Text("Cor: ${vehicleData['cor']}\nPlaca: ${vehicleData['placa']}"),
                        ),
                      );
                    }).toList();
                  }

                  return Stack(
                    children: [
                      ListView(
                        padding: EdgeInsets.all(16.0),
                        children: vehicleCards,
                      ),
                      Positioned(
                        bottom: 16.0,
                        left: 16.0,
                        right: 16.0,
                        child: ElevatedButton(
                          child: Text(
                            "Cadastrar Veículo",
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
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
              TextFormField(
                controller: _marcaController,
                decoration: InputDecoration(
                  hintText: "Marca",
                ),
                validator: (text) {
                  if (text!.isEmpty) return "Campo Vazio";
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(
                  hintText: "Modelo",
                ),
                validator: (text) {
                  if (text!.isEmpty) return "Campo Vazio";
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _corController,
                decoration: InputDecoration(
                  hintText: "Cor do Veículo",
                ),
                validator: (text) {
                  if (text!.isEmpty) return "Campo Vazio";
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _placaController,
                decoration: InputDecoration(
                  hintText: "Placa do Veículo",
                ),
                validator: (text) {
                  if (text!.isEmpty) return "Campo Vazio";
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: Text(
                  "Cadastrar Veículo",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Map<String, dynamic> vehicleData = {
                      "marca": _marcaController.text,
                      "modelo": _modeloController.text,
                      "cor": _corController.text,
                      "placa": _placaController.text,
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

  void _showVehicleEditForm(BuildContext context, VehicleModel model, String vehicleId, Map<String, dynamic> vehicleData) {
    _marcaController.text = vehicleData['marca'];
    _modeloController.text = vehicleData['modelo'];
    _corController.text = vehicleData['cor'];
    _placaController.text = vehicleData['placa'];

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
              TextFormField(
                controller: _marcaController,
                decoration: InputDecoration(
                  hintText: "Marca",
                ),
                validator: (text) {
                  if (text!.isEmpty) return "Campo Vazio";
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(
                  hintText: "Modelo",
                ),
                validator: (text) {
                  if (text!.isEmpty) return "Campo Vazio";
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _corController,
                decoration: InputDecoration(
                  hintText: "Cor do Veículo",
                ),
                validator: (text) {
                  if (text!.isEmpty) return "Campo Vazio";
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _placaController,
                decoration: InputDecoration(
                  hintText: "Placa do Veículo",
                ),
                validator: (text) {
                  if (text!.isEmpty) return "Campo Vazio";
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: Text(
                  "Atualizar Veículo",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Map<String, dynamic> updatedVehicleData = {
                      "marca": _marcaController.text,
                      "modelo": _modeloController.text,
                      "cor": _corController.text,
                      "placa": _placaController.text,
                    };

                    model.updateVehicle(
                      vehicleId: vehicleId,
                      vehicleData: updatedVehicleData,
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

  void _deleteVehicle(BuildContext context, VehicleModel model, String vehicleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Deletar Veículo"),
        content: Text("Você tem certeza que deseja deletar este veículo?"),
        actions: <Widget>[
          TextButton(
            child: Text("Cancelar"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Deletar"),
            onPressed: () {
              model.deleteVehicle(
                vehicleId: vehicleId,
                onSuccess: () {
                  Navigator.of(context).pop();
                  _onSuccess();
                },
                onFail: _onFail,
              );
            },
          ),
        ],
      ),
    );
  }

  void _onSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Operação realizada com sucesso!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onFail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Falha ao realizar operação. Tente novamente.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }
}
