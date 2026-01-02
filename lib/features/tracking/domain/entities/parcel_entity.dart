class ParcelEntity {
  final String trackingId;
  final String sender;
  final String recipient;
  final String status;
  final String? courierName;
  final String ownerEmail;

  ParcelEntity({
    required this.trackingId,
    required this.sender,
    required this.recipient,
    required this.status,
    this.courierName,
    required this.ownerEmail,
  });
}
