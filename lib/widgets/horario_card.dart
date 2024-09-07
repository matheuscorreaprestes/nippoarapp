import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nippoarapp/models/schedule_model.dart';

class HorarioCard extends StatelessWidget {
  final Horario horario;
  final VoidCallback onCancelar;

  HorarioCard({required this.horario, required this.onCancelar});

  @override
  Widget build(BuildContext context) {
    // Formatar a data e a hora para exibição
    String dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(horario.data);

    return Card(
      child: ListTile(
        title: Text('${horario.veiculo.marca} - ${horario.veiculo.modelo}'),
        subtitle: Text('$dataFormatada - Serviço: ${horario.servico}'),
        trailing: IconButton(
          icon: Icon(Icons.cancel),
          onPressed: onCancelar,
        ),
      ),
    );
  }
}