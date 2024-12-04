
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sanitary_mart/notification/model/notification_model.dart';

class NotificationService {
  Future<void> createNotification(NotificationModel notificationModel) async {
    if (kDebugMode) return;
    final docRef = FirebaseFirestore.instance.collection('notifications').doc();
    notificationModel.id = docRef.id;
    await docRef.set(notificationModel.toJson());
  }
}
