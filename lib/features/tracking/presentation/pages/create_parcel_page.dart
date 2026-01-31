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
  final _receiverName = TextEditingController();
  final _receiverPhone = TextEditingController();
  final _pickupAddress = TextEditingController();
  final _deliveryAddress = TextEditingController();
  final _weight = TextEditingController();
  final _contents = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _senderName.dispose();
    _receiverName.dispose();
    _receiverPhone.dispose();
    _pickupAddress.dispose();
    _deliveryAddress.dispose();
    _weight.dispose();
    _contents.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final vm = Provider.of<ParcelViewModel>(context, listen: false);
    final payload = {
      'sender': {
        'name': _senderName.text.trim(),
        'phone': '',
        'address': _pickupAddress.text.trim(),
      },
      'receiver': {
        'name': _receiverName.text.trim(),
        'phone': _receiverPhone.text.trim(),
        'address': _deliveryAddress.text.trim(),
      },
      'weight': double.tryParse(_weight.text) ?? 0.0,
      'contents': _contents.text.trim(),
      'pickupNow': widget.pickupNow,
    };

    try {
      final created = await vm.createParcel(parcelData: payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parcel created successfully')),
      );

      // Navigate to tracking detail for the newly created parcel
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
              TextFormField(
                controller: _senderName,
                decoration: const InputDecoration(labelText: 'Sender name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
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
                controller: _deliveryAddress,
                decoration: const InputDecoration(
                  labelText: 'Delivery address',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weight,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contents,
                decoration: const InputDecoration(labelText: 'Contents'),
              ),
              const SizedBox(height: 16),
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
