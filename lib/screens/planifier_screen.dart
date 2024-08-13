import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/planifier_model.dart';
import '../widgets/horario_card.dart';
import '../widgets/servico_selection_card.dart';
import '../widgets/calendario_widget.dart';

class AgendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Horário'),
      ),
      body: ScopedModelDescendant<AgendarModel>(
        builder: (context, child, agendarModel) {
          return agendarModel.agendamentos.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Não há horários marcados'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _navegarParaAgendamento(context);
                  },
                  child: Text('Agendar'),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: agendarModel.agendamentos.length,
            itemBuilder: (context, index) {
              final horario = agendarModel.agendamentos[index];
              return HorarioCard(
                horario: horario,
                onCancelar: () {
                  agendarModel.cancelarAgendamento(horario);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _navegarParaAgendamento(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgendarHorarioScreen(),
      ),
    );
  }
}

class AgendarHorarioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final agendarModel = ScopedModel.of<AgendarModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Horário'),
      ),
      body: Column(
        children: [
          _selecionarVeiculo(context, agendarModel),
          _selecionarDataHora(context, agendarModel),
          _selecionarServico(context, agendarModel),
          _mostrarConfirmacao(context, agendarModel),
        ],
      ),
    );
  }

  Widget _selecionarVeiculo(BuildContext context, AgendarModel model) {
    return DropdownButton<Veiculo>(
      hint: Text('Selecione o veículo'),
      value: model.veiculoSelecionado,
      onChanged: (veiculo) {
        model.selecionarVeiculo(veiculo!);
      },
      items: [
        Veiculo(nome: 'Carro 1', placa: 'ABC-1234'),
        Veiculo(nome: 'Carro 2', placa: 'XYZ-5678'),
      ].map((veiculo) {
        return DropdownMenuItem(
          value: veiculo,
          child: Text('${veiculo.nome} - ${veiculo.placa}'),
        );
      }).toList(),
    );
  }

  Widget _selecionarDataHora(BuildContext context, AgendarModel model) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                model.selecionarData(DateTime.now());
                model.selecionarHora(TimeOfDay.now());
              },
              child: Text('Hoje'),
            ),
            ElevatedButton(
              onPressed: () {
                model.selecionarData(DateTime.now().add(Duration(days: 1)));
                model.selecionarHora(TimeOfDay.now());
              },
              child: Text('Amanhã'),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CalendarioWidget(
                    onDateSelected: (date) {
                      model.selecionarData(date);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
              child: Text('Outro dia'),
            ),
          ],
        ),
        if (model.dataSelecionada != null)
          Text('Data: ${model.dataSelecionada!.toLocal()}'),
        if (model.horaSelecionada != null)
          Text('Hora: ${model.horaSelecionada!.format(context)}'),
      ],
    );
  }

  Widget _selecionarServico(BuildContext context, AgendarModel model) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ServicoSelectionDialog(
            onServicoSelected: (servico) {
              model.selecionarServico(servico);
            },
          ),
        );
      },
      child: Text('Selecionar Serviço'),
    );
  }

  Widget _mostrarConfirmacao(BuildContext context, AgendarModel model) {
    return model.veiculoSelecionado != null &&
        model.dataSelecionada != null &&
        model.horaSelecionada != null &&
        model.servicoSelecionado != null
        ? ElevatedButton(
      onPressed: () {
        final novoHorario = Horario(
          data: model.dataSelecionada!,
          veiculo: model.veiculoSelecionado!.nome,
          placa: model.veiculoSelecionado!.placa,
          servico: model.servicoSelecionado!,
        );
        model.adicionarAgendamento(novoHorario);
        Navigator.pop(context); // Voltar para a tela principal
      },
      child: Text('Confirmar Agendamento'),
    )
        : SizedBox.shrink();
  }
}
