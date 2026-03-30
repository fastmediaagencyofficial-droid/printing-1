import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../data/models/product_model.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class ProductEvent {}

class LoadProductsEvent extends ProductEvent {
  final String? category;
  final String? search;
  final bool featured;
  LoadProductsEvent({this.category, this.search, this.featured = false});
}

class LoadProductDetailEvent extends ProductEvent {
  final String id;
  LoadProductDetailEvent(this.id);
}

class LoadCategoriesEvent extends ProductEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductsLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final int total;
  ProductsLoaded({required this.products, required this.categories, required this.total});
}

class ProductDetailLoaded extends ProductState {
  final ProductModel product;
  ProductDetailLoaded(this.product);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<LoadProductDetailEvent>(_onLoadDetail);
    on<LoadCategoriesEvent>(_onLoadCategories);
  }

  final _dio = ApiService.instance.dio;
  List<CategoryModel> _categories = [];

  Future<void> _onLoadProducts(LoadProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductsLoading());
    try {
      final params = <String, dynamic>{'limit': '50'};
      if (event.category != null && event.category!.isNotEmpty) params['category'] = event.category;
      if (event.search != null && event.search!.isNotEmpty) params['search'] = event.search;
      if (event.featured) params['featured'] = 'true';

      final results = await Future.wait([
        _dio.get(ApiConstants.products, queryParameters: params),
        if (_categories.isEmpty) _dio.get(ApiConstants.productCategories),
      ]);

      final productsRes = results[0];
      final productsData = productsRes.data['data'] as Map<String, dynamic>;
      final products = (productsData['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (results.length > 1) {
        final catsData = results[1].data['data'] as Map<String, dynamic>;
        _categories = (catsData['categories'] as List<dynamic>)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      emit(ProductsLoaded(
        products: products,
        categories: _categories,
        total: (productsData['total'] as num?)?.toInt() ?? products.length,
      ));
    } on DioException catch (e) {
      emit(ProductError(e.response?.data?['error'] ?? 'Failed to load products'));
    } catch (_) {
      emit(ProductError('Failed to load products'));
    }
  }

  Future<void> _onLoadDetail(LoadProductDetailEvent event, Emitter<ProductState> emit) async {
    emit(ProductsLoading());
    try {
      final res = await _dio.get(ApiConstants.productById(event.id));
      final product = ProductModel.fromJson(res.data['data'] as Map<String, dynamic>);
      emit(ProductDetailLoaded(product));
    } on DioException catch (e) {
      emit(ProductError(e.response?.data?['error'] ?? 'Failed to load product'));
    }
  }

  Future<void> _onLoadCategories(LoadCategoriesEvent event, Emitter<ProductState> emit) async {
    try {
      final res = await _dio.get(ApiConstants.productCategories);
      final data = res.data['data'] as Map<String, dynamic>;
      _categories = (data['categories'] as List<dynamic>)
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }
}
