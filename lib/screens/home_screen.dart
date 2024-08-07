import 'package:flutter/material.dart';
import 'package:nippoarapp/screens/login_screen.dart';
import 'package:nippoarapp/screens/loyalty_screen.dart';
import 'package:nippoarapp/screens/profile_screen.dart';
import 'package:nippoarapp/screens/vehicle_register_screen.dart';
import 'package:nippoarapp/widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  int _selectedIndex = 0;

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
          Center(child: Text('Pagina teste')),
          ProfileScreen(),
          VehicleRegisterScreen(),
          LoyaltyScreen(),
        ],
      ),
      drawer: CustomDrawer(pageController: _pageController),
    );
  }
}
