import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  Future<void> loadProducts() async {
    try {
      emit(ProductLoading());
      final products = await DatabaseService.instance.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await DatabaseService.instance.insertProduct(product);
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await DatabaseService.instance.updateProduct(product);
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await DatabaseService.instance.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> updateStock(String productId, int quantity) async {
    try {
      final currentState = state;
      if (currentState is! ProductLoaded) return;

      final product = currentState.getProductById(productId);
      if (product == null) return;

      final updatedProduct = product.copyWith(
        stockQuantity: product.stockQuantity + quantity,
      );
      await updateProduct(updatedProduct);
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}

