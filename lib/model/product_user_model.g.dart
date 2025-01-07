// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserdatamodelAdapter extends TypeAdapter<Userdatamodel> {
  @override
  final int typeId = 0;

  @override
  Userdatamodel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Userdatamodel(
      id: fields[0] as int,
      name: fields[1] as String,
      email: fields[2] as String,
      password: fields[3] as String,
      isLoggedIn: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Userdatamodel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.isLoggedIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserdatamodelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductmodelAdapter extends TypeAdapter<Productmodel> {
  @override
  final int typeId = 1;

  @override
  Productmodel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Productmodel(
      productName: fields[0] as String,
      productQuantity: fields[1] as int,
      productPrice: fields[4] as double,
      category: fields[2] as String,
      imagePath: fields[3] as String,
      id: fields[5] as int,
      description: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Productmodel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.productName)
      ..writeByte(1)
      ..write(obj.productQuantity)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.productPrice)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductmodelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SalemodelAdapter extends TypeAdapter<Salemodel> {
  @override
  final int typeId = 2;

  @override
  Salemodel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Salemodel(
      productId: fields[0] as int,
      productName: fields[1] as String,
      productPrice: fields[2] as double,
      quantitySold: fields[3] as int,
      totalPrice: fields[4] as double,
      custName: fields[5] as String,
      custPhone: fields[6] as String,
      saleDate: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Salemodel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.productPrice)
      ..writeByte(3)
      ..write(obj.quantitySold)
      ..writeByte(4)
      ..write(obj.totalPrice)
      ..writeByte(5)
      ..write(obj.custName)
      ..writeByte(6)
      ..write(obj.custPhone)
      ..writeByte(7)
      ..write(obj.saleDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalemodelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RevenuemodelAdapter extends TypeAdapter<Revenuemodel> {
  @override
  final int typeId = 3;

  @override
  Revenuemodel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Revenuemodel(
      totalRevenue: fields[0] as double,
      dailyRevenue: fields[1] as double,
      monthlyRevenue: fields[2] as double,
      growthPercentage: fields[3] as double,
      averageSaleValue: fields[4] as double,
      filteredRevenue: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Revenuemodel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.totalRevenue)
      ..writeByte(1)
      ..write(obj.dailyRevenue)
      ..writeByte(2)
      ..write(obj.monthlyRevenue)
      ..writeByte(3)
      ..write(obj.growthPercentage)
      ..writeByte(4)
      ..write(obj.averageSaleValue)
      ..writeByte(5)
      ..write(obj.filteredRevenue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevenuemodelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
