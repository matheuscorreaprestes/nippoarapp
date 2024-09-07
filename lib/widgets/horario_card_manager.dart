import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nippoarapp/models/schedule_model.dart';

// Dentro de horario_card_manager.dart

class HorarioCardManager extends StatelessWidget {
  final Horario horario;
  final VoidCallback onCancelar;

  const HorarioCardManager({
    Key? key,
    required this.horario,
    required this.onCancelar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Exibir informações formatadas do agendamento
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
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onCancelar,
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
            ),
          ],
        ),
      ),
    );
  }
}

