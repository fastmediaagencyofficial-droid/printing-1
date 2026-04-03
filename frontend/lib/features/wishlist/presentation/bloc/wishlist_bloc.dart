import 'package:flutter_bloc/flutter_bloc.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class WishlistItemModel {
  final String productId;
  final String productName;
  final String category;
  final double startingPrice;
  final String? imageUrl;

  const WishlistItemModel({
    required this.productId,
    required this.productName,
    required this.category,
    required this.startingPrice,
    this.imageUrl,
  });
}

// ── Events ────────────────────────────────────────────────────────────────────

abstract class WishlistEvent {}

class LoadWishlistEvent extends WishlistEvent {}

class AddToWishlistEvent extends WishlistEvent {
  final String productId;
  final String productName;
  final String category;
  final double startingPrice;
  final String? imageUrl;

  AddToWishlistEvent({
    required this.productId,
    required this.productName,
    required this.category,
    required this.startingPrice,
    this.imageUrl,
  });
}

class RemoveFromWishlistEvent extends WishlistEvent {
  final String productId;
  RemoveFromWishlistEvent(this.productId);
}

class ClearWishlistEvent extends WishlistEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class WishlistState {}

class WishlistInitial extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistItemModel> items;
  WishlistLoaded(this.items);
  bool contains(String productId) => items.any((i) => i.productId == productId);
}

// ── BLoC (in-memory, no auth required) ───────────────────────────────────────

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc() : super(WishlistLoaded(const [])) {
    on<LoadWishlistEvent>(_onLoad);
    on<AddToWishlistEvent>(_onAdd);
    on<RemoveFromWishlistEvent>(_onRemove);
    on<ClearWishlistEvent>(_onClear);
  }

  List<WishlistItemModel> get _items =>
      state is WishlistLoaded ? (state as WishlistLoaded).items : [];

  void _onLoad(LoadWishlistEvent event, Emitter<WishlistState> emit) {
    emit(WishlistLoaded(List.from(_items)));
  }

  void _onAdd(AddToWishlistEvent event, Emitter<WishlistState> emit) {
    // Avoid duplicates
    if (_items.any((i) => i.productId == event.productId)) return;
    final updated = List<WishlistItemModel>.from(_items)
      ..add(WishlistItemModel(
        productId: event.productId,
        productName: event.productName,
        category: event.category,
        startingPrice: event.startingPrice,
        imageUrl: event.imageUrl,
      ));
    emit(WishlistLoaded(updated));
  }

  void _onRemove(RemoveFromWishlistEvent event, Emitter<WishlistState> emit) {
    final updated = List<WishlistItemModel>.from(_items)
      ..removeWhere((i) => i.productId == event.productId);
    emit(WishlistLoaded(updated));
  }

  void _onClear(ClearWishlistEvent event, Emitter<WishlistState> emit) {
    emit(WishlistLoaded(const []));
  }
}
