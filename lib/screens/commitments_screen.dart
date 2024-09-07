import 'package:flutter/material.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/screens/schedule_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:nippoarapp/models/schedule_model.dart';
import 'package:nippoarapp/widgets/horario_card.dart';

class CommitmentsScreen extends StatefulWidget {
  @override
  _CommitmentsScreenState createState() => _CommitmentsScreenState();
}

class _CommitmentsScreenState extends State<CommitmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ScopedModel.of<UserModel>(context, rebuildOnChange: false).currentUser!.uid;
      ScopedModel.of<ScheduleModel>(context, rebuildOnChange: false).carregarAgendamentosDoCliente(userId);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Compromissos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ScopedModelDescendant<ScheduleModel>(
              builder: (context, child, agendarModel) {
                return agendarModel.agendamentos.isEmpty
                    ? Center(
                  child: Text('Não há horários marcados'),
                )
                    : ListView.builder(
                  itemCount: agendarModel.agendamentos.length,
                  itemBuilder: (context, index) {
                    final horario = agendarModel.agendamentos[index];
                    return HorarioCard(
                      horario: horario,
                      onCancelar: () {
                        agendarModel.cancelarAgendamento(horario, horario.userId);
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleScreen(),
                  ),
                );
              },
              child: Text(
                'Agendar',
                style: TextStyle(color: Colors.black),
              ),
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(Theme.of(context).primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

}