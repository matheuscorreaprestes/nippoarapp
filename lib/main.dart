import 'package:flutter/material.dart';
import 'package:nippoarapp/models/caixa_model.dart';
import 'package:nippoarapp/models/loyalty_model.dart';
import 'package:nippoarapp/models/promotion_model.dart';
import 'package:nippoarapp/models/schedule_model.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/models/vehicle_model.dart';
import 'package:nippoarapp/screens/home_screen.dart';
import 'package:nippoarapp/screens/login_screen.dart';
import 'package:nippoarapp/screens/commitments_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}


class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context){
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
                  style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 196, 47, 47),
                  ),
                ),
                primarySwatch: Colors.red,
                primaryColor: Color.fromARGB(255, 196, 47, 47)
             ),
            debugShowCheckedModeBanner: false,
            home: LoginScreen()
           ),
          ),
         ),
        ),
       ),
      ),
    );
  }
}

