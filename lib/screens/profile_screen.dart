import 'package:flutter/material.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/screens/login_screen.dart';
import 'package:scoped_model/scoped_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load user data into controllers if UserModel has current user data
    ScopedModel.of<UserModel>(context, rebuildOnChange: false).loadUserData();
    UserModel userModel = ScopedModel.of<UserModel>(context, rebuildOnChange: false);
    _nameController.text = userModel.userData['name'] ?? '';
    _phoneController.text = userModel.userData['celular'] ?? '';
    _birthController.text = userModel.userData['data de nascimento'] ?? '';
    _emailController.text = userModel.userData['email'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Perfil"),
        centerTitle: true,
      ),
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          if (model.isLoading) return Center(child: CircularProgressIndicator());

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: "Nome"),
                  validator: (text) {
                    if (text!.isEmpty) return "Campo Vazio";
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(hintText: "Celular"),
                  keyboardType: TextInputType.phone,
                  validator: (text) {
                    if (text!.isEmpty) return "Campo Vazio";
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _birthController,
                  decoration: InputDecoration(hintText: "Data de nascimento"),
                  keyboardType: TextInputType.datetime,
                  validator: (text) {
                    if (text!.isEmpty) return "Campo Vazio";
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: "E-mail"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (text) {
                    if (text!.isEmpty || !text.contains("@")) return "E-mail inválido";
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passController,
                  decoration: InputDecoration(hintText: "Senha"),
                  obscureText: true,
                  validator: (text) {
                    if (text!.isNotEmpty && text.length < 6) return "Senha inválida";
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text(
                    "Atualizar Perfil",
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Map<String, dynamic> userData = {
                        "name": _nameController.text,
                        "celular": _phoneController.text,
                        "data de nascimento": _birthController.text,
                        "email": _emailController.text,
                      };

                      model.updateUser(
                        userData: userData,
                        pass: _passController.text.isNotEmpty ? _passController.text : null,
                        onSuccess: _onSuccess,
                        onFail: _onFail,
                      );
                    }
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text(
                    "Deletar perfil",
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Deletar perfil"),
                        content: Text("Você tem certeza que deseja deletar sua conta?"),
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
                              model.deleteUser(onSuccess: _onDeleteSuccess, onFail: _onFail);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Perfil atualizado com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onDeleteSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Perfil deletado com sucesso!"),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _onFail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Falha ao atualizar perfil ou deletar perfil."),
        backgroundColor: Colors.red,
      ),
    );
  }
}
