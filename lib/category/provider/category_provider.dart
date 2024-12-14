import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sanitary_mart/brand/model/brand_model.dart';
import 'package:sanitary_mart/category/model/category_model.dart';
import 'package:sanitary_mart/category/service/category_firebase_service.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/product/model/product_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryFirebaseService firebaseService;

  CategoryProvider(this.firebaseService);

  List<Category> _categoryList = [];
  List<Category> _filteredCategoryList = [];
  ProviderState _state = ProviderState.idle;

  ProviderState get state => _state;

  List<Category> get filteredCategoryList => _filteredCategoryList;

  String? _error;

  List<Category> get categoryList => _categoryList;

  List<Product> _products = [];
  List<Product> _filterProductList = [];

  List<Product> get filteredProductList => _filterProductList;

  String? get error => _error;
  Timer? _debounce;

  Future<void> fetchCategories() async {
    try {
      _error = null;
      _state = ProviderState.loading;
      notifyListeners();
      _categoryList = await firebaseService.getCategories();
      _filteredCategoryList = _categoryList;
      _state = ProviderState.idle;
    } catch (e) {
      _error = 'Failed to fetch items: $e';
      _state = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }


  Future filterProduct(String query)async{
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {

      if(query.isEmpty)return;

      _filterProduct(query);
    });
  }

  Future<void> _filterProduct(String query) async {
    try {
      _error = null;
      _state = ProviderState.loading;
      notifyListeners();
      _filterProductList = await firebaseService.fetchProducts(query);
      _state = ProviderState.idle;
    } on SocketException {
      _error = 'Unable to search due to slow internet';
      _state = ProviderState.error;
    } on TimeoutException {
      _error = 'Timeout. Please try again';
    } catch (e) {
      _error = 'Failed to fetch items: $e';
      _state = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<String?> fetchBrand(String brandId) async {
    try {
      _error = null;
      _state = ProviderState.loading;
      notifyListeners();
      Brand? brand = await firebaseService.fetchBrandById(brandId);
      _state = ProviderState.idle;
      return brand!.name;
    } catch (e) {
      _error = 'Failed to fetch items: $e';
      _state = ProviderState.error;
      return null;
    } finally {
      notifyListeners();
    }
  }
}
