import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_model.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CartEvent {}

class LoadCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final Map<String, dynamic>? customSpecs;
  final String? note;
  AddToCartEvent({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    this.quantity = 1,
    this.customSpecs,
    this.note,
  });
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

// ── BLoC (in-memory, no auth required) ───────────────────────────────────────

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartLoaded(cartItems: const [], total: 0)) {
    on<LoadCartEvent>(_onLoad);
    on<AddToCartEvent>(_onAdd);
    on<UpdateCartItemEvent>(_onUpdate);
    on<RemoveCartItemEvent>(_onRemove);
    on<ClearCartEvent>(_onClear);
  }

  List<CartItemModel> get _currentItems =>
      state is CartLoaded ? (state as CartLoaded).cartItems : [];

  double _calcTotal(List<CartItemModel> items) =>
      items.fold(0, (sum, i) => sum + i.totalPrice);

  void _emitItems(List<CartItemModel> items, Emitter<CartState> emit) =>
      emit(CartLoaded(cartItems: items, total: _calcTotal(items)));

  void _onLoad(LoadCartEvent event, Emitter<CartState> emit) {
    // Cart is already in state — just re-emit it
    final items = _currentItems;
    _emitItems(items, emit);
  }

  void _onAdd(AddToCartEvent event, Emitter<CartState> emit) {
    final items = List<CartItemModel>.from(_currentItems);

    // If same product + same specs already in cart, increment quantity
    final existingIndex = items.indexWhere(
      (i) => i.productId == event.productId &&
          _specsMatch(i.customSpecs, event.customSpecs),
    );

    if (existingIndex >= 0) {
      final existing = items[existingIndex];
      final newQty = existing.quantity + event.quantity;
      items[existingIndex] = existing.copyWith(
        quantity: newQty,
        totalPrice: existing.unitPrice * newQty,
      );
    } else {
      items.add(CartItemModel(
        id: '${event.productId}_${DateTime.now().millisecondsSinceEpoch}',
        productId: event.productId,
        productName: event.productName,
        quantity: event.quantity,
        unitPrice: event.unitPrice,
        totalPrice: event.unitPrice * event.quantity,
        customSpecs: event.customSpecs,
        note: event.note,
      ));
    }

    _emitItems(items, emit);
  }

  void _onUpdate(UpdateCartItemEvent event, Emitter<CartState> emit) {
    final items = List<CartItemModel>.from(_currentItems);
    final idx = items.indexWhere((i) => i.id == event.itemId);
    if (idx >= 0) {
      final item = items[idx];
      if (event.quantity <= 0) {
        items.removeAt(idx);
      } else {
        items[idx] = item.copyWith(
          quantity: event.quantity,
          totalPrice: item.unitPrice * event.quantity,
        );
      }
    }
    _emitItems(items, emit);
  }

  void _onRemove(RemoveCartItemEvent event, Emitter<CartState> emit) {
    final items = List<CartItemModel>.from(_currentItems)
      ..removeWhere((i) => i.id == event.itemId);
    _emitItems(items, emit);
  }

  void _onClear(ClearCartEvent event, Emitter<CartState> emit) {
    _emitItems([], emit);
  }

  bool _specsMatch(
      Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
