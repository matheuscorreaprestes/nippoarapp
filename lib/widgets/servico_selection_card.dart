import 'package:flutter/material.dart';
import 'package:nippoarapp/models/servico_model.dart';
import 'package:nippoarapp/models/promotion_model.dart'; // Importar o modelo de promoção, se necessário

class ServicoSelectionDialog extends StatelessWidget {
  final Function(Servico) onServicoSelected; // Alterado para aceitar um objeto Servico

  ServicoSelectionDialog({required this.onServicoSelected});

  double aplicarDesconto(double preco, double desconto) {
    return preco * (1 - desconto / 100);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selecione o Serviço'),
      content: StreamBuilder<List<Servico>>(
        stream: listarServicos(), // Usando a função que lista serviços do Firestore
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
                // Simular um desconto e uma promoção, você precisará buscar a promoção certa
                final desconto = 10.0; // Valor do desconto em porcentagem
                final precoComDesconto = aplicarDesconto(servico.preco, desconto);
                final nomePromocao = "Promoção Especial"; // Nome da promoção, ajustar conforme necessário

                return ListTile(
                  title: Text(servico.nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'R\$ ${servico.preco.toStringAsFixed(2)}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough, // Texto riscado
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'R\$ ${precoComDesconto.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        nomePromocao,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    servico.preco = precoComDesconto; // Atualizar o preço do serviço
                    onServicoSelected(servico);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
