import 'package:flutter/material.dart';
import 'package:pathau_now/features/dashboard/models/tracking_info.dart';
import 'package:pathau_now/features/dashboard/models/order_info.dart';
import 'package:pathau_now/features/support/presentation/pages/support_page.dart';

class CardShell extends StatelessWidget {
  final Widget child;
  const CardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill({super.key, required this.status});

  Color _bg(String s) {
    final t = s.toLowerCase();
    if (t.contains("deliver")) return const Color(0xFFE8F7EE);
    if (t.contains("transit")) return const Color(0xFFEAF2FF);
    if (t.contains("pending")) return const Color(0xFFFFF4E5);
    return const Color(0xFFF1F2F6);
  }

  Color _fg(String s) {
    final t = s.toLowerCase();
    if (t.contains("deliver")) return const Color(0xFF1B7F3A);
    if (t.contains("transit")) return const Color(0xFF2157D6);
    if (t.contains("pending")) return const Color(0xFFB35A00);
    return const Color(0xFF4B5563);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bg(status),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _fg(status).withOpacity(.18)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _fg(status),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderInfo order;
  final Color primary;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6E8EE)),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.inventory_2_rounded, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.id,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.route,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.meta,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.price,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SimpleInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const SimpleInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineTile extends StatelessWidget {
  final String title;
  final String time;
  final bool done;
  final bool isLast;
  final Color primary;
  final bool compact;

  const TimelineTile({
    super.key,
    required this.title,
    required this.time,
    required this.done,
    required this.isLast,
    required this.primary,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = done ? primary : Colors.grey.shade400;
    final lineColor = done ? primary.withOpacity(.5) : Colors.grey.shade300;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    height: compact ? 28 : 34,
                    width: 2,
                    margin: const EdgeInsets.only(top: 6),
                    color: lineColor,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(compact ? 10 : 12),
              decoration: BoxDecoration(
                color: done
                    ? primary.withOpacity(.06)
                    : const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    done ? Icons.check_circle_rounded : Icons.timelapse_rounded,
                    color: dotColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingDetails extends StatelessWidget {
  final TrackingInfo info;
  final Color primary;
  final bool compact;

  const TrackingDetails({
    super.key,
    required this.info,
    required this.primary,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StatusPill(status: info.status),
            const Spacer(),
            Text(info.id, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 10),
        SimpleInfoRow(label: "From", value: info.from),
        SimpleInfoRow(label: "To", value: info.to),
        SimpleInfoRow(label: "ETA", value: info.eta),
        const SizedBox(height: 12),
        const Text(
          "Tracking timeline",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        ...List.generate(info.steps.length, (i) {
          final s = info.steps[i];
          final isLast = i == info.steps.length - 1;
          return TimelineTile(
            title: s.title,
            time: s.time,
            done: s.done,
            isLast: isLast,
            primary: primary,
            compact: compact,
          );
        }),
        if (!compact) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SupportPage(reference: info.id),
                    ),
                  ),
                  icon: const Icon(Icons.support_agent),
                  label: const Text("Contact Support"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Live tracking is not available for this parcel",
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.my_location),
                  label: const Text("Live Track"),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class OrderDetails extends StatelessWidget {
  final OrderInfo order;
  final Color primary;
  final VoidCallback onTrack;

  const OrderDetails({
    super.key,
    required this.order,
    required this.primary,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.id,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              StatusPill(status: order.status),
              const Spacer(),
              Text(
                order.price,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SimpleInfoRow(label: "Route", value: order.route),
          SimpleInfoRow(label: "Info", value: order.meta),
          const SizedBox(height: 14),
          CardShell(
            child: Row(
              children: [
                Icon(Icons.local_shipping_rounded, color: primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Tap Track to open tracking details for this order.",
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onTrack,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.radar_rounded),
              label: const Text("Track this Order"),
            ),
          ),
        ],
      ),
    );
  }
}
