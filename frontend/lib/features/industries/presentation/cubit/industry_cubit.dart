import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../data/models/industry_model.dart';

abstract class IndustryState {}
class IndustryInitial extends IndustryState {}
class IndustryLoading extends IndustryState {}
class IndustryLoaded extends IndustryState {
  final List<IndustryModel> industries;
  IndustryLoaded(this.industries);
}
class IndustryError extends IndustryState {
  final String message;
  IndustryError(this.message);
}

class IndustryCubit extends Cubit<IndustryState> {
  IndustryCubit() : super(IndustryInitial());

  final _dio = ApiService.instance.dio;

  Future<void> loadIndustries() async {
    emit(IndustryLoading());
    try {
      final res = await _dio.get(ApiConstants.industries);
      final list = res.data['data'] as List<dynamic>;
      final industries = list.map((e) => IndustryModel.fromJson(e as Map<String, dynamic>)).toList();
      emit(IndustryLoaded(industries));
    } on DioException catch (e) {
      emit(IndustryError(e.response?.data?['error'] ?? 'Failed to load industries'));
    }
  }
}
