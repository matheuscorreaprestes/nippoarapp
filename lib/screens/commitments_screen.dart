import 'package:flutter/material.dart';
import 'package:nippoarapp/screens/schedule_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:nippoarapp/models/schedule_model.dart';
import 'package:nippoarapp/widgets/horario_card.dart';

class CommitmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Compromissos'),
        centerTitle: true,
      ),
      body: ScopedModelDescendant<ScheduleModel>(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleScreen(),
                      ),
                    );
                  },
                  child: Text('Agendar',
                    style: TextStyle(
                        color: Colors.black,
                        backgroundColor: Theme.of(context).primaryColor
                    ),
                  ),
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

}

