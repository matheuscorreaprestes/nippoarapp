import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends Model {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? firebaseUser;
  Map<String, dynamic> userData = {};

  bool isLoading = false;

  UserModel() {
    _loadCurrentUser();
  }

  String get userType => userData['userType'] ?? 'client';

  void _loadCurrentUser() async {
    firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await loadUserData();
    }
    notifyListeners();
  }

  User? get currentUser => firebaseUser;

  // Método para registrar um novo usuário
  void signUp({
    required Map<String, dynamic> userData,
    required String pass,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: userData["email"],
        password: pass,
      );
      firebaseUser = userCredential.user;

      await _saveUserData(userData);

      onSuccess();
    } catch (e) {
      print(e); // Adicione logs ou rastreamento aqui
      onFail();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para fazer login de um usuário existente
  void signIn({
    required String email,
    required String pass,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      firebaseUser = userCredential.user;

      await loadUserData();

      onSuccess();
    } catch (e) {
      print(e); // Adicione logs ou rastreamento aqui
      onFail();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para recuperar a senha do usuário
  void recoverPass(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e); // Adicione logs ou rastreamento aqui
    }
  }

  // Método para salvar os dados do usuário no Firestore
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    if (firebaseUser != null) {
      await FirebaseFirestore.instance.collection("users").doc(firebaseUser!.uid).set(userData);
    }
  }

  // Método para carregar os dados do usuário do Firestore
  Future<void> loadUserData() async {
    if (firebaseUser == null) {
      firebaseUser = _auth.currentUser;
    }
    if (firebaseUser != null) {
      DocumentSnapshot docUser = await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUser!.uid)
          .get();
      userData = docUser.data() as Map<String, dynamic>;
      notifyListeners();
    }
  }

  // Método para atualizar os dados do usuário no Firestore
  void updateUser({
    required Map<String, dynamic> userData,
    String? pass,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      if (firebaseUser == null) {
        firebaseUser = _auth.currentUser;
      }
      if (firebaseUser != null) {
        await FirebaseFirestore.instance.collection("users").doc(firebaseUser!.uid).update(userData);
        this.userData = userData;

        if (pass != null && pass.isNotEmpty) {
          await firebaseUser!.updatePassword(pass);
        }

        onSuccess();
      } else {
        onFail();
      }
    } catch (e) {
      print(e); // Adicione logs ou rastreamento aqui
      onFail();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para deletar a conta do usuário no Firestore e no Authentication
  void deleteUser({
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      if (firebaseUser == null) {
        firebaseUser = _auth.currentUser;
      }
      if (firebaseUser != null) {
        await FirebaseFirestore.instance.collection("users").doc(firebaseUser!.uid).delete();
        await firebaseUser!.delete();

        firebaseUser = null;
        userData = {};
        onSuccess();
      } else {
        onFail();
      }
    } catch (e) {
      print(e); // Adicione logs ou rastreamento aqui
      onFail();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    firebaseUser = null;
    userData = {};
    notifyListeners();
  }
}
