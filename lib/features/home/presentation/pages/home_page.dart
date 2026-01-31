import 'package:flutter/material.dart';
import 'package:pathau_now/features/dashboard/models/order_info.dart';
import 'package:pathau_now/features/dashboard/presentation/widgets/shared_widgets.dart';
import 'package:pathau_now/features/map/presentation/pages/map_screen.dart';

class HomePage extends StatelessWidget {
  final Color primaryColor;
  final List<OrderInfo> recentOrders;
  final VoidCallback onTrackParcel;
  final Function(String) onOrderTap;

  const HomePage({
    super.key,
    required this.primaryColor,
    required this.recentOrders,
    required this.onTrackParcel,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 900;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 22 : 16,
        vertical: 16,
      ),
      children: [
        _HeaderCard(primary: primaryColor),
        const SizedBox(height: 14),
        _ResponsiveGrid(
          isTablet: isTablet,
          children: [
            _QuickAction(
              title: "Track Parcel",
              subtitle: "Check status fast",
              icon: Icons.radar_rounded,
              primary: primaryColor,
              onTap: onTrackParcel,
            ),
            _QuickAction(
              title: "Create Order",
              subtitle: "Send a parcel",
              icon: Icons.add_box_rounded,
              primary: primaryColor,
              onTap: () => Navigator.pushNamed(context, '/create-parcel'),
            ),
            _QuickAction(
              title: "Rider Request",
              subtitle: "Pickup now",
              icon: Icons.motorcycle_rounded,
              primary: primaryColor,
              onTap: () => Navigator.pushNamed(
                context,
                '/create-parcel',
                arguments: {'pickupNow': true},
              ),
            ),
            _QuickAction(
              title: "Support",
              subtitle: "Help center",
              icon: Icons.support_agent_rounded,
              primary: primaryColor,
              onTap: () => Navigator.pushNamed(context, '/support'),
            ),
            _QuickAction(
              title: "Live Map",
              subtitle: "View route & navigate",
              icon: Icons.map_rounded,
              primary: primaryColor,
              onTap: () => Navigator.pushNamed(context, MapScreen.routeName),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          "Recent activity",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...recentOrders
            .take(3)
            .map(
              (o) => OrderCard(
                order: o,
                primary: primaryColor,
                onTap: () => onOrderTap(o.id),
              ),
            ),
        const SizedBox(height: 18),
        _TipCard(primary: primaryColor),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Color primary;
  const _HeaderCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(.85), const Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(.28),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Fast courier & parcel tracking",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Track, manage orders, and get updates in one place.",
                  style: TextStyle(color: Colors.white.withOpacity(.9)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    _MiniChip(icon: Icons.verified_rounded, label: "Secure"),
                    SizedBox(width: 8),
                    _MiniChip(icon: Icons.flash_on_rounded, label: "Fast"),
                    SizedBox(width: 8),
                    _MiniChip(
                      icon: Icons.support_agent_rounded,
                      label: "Support",
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final bool isTablet;
  final List<Widget> children;
  const _ResponsiveGrid({required this.isTablet, required this.children});

  @override
  Widget build(BuildContext context) {
    if (!isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: children[0]),
              const SizedBox(width: 12),
              Expanded(child: children[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: children[2]),
              const SizedBox(width: 12),
              Expanded(child: children[3]),
            ],
          ),
          if (children.length > 4) ...[const SizedBox(height: 12), children[4]],
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              children[0],
              const SizedBox(height: 12),
              children[2],
              if (children.length > 4) ...[
                const SizedBox(height: 12),
                children[4],
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [children[1], const SizedBox(height: 12), children[3]],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primary;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: primary.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final Color primary;
  const _TipCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.lightbulb_rounded, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pro tip",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  "Save frequent tracking IDs for faster access (feature idea).",
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
