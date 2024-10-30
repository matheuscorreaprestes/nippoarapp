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

  // Função para carregar o usuário atual
  void _loadCurrentUser() async {
    firebaseUser = _auth.currentUser;
    notifyListeners();
  }

  // Getter para obter o usuário atual
  User? get currentUser => firebaseUser;

  // Função para criar um novo veículo no Firestore
  Future<void> createVehicle({
    required Map<String, dynamic> vehicleData,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners(); // Notifica que o estado de loading foi iniciado

    try {
      firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _firestore
            .collection("users")
            .doc(firebaseUser!.uid)
            .collection("cars")
            .add(vehicleData);
        onSuccess(); // Chama a callback de sucesso
      } else {
        onFail(); // Chama a callback de falha se o usuário não estiver autenticado
      }
    } catch (e) {
      print("Error: $e");
      onFail(); // Chama a callback de falha em caso de erro
    } finally {
      isLoading = false;
      notifyListeners(); // Notifica que o estado de loading foi concluído
    }
  }

  // Função para atualizar os dados de um veículo existente
  Future<void> updateVehicle({
    required String vehicleId,
    required Map<String, dynamic> vehicleData,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners(); // Inicia o estado de loading

    try {
      firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _firestore
            .collection("users")
            .doc(firebaseUser!.uid)
            .collection("cars")
            .doc(vehicleId)
            .update(vehicleData);
        onSuccess(); // Chama a callback de sucesso
      } else {
        onFail(); // Callback de falha se o usuário não estiver autenticado
      }
    } catch (e) {
      print("Error: $e");
      onFail(); // Callback de falha em caso de erro
    } finally {
      isLoading = false;
      notifyListeners(); // Notifica que o estado de loading foi concluído
    }
  }

  // Função para excluir um veículo
  Future<void> deleteVehicle({
    required String vehicleId,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners(); // Inicia o estado de loading

    try {
      firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _firestore
            .collection("users")
            .doc(firebaseUser!.uid)
            .collection("cars")
            .doc(vehicleId)
            .delete();
        onSuccess(); // Callback de sucesso após exclusão
      } else {
        onFail(); // Callback de falha se o usuário não estiver autenticado
      }
    } catch (e) {
      print("Error: $e");
      onFail(); // Callback de falha em caso de erro
    } finally {
      isLoading = false;
      notifyListeners(); // Notifica que o estado de loading foi concluído
    }
  }

  // Função para obter todos os veículos do usuário
  Future<QuerySnapshot> getVehicles() async {
    firebaseUser = _auth.currentUser; // Certifica-se de que o usuário está atualizado
    if (firebaseUser != null) {
      return await _firestore
          .collection("users")
          .doc(firebaseUser!.uid)
          .collection("cars")
          .get();
    } else {
      throw Exception("Usuário não autenticado");
    }
  }

  // Função para obter as marcas de carros do Firestore
  Future<QuerySnapshot> getCarBrands() async {
    return await _firestore.collection("cars").get(); // Puxa todas as marcas
  }

  // Função para obter os modelos de uma marca específica
  Future<QuerySnapshot> getCarModels(String brandId) async {
    return await _firestore.collection("cars").doc(brandId).collection("models").get();
  }

  // Função para calcular o valor do serviço baseado na categoria do veículo
  Future<double> calculateServicePrice(String category, double basePrice) async {
    switch (category) {
      case 'baixo':
        return basePrice;
      case 'médio':
        return basePrice + 10.0; // Adiciona 10 reais para SUVs
      case 'alto':
        return basePrice + 20.0; // Adiciona 20 reais para caminhonetes
      default:
        throw Exception("Categoria desconhecida");
    }
  }

  // Função para permitir que o cliente adicione um modelo manualmente
  Future<void> addCustomVehicle({
    required String brandId,
    required String modelName,
    required String category,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    isLoading = true;
    notifyListeners(); // Inicia o loading

    try {
      await _firestore.collection("cars").doc(brandId).collection("models").add({
        "model": modelName,
        "category": category,
      });
      onSuccess(); // Callback de sucesso
    } catch (e) {
      print("Error: $e");
      onFail(); // Callback de falha em caso de erro
    } finally {
      isLoading = false;
      notifyListeners(); // Notifica que o estado de loading foi concluído
    }
  }
}
