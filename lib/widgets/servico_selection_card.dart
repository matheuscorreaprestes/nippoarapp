import 'package:flutter/material.dart';
import 'package:nippoarapp/models/servico_model.dart';

class ServicoSelectionDialog extends StatelessWidget {
  final Function(Servico) onServicoSelected; // Alterado para aceitar um objeto Servico

  ServicoSelectionDialog({required this.onServicoSelected});

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
                return ListTile(
                  title: Text(servico.nome),
                  subtitle: Text('R\$ ${servico.preco.toStringAsFixed(2)}'),
                  onTap: () {
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
