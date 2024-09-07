import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nippoarapp/models/servico_model.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class ScheduleModel extends Model {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  List<Horario> agendamentos = [];
  List<TimeOfDay> horariosDisponiveis = [];

  Veiculo? veiculoSelecionado;
  DateTime? dataSelecionada;
  TimeOfDay? horaSelecionada;
  String? servicoSelecionado;
  double? valorServicoSelecionado;

  // Método para carregar agendamentos do cliente
  Future<void> carregarAgendamentosDoCliente(String userId) async {
    try {
      agendamentos.clear();
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('agendamentos')
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
        DateTime data = DateTime.parse(doc.get('data'));
        String horaString = doc.get('hora');
        List<String> partesHora = horaString.split(':');
        TimeOfDay hora = TimeOfDay(
          hour: int.parse(partesHora[0]),
          minute: int.parse(partesHora[1]),
        );

        agendamentos.add(Horario(
          data: DateTime(
            data.year,
            data.month,
            data.day,
            hora.hour,
            hora.minute,
          ),
          veiculo: Veiculo(
            marca: doc.get('veiculo.marca') ?? 'Desconhecida',
            modelo: doc.get('veiculo.modelo') ?? 'Desconhecido',
            placa: doc.get('veiculo.placa') ?? 'Desconhecida',
          ),
          servico: doc.get('servico') ?? 'Não especificado',
          nomeCliente: doc.get('nomeCliente') ?? 'Não especificado',
          userId: doc.get('userId') ?? 'Não especificado',
          valorServico: doc.get('valorServico') ?? null,
        ));
      }
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar agendamentos: $e');
    }
  }

  // Método consolidado para carregar horários disponíveis
  Future<void> carregarHorariosDisponiveis(DateTime dataSelecionada) async {
    String dataFormatada = DateFormat('yyyyMMdd').format(dataSelecionada);
    List<String> todosHorarios = ["08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00"];
    horariosDisponiveis.clear();

    try {
      QuerySnapshot agendamentosSnapshot = await _firestore
          .collection('agendamentos')
          .doc(dataFormatada)
          .collection('horarios')
          .get();

      if (agendamentosSnapshot.docs.isEmpty) {
        print("Nenhum horário encontrado para a data: $dataFormatada");
      } else {
        for (var doc in agendamentosSnapshot.docs) {
          print("Horário encontrado: ${doc.id}, dados: ${doc.data()}");
        }
      }

      Set<String> horariosAgendados = agendamentosSnapshot.docs
          .map((doc) => doc.get('hora') as String)
          .toSet();

      for (String horario in todosHorarios) {
        if (!horariosAgendados.contains(horario)) {
          horariosDisponiveis.add(_convertStringToTimeOfDay(horario));
        }
      }

      // Verificar se horários disponíveis estão sendo carregados corretamente
      print("Horários disponíveis: $horariosDisponiveis");
    } catch (e) {
      print("Erro ao carregar horários disponíveis: $e");
    }

    notifyListeners();
  }

  TimeOfDay _convertStringToTimeOfDay(String horario) {
    final partes = horario.split(':');
    final int horas = int.parse(partes[0]);
    final int minutos = int.parse(partes[1]);
    return TimeOfDay(hour: horas, minute: minutos);
  }

  List<TimeOfDay> _gerarTodosHorarios() {
    List<TimeOfDay> horarios = [];
    for (int hour = 8; hour <= 16; hour++) {
      for (int minute = 0; minute < 60; minute += 60) {
        horarios.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
    return horarios;
  }


// Método para carregar agendamentos para o gestor (userType = manager)
  Future<void> carregarHorariosManager(DateTime dataSelecionada) async {
    String dataFormatada = DateFormat('yyyyMMdd').format(dataSelecionada);
    agendamentos.clear();

    try {
      // Busca agendamentos na coleção geral de 'agendamentos'
      QuerySnapshot snapshot = await _firestore
          .collection('agendamentos')
          .doc(dataFormatada)
          .collection('horarios')
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
        String horaString = doc.get('hora');
        List<String> partesHora = horaString.split(':');
        TimeOfDay hora = TimeOfDay(
          hour: int.parse(partesHora[0]),
          minute: int.parse(partesHora[1]),
        );

        agendamentos.add(Horario(
          data: DateTime(
            dataSelecionada.year,
            dataSelecionada.month,
            dataSelecionada.day,
            hora.hour,
            hora.minute,
          ),
          veiculo: Veiculo(
            marca: doc.get('veiculo.marca') ?? 'Desconhecida',
            modelo: doc.get('veiculo.modelo') ?? 'Desconhecido',
            placa: doc.get('veiculo.placa') ?? 'Desconhecida',
          ),
          servico: doc.get('servico') ?? 'Não especificado',
          nomeCliente: doc.get('nomeCliente') ?? 'Não especificado',
          userId: doc.get('userId') ?? 'Não especificado',
          valorServico: doc.get('valorServico') ?? 0.0,
        ));
      }

      // Ordena os agendamentos por horário
      agendamentos.sort((a, b) => a.data.compareTo(b.data));
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar agendamentos para o gestor: $e');
    }
  }


  Future<void> adicionarAgendamento(Horario horario, String nomeCliente, String userId) async {
    try {
      // Adiciona agendamento na coleção do usuário
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('agendamentos')
          .add({
        'data': DateFormat('yyyyMMdd').format(horario.data),
        'hora': '${horario.data.hour.toString().padLeft(2, '0')}:${horario.data.minute.toString().padLeft(2, '0')}',
        'veiculo': {
          'marca': horario.veiculo.marca,
          'modelo': horario.veiculo.modelo,
          'placa': horario.veiculo.placa,
        },
        'servico': horario.servico,
        'valorServico': horario.valorServico,
        'nomeCliente': nomeCliente,
        'status': 'confirmado',
        'userId': userId,
      });

      // Adiciona agendamento na coleção geral
      String dataFormatada = DateFormat('yyyyMMdd').format(horario.data);
      DocumentReference agendamentoRef = _firestore
          .collection('agendamentos')
          .doc(dataFormatada)
          .collection('horarios')
          .doc('${horario.data.hour.toString().padLeft(2, '0')}:${horario.data.minute.toString().padLeft(2, '0')}');

      await agendamentoRef.set({
        'hora': '${horario.data.hour.toString().padLeft(2, '0')}:${horario.data.minute.toString().padLeft(2, '0')}',
        'veiculo': {
          'marca': horario.veiculo.marca,
          'modelo': horario.veiculo.modelo,
          'placa': horario.veiculo.placa,
        },
        'servico': horario.servico,
        'valorServico': horario.valorServico,
        'nomeCliente': nomeCliente,
        'userId': userId,
        'status': 'confirmado',
      });

      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar agendamento: $e');
    }
  }

  Future<void> cancelarAgendamento(Horario horario, String userId) async {
    try {
      // Cancelar agendamento na coleção do usuário
      CollectionReference userAgendamentosRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('agendamentos');

      QuerySnapshot userAgendamentosSnapshot = await userAgendamentosRef
          .where('data', isEqualTo: DateFormat('yyyy-MM-dd').format(horario.data))
          .where('hora', isEqualTo: '${horario.data.hour.toString().padLeft(2, '0')}:${horario.data.minute.toString().padLeft(2, '0')}')
          .get();

      if (userAgendamentosSnapshot.docs.isNotEmpty) {
        await userAgendamentosSnapshot.docs.first.reference.delete();
      }

      // Cancelar agendamento na coleção geral
      String dataFormatada = DateFormat('yyyy-MM-dd').format(horario.data);
      CollectionReference subcolecao = _firestore
          .collection('agendamentos')
          .doc(dataFormatada)
          .collection('horarios');

      QuerySnapshot snapshot = await subcolecao
          .where('hora', isEqualTo: '${horario.data.hour.toString().padLeft(2, '0')}:${horario.data.minute.toString().padLeft(2, '0')}')
          .where('userId', isEqualTo: horario.userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        agendamentos.remove(horario);
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao cancelar agendamento: $e');
    }
  }

  void resetarSelecoes() {
    veiculoSelecionado = null;
    dataSelecionada = null;
    horaSelecionada = null;
    servicoSelecionado = null;
    valorServicoSelecionado = null;
    notifyListeners();
  }

  void ordenarHorarios() {
    horariosDisponiveis.sort((a, b) => a.hour.compareTo(b.hour) == 0
        ? a.minute.compareTo(b.minute)
        : a.hour.compareTo(b.hour));
  }

  void selecionarVeiculo(Veiculo veiculo) {
    veiculoSelecionado = veiculo;
    notifyListeners();
  }

  void selecionarData(DateTime data, String userId) {
    dataSelecionada = data;
    carregarHorariosDisponiveis(dataSelecionada!);
    notifyListeners();
  }

  void selecionarHora(TimeOfDay hora) {
    horaSelecionada = hora;
    notifyListeners();
  }

  void selecionarServico(Servico servico) {
    servicoSelecionado = servico.nome;
    valorServicoSelecionado = servico.preco;
    notifyListeners();
  }
}

class Horario {
  final DateTime data;
  final Veiculo veiculo;
  final String servico;
  final String nomeCliente;
  final String userId;
  final double valorServico;

  Horario({
    required this.data,
    required this.veiculo,
    required this.servico,
    required this.nomeCliente,
    required this.userId,
    required this.valorServico,
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
