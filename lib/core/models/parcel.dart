import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Parcel extends HiveObject {
  @HiveField(0)
  String trackingId;

  @HiveField(1)
  String sender;

  @HiveField(2)
  String recipient;

  @HiveField(3)
  String status;

  @HiveField(4)
  String? courierName;

  @HiveField(5)
  String ownerEmail;

  Parcel({
    required this.trackingId,
    required this.sender,
    required this.recipient,
    required this.status,
    this.courierName,
    required this.ownerEmail,
  });
}
