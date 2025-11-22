// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_outfit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedOutfitAdapter extends TypeAdapter<SavedOutfit> {
  @override
  final int typeId = 1;

  @override
  SavedOutfit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedOutfit(
      id: fields[0] as String,
      description: fields[1] as String,
      style: fields[2] as String,
      event: fields[3] as String,
      dateSaved: fields[4] as DateTime,
      itemIds: (fields[5] as List).cast<String>(),
      imageUrl: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedOutfit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.style)
      ..writeByte(3)
      ..write(obj.event)
      ..writeByte(4)
      ..write(obj.dateSaved)
      ..writeByte(5)
      ..write(obj.itemIds)
      ..writeByte(6)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedOutfitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
