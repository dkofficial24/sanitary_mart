import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sanitary_mart/category/model/category_model.dart';

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
}
