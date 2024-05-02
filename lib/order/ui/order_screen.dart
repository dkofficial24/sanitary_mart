import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/core/widget/translucent_overlay_loader.dart';
import 'package:sanitary_mart/core/widget/widget.dart';
import 'package:sanitary_mart/order/model/order_status.dart';
import 'package:sanitary_mart/order/provider/order_provider.dart';
import 'package:sanitary_mart/order/ui/widget/order_card_widget.dart';
import 'package:sanitary_mart/order/ui/widget/order_filter_bottom_screen.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderStatus? filterStatus;

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
    return Consumer<OrderProvider>(
      builder: (context, provider, child){
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Orders',
            actions: [
              Stack(
                children: [
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return OrderFilterBottomSheet((orderStatus) {
                              filterStatus = orderStatus;
                              Provider.of<OrderProvider>(context, listen: false)
                                  .filterOrderByStatus(filterStatus);
                            },selectedOrderStatus: filterStatus,);
                          },
                        );
                      },
                      icon: const Icon(Icons.filter_alt)),
                  if(filterStatus!=null)const Positioned(
                    right:12,
                    child: Text(
                      '.',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold,fontSize: 32),
                    ),
                  )
                ],
              )
            ],
          ),
          body: body(provider),
        );
      },
    );
  }

  Widget body(OrderProvider provider) {
     if (provider.state == ProviderState.error) {
      return ErrorRetryWidget(
        onRetry: () {
          fetchOrders();
        },
      );
    }

    if (provider.state == ProviderState.idle &&
        (provider.filteredOrderModelList == null ||
            provider.filteredOrderModelList!.isEmpty)) {
      return Center(
        child: Text(
          'There are no orders yet.',
          style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
        ),
      );
    }

    return TranslucentOverlayLoader(
      enabled: provider.state == ProviderState.loading,
      child: ListView.builder(
        itemCount: provider.filteredOrderModelList?.length ?? 0,
        itemBuilder: (context, index) {
          final order = provider.filteredOrderModelList![index];
          return OrderCard(
              order: order); // Use a separate OrderCard widget
        },
      ),
    );
  }
}
