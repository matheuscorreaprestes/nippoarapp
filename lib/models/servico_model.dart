import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Servico {
  String id; // ID do serviço, gerado automaticamente pelo banco de dados
  String nome; // Nome do serviço, ex: Lavagem Externa
  double precoBaixo; // Preço para carro baixo (hatch, sedan)
  double precoMedio; // Preço para carro médio (SUV)
  double precoAlto; // Preço para carro alto (caminhonetes)
  String clienteToken;

  Servico({
    required this.id,
    required this.nome,
    required this.precoBaixo,
    required this.precoMedio,
    required this.precoAlto,
    required this.clienteToken,
  });

  // Getter para calcular o preço conforme a categoria
  double getPrecoPorCategoria(String categoriaCarro) {
    switch (categoriaCarro.toLowerCase()) {
      case 'baixo':
        return precoBaixo;
      case 'médio':
        return precoMedio;
      case 'alto':
        return precoAlto;
      default:
        throw Exception('Categoria desconhecida: $categoriaCarro');
    }
  }

  // Método para converter para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'precoBaixo': precoBaixo,
      'precoMedio': precoMedio,
      'precoAlto': precoAlto,
      'clienteToken': clienteToken,
    };
  }

  // Método para converter do Firestore
  static Servico fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      precoBaixo: map['precoBaixo']?.toDouble() ?? 0.0,
      precoMedio: map['precoMedio']?.toDouble() ?? 0.0,
      precoAlto: map['precoAlto']?.toDouble() ?? 0.0,
      clienteToken: map['clienteToken'],
    );
  }
}

// Função para buscar configuração de pontos por real gasto
Future<double> buscarPontosPorReal() async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('config').doc('pontosPorReal').get();
    return doc['valor']?.toDouble() ?? 10.0; // Default para 10.0 se não houver valor no Firestore
  } catch (e) {
    print('Erro ao buscar pontosPorReal: $e');
    return 10.0; // Valor padrão
  }
}

// Função para salvar token FCM no banco de dados
Future<void> saveTokenToDatabase(String token, String userId) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'token': token,
  });
}

// Função para salvar o token FCM
void saveFCMToken(String userId) async {
  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    saveTokenToDatabase(token, userId);
  }
}

// Funções de CRUD

// Adicionar novo serviço com preços por categoria
Future<void> adicionarServico(Servico servico) async {
  final docRef = FirebaseFirestore.instance.collection('servicos').doc();
  servico.id = docRef.id; // Define o ID gerado pelo Firestore
  await docRef.set(servico.toMap());
}

// Editar serviço existente com preços por categoria
Future<void> editarServico(Servico servico) async {
  await FirebaseFirestore.instance.collection('servicos').doc(servico.id).update(servico.toMap());
}

// Remover serviço pelo ID
Future<void> removerServico(String id) async {
  await FirebaseFirestore.instance.collection('servicos').doc(id).delete();
}

// Listar todos os serviços como stream de dados
Stream<List<Servico>> listarServicos() {
  return FirebaseFirestore.instance
      .collection('servicos')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Servico.fromMap(doc.data())).toList());
}
