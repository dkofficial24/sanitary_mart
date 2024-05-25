import 'package:flutter/material.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/product/model/product_model.dart';
import 'package:sanitary_mart/product/service/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService productService;

  ProductProvider(this.productService);

  List<Product> _products = [];
  final List<String> _categories = [];
  List<Product> _filteredProducts = [];

  List<Product> get products => _products;
  List<String> get categories => _categories;
  List<Product> get filteredProducts => _filteredProducts;

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  Future<void> fetchAllProducts(String categoryId, String brandId) async {
    try {
      _state = ProviderState.loading;
      _products.clear();
      notifyListeners();
      _products =
      await productService.fetchProductsByBrand(categoryId, brandId);
      _filteredProducts = _products;
      _state = ProviderState.idle;
    } catch (e) {
      _state = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products
          .where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
