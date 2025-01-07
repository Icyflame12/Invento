import 'package:hive/hive.dart';

// Ensure this is included to generate the necessary files
part 'product_user_model.g.dart';

@HiveType(typeId: 0)
class Userdatamodel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final bool isLoggedIn;

  Userdatamodel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.isLoggedIn,
  });
}

// Product Data Model
@HiveType(typeId: 1)
class Productmodel extends HiveObject {
  @HiveField(0)
  final String productName;

  @HiveField(1)
  int productQuantity;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String imagePath;

  @HiveField(4)
  final double productPrice;

  @HiveField(5)
  int id;

  @HiveField(6)
  final String description;

  Productmodel({
    required this.productName,
    required this.productQuantity,
    required this.productPrice,
    required this.category,
    required this.imagePath,
    required this.id,
    required this.description,
  });
}

// Sale Data Model
@HiveType(typeId: 2)
class Salemodel extends HiveObject {
  @HiveField(0)
  final int productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final double productPrice;

  @HiveField(3)
  final int quantitySold;

  @HiveField(4)
  final double totalPrice;

  @HiveField(5)
  final String custName;

  @HiveField(6)
  final String custPhone;

  @HiveField(7)
  final DateTime saleDate;

  Salemodel({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantitySold,
    required this.totalPrice,
    required this.custName,
    required this.custPhone,
    required this.saleDate,
  });
}

// Revenue Model
@HiveType(typeId: 3)
class Revenuemodel extends HiveObject {
  @HiveField(0)
  double totalRevenue;

  @HiveField(1)
  double dailyRevenue;

  @HiveField(2)
  double monthlyRevenue;

  @HiveField(3)
  double growthPercentage;

  @HiveField(4)
  double averageSaleValue;

  @HiveField(5)
  double filteredRevenue;

  Revenuemodel({
    required this.totalRevenue,
    required this.dailyRevenue,
    required this.monthlyRevenue,
    required this.growthPercentage,
    required this.averageSaleValue,
    required this.filteredRevenue,
  });
}
