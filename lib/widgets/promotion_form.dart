import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nippoarapp/models/promotion_model.dart';

class PromotionForm extends StatefulWidget {
  final Promotion? promotion;
  final Function(Promotion) onSave;

  PromotionForm({this.promotion, required this.onSave});

  @override
  _PromotionFormState createState() => _PromotionFormState();
}

class _PromotionFormState extends State<PromotionForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late DateTime _startDate;
  late DateTime _endDate;
  late double _discount;

  @override
  void initState() {
    super.initState();
    if (widget.promotion != null) {
      _name = widget.promotion!.name;
      _startDate = widget.promotion!.startDate;
      _endDate = widget.promotion!.endDate;
      _discount = widget.promotion!.discount;
    } else {
      _name = '';
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(Duration(days: 7));
      _discount = 0.0;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSave(Promotion(
        id: '', // Ou algum ID se você estiver editando
        name: _name,
        discount: _discount,
        startDate: _startDate,
        endDate: _endDate,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.promotion != null ? 'Editar Promoção' : 'Nova Promoção'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(labelText: 'Nome da Promoção'),
              validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              initialValue: _discount.toString(),
              decoration: InputDecoration(labelText: 'Desconto (%)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Informe o desconto' : null,
              onSaved: (value) => _discount = double.parse(value!),
            ),
            ListTile(
              title: Text('Início: ${DateFormat('dd/MM/yyyy').format(_startDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
            ),
            ListTile(
              title: Text('Fim: ${DateFormat('dd/MM/yyyy').format(_endDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _endDate = picked);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Salvar'),
          onPressed: _submitForm,
        ),
      ],
    );
  }
}
