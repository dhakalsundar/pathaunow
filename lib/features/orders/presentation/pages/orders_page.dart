import 'package:flutter/material.dart';
import 'package:pathau_now/features/dashboard/models/order_info.dart';
import 'package:pathau_now/features/dashboard/presentation/widgets/shared_widgets.dart';

class OrdersPage extends StatelessWidget {
  final Color primaryColor;
  final List<OrderInfo> orders;
  final OrderInfo? selectedOrder;
  final Function(String) onOrderTap;
  final Function(String) onTrackOrder;
  final VoidCallback onShowFilter;

  const OrdersPage({
    super.key,
    required this.primaryColor,
    required this.orders,
    required this.selectedOrder,
    required this.onOrderTap,
    required this.onTrackOrder,
    required this.onShowFilter,
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
        Row(
          children: [
            const Text(
              "My Orders",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onShowFilter,
              icon: const Icon(Icons.tune_rounded),
              label: const Text("Filter"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...orders.map(
          (o) => OrderCard(
            order: o,
            primary: primaryColor,
            onTap: () => onOrderTap(o.id),
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
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Orders",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onShowFilter,
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text("Filter"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: orders.map((o) {
                      final selected = selectedOrder?.id == o.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => onOrderTap(o.id),
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
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_rounded,
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
                                            o.id,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          StatusPill(status: o.status),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        o.route,
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        o.meta,
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
              child: selectedOrder == null
                  ? const Center(child: Text("Select an order to see details"))
                  : OrderDetails(
                      order: selectedOrder!,
                      primary: primaryColor,
                      onTrack: () => onTrackOrder(selectedOrder!.id),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
