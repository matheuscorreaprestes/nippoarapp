import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nippoarapp/models/user_model.dart';

class LoyaltyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (context, child, model) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Pontos de Fidelidade"),
            centerTitle: true,
          ),
          body: model.userType == 'client'
              ? _buildClientLoyaltyScreen(context, model)
              : _buildManagerLoyaltyScreen(context, model),
        );
      },
    );
  }

  Widget _buildClientLoyaltyScreen(BuildContext context, UserModel model) {
    return Center(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(model.firebaseUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          var userDoc = snapshot.data!;
          var userData = userDoc.data() as Map<String, dynamic>;
          int points = userData.containsKey('points') ? userData['points'] : 0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${model.userData['name']}, você tem $points pontos de fidelidade.",
                style: TextStyle(fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildManagerLoyaltyScreen(BuildContext context, UserModel model) {
    return Center(
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
            child: Text("Editar Regras de Fidelidade",
              style: TextStyle(color: Colors.black,
                  backgroundColor: Theme.of(context).primaryColor
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditLoyaltyRulesDialog(BuildContext context) {
    final _pointsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Regras de Fidelidade",),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _pointsController,
                decoration: InputDecoration(
                  labelText: "Pontos por Lavagem",
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
                _updateLoyaltyRules(_pointsController.text);
                Navigator.of(context).pop();
              },
              child: Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  void _updateLoyaltyRules(String points) {
    // Implementar lógica para atualizar regras de fidelidade no Firebase
    int pointsPerWash = int.tryParse(points) ?? 0;

    FirebaseFirestore.instance
        .collection('loyalty_rules')
        .doc('default')
        .set({'pointsPerWash': pointsPerWash});
  }
}
