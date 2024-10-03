import 'package:flutter/material.dart';
import 'package:nippoarapp/models/servico_model.dart';
import 'package:nippoarapp/models/promotion_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicoSelectionDialog extends StatelessWidget {
  final Function(Servico) onServicoSelected;

  ServicoSelectionDialog({required this.onServicoSelected});

  // Função para aplicar o desconto
  double aplicarDesconto(double preco, double desconto) {
    return preco * (1 - desconto / 100);
  }

  // Função para verificar se a promoção é válida
  bool promocaoValida(DateTime endDate) {
    return endDate.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selecione o Serviço'),
      content: StreamBuilder<List<Servico>>(
        stream: listarServicos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Nenhum serviço disponível'),
            );
          }

          final servicos = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: servicos.map((servico) {
                return FutureBuilder<Promotion?>(
                  future: buscarPromocaoDoServico(servico.id), // Função para buscar a promoção do serviço
                  builder: (context, promoSnapshot) {
                    if (!promoSnapshot.hasData) {
                      // Se não houver promoção, mostrar o preço normal
                      return _buildServicoTile(servico, servico.preco, null, context);
                    }

                    final promocao = promoSnapshot.data;

                    if (promocao != null && promocaoValida(promocao.endDate)) {
                      // Se houver promoção válida, aplicar o desconto
                      final precoComDesconto = aplicarDesconto(servico.preco, promocao.discount);
                      return _buildServicoTile(servico, precoComDesconto, promocao.name, context);
                    } else {
                      // Se a promoção não for válida ou não existir, mostrar o preço normal
                      return _buildServicoTile(servico, servico.preco, null, context);
                    }
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  // Função para construir o ListTile do serviço
  Widget _buildServicoTile(Servico servico, double preco, String? nomePromocao, BuildContext context) {
    return ListTile(
      title: Text(servico.nome),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nomePromocao != null)
            Row(
              children: [
                Text(
                  'R\$ ${servico.preco.toStringAsFixed(2)}',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8),
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
          if (nomePromocao != null) SizedBox(height: 4),
          if (nomePromocao != null)
            Text(
              nomePromocao,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey,
              ),
            ),
          if (nomePromocao == null)
            Text(
              'R\$ ${preco.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
        ],
      ),
      onTap: () {
        servico.preco = preco;
        onServicoSelected(servico);
        Navigator.pop(context);
      },
    );
  }

  // Função para buscar a promoção associada ao serviço
  Future<Promotion?> buscarPromocaoDoServico(String servicoId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('promotions')
          .where('servicoId', isEqualTo: servicoId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Promotion.fromDocument(snapshot.docs.first); // Convertendo para Promotion
      }
    } catch (e) {
      print('Erro ao buscar promoção: $e');
    }
    return null;
  }
}
