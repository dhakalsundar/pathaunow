import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color kPrimary = Color(0xFFF57C00);
  static const Color kBg = Color(0xFFF6F7FB);

  int _index = 0;
  final TextEditingController _trackingController = TextEditingController();

  // Tablet split-view selection
  TrackingInfo? _selectedTracking;
  OrderInfo? _selectedOrder;

  final Map<String, TrackingInfo> _demoTrackingDb = {
    "PN-1001": TrackingInfo(
      id: "PN-1001",
      status: "In Transit",
      eta: "Today, 5:30 PM",
      from: "Koteshwor, KTM",
      to: "Baneshwor, KTM",
      steps: [
        TrackStep("Picked up from sender", "09:10 AM", true),
        TrackStep("Arrived at hub (KTM)", "11:05 AM", true),
        TrackStep("Out for delivery", "02:40 PM", true),
        TrackStep("Delivering to receiver", "05:10 PM", false),
      ],
    ),
    "PN-2007": TrackingInfo(
      id: "PN-2007",
      status: "Delivered",
      eta: "Delivered",
      from: "Kalanki, KTM",
      to: "Lalitpur",
      steps: [
        TrackStep("Picked up from sender", "Yesterday, 03:15 PM", true),
        TrackStep("Arrived at hub (KTM)", "Yesterday, 06:20 PM", true),
        TrackStep("Out for delivery", "Today, 09:00 AM", true),
        TrackStep("Delivered successfully", "Today, 11:35 AM", true),
      ],
    ),
    "PN-8888": TrackingInfo(
      id: "PN-8888",
      status: "Pending Pickup",
      eta: "Today",
      from: "Thimi, Bhaktapur",
      to: "Chabahil, KTM",
      steps: [
        TrackStep("Order created", "10:05 AM", true),
        TrackStep("Waiting for rider pickup", "10:10 AM", false),
        TrackStep("In Transit", "--", false),
        TrackStep("Delivered", "--", false),
      ],
    ),
  };

  late final List<OrderInfo> _orders = [
    OrderInfo(
      "PN-2007",
      "Delivered",
      "Kalanki → Lalitpur",
      "NPR 180",
      "Today, 11:35 AM",
    ),
    OrderInfo(
      "PN-1001",
      "In Transit",
      "Koteshwor → Baneshwor",
      "NPR 120",
      "ETA 5:30 PM",
    ),
    OrderInfo(
      "PN-8888",
      "Pending Pickup",
      "Thimi → Chabahil",
      "NPR 150",
      "Pickup today",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Default selection for tablet details
    _selectedTracking = _demoTrackingDb["PN-1001"];
    _selectedOrder = _orders.first;
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  void _setIndex(int i) => setState(() => _index = i);

  void _toast(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openSearch() async {
    final result = await showSearch<String?>(
      context: context,
      delegate: _TrackingSearchDelegate(
        hint: "Search Tracking ID (e.g., PN-1001)",
        suggestions: _demoTrackingDb.keys.toList(),
      ),
    );
    if (result == null) return;
    _trackingController.text = result;
    _setIndex(1);
    _handleTrack(result);
  }

  void _handleTrack([String? overrideId]) {
    final id = (overrideId ?? _trackingController.text).trim().toUpperCase();
    if (id.isEmpty) {
      _toast("Please enter a Tracking ID.");
      return;
    }
    final info = _demoTrackingDb[id];
    if (info == null) {
      _showNotFound(id);
      return;
    }

    final isTablet = MediaQuery.of(context).size.width >= 900;
    if (isTablet) {
      setState(() => _selectedTracking = info);
      return;
    }
    _showTrackingSheet(info);
  }

  void _showNotFound(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tracking not found"),
        content: Text(
          'No parcel found for "$id".\nTry: PN-1001, PN-2007, PN-8888',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showTrackingSheet(TrackingInfo info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 8,
          ),
          child: SingleChildScrollView(
            child: _TrackingDetails(
              info: info,
              primary: kPrimary,
              compact: false,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 900;

    final content = IndexedStack(
      index: _index,
      children: [
        _homeView(isTablet: isTablet),
        _trackView(isTablet: isTablet),
        _ordersView(isTablet: isTablet),
        _profileView(isTablet: isTablet),
      ],
    );

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            _BrandDot(primary: kPrimary),
            const SizedBox(width: 10),
            const Text(
              "PathauNow",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
            tooltip: "Search tracking",
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _toast("Notifications (demo)"),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: isTablet
          ? Row(
              children: [
                _TabletRail(
                  selectedIndex: _index,
                  onSelect: _setIndex,
                  primary: kPrimary,
                ),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: isTablet
          ? null
          : BottomNavigationBar(
              currentIndex: _index,
              onTap: _setIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: kPrimary,
              unselectedItemColor: Colors.grey.shade600,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner_rounded),
                  label: "Track",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_rounded),
                  label: "Orders",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
    );
  }

  // -------------------- HOME --------------------
  Widget _homeView({required bool isTablet}) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 22 : 16,
        vertical: 16,
      ),
      children: [
        _HeaderCard(primary: kPrimary),
        const SizedBox(height: 14),
        _ResponsiveGrid(
          isTablet: isTablet,
          children: [
            _QuickAction(
              title: "Track Parcel",
              subtitle: "Check status fast",
              icon: Icons.radar_rounded,
              primary: kPrimary,
              onTap: () => _setIndex(1),
            ),
            _QuickAction(
              title: "Create Order",
              subtitle: "Send a parcel",
              icon: Icons.add_box_rounded,
              primary: kPrimary,
              onTap: () => _toast("Create order (demo)"),
            ),
            _QuickAction(
              title: "Rider Request",
              subtitle: "Pickup now",
              icon: Icons.motorcycle_rounded,
              primary: kPrimary,
              onTap: () => _toast("Rider request (demo)"),
            ),
            _QuickAction(
              title: "Support",
              subtitle: "Help center",
              icon: Icons.support_agent_rounded,
              primary: kPrimary,
              onTap: () => _toast("Support (demo)"),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          "Recent activity",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ..._orders
            .take(3)
            .map(
              (o) => _OrderCard(
                order: o,
                primary: kPrimary,
                onTap: () {
                  _trackingController.text = o.id;
                  _setIndex(1);
                  _handleTrack(o.id);
                },
              ),
            ),
        const SizedBox(height: 18),
        _TipCard(primary: kPrimary),
      ],
    );
  }

  // -------------------- TRACK --------------------
  Widget _trackView({required bool isTablet}) {
    if (!isTablet) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CardShell(
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
                  controller: _trackingController,
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
                  onSubmitted: (_) => _handleTrack(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _handleTrack,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text("Track Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
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
            "Try demo tracking IDs",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _demoTrackingDb.keys.map((id) {
              return InkWell(
                onTap: () {
                  _trackingController.text = id;
                  _handleTrack(id);
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
                      Icon(Icons.qr_code_2_rounded, size: 18, color: kPrimary),
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
          ),
          const SizedBox(height: 18),
          _CardShell(
            child: Row(
              children: [
                Icon(Icons.security_rounded, color: kPrimary),
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

    // Tablet split view: left list + right details
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
                _CardShell(
                  child: Column(
                    children: [
                      TextField(
                        controller: _trackingController,
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
                        onSubmitted: (_) => _handleTrack(),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _handleTrack,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
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
                  "Demo IDs",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: _demoTrackingDb.values.map((info) {
                      final selected = _selectedTracking?.id == info.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => setState(() => _selectedTracking = info),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? kPrimary.withOpacity(.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected
                                    ? kPrimary.withOpacity(.25)
                                    : const Color(0xFFE6E8EE),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 42,
                                  width: 42,
                                  decoration: BoxDecoration(
                                    color: kPrimary.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.qr_code_2_rounded,
                                    color: kPrimary,
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
                                          _StatusPill(status: info.status),
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
            child: _CardShell(
              child: _selectedTracking == null
                  ? const Center(
                      child: Text("Select a tracking ID to see details"),
                    )
                  : SingleChildScrollView(
                      child: _TrackingDetails(
                        info: _selectedTracking!,
                        primary: kPrimary,
                        compact: true,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- ORDERS --------------------
  Widget _ordersView({required bool isTablet}) {
    if (!isTablet) {
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
                onPressed: () => _toast("Filter (demo)"),
                icon: const Icon(Icons.tune_rounded),
                label: const Text("Filter"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._orders.map(
            (o) => _OrderCard(
              order: o,
              primary: kPrimary,
              onTap: () {
                _trackingController.text = o.id;
                _setIndex(1);
                _handleTrack(o.id);
              },
            ),
          ),
        ],
      );
    }

    // Tablet split view orders
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
                      onPressed: () => _toast("Filter (demo)"),
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text("Filter"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: _orders.map((o) {
                      final selected = _selectedOrder?.id == o.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => setState(() => _selectedOrder = o),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? kPrimary.withOpacity(.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected
                                    ? kPrimary.withOpacity(.25)
                                    : const Color(0xFFE6E8EE),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: kPrimary.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_rounded,
                                    color: kPrimary,
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
                                          _StatusPill(status: o.status),
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
            child: _CardShell(
              child: _selectedOrder == null
                  ? const Center(child: Text("Select an order to see details"))
                  : _OrderDetails(
                      order: _selectedOrder!,
                      primary: kPrimary,
                      onTrack: () {
                        _trackingController.text = _selectedOrder!.id;
                        _setIndex(1);
                        _handleTrack(_selectedOrder!.id);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- PROFILE --------------------
  Widget _profileView({required bool isTablet}) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 22 : 16,
        vertical: 16,
      ),
      children: [
        _CardShell(
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: kPrimary.withOpacity(.12),
                child: Icon(Icons.person_rounded, color: kPrimary, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Guest User",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("Sign in to manage orders and addresses"),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: null, child: Text("Login")), // demo
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SettingsTile(
          icon: Icons.location_on_rounded,
          title: "Saved Addresses",
          subtitle: "Home, Office, etc.",
          onTap: () => _toast("Addresses (demo)"),
          primary: kPrimary,
        ),
        _SettingsTile(
          icon: Icons.payment_rounded,
          title: "Payments",
          subtitle: "Wallet and history",
          onTap: () => _toast("Payments (demo)"),
          primary: kPrimary,
        ),
        _SettingsTile(
          icon: Icons.support_agent_rounded,
          title: "Help & Support",
          subtitle: "FAQs and contact",
          onTap: () => _toast("Support (demo)"),
          primary: kPrimary,
        ),
        _SettingsTile(
          icon: Icons.settings_rounded,
          title: "Settings",
          subtitle: "App preferences",
          onTap: () => _toast("Settings (demo)"),
          primary: kPrimary,
        ),
        const SizedBox(height: 10),
        Text(
          "Version 1.0.0 (demo)",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// ---------------- Models ----------------
class TrackingInfo {
  final String id;
  final String status;
  final String eta;
  final String from;
  final String to;
  final List<TrackStep> steps;

  TrackingInfo({
    required this.id,
    required this.status,
    required this.eta,
    required this.from,
    required this.to,
    required this.steps,
  });
}

class TrackStep {
  final String title;
  final String time;
  final bool done;
  TrackStep(this.title, this.time, this.done);
}

class OrderInfo {
  final String id;
  final String status;
  final String route;
  final String price;
  final String meta;
  OrderInfo(this.id, this.status, this.route, this.price, this.meta);
}

// ---------------- Widgets ----------------
class _TabletRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color primary;

  const _TabletRail({
    required this.selectedIndex,
    required this.onSelect,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: const Color(0xFFE6E8EE))),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: IconThemeData(color: primary),
        selectedLabelTextStyle: TextStyle(
          color: primary,
          fontWeight: FontWeight.w800,
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: Text("Home"),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: Text("Track"),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.inventory_2_rounded),
            label: Text("Orders"),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.person_rounded),
            label: Text("Profile"),
          ),
        ],
      ),
    );
  }
}

class _BrandDot extends StatelessWidget {
  final Color primary;
  const _BrandDot({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, size: 15, color: Colors.white),
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
        ],
      );
    }

    // tablet: 2x2 but more spaced
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [children[0], const SizedBox(height: 12), children[2]],
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

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

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

class _OrderCard extends StatelessWidget {
  final OrderInfo order;
  final Color primary;
  final VoidCallback onTap;

  const _OrderCard({
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
                        _StatusPill(status: order.status),
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

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

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

class _TipCard extends StatelessWidget {
  final Color primary;
  const _TipCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color primary;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.primary,
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}

// ----- Tablet Details widgets -----
class _TrackingDetails extends StatelessWidget {
  final TrackingInfo info;
  final Color primary;
  final bool compact;

  const _TrackingDetails({
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
            _StatusPill(status: info.status),
            const Spacer(),
            Text(info.id, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 10),
        _InfoRow(label: "From", value: info.from),
        _InfoRow(label: "To", value: info.to),
        _InfoRow(label: "ETA", value: info.eta),
        const SizedBox(height: 12),
        const Text(
          "Tracking timeline",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        ...List.generate(info.steps.length, (i) {
          final s = info.steps[i];
          final isLast = i == info.steps.length - 1;
          return _TimelineTile(
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
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Support is demo 🙂")),
                  ),
                  icon: const Icon(Icons.support_agent),
                  label: const Text("Contact Support"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Live tracking is demo 🙂")),
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

class _OrderDetails extends StatelessWidget {
  final OrderInfo order;
  final Color primary;
  final VoidCallback onTrack;

  const _OrderDetails({
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
              _StatusPill(status: order.status),
              const Spacer(),
              Text(
                order.price,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoRow(label: "Route", value: order.route),
          _InfoRow(label: "Info", value: order.meta),
          const SizedBox(height: 14),
          _CardShell(
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

class _TimelineTile extends StatelessWidget {
  final String title;
  final String time;
  final bool done;
  final bool isLast;
  final Color primary;
  final bool compact;

  const _TimelineTile({
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

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

class _TrackingSearchDelegate extends SearchDelegate<String?> {
  final String hint;
  final List<String> suggestions;

  _TrackingSearchDelegate({required this.hint, required this.suggestions})
    : super(searchFieldLabel: hint);

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];
    }
    return [];
  }

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final q = query.trim();
    if (q.isEmpty) return const Center(child: Text("Enter a Tracking ID"));
    return ListTile(
      leading: const Icon(Icons.search),
      title: Text('Track "$q"'),
      subtitle: const Text("Open tracking details"),
      onTap: () => close(context, q),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.trim().toLowerCase();
    final items = suggestions
        .where((s) => q.isEmpty ? true : s.toLowerCase().contains(q))
        .take(8)
        .toList();

    if (items.isEmpty) return const Center(child: Text("No suggestions"));

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final id = items[i];
        return ListTile(
          leading: const Icon(Icons.qr_code_2_rounded),
          title: Text(id),
          subtitle: const Text("Demo tracking ID"),
          onTap: () => close(context, id),
        );
      },
    );
  }
}
