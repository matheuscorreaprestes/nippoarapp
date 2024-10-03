import 'package:flutter/material.dart';
import 'package:nippoarapp/screens/registro_caixa_screen.dart';
import 'package:nippoarapp/screens/visualizar_caixa_screen.dart';

class CaixaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caixa'),
        centerTitle: true, // Centralizar o título
      ),
      body: Container(
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botão para registrar
                ElevatedButton.icon(
                  onPressed: () {
                    // Navegar para a tela de Registro de Caixa
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistroCaixaScreen()),
                    );
                  },
                  icon: Icon(Icons.edit, size: 28, color: Colors.black,), // Adicionar ícone
                  label: Text(
                    'Registrar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0), // Aumentar a altura do botã// Cor do botão
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bordas arredondadas
                    ),
                    elevation: 5, // Sombra para profundidade
                  ),
                ),
                SizedBox(height: 30), // Mais espaçamento entre os botões
                // Botão para visualizar
                ElevatedButton.icon(
                  onPressed: () {
                    // Navegar para a tela de Visualização de Caixa
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VisualizarCaixaScreen()),
                    );
                  },
                  icon: Icon(Icons.visibility, size: 28, color: Colors.black,), // Adicionar ícone
                  label: Text(
                    'Visualizar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0), // Aumentar a altura do botão// Cor do botão
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bordas arredondadas
                    ),
                    elevation: 5, // Sombra para profundidade
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
