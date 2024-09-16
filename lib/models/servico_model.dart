import 'package:cloud_firestore/cloud_firestore.dart';

class Servico {
  String id; // ID do serviço, gerado automaticamente pelo banco de dados
  String nome; // Nome do serviço, ex: Lavagem Externa
  double preco; // Preço do serviço, ex: 50.0
  String? promotionId;

  Servico({
    required this.id,
    required this.nome,
    required this.preco,
    this.promotionId,
  });

  // Método para converter de e para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'promotionId': promotionId,
    };
  }

  static Servico fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      preco: map['preco']?.toDouble() ?? 0.0,
      promotionId: map['promotionId'],
    );
  }
}

// Funções de CRUD

Future<void> adicionarServico(Servico servico) async {
  final docRef = FirebaseFirestore.instance.collection('servicos').doc();
  servico.id = docRef.id; // Define o ID gerado pelo Firestore
  await docRef.set(servico.toMap());
}

Future<void> editarServico(Servico servico) async {
  await FirebaseFirestore.instance.collection('servicos').doc(servico.id).update(servico.toMap());
}

Future<void> removerServico(String id) async {
  await FirebaseFirestore.instance.collection('servicos').doc(id).delete();
}

Stream<List<Servico>> listarServicos() {
  return FirebaseFirestore.instance
      .collection('servicos')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Servico.fromMap(doc.data())).toList());
}
