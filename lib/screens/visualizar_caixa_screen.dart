import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nippoarapp/models/caixa_model.dart';
import 'package:scoped_model/scoped_model.dart';

class VisualizarCaixaScreen extends StatefulWidget {
  @override
  _VisualizarCaixaScreenState createState() => _VisualizarCaixaScreenState();
}

class _VisualizarCaixaScreenState extends State<VisualizarCaixaScreen> {
  bool _dadosCarregados = false;

  @override
  void initState() {
    super.initState();
    _carregarDados(); // Carregar receitas e despesas ao iniciar a tela
  }

  void _carregarDados() {
    final model = ScopedModel.of<RegistroCaixaModel>(context, rebuildOnChange: false);
    if (!_dadosCarregados) {
      model.carregarReceitas().then((_) {
        model.carregarDespesas().then((_) {
          setState(() {
            _dadosCarregados = true;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<RegistroCaixaModel>(
      builder: (context, child, model) {
        double totalReceitas = model.receitas.fold(0, (sum, item) => sum + item.valor);
        double totalDespesas = model.despesas.fold(0, (sum, item) => sum + item.valor);
        double saldo = totalReceitas - totalDespesas;

        return Scaffold(
          appBar: AppBar(
            title: Text('Balanço do Caixa'),
          ),
          body: !_dadosCarregados || model.isLoading
              ? Center(child: CircularProgressIndicator()) // Exibir o indicador de loading enquanto os dados são carregados
              : Column(
            children: [
              Expanded(
                child: PageView(
                  children: [
                    _buildBarChart(totalReceitas, totalDespesas),
                    _buildPieChart(totalReceitas, totalDespesas),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildSaldoResumo(saldo, totalReceitas, totalDespesas),
              Divider(),
              Expanded(child: _buildReceitasDespesasList(model)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarChart(double totalReceitas, double totalDespesas) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(
                toY: totalReceitas, // Total de receitas
                color: Colors.green,
                width: 30,
                borderRadius: BorderRadius.circular(4),
              )
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                toY: totalDespesas, // Total de despesas
                color: Colors.red,
                width: 30,
                borderRadius: BorderRadius.circular(4),
              )
            ]),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('Receitas');
                    case 1:
                      return Text('Despesas');
                    default:
                      return Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(double totalReceitas, double totalDespesas) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: totalReceitas,
              color: Colors.green,
              title: 'Receitas',
              radius: 100,
              titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: totalDespesas,
              color: Colors.red,
              title: 'Despesas',
              radius: 100,
              titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
          sectionsSpace: 4,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildSaldoResumo(double saldo, double totalReceitas, double totalDespesas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saldo Total: R\$ ${saldo.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: saldo >= 0 ? Colors.green : Colors.red,
          ),
        ),
        SizedBox(height: 10),
        Text('Total de Receitas: R\$ ${totalReceitas.toStringAsFixed(2)}'),
        Text('Total de Despesas: R\$ ${totalDespesas.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildReceitasDespesasList(RegistroCaixaModel model) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Receitas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ...model.receitas.map((receita) => ListTile(
          title: Text(receita.descricao),
          subtitle: Text('Valor: R\$ ${receita.valor.toStringAsFixed(2)}'),
          trailing: Text('Data: ${receita.data.toLocal()}'),
        )),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Despesas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ...model.despesas.map((despesa) => ListTile(
          title: Text(despesa.descricao),
          subtitle: Text('Valor: R\$ ${despesa.valor.toStringAsFixed(2)}'),
          trailing: Text('Data: ${despesa.data.toLocal()}'),
        )),
      ],
    );
  }
}
