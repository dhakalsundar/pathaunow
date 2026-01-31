import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/features/tracking/presentation/viewmodels/parcel_viewmodel.dart';
import 'package:pathau_now/features/dashboard/models/tracking_info.dart';
import 'package:pathau_now/features/dashboard/presentation/widgets/shared_widgets.dart';

class TrackPage extends StatelessWidget {
  final Color primaryColor;
  final TextEditingController trackingController;
  final TrackingInfo? selectedTracking;
  final Map<String, TrackingInfo> demoTrackingDb;
  final Function() onTrack;
  final Function(String) onTrackId;

  const TrackPage({
    super.key,
    required this.primaryColor,
    required this.trackingController,
    required this.selectedTracking,
    required this.demoTrackingDb,
    required this.onTrack,
    required this.onTrackId,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 900;

    if (!isTablet) {
      return _buildMobileView(context);
    }

    return _buildTabletView(context);
  }

  Widget _buildMobileView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Track your parcel",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                "Enter Tracking ID to see status and timeline.",
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: trackingController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: "e.g., PN-1001",
                  prefixIcon: const Icon(Icons.confirmation_number_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF4F5F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => onTrack(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onTrack,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text("Track Now"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          "Recent tracking IDs",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Consumer<ParcelViewModel>(
          builder: (context, pv, _) {
            final ids = pv.userParcels.isNotEmpty
                ? pv.userParcels.map((p) => p.trackingId).toList()
                : demoTrackingDb.keys.toList();

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ids.map((id) {
                return InkWell(
                  onTap: () {
                    trackingController.text = id;
                    onTrackId(id);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE6E8EE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 18,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          id,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 18),
        CardShell(
          child: Row(
            children: [
              Icon(Icons.security_rounded, color: primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Tip: Share tracking ID only with trusted people.",
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(
            width: 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Track",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                CardShell(
                  child: Column(
                    children: [
                      TextField(
                        controller: trackingController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: "Enter Tracking ID (e.g., PN-1001)",
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF4F5F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => onTrack(),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: onTrack,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Track"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Recent IDs",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: demoTrackingDb.values.map((info) {
                      final selected = selectedTracking?.id == info.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => onTrackId(info.id),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primaryColor.withOpacity(.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected
                                    ? primaryColor.withOpacity(.25)
                                    : const Color(0xFFE6E8EE),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 42,
                                  width: 42,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.qr_code_2_rounded,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            info.id,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          StatusPill(status: info.status),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${info.from} → ${info.to}",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CardShell(
              child: selectedTracking == null
                  ? const Center(
                      child: Text("Select a tracking ID to see details"),
                    )
                  : SingleChildScrollView(
                      child: TrackingDetails(
                        info: selectedTracking!,
                        primary: primaryColor,
                        compact: true,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
