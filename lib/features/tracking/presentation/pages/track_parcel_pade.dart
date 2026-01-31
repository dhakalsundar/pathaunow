import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/features/tracking/presentation/viewmodels/tracking_view_model.dart';
import 'package:pathau_now/features/tracking/presentation/pages/tracking_detail_page.dart';

class TrackParcelPage extends StatefulWidget {
  const TrackParcelPage({super.key});

  @override
  State<TrackParcelPage> createState() => _TrackParcelPageState();
}

class _TrackParcelPageState extends State<TrackParcelPage> {
  final _trackController = TextEditingController();

  @override
  void dispose() {
    _trackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TrackingViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Track parcel')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _trackController,
              decoration: const InputDecoration(
                labelText: 'Enter tracking ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final id = _trackController.text.trim();
                if (id.isEmpty) return;
                await vm.getParcel(id);
                if (vm.parcel != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackingDetailPage(parcel: vm.parcel!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Parcel not found')),
                  );
                }
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'My parcels',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: vm.parcels.length,
                      itemBuilder: (context, i) {
                        final p = vm.parcels[i];
                        return ListTile(
                          title: Text(p.trackingId),
                          subtitle: Text('${p.receiver.name} — ${p.status}'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TrackingDetailPage(parcel: p),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
