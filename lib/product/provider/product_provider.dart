import 'package:flutter/material.dart';
import 'package:sanitary_mart/product/model/product_model.dart';
import 'package:sanitary_mart/product/service/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService productService;

  ProductProvider(this.productService);

  List<Product> _products = [];
  List<String> _categories = [];

  List<Product> get products => _products;

  List<String> get categories => _categories;
  bool isLoading = false;

  Future<void> fetchAllProducts(String categoryId,String brandId) async {
    isLoading = true;
    _products.clear();
    notifyListeners();
    _products = await productService.fetchProductsByBrand(categoryId,brandId);
    isLoading = false;
    notifyListeners();
  }
}
