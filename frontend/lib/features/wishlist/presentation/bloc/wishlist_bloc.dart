import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../products/data/models/product_model.dart';

class WishlistItemModel {
  final String id;
  final String productId;
  final ProductModel product;
  const WishlistItemModel({required this.id, required this.productId, required this.product});
  factory WishlistItemModel.fromJson(Map<String, dynamic> json) => WishlistItemModel(
        id: json['id'] as String,
        productId: json['productId'] as String,
        product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      );
}

abstract class WishlistEvent {}
class LoadWishlistEvent extends WishlistEvent {}
class AddToWishlistEvent extends WishlistEvent {
  final String productId;
  AddToWishlistEvent(this.productId);
}
class RemoveFromWishlistEvent extends WishlistEvent {
  final String productId;
  RemoveFromWishlistEvent(this.productId);
}
class MoveWishlistToCartEvent extends WishlistEvent {
  final String productId;
  MoveWishlistToCartEvent(this.productId);
}

abstract class WishlistState {}
class WishlistInitial extends WishlistState {}
class WishlistLoading extends WishlistState {}
class WishlistLoaded extends WishlistState {
  final List<WishlistItemModel> items;
  WishlistLoaded(this.items);
}
class WishlistError extends WishlistState {
  final String message;
  WishlistError(this.message);
}

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc() : super(WishlistInitial()) {
    on<LoadWishlistEvent>(_onLoad);
    on<AddToWishlistEvent>(_onAdd);
    on<RemoveFromWishlistEvent>(_onRemove);
    on<MoveWishlistToCartEvent>(_onMove);
  }

  final _dio = ApiService.instance.dio;

  Future<void> _onLoad(LoadWishlistEvent event, Emitter<WishlistState> emit) async {
    emit(WishlistLoading());
    try {
      final res = await _dio.get(ApiConstants.wishlist);
      final items = (res.data['data']['items'] as List<dynamic>)
          .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(WishlistLoaded(items));
    } on DioException catch (e) {
      emit(WishlistError(e.response?.data?['error'] ?? 'Failed to load wishlist'));
    }
  }

  Future<void> _onAdd(AddToWishlistEvent event, Emitter<WishlistState> emit) async {
    try {
      await _dio.post(ApiConstants.wishlistAdd, data: {'productId': event.productId});
      add(LoadWishlistEvent());
    } on DioException catch (e) {
      emit(WishlistError(e.response?.data?['error'] ?? 'Failed to add to wishlist'));
    }
  }

  Future<void> _onRemove(RemoveFromWishlistEvent event, Emitter<WishlistState> emit) async {
    try {
      await _dio.delete(ApiConstants.wishlistRemove(event.productId));
      add(LoadWishlistEvent());
    } on DioException catch (e) {
      emit(WishlistError(e.response?.data?['error'] ?? 'Failed to remove from wishlist'));
    }
  }

  Future<void> _onMove(MoveWishlistToCartEvent event, Emitter<WishlistState> emit) async {
    try {
      await _dio.post(ApiConstants.wishlistMoveToCart(event.productId), data: {'quantity': 1});
      add(LoadWishlistEvent());
    } on DioException catch (e) {
      emit(WishlistError(e.response?.data?['error'] ?? 'Failed to move to cart'));
    }
  }
}
