import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/core/widget/widget.dart';
import 'package:sanitary_mart/order/provider/order_provider.dart';
import 'package:sanitary_mart/order/ui/widget/order_card_widget.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchOrders();
    });
    super.initState();
  }

  Future<void> fetchOrders() async {
    UserModel? userModel = await Provider.of<UserProvider>(
      context,
      listen: false,
    ).getCurrentUser();

    if (userModel != null && mounted) {
      await Provider.of<OrderProvider>(
        context,
        listen: false,
      ).loadOrders(userModel.uId);
    }
    FirebaseAnalytics.instance.logEvent(name: 'fetch_orders');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Orders'),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.state == ProviderState.loading) {
            return const CircularProgressIndicator();
          } else if (provider.state == ProviderState.error) {
            return ErrorRetryWidget(
              onRetry: () {
                fetchOrders();
              },
            );
          }

          if (provider.orderModelList == null ||
              provider.orderModelList!.isEmpty) {
            return Center(
              child: Text(
                'There are no orders yet.',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
              ),
            );
          }
          if (provider.state == ProviderState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: provider.orderModelList?.length ?? 0,
            itemBuilder: (context, index) {
              final order = provider.orderModelList![index];
              return OrderCard(order: order); // Use a separate OrderCard widget
            },
          );
        },
      ),
    );
  }
}
