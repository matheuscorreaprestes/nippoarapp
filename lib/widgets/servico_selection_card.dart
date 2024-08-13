import 'package:flutter/material.dart';

class ServicoSelectionDialog extends StatelessWidget {
  final Function(String) onServicoSelected;

  ServicoSelectionDialog({required this.onServicoSelected});

  @override
  Widget build(BuildContext context) {
    final List<String> servicos = [
      'Lavagem Simples',
      'Lavagem Completa',
      'Polimento',
    ];

    return AlertDialog(
      title: Text('Selecione o Serviço'),
      content: SingleChildScrollView(
        child: Column(
          children: servicos.map((servico) {
            return ListTile(
              title: Text(servico),
              onTap: () {
                onServicoSelected(servico);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
