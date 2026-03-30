import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../data/models/cart_model.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CartEvent {}

class LoadCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final String productId;
  final int quantity;
  final Map<String, dynamic>? customSpecs;
  final String? note;
  AddToCartEvent({required this.productId, this.quantity = 1, this.customSpecs, this.note});
}

class UpdateCartItemEvent extends CartEvent {
  final String itemId;
  final int quantity;
  UpdateCartItemEvent({required this.itemId, required this.quantity});
}

class RemoveCartItemEvent extends CartEvent {
  final String itemId;
  RemoveCartItemEvent(this.itemId);
}

class ClearCartEvent extends CartEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemModel> cartItems;
  final double total;
  CartLoaded({required this.cartItems, required this.total});
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<LoadCartEvent>(_onLoad);
    on<AddToCartEvent>(_onAdd);
    on<UpdateCartItemEvent>(_onUpdate);
    on<RemoveCartItemEvent>(_onRemove);
    on<ClearCartEvent>(_onClear);
  }

  final _dio = ApiService.instance.dio;

  Future<void> _onLoad(LoadCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final res = await _dio.get(ApiConstants.cart);
      final data = res.data['data'] as Map<String, dynamic>;
      final cart = CartModel.fromJson(data);
      emit(CartLoaded(cartItems: cart.items, total: cart.total));
    } on DioException catch (e) {
      emit(CartError(e.response?.data?['error'] ?? 'Failed to load cart'));
    } catch (_) {
      emit(CartError('Failed to load cart'));
    }
  }

  Future<void> _onAdd(AddToCartEvent event, Emitter<CartState> emit) async {
    try {
      await _dio.post(ApiConstants.cartAdd, data: {
        'productId': event.productId,
        'quantity': event.quantity,
        if (event.customSpecs != null) 'customSpecs': event.customSpecs,
        if (event.note != null) 'note': event.note,
      });
      add(LoadCartEvent());
    } on DioException catch (e) {
      emit(CartError(e.response?.data?['error'] ?? 'Failed to add to cart'));
    }
  }

  Future<void> _onUpdate(UpdateCartItemEvent event, Emitter<CartState> emit) async {
    try {
      await _dio.put(ApiConstants.cartItem(event.itemId), data: {'quantity': event.quantity});
      add(LoadCartEvent());
    } on DioException catch (e) {
      emit(CartError(e.response?.data?['error'] ?? 'Failed to update cart'));
    }
  }

  Future<void> _onRemove(RemoveCartItemEvent event, Emitter<CartState> emit) async {
    try {
      await _dio.delete(ApiConstants.cartItem(event.itemId));
      add(LoadCartEvent());
    } on DioException catch (e) {
      emit(CartError(e.response?.data?['error'] ?? 'Failed to remove item'));
    }
  }

  Future<void> _onClear(ClearCartEvent event, Emitter<CartState> emit) async {
    try {
      await _dio.delete(ApiConstants.cartClear);
      emit(CartLoaded(cartItems: [], total: 0));
    } on DioException catch (e) {
      emit(CartError(e.response?.data?['error'] ?? 'Failed to clear cart'));
    }
  }
}
