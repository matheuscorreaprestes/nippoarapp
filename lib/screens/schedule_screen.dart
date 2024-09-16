import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nippoarapp/models/servico_model.dart';
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

extension DateTimeExtensions on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  TimeOfDay? horarioSelecionado; // Variável de instância para o horário selecionado

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
        child: FutureBuilder(
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VehicleRegisterScreen(),
                          ),
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
                  _selecionarDataHora(context, agendarModel, userModel),
                  ScopedModelDescendant<ScheduleModel>(
                    builder: (context, child, model) {
                      return _selecionarHorarios(context, model, userModel);
                    },
                  ),
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

  Widget _selecionarDataHora(BuildContext context, ScheduleModel model, UserModel userModel) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  String userId = userModel.currentUser!.uid;
                  model.selecionarData(DateTime.now(), userId);
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (model.dataSelecionada != null &&
                      model.dataSelecionada!.isSameDate(DateTime.now())) {
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
                  String userId = userModel.currentUser!.uid;
                  model.selecionarData(DateTime.now().add(Duration(days: 1)), userId);
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (model.dataSelecionada != null &&
                      model.dataSelecionada!.isSameDate(DateTime.now().add(Duration(days: 1)))) {
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
                    String userId = userModel.currentUser!.uid;
                    model.selecionarData(selectedDate, userId);
                  });
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return model.dataSelecionada != null &&
                      model.dataSelecionada!.isSameDate(model.dataSelecionada!)
                      ? Colors.grey
                      : Theme.of(context).primaryColor;
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

  Widget _selecionarHorarios(BuildContext context, ScheduleModel model, UserModel userModel) {
    if (model.dataSelecionada == null) {
      return Center(child: Text('Selecione uma data primeiro.'));
    }

    if (model.horariosDisponiveis.isEmpty) {
      return Text(
        'Sem horários disponíveis',
        style: TextStyle(color: Colors.red),
      );
    } else {
      model.ordenarHorarios();
      return Column(
        children: model.horariosDisponiveis.map((horario) {
          return ListTile(
            title: Text(horario.format(context)),
            trailing: Radio<TimeOfDay>(
              value: horario,
              groupValue: horarioSelecionado,
              onChanged: (TimeOfDay? value) {
                setState(() {
                  horarioSelecionado = value!;
                  model.selecionarHora(value);
                });
              },
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _selecionarServico(BuildContext context, ScheduleModel model) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ServicoSelectionDialog(
            onServicoSelected: (Servico servico) {
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



  Widget _mostrarConfirmacao(BuildContext context, ScheduleModel agendarModel, UserModel userModel) {
    return ElevatedButton(
      onPressed: () async {
        final nomeCliente = userModel.userData['name'] ?? 'Nome do cliente';
        final userId = userModel.currentUser!.uid;
        if (agendarModel.veiculoSelecionado != null &&
            agendarModel.dataSelecionada != null &&
            agendarModel.horaSelecionada != null &&
            agendarModel.servicoSelecionado != null) {

          DateTime dataAgendada = DateTime(
            agendarModel.dataSelecionada!.year,
            agendarModel.dataSelecionada!.month,
            agendarModel.dataSelecionada!.day,
            agendarModel.horaSelecionada!.hour,
            agendarModel.horaSelecionada!.minute,
          );

          double valorServico = agendarModel.valorServicoSelecionado ?? 0.0;

          Horario novoHorario = Horario(
            data: dataAgendada,
            veiculo: agendarModel.veiculoSelecionado!,
            nomeCliente: nomeCliente,
            userId: userId,
            servico: agendarModel.servicoSelecionado!,
            valorServico: valorServico,
          );

          await agendarModel.adicionarAgendamento(novoHorario, nomeCliente, userId);
          setState(() {
            horarioSelecionado = null;
            agendarModel.resetarSelecoes();
          });

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Confirmação'),
              content: Text('Horário agendado com sucesso!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Erro'),
              content: Text('Por favor, selecione todos os campos.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      },

      child: Text('Confirmar Agendamento',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}
