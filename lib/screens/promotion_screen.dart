import 'package:flutter/material.dart';
import 'package:nippoarapp/models/promotion_model.dart';
import 'package:scoped_model/scoped_model.dart';

class PromotionManagerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PromotionModel>(
      builder: (context, child, promotionModel) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Gerenciar Promoções'),
            centerTitle: true,
          ),
          body: ListView.builder(
            itemCount: promotionModel.promotions.length,
            itemBuilder: (context, index) {
              final promotion = promotionModel.promotions[index];
              return ListTile(
                title: Text(promotion.name),
                subtitle: Text(
                  'Desconto: ${promotion.discount}% - Válido até: ${promotion.endDate.toLocal().toString().split(' ')[0]}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditPromotionDialog(context, promotion, promotionModel);
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddPromotionDialog(context);
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddPromotionDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(Duration(days: 7));
    double discount = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Promoção'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nome da Promoção'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome da promoção';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value ?? '';
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Desconto (%)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o desconto';
                      }
                      final discountValue = double.tryParse(value);
                      if (discountValue == null || discountValue <= 0) {
                        return 'Por favor, insira um valor válido';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      discount = double.parse(value ?? '0');
                    },
                  ),
                  ListTile(
                    title: Text('Data de Início: ${startDate.toLocal().toString().split(' ')[0]}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        startDate = picked;
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Data de Fim: ${endDate.toLocal().toString().split(' ')[0]}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        endDate = picked;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Salvar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newPromotion = Promotion(
                    id: '', // Será gerado pelo Firestore
                    name: name,
                    startDate: startDate,
                    endDate: endDate,
                    discount: discount,
                  );

                  // Adiciona a promoção usando o modelo
                  ScopedModel.of<PromotionModel>(context, rebuildOnChange: false)
                      .addPromotion(newPromotion);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditPromotionDialog(
      BuildContext context, Promotion promotion, PromotionModel promotionModel) {
    final _formKey = GlobalKey<FormState>();
    String name = promotion.name;
    DateTime startDate = promotion.startDate;
    DateTime endDate = promotion.endDate;
    double discount = promotion.discount;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Promoção'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(labelText: 'Nome da Promoção'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome da promoção';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value ?? '';
                    },
                  ),
                  TextFormField(
                    initialValue: discount.toString(),
                    decoration: InputDecoration(labelText: 'Desconto (%)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o desconto';
                      }
                      final discountValue = double.tryParse(value);
                      if (discountValue == null || discountValue <= 0) {
                        return 'Por favor, insira um valor válido';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      discount = double.parse(value ?? '0');
                    },
                  ),
                  ListTile(
                    title: Text('Data de Início: ${startDate.toLocal().toString().split(' ')[0]}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        startDate = picked;
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Data de Fim: ${endDate.toLocal().toString().split(' ')[0]}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        endDate = picked;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Salvar Alterações'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final updatedPromotion = Promotion(
                    id: promotion.id,
                    name: name,
                    startDate: startDate,
                    endDate: endDate,
                    discount: discount,
                  );

                  // Edita a promoção usando o modelo
                  promotionModel.editPromotion(updatedPromotion.id, updatedPromotion);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
