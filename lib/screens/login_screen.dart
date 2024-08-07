import 'package:flutter/material.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/screens/home_screen.dart';
import 'package:nippoarapp/screens/register_screen.dart';
import 'package:scoped_model/scoped_model.dart';


class LoginScreen extends StatelessWidget {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Nippoar",
          style: TextStyle(fontSize: 30.0),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          if (model.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(hintText: "E-mail"),
                            keyboardType: TextInputType.emailAddress,
                            validator: (text) {
                              if (text!.isEmpty || !text.contains("@"))
                                return "E-mail inválido";
                            },
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _passController,
                            decoration: InputDecoration(hintText: "Senha"),
                            obscureText: true,
                            validator: (text) {
                              if (text!.isEmpty || text.length < 6)
                                return "Senha inválida";
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                if (_emailController.text.isEmpty)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Insira seu e-mail para recuperação!"),
                                      backgroundColor: Colors.redAccent,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                else {
                                  model.recoverPass(_emailController.text);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Confira seu e-mail!"),
                                      backgroundColor:
                                      Theme.of(context).primaryColor,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                "Esqueci minha senha",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50), // Largura infinita e altura 50
                      ),
                      child: Text(
                        "Entrar",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          model.signIn(
                            email: _emailController.text,
                            pass: _passController.text,
                            onSuccess: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()),
                              );
                              // Navegar para a próxima tela ou mostrar uma mensagem de sucesso
                            },
                            onFail: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Falha ao entrar"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextButton(
                      child: Text(
                        "CRIAR CONTA",
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
