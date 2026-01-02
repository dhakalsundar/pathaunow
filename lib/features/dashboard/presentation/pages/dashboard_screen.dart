import 'package:flutter/material.dart';
import 'package:pathau_now/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pathau_now/features/auth/domain/entities/user_entity.dart';
import 'package:pathau_now/features/auth/presentation/pages/login_screen.dart';
import 'package:pathau_now/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:pathau_now/features/tracking/domain/entities/parcel_entity.dart';
import 'package:pathau_now/features/tracking/domain/usecases/create_parcel_usecase.dart';
import 'package:pathau_now/features/tracking/domain/usecases/get_parcel_usecase.dart';
import 'package:uuid/uuid.dart';

Color _withOpacity(Color c, double o) {
  final int v = c.toARGB32();
  final int r = (v >> 16) & 0xFF;
  final int g = (v >> 8) & 0xFF;
  final int b = v & 0xFF;
  return Color.fromRGBO(r, g, b, o);
}

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color kPrimary = Color(0xFFF57C00);

  int _index = 0;
  final TextEditingController _trackingController = TextEditingController();

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _handleTrack() async {
    final id = _trackingController.text.trim();
    if (id.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Tracking ID.')),
      );
      return;
    }

    try {
      final repo = TrackingRepositoryImpl();
      final usecase = GetParcelUseCase(repo);
      final parcel = await usecase.execute(id);

      if (!mounted) return;

      if (parcel == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No parcel found for: $id')));
        return;
      }

      _showParcelDialog(parcel);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tracking failed: $e')));
    }
  }

  void _showParcelDialog(ParcelEntity parcel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Parcel ${parcel.trackingId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sender: ${parcel.sender}'),
            Text('Recipient: ${parcel.recipient}'),
            Text('Status: ${parcel.status}'),
            Text('Courier: ${parcel.courierName ?? 'Unassigned'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _createDemoParcel() async {
    try {
      final authRepo = AuthRepositoryImpl();
      final current = await authRepo.getCurrentUser();

      if (current == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login required to create parcel')),
        );
        return;
      }

      final repo = TrackingRepositoryImpl();
      final create = CreateParcelUseCase(repo);

      final uuid = const Uuid();
      final trackingId = "PNOW-${uuid.v4().substring(0, 6).toUpperCase()}";

      final parcel = ParcelEntity(
        trackingId: trackingId,
        sender: current.name,
        recipient: "Receiver Inc.",
        status: "Created",
        courierName: null,
        ownerEmail: current.email,
      );

      await create.execute(parcel);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demo parcel created: $trackingId')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create parcel failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createDemoParcel,
        icon: const Icon(Icons.add),
        label: const Text("New Parcel"),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
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
                  color: _withOpacity(primary, 0.12),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  size: 36,
                  color: primary,
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
  final Future<void> Function() onTrack;
  final Color primary;

  const _HomeDashboard({
    required this.trackingController,
    required this.onTrack,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? "Good morning"
        : now.hour < 17
        ? "Good afternoon"
        : "Good evening";

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "$greeting 👋",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Track your parcel",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: trackingController,
                decoration: InputDecoration(
                  hintText: "e.g. PNOW-ABC123",
                  prefixIcon: Icon(Icons.search_rounded, color: primary),
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
                  onPressed: () => onTrack(),
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
        const SizedBox(height: 12),
        _Card(
          child: ListTile(
            leading: Icon(Icons.info_rounded, color: primary),
            title: const Text("Demo Mode"),
            subtitle: const Text("Create a demo parcel using the + button."),
          ),
        ),
      ],
    );
  }
}

class _TrackTab extends StatelessWidget {
  final TextEditingController trackingController;
  final Future<void> Function() onTrack;
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
                    onPressed: () => onTrack(),
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

class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  List<ParcelEntity> _parcels = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadParcels();
  }

  Future<void> _loadParcels() async {
    setState(() => _loading = true);
    final authRepo = AuthRepositoryImpl();
    final user = await authRepo.getCurrentUser();
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _parcels = [];
        _loading = false;
      });
      return;
    }

    final repo = TrackingRepositoryImpl();
    final list = await repo.getParcelsForUser(user.email);
    if (!mounted) return;
    setState(() {
      _parcels = list;
      _loading = false;
    });
  }

  Future<void> _assignCourier(String trackingId) async {
    final TextEditingController ctrl = TextEditingController();
    final name = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assign courier'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Courier name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final repo = TrackingRepositoryImpl();
    await repo.assignCourier(trackingId, name);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Assigned $name to $trackingId')));
    await _loadParcels();
  }

  Future<void> _updateStatus(String trackingId) async {
    final statuses = [
      'Created',
      'In Transit',
      'Out for delivery',
      'Delivered',
      'Returned',
      'Pending',
    ];
    final chosen = await showDialog<String?>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Update status'),
        children: statuses
            .map(
              (s) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, s),
                child: Text(s),
              ),
            )
            .toList(),
      ),
    );
    if (chosen == null) return;
    final repo = TrackingRepositoryImpl();
    await repo.updateParcelStatus(trackingId, chosen);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Status updated: $chosen')));
    await _loadParcels();
  }

  void _showParcelOptions(ParcelEntity p) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                p.trackingId,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            ListTile(title: Text('Status: ${p.status}')),
            ListTile(title: Text('Courier: ${p.courierName ?? 'Unassigned'}')),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _assignCourier(p.trackingId),
                    child: const Text('Assign Courier'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(p.trackingId),
                    child: const Text('Update Status'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _Card(
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : (_parcels.isEmpty
                  ? ListTile(
                      leading: const Icon(Icons.inventory_2_rounded),
                      title: const Text('Orders'),
                      subtitle: const Text('No parcels found'),
                    )
                  : Column(
                      children: [
                        const ListTile(
                          leading: Icon(Icons.inventory_2_rounded),
                          title: Text('Your Parcels'),
                        ),
                        const Divider(),
                        ..._parcels.map(
                          (p) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              p.trackingId,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: Text('${p.status} • ${p.recipient}'),
                            trailing: Text(p.courierName ?? 'No courier'),
                            onTap: () => _showParcelOptions(p),
                          ),
                        ),
                      ],
                    )),
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  UserEntity? _user;
  List<ParcelEntity> _parcels = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final repo = AuthRepositoryImpl();
    final u = await repo.getCurrentUser();
    if (u != null) {
      final tRepo = TrackingRepositoryImpl();
      final list = await tRepo.getParcelsForUser(u.email);
      if (!mounted) return;
      setState(() {
        _user = u;
        _parcels = list;
      });
      return;
    }
    if (!mounted) return;
    setState(() => _user = u);
  }

  Future<void> _logout() async {
    final repo = AuthRepositoryImpl();
    await repo.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            "Profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              title: Text(_user?.name ?? "Guest"),
              subtitle: Text(_user?.email ?? "Not signed in"),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Parcels',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                if (_parcels.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No parcels yet',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  )
                else
                  ..._parcels.map(
                    (p) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        p.trackingId,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text('${p.status} • ${p.recipient}'),
                      trailing: Text(p.courierName ?? 'No courier'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text("Logout"),
              onTap: _logout,
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
