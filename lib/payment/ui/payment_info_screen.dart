import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/copy_button_widget.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/core/widget/widget.dart';
import 'package:sanitary_mart/payment/provider/payment_info_provider.dart';

class PaymentInfoScreen extends StatefulWidget {
  const PaymentInfoScreen({this.totalPayable, super.key});

  final double? totalPayable;

  @override
  State<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends State<PaymentInfoScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchPaymentAccountInfo();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Consumer<PaymentInfoProvider>(
      builder: (context, provider, child) {
        Widget child = const SizedBox();
        if (provider.providerState == ProviderState.loading) {
          child = const Center(
            child: CircularProgressIndicator(),
          );
        } else if (provider.providerState == ProviderState.error) {
          child = Center(child: ErrorRetryWidget(
            onRetry: () {
              fetchPaymentAccountInfo();
            },
          ));
        } else if (provider.paymentInfo == null) {
          child = const Center(
            child: Text(
              'No Payment details available.\nUse + icon to add it',
              textAlign: TextAlign.center,
            ),
          );
        } else {
          child = Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: NetworkImageWidget(
                    provider.paymentInfo?.qrCodeUrl ?? '',
                    imgHeight: Get.height * 0.4,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold)), // Bold label
                    Text(provider.paymentInfo?.accountHolderName ??
                        'Not Available'),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment method',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('UPI'),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('UPI Id',
                        style: TextStyle(
                            fontWeight: FontWeight.bold)), // Bold label
                    Row(
                      children: [
                        CopyIconButton(provider.paymentInfo!.upiId.toString()),
                        Text(provider.paymentInfo?.upiId ?? 'Not Available'),
                      ],
                    )
                  ],
                ),
               if(widget.totalPayable!=null) Padding(
                 padding: const EdgeInsets.only(top: 16),
                 child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount',
                          style: TextStyle(
                              fontWeight: FontWeight.bold)), // Bold label
                      Text(widget.totalPayable.toString()),
                    ],
                  ),
               ),
                // Add additional info rows here (if applicable)
              ],
            ),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Payment info',
            actions: [
              IconButton(
                  onPressed: () {
                    fetchPaymentAccountInfo();
                  },
                  icon: const Icon(Icons.refresh))
            ],
          ),
          floatingActionButton: provider.paymentInfo != null
              ? Column(

            mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'share_tag',
                      onPressed: () {
                        provider.sharePaymentInfo(
                            paymentInfo: provider.paymentInfo!,
                            totalPayable: widget.totalPayable);
                      },
                      child: const Icon(Icons.share),
                    ),
                  const SizedBox(height: 20,),
                    FloatingActionButton(
                      heroTag: 'proceed_tag',
                      onPressed: () {
                        Get.back();
                      },
                      child: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                )
              : null,
          body: child,
        );
      },
    ));
  }

  Future fetchPaymentAccountInfo() async {
    Provider.of<PaymentInfoProvider>(context, listen: false)
        .fetchPaymentInfo(refresh: true);
  }
}
