import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart/cart/model/cart_item_model.dart';

class CartFirebaseService {
  final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('cart');

  Future<void> addToCart(String userId, CartItem item) async {
    final docRef =
        _cartCollection.doc(userId).collection('cartItems').doc(item.productId);
    DocumentSnapshot snapshot = await docRef.get();
    if (snapshot.exists) {
      CartItem cartItem =
          CartItem.fromJson(snapshot.data() as Map<String, dynamic>);
      int currentQty = cartItem.quantity;
      int updatedQty = currentQty + item.quantity;
      docRef.update({
        'quantity': updatedQty,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      item.createdAt = DateTime.now().millisecondsSinceEpoch;
      docRef.set(item.toJson());
    }
  }

  Future<void> removeProductFromCart(String userId, String productId) async {
    final docRef =
        _cartCollection.doc(userId).collection('cartItems').doc(productId);
    await docRef.delete();
  }

  Future<void> clearFullCart(String userId) async {
    final docRef = _cartCollection.doc(userId);
    // Delete the cart document
    await docRef.delete();

    // Also delete the cart items collection
    final cartItemsRef = docRef.collection('cartItems');
    final cartItemsSnapshot = await cartItemsRef.get();
    for (var doc in cartItemsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateCartItemQuantity(
      String userId, String productId, int newQuantity) async {
    final docRef =
        _cartCollection.doc(userId).collection('cartItems').doc(productId);
    await docRef.update({
      'quantity': newQuantity,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _cartCollection.doc(userId).collection('cartItems').get();

      return snapshot.docs.map((doc) => CartItem.fromJson(doc.data())).toList();
    } catch (e) {
      // Handle errors here
      print('Error fetching cart items: $e');
      return []; // Return empty list or throw an exception as needed
    }
  }

  Future<void> clearCart(String userId) async {
    // Get a write batch to perform multiple deletions efficiently
    final batch = FirebaseFirestore.instance.batch();
    final cartRef = _cartCollection.doc(userId).collection('cartItems');
    final cartSnapshot = await cartRef.get();

    // Add delete operations for all cart items to the batch
    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Commit the batch operation
    await batch.commit();
  }
}
