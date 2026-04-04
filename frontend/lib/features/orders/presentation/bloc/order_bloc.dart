import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../data/models/order_model.dart';

abstract class OrderEvent {}
class LoadOrdersEvent extends OrderEvent {}
class TrackOrdersByPhoneEvent extends OrderEvent {
  final String phone;
  TrackOrdersByPhoneEvent(this.phone);
}
class LoadOrderDetailEvent extends OrderEvent {
  final String id;
  LoadOrderDetailEvent(this.id);
}
class PlaceOrderEvent extends OrderEvent {
  final String paymentMethod;
  final String? shippingStreet;
  final String? shippingCity;
  final String? shippingProvince;
  final String? shippingPostal;
  final String? notes;
  PlaceOrderEvent({
    required this.paymentMethod,
    this.shippingStreet, this.shippingCity, this.shippingProvince,
    this.shippingPostal, this.notes,
  });
}

class PlaceGuestOrderEvent extends OrderEvent {
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String? productDescription;
  final String? productSize;
  final String? productCategory;
  final String paymentMethod;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String? shippingStreet;
  final String? shippingCity;
  final String? notes;
  PlaceGuestOrderEvent({
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    this.productDescription,
    this.productSize,
    this.productCategory,
    required this.paymentMethod,
    required this.items,
    required this.totalAmount,
    this.shippingStreet,
    this.shippingCity,
    this.notes,
  });
}
class CancelOrderEvent extends OrderEvent {
  final String id;
  CancelOrderEvent(this.id);
}

abstract class OrderState {}
class OrderInitial extends OrderState {}
class OrdersLoading extends OrderState {}
class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;
  OrdersLoaded(this.orders);
}
class OrderDetailLoaded extends OrderState {
  final OrderModel order;
  OrderDetailLoaded(this.order);
}
class OrderPlaced extends OrderState {
  final OrderModel order;
  OrderPlaced(this.order);
}
class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<LoadOrdersEvent>(_onLoad);
    on<TrackOrdersByPhoneEvent>(_onTrack);
    on<LoadOrderDetailEvent>(_onDetail);
    on<PlaceOrderEvent>(_onPlace);
    on<PlaceGuestOrderEvent>(_onPlaceGuest);
    on<CancelOrderEvent>(_onCancel);
  }

  final _dio = ApiService.instance.dio;

  Future<void> _onLoad(LoadOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    try {
      final res = await _dio.get(ApiConstants.orders);
      final data = res.data['data'] as Map<String, dynamic>;
      final orders = (data['orders'] as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(OrdersLoaded(orders));
    } on DioException catch (e) {
      emit(OrderError(e.response?.data?['error'] ?? 'Failed to load orders'));
    }
  }

  Future<void> _onTrack(TrackOrdersByPhoneEvent event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    try {
      final res = await _dio.get(ApiConstants.trackOrders(event.phone));
      final raw = res.data['data'];
      final orders = (raw is List ? raw : <dynamic>[])
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(OrdersLoaded(orders));
    } on DioException catch (e) {
      emit(OrderError(e.response?.data?['error'] ?? 'Failed to find orders'));
    }
  }

  Future<void> _onDetail(LoadOrderDetailEvent event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    try {
      final res = await _dio.get(ApiConstants.orderById(event.id));
      final order = OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
      emit(OrderDetailLoaded(order));
    } on DioException catch (e) {
      emit(OrderError(e.response?.data?['error'] ?? 'Failed to load order'));
    }
  }

  Future<void> _onPlace(PlaceOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    try {
      final res = await _dio.post(ApiConstants.orders, data: {
        'paymentMethod': event.paymentMethod,
        if (event.shippingStreet != null) 'shippingStreet': event.shippingStreet,
        if (event.shippingCity != null) 'shippingCity': event.shippingCity,
        if (event.shippingProvince != null) 'shippingProvince': event.shippingProvince,
        if (event.shippingPostal != null) 'shippingPostal': event.shippingPostal,
        if (event.notes != null) 'notes': event.notes,
      });
      final order = OrderModel.fromJson(res.data['data']['order'] as Map<String, dynamic>);
      emit(OrderPlaced(order));
    } on DioException catch (e) {
      emit(OrderError(e.response?.data?['error'] ?? 'Failed to place order'));
    }
  }

  Future<void> _onPlaceGuest(PlaceGuestOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    try {
      final res = await _dio.post(ApiConstants.guestOrder, data: {
        'customerName': event.customerName,
        'customerPhone': event.customerPhone,
        if (event.customerEmail != null) 'customerEmail': event.customerEmail,
        if (event.productDescription != null) 'productDescription': event.productDescription,
        if (event.productSize != null) 'productSize': event.productSize,
        if (event.productCategory != null) 'productCategory': event.productCategory,
        'paymentMethod': event.paymentMethod,
        'items': event.items,
        'totalAmount': event.totalAmount,
        if (event.shippingStreet != null) 'shippingStreet': event.shippingStreet,
        if (event.shippingCity != null) 'shippingCity': event.shippingCity,
        if (event.notes != null) 'notes': event.notes,
      });
      final order = OrderModel.fromJson(res.data['data']['order'] as Map<String, dynamic>);
      emit(OrderPlaced(order));
    } on DioException catch (e) {
      emit(OrderError(e.response?.data?['error'] ?? 'Failed to place order'));
    }
  }

  Future<void> _onCancel(CancelOrderEvent event, Emitter<OrderState> emit) async {
    try {
      final res = await _dio.put(ApiConstants.orderCancel(event.id));
      final order = OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
      emit(OrderDetailLoaded(order));
    } on DioException catch (e) {
      emit(OrderError(e.response?.data?['error'] ?? 'Failed to cancel order'));
    }
  }
}
