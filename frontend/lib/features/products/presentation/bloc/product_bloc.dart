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
      // Backend returns data as a List directly (not wrapped in { products: [...] })
      final rawProducts = productsRes.data['data'];
      final products = (rawProducts is List ? rawProducts : <dynamic>[])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = productsRes.data['pagination'];
      final total = (pagination is Map ? pagination['total'] : null) as int? ?? products.length;

      if (results.length > 1) {
        // Categories endpoint returns a List of strings (category names) directly
        final rawCats = results[1].data['data'];
        _categories = (rawCats is List ? rawCats : <dynamic>[])
            .map((e) {
              final name = e.toString();
              return CategoryModel(id: name, name: name, slug: name.toLowerCase().replaceAll(' ', '-'));
            })
            .toList();
      }

      emit(ProductsLoaded(
        products: products,
        categories: _categories,
        total: total,
      ));
    } on DioException catch (e) {
      final msg = e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout
          ? 'Cannot reach server. Make sure backend is running.'
          : e.response?.data?['error'] ?? e.message ?? 'Failed to load products';
      emit(ProductError(msg));
    } catch (e) {
      emit(ProductError('Error: $e'));
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
      final rawCats = res.data['data'];
      _categories = (rawCats is List ? rawCats : <dynamic>[])
          .map((e) {
            final name = e.toString();
            return CategoryModel(id: name, name: name, slug: name.toLowerCase().replaceAll(' ', '-'));
          })
          .toList();
    } catch (_) {}
  }
}
