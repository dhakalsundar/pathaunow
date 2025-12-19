import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color kPrimary = Color(0xFFF57C00); // PathauNow Orange
  int _index = 0;
  final TextEditingController _trackingController = TextEditingController();

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Row(
          children: [
            if (isTablet)
              _TabletNavRail(
                selectedIndex: _index,
                onSelect: (i) => setState(() => _index = i),
                primary: kPrimary,
              ),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [
                  _HomeDashboard(
                    trackingController: _trackingController,
                    onTrack: _handleTrack,
                    primary: kPrimary,
                  ),
                  _TrackTab(
                    trackingController: _trackingController,
                    onTrack: _handleTrack,
                    primary: kPrimary,
                  ),
                  const _OrdersTab(),
                  const _ProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isTablet
          ? null
          : _MobileBottomNav(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              primary: kPrimary,
            ),
    );
  }

  void _handleTrack() {
    final id = _trackingController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a Tracking ID.")),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Tracking started for: $id")));
  }
}

class _MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color primary;

  const _MobileBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primary,
      unselectedItemColor: Colors.black54,
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
    );
  }
}

class _TabletNavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color primary;

  const _TabletNavRail({
    required this.selectedIndex,
    required this.onSelect,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0x11000000))),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        labelType: NavigationRailLabelType.all,
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(color: primary),
        selectedLabelTextStyle: TextStyle(
          color: primary,
          fontWeight: FontWeight.w800,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(0.12),
                ),
                child: Image.asset(
                  "assets/images/pathau_logo.png",
                  height: 36,
                  width: 36,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.local_shipping_rounded,
                    size: 36,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "PathauNow",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
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

class _HomeDashboard extends StatelessWidget {
  final TextEditingController trackingController;
  final VoidCallback onTrack;
  final Color primary;

  const _HomeDashboard({
    required this.trackingController,
    required this.onTrack,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 700;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(primary: primary, isTablet: isTablet),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _TrackCard(
                trackingController: trackingController,
                onTrack: onTrack,
                primary: primary,
              ),
              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  final bool twoCols = constraints.maxWidth >= 900;
                  if (!twoCols) {
                    return Column(
                      children: [
                        _QuickActions(primary: primary),
                        const SizedBox(height: 16),
                        _SummaryCards(primary: primary),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _QuickActions(primary: primary)),
                      const SizedBox(width: 16),
                      Expanded(child: _SummaryCards(primary: primary)),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
              _RecentShipments(primary: primary),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final Color primary;
  final bool isTablet;

  const _Header({required this.primary, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, isTablet ? 18 : 16, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.90), const Color(0xFFFFA726)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: Image.asset(
              "assets/images/pathau_logo.png",
              height: isTablet ? 54 : 44,
              width: isTablet ? 54 : 44,
              errorBuilder: (_, __, ___) => Icon(
                Icons.local_shipping_rounded,
                size: isTablet ? 54 : 44,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PathauNow Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Track courier & parcels in real time",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notifications: demo only")),
              );
            },
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final TextEditingController trackingController;
  final VoidCallback onTrack;
  final Color primary;

  const _TrackCard({
    required this.trackingController,
    required this.onTrack,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Track your parcel",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            "Enter a Tracking ID to see current status.",
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x11000000)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: primary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: trackingController,
                    decoration: const InputDecoration(
                      hintText: "e.g. PNOW-123456",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onTrack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Track"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final Color primary;
  const _QuickActions({required this.primary});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionTile(
                primary: primary,
                icon: Icons.add_box_rounded,
                label: "Create",
              ),
              _ActionTile(
                primary: primary,
                icon: Icons.location_on_rounded,
                label: "Offices",
              ),
              _ActionTile(
                primary: primary,
                icon: Icons.support_agent_rounded,
                label: "Support",
              ),
              _ActionTile(
                primary: primary,
                icon: Icons.receipt_long_rounded,
                label: "Rates",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final Color primary;
  final IconData icon;
  final String label;

  const _ActionTile({
    required this.primary,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$label: demo only")));
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: primary.withOpacity(0.08),
          border: Border.all(color: primary.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final Color primary;
  const _SummaryCards({required this.primary});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This Week Summary",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  primary: primary,
                  title: "In Transit",
                  value: "4",
                  icon: Icons.local_shipping_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  primary: primary,
                  title: "Delivered",
                  value: "12",
                  icon: Icons.check_circle_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  primary: primary,
                  title: "Pending",
                  value: "2",
                  icon: Icons.pending_actions_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  primary: primary,
                  title: "Returned",
                  value: "1",
                  icon: Icons.assignment_return_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color primary;
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.primary,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentShipments extends StatelessWidget {
  final Color primary;
  const _RecentShipments({required this.primary});

  @override
  Widget build(BuildContext context) {
    const shipments = [
      {
        "id": "PNOW-102948",
        "from": "Kathmandu",
        "to": "Lalitpur",
        "status": "In Transit",
      },
      {
        "id": "PNOW-102913",
        "from": "Pokhara",
        "to": "Kathmandu",
        "status": "Delivered",
      },
      {
        "id": "PNOW-102877",
        "from": "Bhaktapur",
        "to": "Kathmandu",
        "status": "Pending",
      },
      {
        "id": "PNOW-102801",
        "from": "Chitwan",
        "to": "Pokhara",
        "status": "In Transit",
      },
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Shipments",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...shipments.map((s) {
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.local_shipping_rounded, color: primary),
                  ),
                  title: Text(
                    s["id"]!,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text("${s["from"]} → ${s["to"]}"),
                  trailing: _StatusPill(primary: primary, status: s["status"]!),
                ),
                const Divider(height: 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Color primary;
  final String status;
  const _StatusPill({required this.primary, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = primary.withOpacity(0.12);
    Color fg = primary;

    if (status == "Delivered") {
      bg = const Color(0xFF2E7D32).withOpacity(0.12);
      fg = const Color(0xFF2E7D32);
    } else if (status == "Pending") {
      bg = const Color(0xFFF9A825).withOpacity(0.18);
      fg = const Color(0xFFF9A825);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Text(
        status,
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: fg),
      ),
    );
  }
}

class _TrackTab extends StatelessWidget {
  final TextEditingController trackingController;
  final VoidCallback onTrack;
  final Color primary;

  const _TrackTab({
    required this.trackingController,
    required this.onTrack,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            "Track",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
          const SizedBox(height: 10),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter Tracking ID",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: trackingController,
                  decoration: InputDecoration(
                    hintText: "PNOW-XXXXXX",
                    prefixIcon: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTrack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Track Now"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _DemoTrackingTimeline(),
        ],
      ),
    );
  }
}

class _DemoTrackingTimeline extends StatelessWidget {
  const _DemoTrackingTimeline();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tracking Timeline (Demo)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          _TimelineItem(
            title: "Picked up",
            subtitle: "Parcel collected from sender",
            isDone: true,
          ),
          _TimelineItem(
            title: "In transit",
            subtitle: "Moving through sorting hub",
            isDone: true,
          ),
          _TimelineItem(
            title: "Out for delivery",
            subtitle: "Courier is on the way",
            isDone: false,
          ),
          _TimelineItem(
            title: "Delivered",
            subtitle: "Parcel delivered to receiver",
            isDone: false,
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;

  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: _Card(
        child: ListTile(
          leading: Icon(Icons.inventory_2_rounded),
          title: Text("Orders"),
          subtitle: Text("No orders added yet (demo for assignment)."),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: const [
          Text(
            "Profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          _Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person_rounded)),
              title: Text("PathauNow User"),
              subtitle: Text("user@email.com"),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
