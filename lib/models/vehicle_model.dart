import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class VehicleModel extends Model {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? firebaseUser;
  bool isLoading = false;

  VehicleModel() {
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    firebaseUser = _auth.currentUser;
    notifyListeners();
  }

  User? get currentUser => firebaseUser;

  Future<void> createVehicle({
    required Map<String, dynamic> vehicleData,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _firestore.collection("users").doc(firebaseUser!.uid).collection("cars").add(vehicleData);
        onSuccess();
      } else {
        onFail();
      }
    } catch (e) {
      print("Error: $e");
      onFail();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVehicle({
    required String vehicleId,
    required Map<String, dynamic> vehicleData,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _firestore.collection("users").doc(firebaseUser!.uid).collection("cars").doc(vehicleId).update(vehicleData);
        onSuccess();
      } else {
        onFail();
      }
    } catch (e) {
      print("Error: $e");
      onFail();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteVehicle({
    required String vehicleId,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _firestore.collection("users").doc(firebaseUser!.uid).collection("cars").doc(vehicleId).delete();
        onSuccess();
      } else {
        onFail();
      }
    } catch (e) {
      print("Error: $e");
      onFail();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<QuerySnapshot> getVehicles() async {
    firebaseUser = _auth.currentUser;
    return await _firestore.collection("users").doc(firebaseUser!.uid).collection("cars").get();
  }
}
