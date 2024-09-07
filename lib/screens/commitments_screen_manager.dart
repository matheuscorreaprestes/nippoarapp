import 'package:flutter/material.dart';
import 'package:nippoarapp/models/schedule_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:nippoarapp/widgets/horario_card_manager.dart';

class CommitmentsScreenManager extends StatefulWidget {
  @override
  _CommitmentsScreenManagerState createState() => _CommitmentsScreenManagerState();
}

class _CommitmentsScreenManagerState extends State<CommitmentsScreenManager> {
  DateTime selectedDate = DateTime.now();
  Future<void>? _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _carregarHorariosDoManager(selectedDate);
  }

  Future<void> _carregarHorariosDoManager(DateTime date) async {
    final scheduleModel = ScopedModel.of<ScheduleModel>(context, rebuildOnChange: true);
    try {
      // Usar o novo método carregarHorariosManager
      await scheduleModel.carregarHorariosManager(date);
      print("Dados carregados com sucesso para a data: $date");
    } catch (error) {
      print("Erro ao carregar horários: $error");
      // Atribui um future falhado para re-renderizar a UI
      setState(() {
        _loadFuture = Future.error(error);
      });
    }
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      selectedDate = date;
      _loadFuture = _carregarHorariosDoManager(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compromissos do Gestor'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Row de botões para selecionar a data
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _onDateChanged(DateTime.now()),
                child: Text('Hoje'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _onDateChanged(DateTime.now().add(Duration(days: 1))),
                child: Text('Amanhã'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    _onDateChanged(pickedDate);
                  }
                },
                child: Text('Outro Dia'),
              ),
            ],
          ),
          // FutureBuilder para exibir os dados ou mensagens de erro/carregamento
          Expanded(
            child: FutureBuilder<void>(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Exibe o erro, mas os botões permanecem habilitados
                  return Center(child: Text('Erro ao carregar os dados.'));
                } else {
                  // Exibe os compromissos usando ScopedModelDescendant
                  return ScopedModelDescendant<ScheduleModel>(
                    rebuildOnChange: true,
                    builder: (context, child, scheduleModel) {
                      if (scheduleModel.agendamentos.isEmpty) {
                        return Center(
                          child: Text('Não há horários marcados'),
                        );
                      }

                      return ListView.builder(
                        itemCount: scheduleModel.agendamentos.length,
                        itemBuilder: (context, index) {
                          final horario = scheduleModel.agendamentos[index];
                          return HorarioCardManager(
                            horario: horario,
                            onCancelar: () => scheduleModel.cancelarAgendamento(horario, horario.userId),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
