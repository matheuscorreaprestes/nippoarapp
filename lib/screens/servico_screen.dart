import 'package:flutter/material.dart';
import 'package:nippoarapp/models/servico_model.dart';

class GerenciarServicosScreen extends StatefulWidget {
  @override
  _GerenciarServicosScreenState createState() => _GerenciarServicosScreenState();
}

class _GerenciarServicosScreenState extends State<GerenciarServicosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Serviços'),
      ),
      body: StreamBuilder<List<Servico>>(
        stream: listarServicos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final servicos = snapshot.data!;
          return ListView.builder(
            itemCount: servicos.length,
            itemBuilder: (context, index) {
              final servico = servicos[index];
              return ListTile(
                title: Text(servico.nome),
                subtitle: Text('R\$ ${servico.preco.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => removerServico(servico.id),
                ),
                onTap: () {
                  // Navegar para a tela de edição de serviço
                  _mostrarDialogoEditarServico(servico);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Abrir diálogo para adicionar um novo serviço
          _mostrarDialogoAdicionarServico();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoAdicionarServico() {
    final nomeController = TextEditingController();
    final precoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar Serviço'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome do Serviço'),
            ),
            TextField(
              controller: precoController,
              decoration: InputDecoration(labelText: 'Preço do Serviço'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nome = nomeController.text;
              final preco = double.tryParse(precoController.text) ?? 0.0;
              final servico = Servico(id: '', nome: nome, preco: preco);
              adicionarServico(servico);
              Navigator.of(context).pop();
            },
            child: Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditarServico(Servico servico) {
    final nomeController = TextEditingController(text: servico.nome);
    final precoController = TextEditingController(text: servico.preco.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Serviço'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome do Serviço'),
            ),
            TextField(
              controller: precoController,
              decoration: InputDecoration(labelText: 'Preço do Serviço'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nome = nomeController.text;
              final preco = double.tryParse(precoController.text) ?? 0.0;
              servico.nome = nome;
              servico.preco = preco;
              editarServico(servico);
              Navigator.of(context).pop();
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
