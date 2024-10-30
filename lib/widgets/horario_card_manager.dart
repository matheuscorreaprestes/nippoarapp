import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nippoarapp/services/notification_service.dart';
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
                    _finalizarServico(context, horario.valorServico, horario.userId, horario.veiculo.modelo, horario.veiculo.placa, horario.servico);
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

  void _finalizarServico(
      BuildContext context,
      double valorServico,
      String userId,
      String modeloVeiculo,
      String placaVeiculo,
      String tipoServico,
      ) async {
    try {
      // Obtém o documento do cliente
      DocumentSnapshot clienteSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      Map<String, dynamic>? clienteData = clienteSnapshot.data() as Map<String, dynamic>?;

      // Verifica se o campo 'token' existe no documento do cliente
      if (clienteData != null && clienteData.containsKey('token')) {
        String? clienteToken = clienteData['token'];

        if (clienteToken != null) {
          // Envia a notificação para o cliente
          await enviarNotificacaoParaCliente(
            clienteToken,
            'Serviço Concluído',
            'Seu veículo está pronto para ser retirado!',
          );
        } else {
          print('Cliente não possui token de notificação');
        }
      } else {
        print('Documento do cliente não existe ou não contém o campo "token".');
      }

      // Obtém as regras de fidelidade atuais para calcular os pontos
      DocumentSnapshot loyaltyDoc = await FirebaseFirestore.instance.collection('loyalty_rules').doc('default').get();
      Map<String, dynamic>? loyaltyData = loyaltyDoc.data() as Map<String, dynamic>?;

      if (loyaltyData != null) {
        // Verifica se os campos 'pointsAwarded' e 'valueSpent' existem no documento de regras
        int pontosPorValor = loyaltyData.containsKey('pointsAwarded') ? loyaltyData['pointsAwarded'] : 0;
        double valorParaPontos = loyaltyData.containsKey('valueSpent') ? loyaltyData['valueSpent'] : 0;

        // Calcula os pontos a adicionar com base no valor gasto
        int pontosAdicionar = (valorServico / valorParaPontos).floor() * pontosPorValor;

        // Atualiza os pontos no documento do cliente
        DocumentReference clienteRef = FirebaseFirestore.instance.collection('users').doc(userId);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(clienteRef);
          Map<String, dynamic>? clienteDataTrans = snapshot.data() as Map<String, dynamic>?;

          if (clienteDataTrans != null) {
            // Verifica se o campo 'points' existe no documento do cliente
            int pontosAtuais = clienteDataTrans.containsKey('points') ? clienteDataTrans['points'] : 0;
            transaction.update(clienteRef, {'points': pontosAtuais + pontosAdicionar});
          } else {
            print('Documento do cliente não existe.');
          }
        });
      } else {
        print('Documento de regras de fidelidade não encontrado.');
      }

      // Salvar as informações do serviço concluído no Firestore
      await FirebaseFirestore.instance.collection('servicos_concluidos').add({
        'descricao': tipoServico,
        'modelo_veiculo': modeloVeiculo,
        'placa_veiculo': placaVeiculo,
        'valor': valorServico,
        'data': DateTime.now(),
      });

      // Confirmação de que o serviço foi concluído
      onConfirmar();

      // Exibir mensagem de sucesso ao gestor
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Serviço finalizado e informações adicionadas com sucesso!')),
      );
    } catch (e) {
      print('Erro ao finalizar o serviço e adicionar pontos de fidelidade: $e');
      // Exibir uma mensagem de erro para o gestor
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao finalizar o serviço: $e')),
      );
    }
  }



}
