import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/profile/model/point_info.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';

class IncentivePointListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchIncentivePointsHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incentive Points'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.incentivePointsHistory.isEmpty) {
              return const Center(child: Text('No Incentive Points History'));
            } else if (userProvider.providerState == ProviderState.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.separated(
              itemCount: userProvider.incentivePointsHistory.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                IncentivePointInfo point = userProvider.incentivePointsHistory[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      'Points: ${point.totalPoints}',
                      style: TextStyle(color: Colors.black87),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align content left
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 16.0),
                            Text(
                              ' Created: ${_formatDate(point.created!)}',
                              style: const TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5.0), // Add spacing between date and status
                        Row(
                          children: [
                            Text(
                              'Status: ${point.redeemStatus}',
                              style: TextStyle(
                                  color: point.redeemStatus == 'Redeemed'
                                      ? Colors.green
                                      : Colors.orange),
                            ),
                            const SizedBox(width: 5.0),
                            Icon(
                              point.redeemStatus == 'Redeemed'
                                  ? Icons.check_circle_outline
                                  : Icons.access_time_outlined,
                              size: 16.0,
                              color: point.redeemStatus == 'Redeemed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(int millisecondsSinceEpoch) {
    return AppUtil.convertTimestampInDate(millisecondsSinceEpoch);
  }
}
