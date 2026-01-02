import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;
  final TextEditingController _trackingController = TextEditingController();

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  void _handleTrack() {
    final id = _trackingController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Tracking ID.')),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Tracking: $id (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PathauNow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () =>
                showSearch(context: context, delegate: _SimpleSearchDelegate()),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [_homeView(), _trackView(), _ordersView(), _profileView()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _homeView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Welcome to PathauNow',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  Widget _trackView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _trackingController,
            decoration: const InputDecoration(hintText: 'Enter tracking id'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _handleTrack, child: const Text('Track')),
        ],
      ),
    );
  }

  Widget _ordersView() {
    return const Center(child: Text('Orders (demo)'));
  }

  Widget _profileView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 64),
          const SizedBox(height: 12),
          const Text('Guest'),
        ],
      ),
    );
  }
}

class _SimpleSearchDelegate extends SearchDelegate<String?> {
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
    if (query.trim().isEmpty) {
      return const Center(child: Text('Enter a tracking id'));
    }
    return Center(child: Text('Search results for "$query" (demo)'));
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();
}
