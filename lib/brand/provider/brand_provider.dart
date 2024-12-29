import 'package:flutter/material.dart';
import 'package:sanitary_mart/brand/model/brand_model.dart';
import 'package:sanitary_mart/brand/service/brand_firebase_service.dart';
import 'package:sanitary_mart/core/error_util.dart';
import 'package:sanitary_mart/core/provider_state.dart';

class BrandProvider extends ChangeNotifier {
  final BrandFirebaseService firebaseService;

  BrandProvider(this.firebaseService);

  List<Brand> _brandList = [];
  ProviderState _state = ProviderState.idle;
  String? _error;
  bool imageUploading = false;

  List<Brand> get brandList => _brandList;

  ProviderState get state => _state;

  String? get error => _error;
  List<Brand> filteredBrandList = [];


  Future<void> getBrandsByCategory(String categoryId) async {
    try {
      _state = ProviderState.loading;
      _brandList.clear();
      notifyListeners();

      _brandList = await firebaseService.getBrandsByCategory(categoryId);
      filteredBrandList = _brandList;
      _state = ProviderState.idle;
    } catch (e) {
      _error = 'Failed to fetch items: $e';
      ErrorUtil.handleFirebaseError(e);
      _state = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  void filterBrands(String query) {
    if (query.isEmpty) {
      filteredBrandList = _brandList;
    } else {
      filteredBrandList = _brandList
          .where((category) =>
          category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

}
