import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ScheduleModel extends Model {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Horario> agendamentos = [];
  List<TimeOfDay> horariosDisponiveis = [];

  Veiculo? veiculoSelecionado;
  DateTime? dataSelecionada;
  TimeOfDay? horaSelecionada;
  String? servicoSelecionado;

  // Método para adicionar um agendamento e salvá-lo no Firestore
  Future<void> adicionarAgendamento(Horario horario, String nomeCliente) async {
    // Adiciona localmente
    agendamentos.add(horario);
    notifyListeners();

    // Salva no Firestore
    await _firestore.collection('agendamentos').add({
      'nomeCliente': nomeCliente,
      'data': horario.data,
      'veiculo': {
        'marca': horario.veiculo.marca,
        'modelo': horario.veiculo.modelo,
        'placa': horario.veiculo.placa,
      },
      'servico': horario.servico,
    });
  }

  void cancelarAgendamento(Horario horario) {
    agendamentos.remove(horario);
    notifyListeners();
  }

  void selecionarVeiculo(Veiculo veiculo) {
    veiculoSelecionado = veiculo;
    notifyListeners();
  }

  void selecionarData(DateTime data) {
    dataSelecionada = data;
    carregarHorariosDisponiveis(data);
    notifyListeners();
  }

  void selecionarHora(TimeOfDay hora) {
    horaSelecionada = hora;
    notifyListeners();
  }

  void selecionarServico(String servico) {
    servicoSelecionado = servico;
    notifyListeners();
  }

  void carregarHorariosDisponiveis(DateTime data) {
    horariosDisponiveis.clear();

    if (data.weekday == DateTime.sunday) {
      notifyListeners();
      return;
    }

    int startHour = 8;
    int endHour = (data.weekday == DateTime.saturday) ? 14 : 16;

    for (int i = startHour; i <= endHour; i++) {
      horariosDisponiveis.add(TimeOfDay(hour: i, minute: 0));
    }

    agendamentos.forEach((horario) {
      if (horario.data.day == data.day &&
          horario.data.month == data.month &&
          horario.data.year == data.year) {
        horariosDisponiveis.removeWhere(
                (h) => h.hour == horario.data.hour && h.minute == horario.data.minute);
      }
    });

    notifyListeners();
  }
}

class Horario {
  final DateTime data;
  final Veiculo veiculo;
  final String servico;

  Horario({
    required this.data,
    required this.veiculo,
    required this.servico,
  });

}

class Veiculo {
  final String marca;
  final String modelo;
  final String placa;

  Veiculo({
    required this.marca,
    required this.modelo,
    required this.placa,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Veiculo &&
              runtimeType == other.runtimeType &&
              marca == other.marca &&
              modelo == other.modelo &&
              placa == other.placa;

  @override
  int get hashCode => marca.hashCode ^ modelo.hashCode ^ placa.hashCode;
}

