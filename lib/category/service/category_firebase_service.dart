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
    return searchProductsByKeyword(query);
    // QuerySnapshot snapshot;
    // String capitalizedQuery =
    //     query.substring(0, 1).toUpperCase() + query.substring(1);
    // snapshot = await FirebaseFirestore.instance
    //     .collection('products')
    //     .where('name', isGreaterThanOrEqualTo: capitalizedQuery)
    //     .where('name', isLessThan: '${capitalizedQuery}z')
    //     .get();
    // return snapshot.docs.map((doc) => Product.fromFirebase(doc)).toList();
  }

  Future<List<Product>> searchProductsByKeyword(String keyword) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Perform the query on the 'product_keywords' collection
      final snapshot = await firestore.collection('product_keywords')
          .where('keywords', arrayContains: keyword.toLowerCase()) 
          .limit(30)
          .get();

      // If no products found
      if (snapshot.docs.isEmpty) {
        print("No products found for keyword: $keyword");
        return [];
      }

      // Map the snapshot to Product objects (from 'products' collection)
      List<Product> products = [];
      for (final doc in snapshot.docs) {
        final productId = doc['productId'];

        // Fetch the product data from the 'products' collection
        final productSnapshot = await firestore.collection('products').doc(productId).get();

        if (productSnapshot.exists) {
          final product = Product.fromFirebase(productSnapshot);
          products.add(product);
        }
      }

      return products;
    } catch (e) {
      print("Error searching products by keyword: $e");
      return [];
    }
  }

  Future<Brand?> fetchBrandById(String brandId) async {
    DocumentSnapshot brandSnapshot = await FirebaseFirestore.instance
        .collection('brands')
        .doc(brandId)
        .get();

    return Brand.fromFirebase(brandSnapshot);
  }
}
