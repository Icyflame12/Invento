import 'package:inventory_app_final/model/dbfunctions.dart';
import 'package:inventory_app_final/model/product_user_model.dart';

class ProductService {
  static Future<List<Productmodel>> getRecentlyAddedProducts() async {
    try {
      return await getAllProducts();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  static Future<void> deleteProduct(int productId) async {
    try {
      await deleteProduct(productId);
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }
}
