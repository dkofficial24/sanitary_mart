import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart/product/model/product_model.dart';

class ProductService {
  final String collectionName = 'products';

  Future<List<Product>> fetchProductsByBrand(String categoryId,String brandId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('brandId', isEqualTo: brandId)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => Product.fromFirebase(doc)).toList();
  }

}
