import 'package:flutter/material.dart';
import 'package:pathau_now/features/tracking/domain/entities/parcel_entity.dart';
import 'package:pathau_now/core/utils/app_utils.dart';

class TrackingDetailPage extends StatelessWidget {
  final ParcelEntity parcel;
  const TrackingDetailPage({super.key, required this.parcel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Parcel ${parcel.trackingId}')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipient: ${parcel.receiver.name}'),
            const SizedBox(height: 8),
            Text('Sender: ${parcel.sender.name}'),
            const SizedBox(height: 8),
            Text('Status: ${parcel.status}'),
            const SizedBox(height: 8),
            Text('Weight: ${parcel.weight}kg'),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...parcel.timeline.map((t) {
              final time = t.timestamp;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 12,
                      child: Column(
                        children: [
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.status,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          if (t.location != null) Text(t.location!),
                          if (t.description != null) Text(t.description!),
                          const SizedBox(height: 4),
                          Text(
                            DateTimeUtils.formatDateTime(time),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
