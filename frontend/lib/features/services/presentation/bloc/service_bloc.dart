import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../data/models/service_model.dart';

abstract class ServiceEvent {}
class LoadServicesEvent extends ServiceEvent {}
class LoadServiceDetailEvent extends ServiceEvent {
  final String slug;
  LoadServiceDetailEvent(this.slug);
}

abstract class ServiceState {}
class ServiceInitial extends ServiceState {}
class ServicesLoading extends ServiceState {}
class ServicesLoaded extends ServiceState {
  final List<ServiceModel> services;
  ServicesLoaded(this.services);
}
class ServiceDetailLoaded extends ServiceState {
  final ServiceModel service;
  ServiceDetailLoaded(this.service);
}
class ServiceError extends ServiceState {
  final String message;
  ServiceError(this.message);
}

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  ServiceBloc() : super(ServiceInitial()) {
    on<LoadServicesEvent>(_onLoad);
    on<LoadServiceDetailEvent>(_onDetail);
  }

  final _dio = ApiService.instance.dio;

  Future<void> _onLoad(LoadServicesEvent event, Emitter<ServiceState> emit) async {
    emit(ServicesLoading());
    try {
      final res = await _dio.get(ApiConstants.services);
      final services = (res.data['data'] as List<dynamic>)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(ServicesLoaded(services));
    } on DioException catch (e) {
      emit(ServiceError(e.response?.data?['error'] ?? 'Failed to load services'));
    }
  }

  Future<void> _onDetail(LoadServiceDetailEvent event, Emitter<ServiceState> emit) async {
    emit(ServicesLoading());
    try {
      final res = await _dio.get(ApiConstants.serviceBySlug(event.slug));
      final service = ServiceModel.fromJson(res.data['data'] as Map<String, dynamic>);
      emit(ServiceDetailLoaded(service));
    } on DioException catch (e) {
      emit(ServiceError(e.response?.data?['error'] ?? 'Failed to load service'));
    }
  }
}
