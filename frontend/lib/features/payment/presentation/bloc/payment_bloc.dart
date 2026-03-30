import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../data/models/payment_model.dart';

abstract class PaymentEvent {}
class LoadPaymentMethodsEvent extends PaymentEvent {}
class UploadPaymentProofEvent extends PaymentEvent {
  final String orderId;
  final File imageFile;
  UploadPaymentProofEvent({required this.orderId, required this.imageFile});
}

abstract class PaymentState {}
class PaymentInitial extends PaymentState {}
class PaymentLoading extends PaymentState {}
class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodModel> methods;
  PaymentMethodsLoaded(this.methods);
}
class PaymentProofUploading extends PaymentState {}
class PaymentProofUploaded extends PaymentState {
  final String proofUrl;
  PaymentProofUploaded(this.proofUrl);
}
class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial()) {
    on<LoadPaymentMethodsEvent>(_onLoad);
    on<UploadPaymentProofEvent>(_onUpload);
  }

  final _dio = ApiService.instance.dio;

  Future<void> _onLoad(LoadPaymentMethodsEvent event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final res = await _dio.get(ApiConstants.paymentMethods);
      final methods = (res.data['data']['methods'] as List<dynamic>)
          .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(PaymentMethodsLoaded(methods));
    } on DioException catch (e) {
      emit(PaymentError(e.response?.data?['error'] ?? 'Failed to load payment methods'));
    }
  }

  Future<void> _onUpload(UploadPaymentProofEvent event, Emitter<PaymentState> emit) async {
    emit(PaymentProofUploading());
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          event.imageFile.path,
          filename: 'payment_proof.jpg',
        ),
      });
      final res = await _dio.post(
        ApiConstants.orderPaymentProof(event.orderId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final proofUrl = res.data['data']['proofUrl'] as String;
      emit(PaymentProofUploaded(proofUrl));
    } on DioException catch (e) {
      emit(PaymentError(e.response?.data?['error'] ?? 'Failed to upload payment proof'));
    }
  }
}
