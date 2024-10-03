import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/models/caixa_model.dart'; // Importar o modelo

class RegistroCaixaScreen extends StatefulWidget {
  @override
  _RegistroCaixaScreenState createState() => _RegistroCaixaScreenState();
}

class _RegistroCaixaScreenState extends State<RegistroCaixaScreen> {
  final _receitaDescricaoController = TextEditingController();
  final _receitaValorController = TextEditingController();
  final _despesaDescricaoController = TextEditingController();
  final _despesaValorController = TextEditingController();

  // Instância do modelo
  final RegistroCaixaModel _registroCaixaModel = RegistroCaixaModel();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (context, child, model) {
        // Verificar se o usuário é um gestor
        if (model.userType != 'manager') {
          return Scaffold(
            appBar: AppBar(title: Text('Acesso Negado')),
            body: Center(
                child: Text('Apenas gestores têm acesso a esta página.')),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Registro de Caixa'),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Receitas'),
                  Tab(text: 'Despesas'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildReceitaTab(context),
                _buildDespesaTab(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _buscarServicosConcluidos() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('servicos_concluidos')
        .orderBy('data', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id, // Adicionar o ID do documento para deletar depois
      ...doc.data() as Map<String, dynamic>
    }).toList();
  }

  // Função para deletar o documento da coleção "servicos_concluidos"
  Future<void> _deletarServicoConcluido(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('servicos_concluidos')
          .doc(id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Serviço removido da lista de concluídos.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover o serviço: $e')),
      );
    }
  }

  Widget _buildReceitaTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _receitaDescricaoController,
            decoration: InputDecoration(labelText: 'Descrição da Receita'),
          ),
          TextField(
            controller: _receitaValorController,
            decoration: InputDecoration(labelText: 'Valor'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _adicionarReceita(context),
            child: Text('Adicionar Receita', style: TextStyle(color: Colors.black)),
          ),
          SizedBox(height: 20),
          Text(
            'Sugestões de Serviços Concluídos:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _buscarServicosConcluidos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<Map<String, dynamic>> servicos = snapshot.data!;

                if (servicos.isEmpty) {
                  return Text('Nenhum serviço concluído.');
                }

                return ListView.builder(
                  itemCount: servicos.length,
                  itemBuilder: (context, index) {
                    var servico = servicos[index];
                    return ListTile(
                      title: Text(servico['descricao']),
                      subtitle: Text(
                          'Veículo: ${servico['modelo_veiculo']} - Placa: ${servico['placa_veiculo']}'),
                      trailing: Text(
                          'R\$ ${servico['valor'].toStringAsFixed(2)}'),
                      onTap: () {
                        // Preencher automaticamente os campos de receita
                        setState(() {
                          _receitaDescricaoController.text = servico['descricao'];
                          _receitaValorController.text = servico['valor'].toString();
                        });
                        // Remover o serviço da coleção servicos_concluidos
                        _deletarServicoConcluido(servico['id']);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDespesaTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _despesaDescricaoController,
            decoration: InputDecoration(labelText: 'Descrição da Despesa'),
          ),
          TextField(
            controller: _despesaValorController,
            decoration: InputDecoration(labelText: 'Valor'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _adicionarDespesa(context),
            child: Text('Adicionar Despesa'),
          ),
        ],
      ),
    );
  }

  // Adicionar receita
  void _adicionarReceita(BuildContext context) async {
    String descricao = _receitaDescricaoController.text;

    // Substituir vírgulas por pontos para garantir o formato correto
    String valorText = _receitaValorController.text.replaceAll(',', '.');
    double valor = double.tryParse(valorText) ?? 0.0;

    try {
      await _registroCaixaModel.adicionarReceita(descricao, valor);
      _receitaDescricaoController.clear();
      _receitaValorController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receita adicionada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar receita: $e')),
      );
    }
  }

  // Adicionar despesa
  void _adicionarDespesa(BuildContext context) async {
    String descricao = _despesaDescricaoController.text;

    // Substituir vírgulas por pontos para garantir o formato correto
    String valorText = _despesaValorController.text.replaceAll(',', '.');
    double valor = double.tryParse(valorText) ?? 0.0;

    try {
      await _registroCaixaModel.adicionarDespesa(descricao, valor);
      _despesaDescricaoController.clear();
      _despesaValorController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Despesa adicionada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar despesa: $e')),
      );
    }
  }
}
