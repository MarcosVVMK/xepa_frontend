import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../auth/token_storage.dart';
import '../utils/navigation_service.dart';

// ── Auth ────────────────────────────────────────────────────────────────────
import '../../features/auth/data/datasources/auth_remote_ds.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';

// ── Profile ──────────────────────────────────────────────────────────────────
import '../../features/profile/data/datasources/profile_remote_ds.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/i_profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/save_address_usecase.dart';
import '../../features/profile/domain/usecases/change_password_usecase.dart';
import '../../features/profile/domain/usecases/delete_account_usecase.dart';
import '../services/i_geocoding_service.dart';
import '../services/geocoding_service_impl.dart';
import '../services/i_zipcode_service.dart';
import '../services/zipcode_service_impl.dart';

// ── Shopping List ─────────────────────────────────────────────────────────────
import '../../features/shopping_list/data/datasources/i_shopping_list_datasource.dart';
import '../../features/shopping_list/data/datasources/shopping_list_service.dart';
import '../../features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import '../../features/shopping_list/domain/repositories/i_shopping_list_repository.dart';
import '../../features/shopping_list/domain/usecases/get_shopping_lists_usecase.dart';
import '../../features/shopping_list/domain/usecases/get_shopping_list_by_id_usecase.dart';
import '../../features/shopping_list/domain/usecases/create_shopping_list_usecase.dart';
import '../../features/shopping_list/domain/usecases/delete_shopping_list_usecase.dart';
import '../../features/shopping_list/domain/usecases/add_item_to_list_usecase.dart';
import '../../features/shopping_list/domain/usecases/remove_item_from_list_usecase.dart';
import '../../features/shopping_list/domain/usecases/update_shopping_list_usecase.dart';
import '../../features/shopping_list/domain/usecases/compare_shopping_list_usecase.dart';

// ── Product ───────────────────────────────────────────────────────────────────
import '../../features/product/data/datasources/i_product_datasource.dart';
import '../../features/product/data/datasources/product_service.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/i_product_repository.dart';
import '../../features/product/domain/usecases/product_usecases.dart';

// ── Supermarket ───────────────────────────────────────────────────────────────
import '../../features/supermarket_finder/data/datasources/i_supermarket_datasource.dart';
import '../../features/supermarket_finder/data/datasources/supermarket_service.dart';
import '../../features/supermarket_finder/data/repositories/supermarket_repository_impl.dart';
import '../../features/supermarket_finder/domain/repositories/i_supermarket_repository.dart';
import '../../features/supermarket_finder/domain/usecases/supermarket_usecases.dart';

// ── NFC Scanner ───────────────────────────────────────────────────────────────
import '../../features/nfc_scanner/data/datasources/nfc_parser_service.dart';
import '../../features/nfc_scanner/data/repositories/nfc_repository_impl.dart';
import '../../features/nfc_scanner/domain/repositories/i_nfc_repository.dart';
import '../../features/nfc_scanner/domain/usecases/nfc_usecases.dart';

final getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // ------------------------------------------------------------------
    // 1. CORE
    // ------------------------------------------------------------------
    getIt.registerLazySingleton(() => const FlutterSecureStorage());
    getIt.registerLazySingleton(() => Dio());
    getIt.registerLazySingleton(() => NavigationService());
    getIt.registerLazySingleton(() => TokenStorage(getIt()));
    getIt.registerLazySingleton(() => ApiClient(getIt(), getIt(), getIt()));

    // ------------------------------------------------------------------
    // 2. FEATURES — AUTH
    // ------------------------------------------------------------------
    getIt.registerLazySingleton(() => AuthRemoteDataSource(getIt<ApiClient>()));
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        tokenStorage: getIt<TokenStorage>(),
      ),
    );
    getIt.registerLazySingleton(() => LoginUseCase(getIt<IAuthRepository>()));
    getIt.registerLazySingleton(() => RegisterUseCase(getIt<IAuthRepository>()));

    // ------------------------------------------------------------------
    // 3. FEATURES — PROFILE
    // ------------------------------------------------------------------
    getIt.registerLazySingleton(
      () => ProfileRemoteDataSource(getIt<ApiClient>()),
    );
    getIt.registerLazySingleton<IGeocodingService>(() => GeocodingServiceImpl());
    getIt.registerLazySingleton<IZipCodeService>(
      () => ZipCodeServiceImpl(getIt<ApiClient>()),
    );
    getIt.registerLazySingleton<IProfileRepository>(
      () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
    );
    getIt.registerLazySingleton(() => GetProfileUseCase(getIt<IProfileRepository>()));
    getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt<IProfileRepository>()));
    getIt.registerLazySingleton(() => SaveAddressUseCase(getIt<IProfileRepository>()));
    getIt.registerLazySingleton(() => ChangePasswordUseCase(getIt<IProfileRepository>()));
    getIt.registerLazySingleton(() => DeleteAccountUseCase(getIt<IProfileRepository>()));

    // ------------------------------------------------------------------
    // 4. FEATURES — SHOPPING LIST
    // ------------------------------------------------------------------
    getIt.registerLazySingleton<IShoppingListDataSource>(
      () => ShoppingListRemoteDataSource(getIt<ApiClient>()),
    );
    getIt.registerLazySingleton<IShoppingListRepository>(
      () => ShoppingListRepositoryImpl(getIt<IShoppingListDataSource>()),
    );
    getIt.registerLazySingleton(
      () => GetShoppingListsUseCase(getIt<IShoppingListRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShoppingListByIdUseCase(getIt<IShoppingListRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateShoppingListUseCase(getIt<IShoppingListRepository>()),
    );
    getIt.registerLazySingleton(
      () => DeleteShoppingListUseCase(getIt<IShoppingListRepository>()),
    );
    getIt.registerLazySingleton(
      () => AddItemToListUseCase(getIt<IShoppingListRepository>()),
    );
    getIt.registerLazySingleton(
      () => RemoveItemFromListUseCase(getIt<IShoppingListRepository>()),
    );
    getIt.registerLazySingleton(
      () => UpdateShoppingListUseCase(getIt<IShoppingListRepository>()),
    );
    getIt.registerLazySingleton(
      () => CompareShoppingListUseCase(getIt<IShoppingListRepository>()),
    );

    // ------------------------------------------------------------------
    // 5. FEATURES — PRODUCT
    // ------------------------------------------------------------------
    getIt.registerLazySingleton<IProductDataSource>(
      () => ProductRemoteDataSource(getIt<ApiClient>()),
    );
    getIt.registerLazySingleton<IProductRepository>(
      () => ProductRepositoryImpl(getIt<IProductDataSource>()),
    );
    getIt.registerLazySingleton(
      () => GetAllProductsUseCase(getIt<IProductRepository>()),
    );
    getIt.registerLazySingleton(
      () => SearchProductsUseCase(getIt<IProductRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetCheapestProductsUseCase(getIt<IProductRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetClosestProductsUseCase(getIt<IProductRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetProductPricesUseCase(getIt<IProductRepository>()),
    );

    // ------------------------------------------------------------------
    // 6. FEATURES — SUPERMARKET FINDER
    // ------------------------------------------------------------------
    getIt.registerLazySingleton<ISupermarketDataSource>(
      () => SupermarketRemoteDataSource(getIt<ApiClient>()),
    );
    getIt.registerLazySingleton<ISupermarketRepository>(
      () => SupermarketRepositoryImpl(getIt<ISupermarketDataSource>()),
    );
    getIt.registerLazySingleton(
      () => GetAllSupermarketsUseCase(getIt<ISupermarketRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetClosestSupermarketsUseCase(getIt<ISupermarketRepository>()),
    );
    getIt.registerLazySingleton(
      () => SearchSupermarketsUseCase(getIt<ISupermarketRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetSupermarketProductsUseCase(getIt<ISupermarketRepository>()),
    );

    // ------------------------------------------------------------------
    // 7. FEATURES — NFC SCANNER
    // ------------------------------------------------------------------
    getIt.registerLazySingleton(
      () => NfcRemoteDataSource(getIt<ApiClient>()),
    );
    getIt.registerLazySingleton<INfcRepository>(
      () => NfcRepositoryImpl(getIt<NfcRemoteDataSource>()),
    );
    getIt.registerLazySingleton(
      () => SaveNfceUseCase(getIt<INfcRepository>()),
    );
    getIt.registerLazySingleton(
      () => ConsultNfceByKeyUseCase(getIt<INfcRepository>()),
    );
    getIt.registerLazySingleton(
      () => ParseNfceUrlUseCase(getIt<INfcRepository>()),
    );
  }
}
