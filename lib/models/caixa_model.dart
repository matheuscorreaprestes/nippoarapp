import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';

class Receita {
  String id;
  String descricao;
  double valor;
  DateTime data;

  Receita({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
  });

  // Converte um documento Firestore para o objeto Receita
  factory Receita.fromDocument(DocumentSnapshot doc) {
    return Receita(
      id: doc.id,
      descricao: doc['descricao'],
      valor: doc['valor'].toDouble(),
      data: (doc['data'] as Timestamp).toDate(),
    );
  }
}

class Despesa {
  String id;
  String descricao;
  double valor;
  DateTime data;

  Despesa({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
  });

  // Converte um documento Firestore para o objeto Despesa
  factory Despesa.fromDocument(DocumentSnapshot doc) {
    return Despesa(
      id: doc.id,
      descricao: doc['descricao'],
      valor: doc['valor'].toDouble(),
      data: (doc['data'] as Timestamp).toDate(),
    );
  }
}

class RegistroCaixaModel extends Model {
  List<Receita> receitas = [];
  List<Despesa> despesas = [];
  bool isLoading = false;

  // Método para adicionar uma receita
  Future<void> adicionarReceita(String descricao, double valor) async {
    String mesAtual = _getMesAnoAtual();
    await FirebaseFirestore.instance
        .collection('caixa')
        .doc('receitas')
        .collection(mesAtual)
        .add({
      'descricao': descricao,
      'valor': valor,
      'data': DateTime.now(),
    });

    // Atualiza a lista local de receitas
    carregarReceitas();
  }

  // Método para adicionar uma despesa
  Future<void> adicionarDespesa(String descricao, double valor) async {
    String mesAtual = _getMesAnoAtual();
    await FirebaseFirestore.instance
        .collection('caixa')
        .doc('despesas')
        .collection(mesAtual)
        .add({
      'descricao': descricao,
      'valor': valor,
      'data': DateTime.now(),
    });

    // Atualiza a lista local de despesas
    carregarDespesas();
  }

  // Método para carregar receitas
  Future<void> carregarReceitas() async {
    isLoading = true;
    notifyListeners();

    String mesAtual = _getMesAnoAtual();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('caixa')
        .doc('receitas')
        .collection(mesAtual)
        .get();

    receitas = querySnapshot.docs.map((doc) => Receita.fromDocument(doc)).toList();

    isLoading = false;
    notifyListeners();
  }

  // Método para carregar despesas
  Future<void> carregarDespesas() async {
    isLoading = true;
    notifyListeners();

    String mesAtual = _getMesAnoAtual();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('caixa')
        .doc('despesas')
        .collection(mesAtual)
        .get();

    despesas = querySnapshot.docs.map((doc) => Despesa.fromDocument(doc)).toList();

    isLoading = false;
    notifyListeners();
  }

  // Método para obter o mês e ano atual no formato 'YYYY-MM'
  String _getMesAnoAtual() {
    DateTime now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}
