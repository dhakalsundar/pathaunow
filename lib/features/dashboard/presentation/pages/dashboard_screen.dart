import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pathau_now/core/localization/app_localizations.dart';
import 'package:pathau_now/core/services/hive/hive_service.dart';
import 'package:pathau_now/core/services/locale_service.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pathau_now/features/profile/presentation/pages/profile_page.dart';
import 'package:pathau_now/features/home/presentation/pages/home_page.dart';
import 'package:pathau_now/features/tracking/presentation/pages/track_page.dart';
import 'package:pathau_now/features/orders/presentation/pages/orders_page.dart';
import 'package:pathau_now/features/tracking/presentation/viewmodels/parcel_viewmodel.dart';
import 'package:pathau_now/features/tracking/domain/entities/parcel_entity.dart';
import 'package:pathau_now/features/dashboard/models/tracking_info.dart';
import 'package:pathau_now/features/dashboard/models/order_info.dart';
import 'package:pathau_now/features/dashboard/presentation/widgets/shared_widgets.dart';
import 'package:pathau_now/core/utils/app_utils.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color kPrimary = Color(0xFFF57C00);
  static const Color kBg = Color(0xFFF6F7FB);

  int _index = 0;
  final TextEditingController _trackingController = TextEditingController();

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
    // set initial selected tab from constructor
    _index = widget.initialIndex;
    _selectedOrder = _orders.first;

    // Ensure AuthViewModel loads current user when dashboard opens and prefetch user's parcels
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      print('📱 Dashboard: Fetching current user...');
      await authVm.getCurrentUser();
      print('📱 Dashboard: User = ${authVm.user?.name ?? "null"}');
      print('📱 Dashboard: User email = ${authVm.user?.email ?? "null"}');

      // Prefetch user's parcels to show recent IDs and select first if available
      final pv = Provider.of<ParcelViewModel>(context, listen: false);
      try {
        await pv.getUserParcels();
        if (pv.userParcels.isNotEmpty && mounted) {
          final firstParcel = pv.userParcels.first;
          setState(() {
            _selectedTracking = _parcelToTrackingInfo(firstParcel);
          });
        } else {
          // Fallback to demo tracking
          setState(() => _selectedTracking = _demoTrackingDb["PN-1001"]);
        }
      } catch (_) {
        if (mounted) {
          setState(() => _selectedTracking = _demoTrackingDb["PN-1001"]);
        }
      }
    });
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

  Future<void> _openSearch() async {
    // try to load user's parcels for suggestions
    final pv = Provider.of<ParcelViewModel>(context, listen: false);
    try {
      await pv.getUserParcels();
    } catch (_) {}

    final suggestions = pv.userParcels.map((p) => p.trackingId).toList();

    final result = await showSearch<String?>(
      context: context,
      delegate: _TrackingSearchDelegate(
        hint: "Search Tracking ID (e.g., PN-1001)",
        suggestions: suggestions.isNotEmpty
            ? suggestions
            : _demoTrackingDb.keys.toList(),
      ),
    );
    if (result == null) return;
    _trackingController.text = result;
    _setIndex(1);
    await _handleTrack(result);
  }

  Future<void> _handleTrack([String? overrideId]) async {
    final id = (overrideId ?? _trackingController.text).trim().toUpperCase();
    if (id.isEmpty) {
      _toast("Please enter a Tracking ID.");
      return;
    }

    final pv = Provider.of<ParcelViewModel>(context, listen: false);
    try {
      await pv.getParcelByTracking(id);
      final parcel = pv.selectedParcel;
      if (parcel == null) {
        _showNotFound(id);
        return;
      }

      final info = _parcelToTrackingInfo(parcel);

      final isTablet = MediaQuery.of(context).size.width >= 900;
      if (isTablet) {
        setState(() => _selectedTracking = info);
        return;
      }
      _showTrackingSheet(info);
    } catch (e) {
      _showNotFound(id);
    }
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
            child: TrackingDetails(
              info: info,
              primary: kPrimary,
              compact: false,
            ),
          ),
        ),
      ),
    );
  }

  // Shows a bottom sheet to choose camera or gallery and uploads chosen image
  Future<void> _showImageSourceSheet(
    BuildContext context,
    AuthViewModel authVm,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.of(context).pop();
                final picker = ImagePicker();
                final XFile? picked = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (picked == null) return;
                final file = File(picked.path);
                // Show a blocking progress dialog while uploading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) =>
                      const Center(child: CircularProgressIndicator()),
                );
                try {
                  await authVm.updateProfileImage(file);
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile photo updated')),
                  );
                  setState(() {});

                  // Navigate to profile tab via route so user sees updated photo
                  Navigator.pushReplacementNamed(
                    context,
                    DashboardScreen.routeName,
                    arguments: {'initialIndex': 3},
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final picker = ImagePicker();
                final XFile? picked = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked == null) return;
                final file = File(picked.path);
                // Show a blocking progress dialog while uploading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) =>
                      const Center(child: CircularProgressIndicator()),
                );
                try {
                  await authVm.updateProfileImage(file);
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile photo updated')),
                  );
                  setState(() {});

                  // Navigate to profile tab via route so user sees updated photo
                  Navigator.pushReplacementNamed(
                    context,
                    DashboardScreen.routeName,
                    arguments: {'initialIndex': 3},
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.of(context).pop('en'),
            ),
            ListTile(
              title: const Text('नेपाली (Nepali)'),
              onTap: () => Navigator.of(context).pop('ne'),
            ),
            ListTile(
              title: const Text('Cancel'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );

    if (selected != null && selected.isNotEmpty) {
      try {
        // update app locale via LocaleService so UI refreshes
        await Provider.of<LocaleService>(
          context,
          listen: false,
        ).setLocale(selected);
        if (!mounted) return;
        setState(() {}); // refresh UI where language is shown
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).t('language_set')),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to set language: $e')));
      }
    }
  }

  // Map ParcelEntity into the existing TrackingInfo model used by the UI
  TrackingInfo _parcelToTrackingInfo(ParcelEntity p) {
    final timeline = List<TrackingTimelineEntity>.from(p.timeline)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final steps = <TrackStep>[];
    for (var i = 0; i < timeline.length; i++) {
      final t = timeline[i];
      final isLast = i == timeline.length - 1;
      final done = !isLast || p.status.toLowerCase() == 'delivered';
      final titleParts = [t.status];
      if (t.location != null && t.location!.isNotEmpty) {
        titleParts.add(t.location!);
      }
      if (t.description != null && t.description!.isNotEmpty) {
        titleParts.add(t.description!);
      }
      final title = titleParts.join(' — ');
      final time = DateTimeUtils.formatDateTime(t.timestamp);
      steps.add(TrackStep(title, time, done));
    }

    final from =
        '${p.sender.address}${p.sender.city.isNotEmpty ? ', ${p.sender.city}' : ''}';
    final to =
        '${p.receiver.address}${p.receiver.city.isNotEmpty ? ', ${p.receiver.city}' : ''}';
    final eta = p.estimatedDelivery != null
        ? DateTimeUtils.formatDateTime(p.estimatedDelivery!)
        : (p.actualDelivery != null ? 'Delivered' : '-');

    return TrackingInfo(
      id: p.trackingId,
      status: p.status,
      eta: eta,
      from: from,
      to: to,
      steps: steps,
    );
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'ne':
        return 'नेपाली (Nepali)';
      case 'en':
      default:
        return 'English';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              onTap: () => Navigator.of(context).pop(null),
            ),
            ListTile(
              title: const Text('Pending Pickup'),
              onTap: () => Navigator.of(context).pop('Pending Pickup'),
            ),
            ListTile(
              title: const Text('In Transit'),
              onTap: () => Navigator.of(context).pop('In Transit'),
            ),
            ListTile(
              title: const Text('Delivered'),
              onTap: () => Navigator.of(context).pop('Delivered'),
            ),
            ListTile(
              title: const Text('Cancelled'),
              onTap: () => Navigator.of(context).pop('Cancelled'),
            ),
            ListTile(
              title: const Text('Cancel'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    if (selected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Filter cleared')));
      return;
    }

    setState(() {
      // apply a simple local filter on orders
      // In future this could call an API to filter server-side
      _selectedOrder = _orders.firstWhere(
        (o) => o.status == selected,
        orElse: () => _orders.first,
      );
      _trackingController.text = _selectedOrder!.id;
      _setIndex(1);
    });
  }

  Future<void> _clearCache() async {
    try {
      // clear parcels cache
      final parcels = HiveService.parcelsBox();
      await parcels.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to clear cache: $e')));
    }
  }

  Future<void> _clearHistory() async {
    try {
      // for now clear parcels as history
      final parcels = HiveService.parcelsBox();
      await parcels.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('History cleared')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to clear history: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 900;

    final content = IndexedStack(
      index: _index,
      children: [
        HomePage(
          primaryColor: kPrimary,
          recentOrders: _orders,
          onTrackParcel: () => _setIndex(1),
          onOrderTap: (id) {
            _trackingController.text = id;
            _setIndex(1);
            _handleTrack(id);
          },
        ),
        TrackPage(
          primaryColor: kPrimary,
          trackingController: _trackingController,
          selectedTracking: _selectedTracking,
          demoTrackingDb: _demoTrackingDb,
          onTrack: _handleTrack,
          onTrackId: (id) {
            _trackingController.text = id;
            _handleTrack(id);
          },
        ),
        OrdersPage(
          primaryColor: kPrimary,
          orders: _orders,
          selectedOrder: _selectedOrder,
          onOrderTap: (id) {
            setState(() {
              _selectedOrder = _orders.firstWhere((o) => o.id == id);
            });
          },
          onTrackOrder: (id) {
            _trackingController.text = id;
            _setIndex(1);
            _handleTrack(id);
          },
          onShowFilter: () => _showFilterSheet(context),
        ),
        ProfilePage(onNavigateBack: () => _setIndex(0), primaryColor: kPrimary),
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
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
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
}

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
          subtitle: const Text("Tracking ID"),
          onTap: () => close(context, id),
        );
      },
    );
  }
}
