import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:nippoarapp/models/schedule_model.dart';
import 'package:nippoarapp/models/loyalty_model.dart';

class HorarioCardManager extends StatelessWidget {
  final Horario horario;
  final VoidCallback onCancelar;
  final VoidCallback onConfirmar;

  const HorarioCardManager({
    Key? key,
    required this.horario,
    required this.onCancelar,
    required this.onConfirmar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(horario.data);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente: ${horario.nomeCliente}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Horário: $dataFormatada',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Veículo: ${horario.veiculo.marca} ${horario.veiculo.modelo}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Placa: ${horario.veiculo.placa}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Serviço: ${horario.servico}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              // Exibir o valor do serviço formatado para a moeda
              'Valor: ${NumberFormat.currency(symbol: 'R\$').format(horario.valorServico)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            horario.isConcluido
                ? Center(
              child: Text(
                'Serviço Concluído',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Adicionar lógica para confirmar o serviço
                    _finalizarServico(context, horario.valorServico, horario.userId);
                  },
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text(
                    'Confirmar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onCancelar, // Botão para cancelar o agendamento
                  icon: Icon(Icons.cancel, color: Colors.white),
                  label: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método para finalizar o serviço e adicionar pontos ao cliente
  void _finalizarServico(BuildContext context, double valorServico, String userId) async {
    try {
      // Obter as regras de fidelidade atuais para calcular os pontos
      DocumentSnapshot loyaltyDoc = await FirebaseFirestore.instance
          .collection('loyalty_rules')
          .doc('default')
          .get();

      int pontosPorValor = loyaltyDoc['pointsAwarded'] ?? 0;
      double valorParaPontos = loyaltyDoc['valueSpent'] ?? 0;

      // Calcular os pontos a adicionar com base no valor gasto
      int pontosAdicionar = (valorServico / valorParaPontos).floor() * pontosPorValor;

      // Atualizar os pontos no documento do cliente
      DocumentReference clienteRef = FirebaseFirestore.instance.collection('users').doc(userId);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(clienteRef);

        if (snapshot.exists) {
          int pontosAtuais = snapshot['points'] ?? 0;
          transaction.update(clienteRef, {'points': pontosAtuais + pontosAdicionar});
        }
      });

      // Confirmar o serviço
      onConfirmar();
    } catch (e) {
      print('Erro ao adicionar pontos de fidelidade: $e');
      // Você pode adicionar uma lógica para exibir um alerta ou mensagem de erro para o usuário
    }
  }
}
