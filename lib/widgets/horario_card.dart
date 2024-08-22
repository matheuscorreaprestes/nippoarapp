import 'package:flutter/material.dart';
import 'package:nippoarapp/models/schedule_model.dart';

class HorarioCard extends StatelessWidget {
  final Horario horario;
  final VoidCallback onCancelar;

  HorarioCard({required this.horario, required this.onCancelar});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${horario.veiculo} - ${horario.veiculo}'),
        subtitle: Text(
            '${horario.data.toLocal()} - Serviço: ${horario.servico}'),
        trailing: IconButton(
          icon: Icon(Icons.cancel),
          onPressed: onCancelar,
        ),
      ),
    );
  }
}
