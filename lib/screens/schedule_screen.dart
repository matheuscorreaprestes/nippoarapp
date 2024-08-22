import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/models/schedule_model.dart';
import 'package:nippoarapp/models/vehicle_model.dart';
import 'package:nippoarapp/screens/vehicle_register_screen.dart';
import 'package:nippoarapp/widgets/servico_selection_card.dart';
import 'package:scoped_model/scoped_model.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  TimeOfDay? horarioSelecionado;

  @override
  Widget build(BuildContext context) {
    final agendarModel = ScopedModel.of<ScheduleModel>(context);
    final vehicleModel = ScopedModel.of<VehicleModel>(context);
    final userModel = ScopedModel.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Horário'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
      child:FutureBuilder(
        future: vehicleModel.getVehicles(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar veículos'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Não há veículos cadastrados'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => VehicleRegisterScreen()),
                      );
                    },
                    child: Text('Cadastrar Veículo'),
                  ),
                ],
              ),
            );
          } else {
            final vehicles = snapshot.data!.docs.map((doc) {
              return Veiculo(
                marca: doc['marca'],
                modelo: doc['modelo'],
                placa: doc['placa'],
              );
            }).toList();

            return Column(
              children: [
                _selecionarVeiculo(context, agendarModel, vehicles),
                _selecionarDataHora(context, agendarModel),
                _selecionarHorarios(context, agendarModel),
                _selecionarServico(context, agendarModel),
                _mostrarConfirmacao(context, agendarModel, userModel),
              ],
            );
          }
        },
       ),
      ),
    );
  }

  Widget _selecionarVeiculo(BuildContext context, ScheduleModel model, List<Veiculo> veiculos) {
    return DropdownButton<Veiculo>(
      hint: Text('Selecione o veículo'),
      value: model.veiculoSelecionado,
      onChanged: (veiculo) {
        setState(() {
          model.selecionarVeiculo(veiculo!);
        });
      },
      items: veiculos.map((veiculo) {
        return DropdownMenuItem(
          value: veiculo,
          child: Text('${veiculo.modelo} - ${veiculo.placa}'),
        );
      }).toList(),
    );
  }

  Widget _selecionarDataHora(BuildContext context, ScheduleModel model) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  model.selecionarData(DateTime.now());
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (model.dataSelecionada != null &&
                      model.dataSelecionada!.day == DateTime.now().day &&
                      model.dataSelecionada!.month == DateTime.now().month &&
                      model.dataSelecionada!.year == DateTime.now().year) {
                    return Colors.grey;
                  }
                  return Theme.of(context).primaryColor;
                }),
              ),
              child: Text(
                'Hoje',
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  model.selecionarData(DateTime.now().add(Duration(days: 1)));
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (model.dataSelecionada != null &&
                      model.dataSelecionada!.day ==
                          DateTime.now().add(Duration(days: 1)).day) {
                    return Colors.grey;
                  }
                  return Theme.of(context).primaryColor;
                }),
              ),
              child: Text(
                'Amanhã',
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  setState(() {
                    model.selecionarData(selectedDate);
                  });
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (model.dataSelecionada != null &&
                      model.dataSelecionada!.day == DateTime.now().day) {
                    return Colors.grey;
                  }
                  return Theme.of(context).primaryColor;
                }),
              ),
              child: Text(
                'Outro dia',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _selecionarHorarios(BuildContext context, ScheduleModel model) {
    if (model.dataSelecionada == null) {
      return SizedBox.shrink();
    }

    if (model.dataSelecionada!.weekday == DateTime.sunday) {
      return Center(child: Text('Não é possível agendar aos domingos.'));
    }

    return Column(
      children: [
        horarioSelecionado != null
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Horário Selecionado: ${horarioSelecionado!.format(context)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        )
            : Container(),
        Column(
          children: model.horariosDisponiveis.map((hora) {
            final isDisponivel = !model.agendamentos.any((agendamento) =>
            agendamento.data.day == model.dataSelecionada!.day &&
                agendamento.data.month == model.dataSelecionada!.month &&
                agendamento.data.year == model.dataSelecionada!.year &&
                agendamento.data.hour == hora.hour &&
                agendamento.data.minute == hora.minute);

            return ListTile(
              title: Text('Horário: ${hora.format(context)}'),
              tileColor:
              isDisponivel ? Colors.grey : Theme.of(context).primaryColor,
              onTap: isDisponivel
                  ? () {
                setState(() {
                  horarioSelecionado = hora;
                  model.selecionarHora(hora);  // Salva o horário selecionado no model
                });
              }
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _selecionarServico(BuildContext context, ScheduleModel model) {
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
      child: Text(
        'Selecionar Serviço',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _mostrarConfirmacao(BuildContext context, ScheduleModel model, UserModel userModel) {
    return model.veiculoSelecionado != null &&
        model.dataSelecionada != null &&
        model.horaSelecionada != null &&
        model.servicoSelecionado != null
        ? ElevatedButton(
      onPressed: () async {
        final nomeCliente = userModel.userData['name'] ?? 'Nome do cliente'; // Substitua pelo nome do cliente autenticado
        final novoHorario = Horario(
          data: DateTime(
            model.dataSelecionada!.year,
            model.dataSelecionada!.month,
            model.dataSelecionada!.day,
            model.horaSelecionada!.hour,
            model.horaSelecionada!.minute,
          ),
          veiculo: model.veiculoSelecionado!,
          servico: model.servicoSelecionado!,
        );

        // Chama o método para adicionar o agendamento e salva no Firestore
        await model.adicionarAgendamento(novoHorario, nomeCliente);

        // Fecha a tela de horários após confirmar
        Navigator.pop(context);
      },
      child: Text('Confirmar Agendamento'),
    )
        : SizedBox.shrink();
  }

}
