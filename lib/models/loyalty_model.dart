import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scoped_model/scoped_model.dart';

class LoyaltyModel extends Model {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? firebaseUser;
  int points = 0;
  bool isLoading = false;

  LoyaltyModel() {
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await _loadPoints();
    }
    notifyListeners();
  }

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

}
