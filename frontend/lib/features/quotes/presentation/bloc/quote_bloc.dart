import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../data/models/quote_model.dart';

abstract class QuoteEvent {}
class SubmitQuoteEvent extends QuoteEvent {
  final Map<String, dynamic> data;
  SubmitQuoteEvent(this.data);
}
class LoadMyQuotesEvent extends QuoteEvent {}

abstract class QuoteState {}
class QuoteInitial extends QuoteState {}
class QuoteLoading extends QuoteState {}
class QuoteSubmitted extends QuoteState {
  final String quoteId;
  QuoteSubmitted(this.quoteId);
}
class QuotesLoaded extends QuoteState {
  final List<QuoteModel> quotes;
  QuotesLoaded(this.quotes);
}
class QuoteError extends QuoteState {
  final String message;
  QuoteError(this.message);
}

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  QuoteBloc() : super(QuoteInitial()) {
    on<SubmitQuoteEvent>(_onSubmit);
    on<LoadMyQuotesEvent>(_onLoad);
  }

  final _dio = ApiService.instance.dio;

  Future<void> _onSubmit(SubmitQuoteEvent event, Emitter<QuoteState> emit) async {
    emit(QuoteLoading());
    try {
      final res = await _dio.post(ApiConstants.quoteRequest, data: event.data);
      final quoteId = res.data['data']['quoteId'] as String;
      emit(QuoteSubmitted(quoteId));
    } on DioException catch (e) {
      emit(QuoteError(e.response?.data?['error'] ?? 'Failed to submit quote'));
    }
  }

  Future<void> _onLoad(LoadMyQuotesEvent event, Emitter<QuoteState> emit) async {
    emit(QuoteLoading());
    try {
      final res = await _dio.get(ApiConstants.myQuotes);
      final quotes = (res.data['data'] as List<dynamic>)
          .map((e) => QuoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(QuotesLoaded(quotes));
    } on DioException catch (e) {
      emit(QuoteError(e.response?.data?['error'] ?? 'Failed to load quotes'));
    }
  }
}
