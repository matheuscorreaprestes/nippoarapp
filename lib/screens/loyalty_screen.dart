import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nippoarapp/models/user_model.dart';

class ClientLoyaltyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (context, child, model) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Pontos de Fidelidade"),
            centerTitle: true,
          ),
          body: _buildClientLoyaltyScreen(context, model),
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
}
