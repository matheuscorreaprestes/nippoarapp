import 'package:flutter/material.dart';
import 'package:nippoarapp/models/servico_model.dart';
import 'package:nippoarapp/models/promotion_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicoSelectionDialog extends StatefulWidget {
  final String userId;
  final Function(Servico, double) onServicoSelected; // Inclui o preço junto com o serviço
  final String categoriaCarro;

  ServicoSelectionDialog({
    required this.userId,
    required this.onServicoSelected,
    required this.categoriaCarro,
  });

  @override
  _ServicoSelectionDialogState createState() => _ServicoSelectionDialogState();
}

class _ServicoSelectionDialogState extends State<ServicoSelectionDialog> {
  bool usarPontos = false;
  int pontosDisponiveis = 0;
  double pontosPorReal = 1.0;

  @override
  void initState() {
    super.initState();
    _fetchPontos();
  }

  Future<void> _fetchPontos() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      setState(() {
        pontosDisponiveis = userDoc['points'] ?? 0;
      });

      print("Pontos disponíveis: $pontosDisponiveis"); // Log para verificar pontos
    } catch (e) {
      print("Erro ao buscar pontos do usuário: $e"); // Log de erro
    }
  }

  Future<double> _fetchPontosPorReal() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('pontosPorReal')
          .get();
      double pontosPorReal = doc['pontosPorReal']?.toDouble() ?? 1.0;

      print("Pontos por real: $pontosPorReal"); // Log para verificar pontos por real
      return pontosPorReal;
    } catch (e) {
      print("Erro ao buscar pontosPorReal: $e"); // Log de erro
      return 1.0; // Valor padrão
    }
  }

  int calcularPontosNecessarios(double preco) {
    int pontos = (preco / pontosPorReal).ceil();
    print("Pontos necessários para $preco: $pontos"); // Log para verificar cálculo de pontos
    return pontos;
  }

  double aplicarDesconto(double preco, double desconto) {
    double precoComDesconto = preco * (1 - desconto / 100);
    print("Preço com desconto: $precoComDesconto (Desconto de $desconto%)"); // Log para verificar desconto
    return precoComDesconto;
  }

  bool promocaoValida(DateTime endDate) {
    bool valida = endDate.isAfter(DateTime.now());
    print("Promoção válida? $valida (Data final: $endDate)"); // Log para verificar validade
    return valida;
  }

  Stream<List<Servico>> listarServicos() {
    return FirebaseFirestore.instance
        .collection('servicos')
        .snapshots()
        .map((snapshot) {
      print("Número de serviços encontrados: ${snapshot.docs.length}"); // Log para verificar quantos serviços
      return snapshot.docs.map((doc) => Servico.fromMap(doc.data())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _fetchPontosPorReal(),
      builder: (context, pontosPorRealSnapshot) {
        if (!pontosPorRealSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        pontosPorReal = pontosPorRealSnapshot.data!;

        return AlertDialog(
          title: Text('Selecione o Serviço'),
          content: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Usar Pontos'),
                  Switch(
                    value: usarPontos,
                    onChanged: (value) {
                      setState(() {
                        usarPontos = value;
                      });
                      print("Usar pontos: $usarPontos"); // Log para verificar uso de pontos
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<Servico>>(
                  stream: listarServicos(),
                  builder: (context, servicoSnapshot) {
                    if (servicoSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!servicoSnapshot.hasData || servicoSnapshot.data!.isEmpty) {
                      print("Nenhum serviço disponível."); // Log para verificar se há serviços
                      return Center(
                        child: Text('Nenhum serviço disponível'),
                      );
                    }

                    List<Servico> servicos = servicoSnapshot.data!;

                    return SingleChildScrollView(
                      child: Column(
                        children: servicos.map((servico) {
                          double preco = _obterPrecoPorCategoria(servico, widget.categoriaCarro);

                          print("Serviço: ${servico.nome}, Preço: $preco"); // Log para verificar preço por categoria

                          int pontosNecessarios = calcularPontosNecessarios(preco);
                          bool pontosSuficientes = pontosDisponiveis >= pontosNecessarios;

                          if (usarPontos && !pontosSuficientes) {
                            return Container();
                          }

                          return FutureBuilder<Promotion?>(
                            future: buscarPromocaoAtiva(),
                            builder: (context, promoSnapshot) {
                              if (!promoSnapshot.hasData) {
                                print("Nenhuma promoção ativa encontrada."); // Log para verificar promoções
                                return _buildServicoTile(servico, preco, null, pontosSuficientes);
                              }

                              final promocao = promoSnapshot.data;
                              if (promocao != null && promocaoValida(promocao.endDate)) {
                                final precoComDesconto = aplicarDesconto(preco, promocao.discount);
                                return _buildServicoTile(servico, precoComDesconto, promocao.name, pontosSuficientes);
                              } else {
                                return _buildServicoTile(servico, preco, null, pontosSuficientes);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServicoTile(Servico servico, double preco, String? nomePromocao, bool pontosSuficientes) {
    return ListTile(
      leading: usarPontos
          ? Icon(
        pontosSuficientes ? Icons.check_circle : Icons.block,
        color: pontosSuficientes ? Colors.green : Colors.red,
      )
          : null,
      title: Text(servico.nome),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nomePromocao != null)
            Row(
              children: [
                Text(
                  'R\$ ${preco.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (usarPontos)
            Text(
              pontosSuficientes
                  ? 'É possível usar pontos para este serviço'
                  : 'Pontos insuficientes',
              style: TextStyle(
                color: pontosSuficientes ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
        ],
      ),
      onTap: () {
        if (usarPontos && pontosSuficientes) {
          _usarPontosParaServico(calcularPontosNecessarios(preco));
        }

        print("Serviço selecionado: ${servico.nome}, Preço: $preco"); // Log para verificar serviço selecionado
        widget.onServicoSelected(servico, preco); // Passa o serviço e o preço selecionado
        Navigator.pop(context);
      },
    );
  }

  double _obterPrecoPorCategoria(Servico servico, String categoriaCarro) {
    switch (categoriaCarro.toLowerCase()) {
      case 'baixo':
        return servico.precoBaixo;
      case 'médio':
        return servico.precoMedio;
      case 'alto':
        return servico.precoAlto;
      default:
        return servico.precoBaixo; // Retorno padrão
    }
  }

  void _usarPontosParaServico(int pontosUsados) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'points': pontosDisponiveis - pontosUsados});
    print("Pontos atualizados: ${pontosDisponiveis - pontosUsados}"); // Log para verificar pontos atualizados
  }

  Future<Promotion?> buscarPromocaoAtiva() async {
    try {
      final now = DateTime.now();
      final snapshot = await FirebaseFirestore.instance
          .collection('promotions')
          .where('endDate', isGreaterThan: now)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final promocao = Promotion.fromDocument(snapshot.docs.first);
        print("Promoção ativa encontrada: ${promocao.name}"); // Log para verificar promoção ativa
        return promocao;
      } else {
        print("Nenhuma promoção ativa no momento."); // Log se não houver promoções
        return null;
      }
    } catch (e) {
      print("Erro ao buscar promoções: $e"); // Log de erro
      return null;
    }
  }
}
