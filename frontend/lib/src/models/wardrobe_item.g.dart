// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wardrobe_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WardrobeItemAdapter extends TypeAdapter<WardrobeItem> {
  @override
  final int typeId = 0;

  @override
  WardrobeItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WardrobeItem(
      id: fields[0] as String,
      category: fields[1] as String,
      imagePath: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WardrobeItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WardrobeItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
