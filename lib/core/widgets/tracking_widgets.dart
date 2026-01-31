import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pathau_now/domain/entities/parcel_entity.dart';
import 'package:pathau_now/core/utils/app_utils.dart';

class TrackingMapWidget extends StatefulWidget {
  final ParcelEntity parcel;
  final TrackingEntity? currentTracking;

  const TrackingMapWidget({
    super.key,
    required this.parcel,
    this.currentTracking,
  });

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    final pickupLat = widget.parcel.pickupLocation?.latitude ?? 0;
    final pickupLng = widget.parcel.pickupLocation?.longitude ?? 0;
    final deliveryLat = widget.parcel.deliveryLocation?.latitude ?? 0;
    final deliveryLng = widget.parcel.deliveryLocation?.longitude ?? 0;

    final Set<Marker> markers = {};

    if (pickupLat != 0 && pickupLng != 0) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(pickupLat, pickupLng),
          infoWindow: const InfoWindow(title: 'Pickup Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    if (deliveryLat != 0 && deliveryLng != 0) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: LatLng(deliveryLat, deliveryLng),
          infoWindow: const InfoWindow(title: 'Delivery Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    if (widget.currentTracking != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(
            widget.currentTracking!.latitude,
            widget.currentTracking!.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Current: ${widget.currentTracking!.address}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (controller) => mapController = controller,
      initialCameraPosition: CameraPosition(
        target: LatLng(pickupLat, pickupLng),
        zoom: 12,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}

class ParcelInfoCard extends StatelessWidget {
  final ParcelEntity parcel;

  const ParcelInfoCard({super.key, required this.parcel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tracking ID: ${parcel.trackingId}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'From:',
              '${parcel.sender.name}\n${parcel.sender.address}',
            ),
            const Divider(),
            _buildInfoRow(
              context,
              'To:',
              '${parcel.receiver.name}\n${parcel.receiver.address}',
            ),
            const Divider(),
            _buildInfoRow(context, 'Weight:', '${parcel.weight} kg'),
            const SizedBox(height: 16),
            if (parcel.estimatedDelivery != null)
              _buildInfoRow(
                context,
                'Est. Delivery:',
                DateTimeUtils.formatDateTime(parcel.estimatedDelivery!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
