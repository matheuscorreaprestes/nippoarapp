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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Baixo: R\$ ${servico.precoBaixo.toStringAsFixed(2)}'),
                    Text('Médio: R\$ ${servico.precoMedio.toStringAsFixed(2)}'),
                    Text('Alto: R\$ ${servico.precoAlto.toStringAsFixed(2)}'),
                  ],
                ),
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
    final precoBaixoController = TextEditingController();
    final precoMedioController = TextEditingController();
    final precoAltoController = TextEditingController();

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
              controller: precoBaixoController,
              decoration: InputDecoration(labelText: 'Preço para carro Baixo'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: precoMedioController,
              decoration: InputDecoration(labelText: 'Preço para carro Médio'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: precoAltoController,
              decoration: InputDecoration(labelText: 'Preço para carro Alto'),
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
              final precoBaixo = double.tryParse(precoBaixoController.text) ?? 0.0;
              final precoMedio = double.tryParse(precoMedioController.text) ?? 0.0;
              final precoAlto = double.tryParse(precoAltoController.text) ?? 0.0;

              final servico = Servico(
                id: '',
                nome: nome,
                precoBaixo: precoBaixo,
                precoMedio: precoMedio,
                precoAlto: precoAlto,
                clienteToken: '',
              );
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
    final precoBaixoController = TextEditingController(text: servico.precoBaixo.toString());
    final precoMedioController = TextEditingController(text: servico.precoMedio.toString());
    final precoAltoController = TextEditingController(text: servico.precoAlto.toString());

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
              controller: precoBaixoController,
              decoration: InputDecoration(labelText: 'Preço para carro Baixo'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: precoMedioController,
              decoration: InputDecoration(labelText: 'Preço para carro Médio'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: precoAltoController,
              decoration: InputDecoration(labelText: 'Preço para carro Alto'),
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
              final precoBaixo = double.tryParse(precoBaixoController.text) ?? 0.0;
              final precoMedio = double.tryParse(precoMedioController.text) ?? 0.0;
              final precoAlto = double.tryParse(precoAltoController.text) ?? 0.0;

              servico.nome = nome;
              servico.precoBaixo = precoBaixo;
              servico.precoMedio = precoMedio;
              servico.precoAlto = precoAlto;
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
