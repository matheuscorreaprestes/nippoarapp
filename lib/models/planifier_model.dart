import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class AgendarModel extends Model {
  // Lista de horários agendados
  List<Horario> agendamentos = [];

  // Horário selecionado para cancelamento
  Horario? horarioSelecionado;

  // Veículo selecionado para agendamento
  Veiculo? veiculoSelecionado;

  // Data e hora selecionadas
  DateTime? dataSelecionada;
  TimeOfDay? horaSelecionada;

  // Serviço selecionado
  String? servicoSelecionado;

  // Adiciona um novo agendamento
  void adicionarAgendamento(Horario horario) {
    agendamentos.add(horario);
    notifyListeners();
  }

  // Cancela um agendamento
  void cancelarAgendamento(Horario horario) {
    agendamentos.remove(horario);
    notifyListeners();
  }

  // Atualiza o horário selecionado
  void selecionarHorario(Horario horario) {
    horarioSelecionado = horario;
    notifyListeners();
  }

  // Define o veículo selecionado
  void selecionarVeiculo(Veiculo veiculo) {
    veiculoSelecionado = veiculo;
    notifyListeners();
  }

  // Define a data selecionada
  void selecionarData(DateTime data) {
    dataSelecionada = data;
    notifyListeners();
  }

  // Define o horário selecionado
  void selecionarHora(TimeOfDay hora) {
    horaSelecionada = hora;
    notifyListeners();
  }

  // Define o serviço selecionado
  void selecionarServico(String servico) {
    servicoSelecionado = servico;
    notifyListeners();
  }
}

// Modelos auxiliares
class Horario {
  final DateTime data;
  final String veiculo;
  final String placa;
  final String servico;

  Horario({
    required this.data,
    required this.veiculo,
    required this.placa,
    required this.servico,
  });
}

class Veiculo {
  final String nome;
  final String placa;

  Veiculo({required this.nome, required this.placa});
}
