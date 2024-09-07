import 'package:flutter/material.dart';
import 'package:nippoarapp/models/user_model.dart';
import 'package:nippoarapp/screens/login_screen.dart';
import 'package:nippoarapp/tiles/drawer_tile.dart';
import 'package:scoped_model/scoped_model.dart';

class CustomDrawer extends StatelessWidget {
  final PageController pageController;

  const CustomDrawer({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    Widget _buildDrawerBack() => Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color.fromARGB(255, 196, 47, 47), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
    );

    return Drawer(
      child: Stack(
        children: <Widget>[
          _buildDrawerBack(),
          ListView(
            padding: EdgeInsets.only(left: 32.0, top: 16.0),
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 8.0),
                padding: EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 8.0),
                height: 170.0,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 25.0,
                      left: 40.0,
                      child: Text(
                        "NippoAr",
                        style: TextStyle(
                            fontSize: 40.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Olá, ",
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Divider(color: Colors.transparent),
              ScopedModelDescendant<UserModel>(
                builder: (context, child, model) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.userData['name'] ?? 'Usuário',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(color: Colors.transparent),
                     // DrawerTile(Icons.calendar_today, "Agendar", pageController, 0),
                      DrawerTile(Icons.account_box, "Perfil", pageController, 1),
                      if (model.userType == 'client') ...[
                        DrawerTile(Icons.calendar_month, "Meus Compromissos", pageController, 0),
                        DrawerTile(Icons.loyalty_outlined, "Pontos de fidelidade", pageController, 3),
                        DrawerTile(Icons.directions_car, "Gerenciar Automóvel", pageController, 2),
                      ] else if (model.userType == 'manager') ...[
                        DrawerTile(Icons.loyalty_outlined, "Gerenciar Fidelidade", pageController, 3),
                        DrawerTile(Icons.price_change_outlined, "Gerenciar Serviços", pageController, 4),
                        DrawerTile(Icons.calendar_month, "Agendamentos", pageController, 5),
                      ],
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text("Sair"),
                        onTap: () {
                          Navigator.of(context).pop();
                          ScopedModel.of<UserModel>(context, rebuildOnChange: false).signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
