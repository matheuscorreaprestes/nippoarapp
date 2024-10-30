import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

// Função para enviar notificação para o cliente
Future<void> enviarNotificacaoParaCliente(String token, String titulo, String corpo) async {
  try {
    var response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'AIzaSyDVg1h-BPHWN8HQIhF8e__xVHBs3NsyQwY', // Coloque aqui sua chave de servidor do FCM
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': corpo, 'title': titulo},
          'priority': 'high',
          'data': <String, dynamic>{'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
          'to': token,
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Notificação enviada com sucesso');
    } else {
      print('Falha ao enviar notificação: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro ao enviar notificação: $e');
  }
}


// Método para enviar notificação após serviço concluído
Future<void> enviarNotificacaoServicoConcluido(String userId) async {
  try {
    DocumentSnapshot clienteSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String? clienteToken = clienteSnapshot['token'];

    if (clienteToken != null) {
      await enviarNotificacaoParaCliente(
        clienteToken,
        'Serviço Concluído',
        'Seu veículo está pronto para ser retirado!',
      );
    } else {
      print('Cliente não possui token de notificação');
    }
  } catch (e) {
    print('Erro ao enviar notificação: $e');
  }
}
