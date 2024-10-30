import 'package:flutter/material.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/screens/home_screen.dart';
import 'package:nippoarapp/screens/register_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // Função para obter e salvar o token FCM no Firestore
  Future<void> obterETestarToken(String userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Obtenha o token atual do dispositivo
    String? token = await messaging.getToken();

    if (token != null) {
      // Exiba o token no console para testes
      print('Token de notificação: $token');

      // Salve o token no Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'token': token,
      });
    } else {
      print('Falha ao obter o token.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (context, child, model) {
        // Verifica se o usuário está logado e redireciona para a HomeScreen
        if (model.isLoggedIn()) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Nippoar",
              style: TextStyle(fontSize: 30.0),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: model.isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
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
                            decoration:
                            InputDecoration(hintText: "E-mail"),
                            keyboardType: TextInputType.emailAddress,
                            validator: (text) {
                              if (text!.isEmpty ||
                                  !text.contains("@"))
                                return "E-mail inválido";
                            },
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _passController,
                            decoration:
                            InputDecoration(hintText: "Senha"),
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
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Insira seu e-mail para recuperação!"),
                                      backgroundColor: Colors.redAccent,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                else {
                                  model.recoverPass(
                                      _emailController.text);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                      Text("Confira seu e-mail!"),
                                      backgroundColor:
                                      Theme.of(context)
                                          .primaryColor,
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
                        minimumSize: Size(200, 50), // Largura e altura
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
                            onSuccess: () async {
                              // Obtém o userId do modelo
                              final userId = model.firebaseUser!.uid;

                              // Obter e salvar o token FCM
                              await obterETestarToken(userId);

                              // Navegar para a HomeScreen
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomeScreen()),
                              );
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
                              builder: (context) =>
                                  RegisterScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
