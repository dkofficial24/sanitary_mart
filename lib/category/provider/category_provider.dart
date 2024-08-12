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

  Future<void> fetchCategories() async {
    try {
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

  void filterCategories(String query) {
    if (query.isEmpty) {
      _filteredCategoryList = _categoryList;
    } else {
      _filteredCategoryList = _categoryList
          .where((category) =>
              category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> filterProduct(String query) async {
    try {
      _state = ProviderState.loading;
      notifyListeners();
      _filterProductList = await firebaseService.fetchProducts(query);
      _state = ProviderState.idle;
    } catch (e) {
      _error = 'Failed to fetch items: $e';
      _state = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<String?> fetchBrand(String brandId) async {
    try {
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
