import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<void> obterETestarToken(String userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();

    if (token != null) {
      print('Token de notificação: $token');
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'token': token,
      });
    } else {
      print('Falha ao obter o token.');
    }
  }

  static void configurarAtualizacaoToken(String userId) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('Novo token de notificação: $newToken');
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'token': newToken,
      });
    });
  }
}
