// Manual Hive TypeAdapter for Parcel
import 'package:hive/hive.dart';
import 'parcel.dart';

class ParcelAdapter extends TypeAdapter<Parcel> {
  @override
  final int typeId = 1;

  @override
  Parcel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return Parcel(
      trackingId: fields[0] as String,
      sender: fields[1] as String,
      recipient: fields[2] as String,
      status: fields[3] as String,
      courierName: fields[4] as String?,
      ownerEmail: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Parcel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.trackingId)
      ..writeByte(1)
      ..write(obj.sender)
      ..writeByte(2)
      ..write(obj.recipient)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.courierName)
      ..writeByte(5)
      ..write(obj.ownerEmail);
  }
}
