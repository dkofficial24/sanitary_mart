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
            if (userProvider.providerState == ProviderState.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (userProvider.incentivePointsHistory.isEmpty) {
              return const Center(child: Text('No Incentive Points History'));
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
                      'Points: ${point.totalPoints.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.black87),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 5.0),
                        Row(
                          children: [
                            Text(
                              'Status: ${point.redeemStatus}',
                              style: TextStyle(
                                  color: _getStatusColor(point.redeemStatus)),
                            ),
                            const SizedBox(width: 5.0),
                            Icon(
                              getStatusIcon(point.redeemStatus),
                              size: 16.0,
                              color: _getStatusColor(point.redeemStatus),
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

  IconData getStatusIcon(RedeemStatus status) {
    switch (status) {
      case RedeemStatus.accepted:
        return Icons.check_circle_outline;
      case RedeemStatus.rejected:
        return Icons.close_outlined;
      case RedeemStatus.processing:
        return Icons.access_time_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _getStatusColor(RedeemStatus status) {
    switch (status) {
      case RedeemStatus.accepted:
        return Colors.green;
      case RedeemStatus.processing:
        return Colors.orange;
      case RedeemStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
