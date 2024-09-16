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

  void _showConfirmationDialog(Horario horario, ScheduleModel scheduleModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Serviço'),
          content: Text('Você realmente gostaria de confirmar que o serviço foi concluído?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                scheduleModel.confirmarAgendamento(horario, horario.userId); // Confirma o agendamento
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
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
                child: Text('Hoje',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _onDateChanged(DateTime.now().add(Duration(days: 1))),
                child: Text('Amanhã',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
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
                child: Text('Outro Dia',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
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
                            onConfirmar: () => _showConfirmationDialog(horario, scheduleModel), // Função para confirmar o agendamento
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
