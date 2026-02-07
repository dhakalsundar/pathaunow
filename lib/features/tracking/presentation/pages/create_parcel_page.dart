import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/features/tracking/presentation/viewmodels/parcel_viewmodel.dart';
import 'package:pathau_now/features/tracking/presentation/pages/tracking_detail_page.dart';

class CreateParcelPage extends StatefulWidget {
  static const routeName = '/create-parcel';
  final bool pickupNow;

  const CreateParcelPage({super.key, this.pickupNow = false});

  @override
  State<CreateParcelPage> createState() => _CreateParcelPageState();
}

class _CreateParcelPageState extends State<CreateParcelPage> {
  final _formKey = GlobalKey<FormState>();
  final _senderName = TextEditingController();
  final _senderPhone = TextEditingController();
  final _senderCity = TextEditingController();
  final _pickupAddress = TextEditingController();
  final _receiverName = TextEditingController();
  final _receiverPhone = TextEditingController();
  final _receiverCity = TextEditingController();
  final _deliveryAddress = TextEditingController();
  final _weight = TextEditingController();
  final _contents = TextEditingController();
  final _price = TextEditingController();

  String _paymentMethod = 'CASH'; // Default payment method
  bool _submitting = false;

  @override
  void dispose() {
    _senderName.dispose();
    _senderPhone.dispose();
    _senderCity.dispose();
    _pickupAddress.dispose();
    _receiverName.dispose();
    _receiverPhone.dispose();
    _receiverCity.dispose();
    _deliveryAddress.dispose();
    _weight.dispose();
    _contents.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final vm = Provider.of<ParcelViewModel>(context, listen: false);
    final payload = {
      'sender': {
        'name': _senderName.text.trim(),
        'phone': _senderPhone.text.trim(),
        'address': _pickupAddress.text.trim(),
        'city': _senderCity.text.trim(),
      },
      'receiver': {
        'name': _receiverName.text.trim(),
        'phone': _receiverPhone.text.trim(),
        'address': _deliveryAddress.text.trim(),
        'city': _receiverCity.text.trim(),
      },
      'weight': double.tryParse(_weight.text) ?? 0.0,
      'price': double.tryParse(_price.text) ?? 0.0,
      'paymentMethod': _paymentMethod,
      'contents': _contents.text.trim(),
      'pickupNow': widget.pickupNow,
    };

    try {
      final created = await vm.createParcel(parcelData: payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parcel created successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TrackingDetailPage(parcel: created)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create parcel: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Parcel')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Sender Section
              const SizedBox(height: 8),
              const Text(
                'Sender Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _senderName,
                decoration: const InputDecoration(labelText: 'Sender name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _senderPhone,
                decoration: const InputDecoration(labelText: 'Sender phone'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pickupAddress,
                decoration: const InputDecoration(labelText: 'Pickup address'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _senderCity,
                decoration: const InputDecoration(labelText: 'Pickup city'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Receiver Section
              const Text(
                'Receiver Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _receiverName,
                decoration: const InputDecoration(labelText: 'Receiver name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _receiverPhone,
                decoration: const InputDecoration(labelText: 'Receiver phone'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deliveryAddress,
                decoration: const InputDecoration(
                  labelText: 'Delivery address',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _receiverCity,
                decoration: const InputDecoration(labelText: 'Delivery city'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Parcel Details Section
              const Text(
                'Parcel Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weight,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final weight = double.tryParse(v);
                  if (weight == null || weight <= 0) return 'Invalid weight';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price (NPR)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Price is required';
                  final price = double.tryParse(v);
                  if (price == null || price <= 0) return 'Invalid price';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contents,
                decoration: const InputDecoration(
                  labelText: 'Contents (optional)',
                  hintText: 'e.g., Books, Electronics, etc.',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _paymentMethod,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    _paymentMethod = newValue ?? 'CASH';
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'CASH',
                    child: Text('Cash on Delivery'),
                  ),
                  DropdownMenuItem(value: 'CARD', child: Text('Card Payment')),
                  DropdownMenuItem(
                    value: 'WALLET',
                    child: Text('Wallet Balance'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const CircularProgressIndicator()
                      : const Text('Create Parcel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
 
 
 
 
 
 
