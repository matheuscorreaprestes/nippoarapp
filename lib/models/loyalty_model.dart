import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scoped_model/scoped_model.dart';

class LoyaltyModel extends Model {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? firebaseUser;
  int points = 0;
  bool isLoading = false;

  // Novas propriedades para as regras de fidelidade
  double valueSpent = 0.0; // Valor gasto para ganhar pontos
  int pointsAwarded = 0;   // Quantidade de pontos concedida

  LoyaltyModel() {
    _loadCurrentUser();
    _loadLoyaltyRules(); // Carregar regras de fidelidade
  }

  // Método para carregar o usuário atual
  void _loadCurrentUser() async {
    firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await _loadPoints();
    }
    notifyListeners();
  }

  // Método para carregar os pontos do cliente
  Future<void> _loadPoints() async {
    if (firebaseUser != null) {
      isLoading = true;
      notifyListeners();

      DocumentSnapshot docUser = await _firestore.collection("users").doc(firebaseUser!.uid).get();
      Map<String, dynamic> data = docUser.data() as Map<String, dynamic>;
      points = data['points'] ?? 0;

      isLoading = false;
      notifyListeners();
    }
  }

  // Método para carregar as regras de fidelidade do Firestore
  Future<void> _loadLoyaltyRules() async {
    DocumentSnapshot docRules = await _firestore.collection('loyalty_rules').doc('default').get();
    if (docRules.exists) {
      Map<String, dynamic> data = docRules.data() as Map<String, dynamic>;
      valueSpent = data['valueSpent'] ?? 0.0;
      pointsAwarded = data['pointsAwarded'] ?? 0;
      notifyListeners();
    }
  }

  // Método para atualizar as regras de fidelidade no Firestore
  Future<void> updateLoyaltyRules(double value, int points) async {
    valueSpent = value;
    pointsAwarded = points;

    await _firestore.collection('loyalty_rules').doc('default').set({
      'valueSpent': valueSpent,
      'pointsAwarded': pointsAwarded,
    });
    notifyListeners();
  }

  // Método para adicionar pontos ao cliente com base no valor gasto
  Future<void> addPointsBasedOnSpent(double spentAmount) async {
    if (valueSpent > 0) {
      // Calcula a quantidade de pontos com base na regra de fidelidade
      int additionalPoints = (spentAmount / valueSpent * pointsAwarded).floor();

      points += additionalPoints;

      // Atualiza os pontos do cliente no Firestore
      await _firestore.collection('users').doc(firebaseUser!.uid).update({
        'points': points,
      });
      notifyListeners();
    }
  }
}
