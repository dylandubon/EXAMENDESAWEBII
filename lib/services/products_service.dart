import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:productos/models/models.dart';
import 'package:http/http.dart' as http;
class ProductService extends ChangeNotifier{
  final String _baseUrl = "TODO";
  final List<Product> products = [];
  late Product selectedProduct;
  File? newPictureFile;
  bool isLoading = true;
  bool isSaving = false;

  ProductService(){
    loadProducts();
  }
  
  Future<List<Product>> loadProducts() async{
    isLoading = true;
    notifyListeners();
    final url = Uri.https(_baseUrl,'products.json');
    final resp = await http.get(url);
    //Mapeo
    final Map<String, dynamic> productsMap = json.decode(resp.body);

    productsMap.forEach((key, value) { 
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);

    });
    isLoading = false;
    notifyListeners();
    return products;
  }

  Future saveOrCreateProduct(Product product)async{
    isSaving = true;
    notifyListeners();
    if(product.id == null){
      await createProduct(product);
    }else{
      await updateProduct(product);
    }
    isSaving = false;
    notifyListeners();
  }
  
  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl,'products.json');
    final resp = await http.post(url, body:  product.toJson());
     final decodeData = json.decode(resp.body);
     product.id = decodeData["name"];
     products.add(product);
     return product.id!;

  }
  
  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl,'products/${ product.id}.json');
    //http verbos -> get = Obtener, post = Guardar o procesar,
    // put = Actualizar una entidad, delete = Eliminar , patch = Actualizacion parcial
    final resp = await http.put(url, body:  product.toJson());
    final decodeData = resp.body;
    //TODO: Actualizar el listado de productos
    final index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;
    return product.id!;
    
  }
  void updateSelectedProductImage(String path){
    selectedProduct.picture = path;
    newPictureFile = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  Future<String?> uploadImage() async{
    if (newPictureFile == null) return null;
    isSaving = false;
    notifyListeners();
    final url = Uri.parse('TODO ADD URL');
    final imageUploadRequest = http.MultipartRequest('POST',url);
    //file
    final file = await http.MultipartFile.fromPath('file', newPictureFile!.path);
    imageUploadRequest.files.add(file);
    //Enviar el request
    final streamResponse = await imageUploadRequest.send();
    //Validar respuesta
    final resp = await http.Response.fromStream(streamResponse);
    if(resp.statusCode != 200 && resp.statusCode != 201){
      print("Alga falló");
      print(resp.body);
      return null;
    }
    newPictureFile = null;
    final decodedDaata = json.decode(resp.body);
    return decodedDaata["secure_url"];
  }
  //ESTADOS HTTP 200 300 400 500?

}