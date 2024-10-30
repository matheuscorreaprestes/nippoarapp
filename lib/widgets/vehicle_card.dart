import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  final String marca;
  final String modelo;
  final String cor;
  final String placa;
  final String vehicleId;

  VehicleCard({
    required this.marca,
    required this.modelo,
    required this.cor,
    required this.placa,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$marca $modelo",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return {'Editar', 'Deletar'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice == 'Editar' ? 'edit' : 'delete',
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cor: $cor"),
              SizedBox(height: 4.0),
              Text("Placa: $placa"),
            ],
          ),
        ),
      ),
    );
  }
}
