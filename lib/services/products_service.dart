import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:productes_app/models/models.dart';

import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      'flutter-app-productes-89fe0-default-rtdb.europe-west1.firebasedatabase.app';
  final List<Product> products = [];
  late Product selectedProduct;
  File? newPicture;

  bool isLoading = true;
  bool isSaving = false;

  ProductsService() {
    this.loadProducts();
  }

  Future loadProducts() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, "products.json");
    final res = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(res.body);

    productsMap.forEach((key, value) {
      final curr = Product.fromMap(value);
      curr.id = key;
      products.add(curr);
    });

    isLoading = false;
    notifyListeners();
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.id == null)
      await insertProduct(product);
    else
      await updateProduct(product);

    isSaving = false;
    notifyListeners();
  }

  Future<String> insertProduct(Product product) async {
    final url = Uri.https(_baseUrl, "products.json");
    final res = await http.post(url, body: product.toJson());
    final decodedData = json.decode(res.body);

    product.id = decodedData['name'];
    products.add(product);

    return product.id!;
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, "products/${product.id}.json");
    final res = await http.put(url, body: product.toJson());

    int index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) products[index] = product;

    return product.id!;
  }

  void updateSelectedImage(String path) {
    this.newPicture = File.fromUri(Uri(path: path));
    this.selectedProduct.picture = path;
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (this.newPicture == null) return null;

    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/di4oano8z/image/upload?upload_preset=hehajv1i');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', newPicture!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();

    final res = await http.Response.fromStream(streamResponse);

    if (res.statusCode != 200 && res.statusCode != 201) return null;

    this.newPicture = null;

    final decodeData = json.decode(res.body);

    this.isSaving = false;
    notifyListeners();

    return decodeData['secure_url'];
  }
}
