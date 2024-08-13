import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarioWidget extends StatelessWidget {
  final Function(DateTime) onDateSelected;

  CalendarioWidget({required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selecione uma data'),
      content: Container(
        height: 400,
        child: TableCalendar(
          onDaySelected: (selectedDay, focusedDay) {
            onDateSelected(selectedDay);
          },
          firstDay: DateTime.utc(2022, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
        ),
      ),
    );
  }
}
