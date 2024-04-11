import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart/brand/model/brand_model.dart';

class BrandFirebaseService {
  static const String collectionName = 'brands';

  Future<List<Brand>> getBrandsByCategory(String categoryId) async {
    final CollectionReference association =
        FirebaseFirestore.instance.collection('category_brand');
    final snapshot =
        await association.where('categoryId', isEqualTo: categoryId).get();
    Set<String> brandIds = {};
    for (QueryDocumentSnapshot associationDoc in snapshot.docs) {
      String brandId = associationDoc['brandId'];
      brandIds.add(brandId);
    }
    List<Brand> brands = [];
    for (String brandId in brandIds) {
      DocumentSnapshot brandSnapshot = await FirebaseFirestore.instance
          .collection('brands')
          .doc(brandId)
          .get();
      if (brandSnapshot.exists) {
        brands.add(Brand.fromFirebase(brandSnapshot));
      }
    }
    return brands;
  }
}
