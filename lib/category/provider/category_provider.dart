import 'package:flutter/material.dart';
import 'package:sanitary_mart/category/model/category_model.dart';
import 'package:sanitary_mart/category/service/category_firebase_service.dart';
import 'package:sanitary_mart/core/provider_state.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryFirebaseService firebaseService;

  CategoryProvider(this.firebaseService);

  List<Category> _categoryList = [];
  List<Category> _filteredCategoryList = [];
  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String? _error;

  List<Category> get categoryList => _categoryList;

  List<Category> get filteredCategoryList => _filteredCategoryList;

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
}
