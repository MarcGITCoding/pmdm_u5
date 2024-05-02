import 'package:flutter/material.dart';
import 'package:productes_app/models/models.dart';

class ProductFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  Product productCopy;

  ProductFormProvider(this.productCopy);

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  updateAvailability(bool value) {
    this.productCopy.available = value;
    notifyListeners();
  }
}
