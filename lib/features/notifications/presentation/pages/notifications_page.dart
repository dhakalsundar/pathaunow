import 'package:flutter/material.dart';
import 'package:pathau_now/core/services/http_service.dart';

class NotificationsPage extends StatefulWidget {
  static const routeName = '/notifications';
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _loading = true;
  List<dynamic> _notifications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await HttpService.get('/notifications');
      setState(() {
        _notifications = (res['notifications'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.separated(
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = _notifications[i];
                return ListTile(
                  title: Text(n['title'] ?? n['message'] ?? ''),
                  subtitle: Text(n['message'] ?? ''),
                  trailing: Text(n['createdAt']?.toString() ?? ''),
                );
              },
            ),
    );
  }
}
