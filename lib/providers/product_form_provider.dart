import 'package:flutter/material.dart';
import 'package:productos/models/models.dart';

class ProductFormProvider extends ChangeNotifier{
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late Product product;

  ProductFormProvider(this.product);

  updateAvailability(bool value) {
    print(value);
    product.available = value; //TODO verificar despues en el API
    notifyListeners();
  }

  bool isValidForm(){
    print(product.name);
    print(product.price);
    print(product.available);
    return formKey.currentState?.validate() ?? false;
  }

}