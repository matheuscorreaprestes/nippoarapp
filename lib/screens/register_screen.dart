import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/Resource/Strings.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/screens/login_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:br_validators/br_validators.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';


class PortugueseStrings implements FlutterPwValidatorStrings {
  @override
  final String atLeast = 'Pelo menos - caracteres';
  @override
  final String uppercaseLetters = '- Letras maiúsculas';
  @override
  final String numericCharacters = '- Números';
  @override
  final String specialCharacters = '- Caracteres especiais';
  @override
  final String lowercaseLetters = '- Letras minúsculas';
  @override
  final String normalLetters = '- Letras';
}


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  var mobilePhoneMask = BRMasks.mobilePhone;
  var dateMask = BRMasks.date;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text("Criar Conta"),
          centerTitle: true,
        ),
        body: ScopedModelDescendant<UserModel>(
          builder: (context, child, model){
            if(model.isLoading)
              return Center(child: CircularProgressIndicator(),);

            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        hintText: "Nome"
                    ),
                    validator: (text){
                      if(text!.isEmpty) return "Campo Vazio";
                    },
                  ),
                  SizedBox(height: 16.0,),
                  TextFormField(
                    inputFormatters: [BRMasks.mobilePhone],
                    controller: _phoneController,
                    decoration: InputDecoration(
                        hintText: "Celular"
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (text){
                      if(text!.isEmpty) return "Campo Vazio";
                    },
                  ),
                  SizedBox(height: 16.0,),
                  TextFormField(
                    inputFormatters: [BRMasks.date],
                    controller: _birthController,
                    decoration: InputDecoration(
                        hintText: "Data de nascimento"
                    ),
                    keyboardType: TextInputType.number,
                    validator: (text){
                      if(text!.isEmpty) return "Campo Vazio";
                    },
                  ),
                  SizedBox(height: 16.0,),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: "E-mail"
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (text){
                      if(text!.isEmpty || !text.contains("@")) return "E-mail invalido";
                    },
                  ),
                  SizedBox(height: 16.0,),
                  TextFormField(
                    controller: _passController,
                    decoration: InputDecoration(
                      hintText: "Senha",
                    ),
                    obscureText: true,
                    onChanged: (value){
                      setState(() {});
                    },
                    validator: (text){
                      if(text!.isEmpty || text.length < 8) return "Senha Invalida";
                    },
                  ),
                  SizedBox(height: 16.0,),
                  FlutterPwValidator(
                      controller: _passController,
                      width: 400,
                      height: 40,
                      minLength: 8,
                      strings: PortugueseStrings(),
                      onSuccess: (){},
                      onFail: (){},
                      ),
                  TextFormField(
                    controller: _confirmPassController,
                    decoration: InputDecoration(
                      hintText: "Confirmar Senha",
                    ),
                    obscureText: true,
                    onChanged: (value){
                      setState(() {});
                    },
                    validator: (text){
                      if(text!.isEmpty || text != _passController.text) return "As senhas não são iguais";
                    },
                  ),
                  SizedBox(height: 16.0,),
                  ElevatedButton(
                    child: Text("Criar Conta",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: (){
                      if(_formKey.currentState!.validate()){

                        Map<String, dynamic> userData = {
                          "name": _nameController.text,
                          "celular": _phoneController.text,
                          "data de nascimento": _birthController.text,
                          "email": _emailController.text,
                          "usertype" : "cliente",
                        };

                        model.signUp(
                            userData: userData,
                            pass: _passController.text,
                            onSuccess: _onSuccess,
                            onFail: _onFail
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        )
    );
  }

  void _onSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conta criada com sucesso!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  void _onFail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Falha ao criar a conta. Tente novamente.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }
}



