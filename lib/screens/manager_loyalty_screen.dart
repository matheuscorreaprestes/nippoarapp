import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerLoyaltyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerenciar Fidelidade"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Gerenciar Fidelidade",
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _showEditLoyaltyRulesDialog(context);
              },
              child: Text(
                "Editar Regras de Fidelidade",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLoyaltyRulesDialog(BuildContext context) {
    final _valueController = TextEditingController();
    final _pointsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Regras de Fidelidade"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: "Valor Gasto (R\$)",
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _pointsController,
                decoration: InputDecoration(
                  labelText: "Pontos",
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _updateLoyaltyRules(_valueController.text, _pointsController.text);
                Navigator.of(context).pop();
              },
              child: Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  void _updateLoyaltyRules(String value, String points) {
    double valueSpent = double.tryParse(value) ?? 0.0;
    int pointsAwarded = int.tryParse(points) ?? 0;

    FirebaseFirestore.instance
        .collection('loyalty_rules')
        .doc('default')
        .set({'valueSpent': valueSpent, 'pointsAwarded': pointsAwarded});
  }
}
