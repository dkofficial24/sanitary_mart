import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/profile/model/point_info.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';
import 'package:sanitary_mart/profile/ui/screen/point_history_screen.dart';

class IncentivePointsScreen extends StatefulWidget {
  final int points;

  const IncentivePointsScreen({Key? key, required this.points})
      : super(key: key);

  @override
  State<IncentivePointsScreen> createState() => _IncentivePointsScreenState();
}

class _IncentivePointsScreenState extends State<IncentivePointsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAnimationVisible = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false)
          .fetchTotalIncentivePoints();
    });
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 500),
    // );
    //
    // _scaleAnimation =
    //     Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);
  }

  @override
  void dispose() {
    //_animationController.dispose();
    super.dispose();
  }

  void _playRewardAnimation() {
    setState(() {
      _isAnimationVisible = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isAnimationVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Incentive Points',
        actions: [
          IconButton(
              onPressed: () {
                Get.to(IncentivePointListScreen());
              },
              icon: const Icon(Icons.history))
        ],
      ),
      body: Stack(
        children: [
          // Top Section (Gradient background)

          Consumer<UserProvider>(builder: (context, provider, widget) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.totalPoints.toString(),
                    style: const TextStyle(
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  // Text Label
                  const Text(
                    "Incentive Points",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  // Optional Progress Bar
                  // ... (implement progress bar widget here)
                ],
              ),
            );
          }),

          // Lottie Animation
          if (_isAnimationVisible)
            Center(
              child: Lottie.asset(
                'assets/animations/reward.json',
                // width: 200,
                // height: 200,
                fit: BoxFit.contain,
                onLoaded: (composition) {
                  _animationController.duration = composition.duration;
                  _animationController.forward();
                },
              ),
            ),
          // Bottom Section (Button)
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: ElevatedButton(
              onPressed: Provider.of<UserProvider>(context, listen: true)
                          .totalPoints ==
                      0
                  ? null
                  : () {
                      final userProvider = getUserProvider(context);
                      IncentivePointInfo incentivePoint = IncentivePointInfo(
                          totalPoints: userProvider.totalPoints,
                          created: DateTime.now().millisecondsSinceEpoch,
                          updated: DateTime.now().millisecondsSinceEpoch,
                          redeemStatus: RedeemStatus.processing);
                      getUserProvider(context)
                          .requestPointRedeem(incentivePoint);
                    },
              child: const Text("Redeem"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  UserProvider getUserProvider(BuildContext context) =>
      Provider.of<UserProvider>(context, listen: false);
}
