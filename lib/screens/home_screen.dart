import 'package:flutter/material.dart';
import 'package:nippoarapp/screens/commitments_screen_manager.dart';
import 'package:nippoarapp/screens/loyalty_screen.dart';
import 'package:nippoarapp/screens/commitments_screen.dart';
import 'package:nippoarapp/screens/profile_screen.dart';
import 'package:nippoarapp/screens/vehicle_register_screen.dart';
import 'package:nippoarapp/screens/servico_screen.dart';
import 'package:nippoarapp/widgets/custom_drawer.dart'; // Importa o CustomDrawer correto

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose(); // Certifique-se de descartar corretamente o PageController
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Nippoar",
          style: TextStyle(fontSize: 30.0),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          CommitmentsScreen(),
          ProfileScreen(),
          VehicleRegisterScreen(),
          LoyaltyScreen(),
          GerenciarServicosScreen(),
          CommitmentsScreenManager(),
        ],
      ),
      drawer: CustomDrawer(pageController: _pageController,),
    );
  }
}
