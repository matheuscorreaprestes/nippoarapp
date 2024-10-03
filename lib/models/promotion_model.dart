import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';

class Promotion {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;
  double discount;

  Promotion({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.discount,
  });

  // Converte o objeto para um Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startDate': Timestamp.fromDate(startDate), // Salva como Timestamp
      'endDate': Timestamp.fromDate(endDate), // Salva como Timestamp
      'discount': discount,
    };
  }

  // Converte um documento Firestore para o objeto Promotion
  factory Promotion.fromDocument(DocumentSnapshot doc) {
    return Promotion(
      id: doc.id,
      name: doc['name'],
      startDate: (doc['startDate'] as Timestamp).toDate(),
      endDate: (doc['endDate'] as Timestamp).toDate(),
      discount: doc['discount'].toDouble(),
    );
  }
}

class PromotionModel extends Model {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Promotion> promotions = [];

  // Carregar promoções do Firestore
  Future<void> fetchPromotions() async {
    try {
      final querySnapshot = await _firestore.collection('promotions').get();
      promotions = querySnapshot.docs.map((doc) => Promotion.fromDocument(doc)).toList();
      notifyListeners();
    } catch (e) {
      print('Erro ao buscar promoções: $e');
    }
  }

  // Adicionar uma nova promoção
  Future<void> addPromotion(Promotion promotion) async {
    try {
      final docRef = await _firestore.collection('promotions').add(promotion.toMap());
      promotion.id = docRef.id; // Atualiza o ID da promoção com o ID gerado pelo Firestore
      promotions.add(promotion);
      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar promoção: $e');
    }
  }

  // Editar uma promoção existente
  Future<void> editPromotion(String id, Promotion updatedPromotion) async {
    try {
      await _firestore.collection('promotions').doc(id).update(updatedPromotion.toMap());
      final index = promotions.indexWhere((promotion) => promotion.id == id);
      if (index != -1) {
        promotions[index] = updatedPromotion;
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao editar promoção: $e');
    }
  }

  // Remover uma promoção
  Future<void> deletePromotion(String id) async {
    try {
      await _firestore.collection('promotions').doc(id).delete();
      promotions.removeWhere((promotion) => promotion.id == id);
      notifyListeners();
    } catch (e) {
      print('Erro ao remover promoção: $e');
    }
  }

  // Função para buscar a promoção associada a um serviço específico
  Future<Promotion?> buscarPromocaoDoServico(String servicoId) async {
    try {
      final snapshot = await _firestore
          .collection('promotions')
          .where('servicoId', isEqualTo: servicoId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Promotion.fromDocument(snapshot.docs.first); // Corrigido para Promotion
      }
    } catch (e) {
      print('Erro ao buscar promoção: $e');
    }
    return null;
  }
}
