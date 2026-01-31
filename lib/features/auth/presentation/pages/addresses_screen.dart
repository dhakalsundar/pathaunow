import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/address_viewmodel.dart';

class AddressesScreen extends StatefulWidget {
  static const String routeName = '/addresses';
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressViewModel>(context, listen: false).getAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Addresses'),
        backgroundColor: const Color(0xFFF57C00),
      ),
      body: Consumer<AddressViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(child: Text('Error: ${vm.error}'));
          }

          final addresses = vm.addresses;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length + 1,
            itemBuilder: (context, index) {
              if (index == addresses.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          final controller = TextEditingController();
                          return AlertDialog(
                            title: const Text('Add Address'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: 'Address label or details',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final text = controller.text.trim();
                                  if (text.isEmpty) return;
                                  try {
                                    await Provider.of<AddressViewModel>(
                                      context,
                                      listen: false,
                                    ).createAddress(
                                      addressData: {
                                        'label': text,
                                        'fullName': text,
                                        'phone': '',
                                        'address': text,
                                        'city': '',
                                        'state': '',
                                        'zipCode': '',
                                      },
                                    );
                                    Navigator.of(ctx).pop();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed: $e')),
                                    );
                                  }
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add_location_rounded),
                    label: const Text('Add Address'),
                  ),
                );
              }

              final a = addresses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(a.label),
                  subtitle: Text(a.fullAddress),
                  trailing: a.isDefault
                      ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
                      : null,
                  onTap: () {
                    Provider.of<AddressViewModel>(
                      context,
                      listen: false,
                    ).selectAddress(a);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selected address')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
