import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sanitary_mart/brand/model/brand_model.dart';
import 'package:sanitary_mart/category/model/category_model.dart';
import 'package:sanitary_mart/product/model/product_model.dart';

class CategoryFirebaseService {
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('categories');
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<List<Category>> getCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) {
      return Category.fromFirebase(doc);
    }).toList();
  }

  Future<List<Product>> fetchProducts(String query) async {
    QuerySnapshot snapshot;
    String capitalizedQuery =
        query.substring(0, 1).toUpperCase() + query.substring(1);
    snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: capitalizedQuery)
        .where('name', isLessThan: '${capitalizedQuery}z')
        .get();
    return snapshot.docs.map((doc) => Product.fromFirebase(doc)).toList();
  }

  Future<Brand?> fetchBrandById(String brandId) async {
    DocumentSnapshot brandSnapshot = await FirebaseFirestore.instance
        .collection('brands')
        .doc(brandId)
        .get();

    return Brand.fromFirebase(brandSnapshot);
  }
}
