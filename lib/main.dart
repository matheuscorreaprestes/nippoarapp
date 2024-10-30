import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nippoarapp/models/caixa_model.dart';
import 'package:nippoarapp/models/loyalty_model.dart';
import 'package:nippoarapp/models/promotion_model.dart';
import 'package:nippoarapp/models/schedule_model.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/models/vehicle_model.dart';
import 'package:nippoarapp/screens/login_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart'; // Importar o serviço de notificações
import 'services/firebase_service.dart'; // Importar o serviço do Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurar os listeners de notificações
  configurarListenersNotificacoes();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: UserModel(),
      child: ScopedModel<VehicleModel>(
        model: VehicleModel(),
        child: ScopedModel<LoyaltyModel>(
          model: LoyaltyModel(),
          child: ScopedModel<ScheduleModel>(
            model: ScheduleModel(),
            child: ScopedModel<PromotionModel>(
              model: PromotionModel(),
              child: ScopedModel<RegistroCaixaModel>(
                model: RegistroCaixaModel(),
                child: MaterialApp(
                  title: "Nippoar",
                  theme: ThemeData(
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 196, 47, 47),
                      ),
                    ),
                    primarySwatch: Colors.red,
                    primaryColor: Color.fromARGB(255, 196, 47, 47),
                  ),
                  debugShowCheckedModeBanner: false,
                  home: LoginScreen(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Função para configurar os listeners de notificação
void configurarListenersNotificacoes() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Mensagem recebida: ${message.notification?.title}');

    // Aqui você pode exibir uma notificação local ou um diálogo
    // e realizar navegação, se necessário
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notificação aberta: ${message.notification?.title}');
    // Navegar para a tela desejada, se necessário
  });
}

// Chame esta função após o login do usuário para obter e salvar o token
Future<void> afterLogin(String userId) async {
  await FirebaseService.obterETestarToken(userId); // Obter e salvar token
  FirebaseService.configurarAtualizacaoToken(userId); // Monitorar atualizações de token
}
