import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';

abstract class ContactState {}
class ContactInitial extends ContactState {}
class ContactLoading extends ContactState {}
class ContactSent extends ContactState {}
class ContactError extends ContactState {
  final String message;
  ContactError(this.message);
}

class ContactCubit extends Cubit<ContactState> {
  ContactCubit() : super(ContactInitial());

  final _dio = ApiService.instance.dio;

  Future<void> sendMessage({
    required String name,
    required String email,
    required String phone,
    required String message,
    String? service,
  }) async {
    emit(ContactLoading());
    try {
      await _dio.post(ApiConstants.contact, data: {
        'name': name, 'email': email, 'phone': phone, 'message': message,
        if (service != null) 'service': service,
      });
      emit(ContactSent());
    } on DioException catch (e) {
      emit(ContactError(e.response?.data?['error'] ?? 'Failed to send message'));
    }
  }
}
