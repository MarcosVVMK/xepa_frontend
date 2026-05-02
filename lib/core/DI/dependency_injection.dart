import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../auth/token_storage.dart';

import '../../features/auth/data/datasources/auth_remote_ds.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';

import '../../features/profile/data/datasources/profile_remote_ds.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/i_profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/save_address_usecase.dart';
import '../../features/profile/domain/usecases/change_password_usecase.dart';
import '../services/geocoding_service.dart';
import '../services/geocoding_service_impl.dart';
import '../services/zipcode_service.dart';
import '../services/zipcode_service_impl.dart';

import '../../features/nfc_scanner/data/datasources/nfc_parser_service.dart';
import '../../features/product/data/datasources/product_service.dart';
import '../../features/shopping_list/data/datasources/shopping_list_service.dart';

final getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // ------------------------------------------------------------------
    // 1. CORE
    // ------------------------------------------------------------------
    getIt.registerLazySingleton(() => const FlutterSecureStorage());
    getIt.registerLazySingleton(() => Dio());
    getIt.registerLazySingleton(() => TokenStorage(getIt()));
    getIt.registerLazySingleton(() => ApiClient(getIt(), getIt()));

    // ------------------------------------------------------------------
    // 3. FEATURES - AUTH (Exemplo completo de fluxo)
    // ------------------------------------------------------------------
    
    // DataSources
    getIt.registerLazySingleton(() => AuthRemoteDataSource(getIt<ApiClient>()));

    // Repositories
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        tokenStorage: getIt<TokenStorage>(),
      ),
    );

    // UseCases
    getIt.registerLazySingleton(() => LoginUseCase(getIt<IAuthRepository>()));
    getIt.registerLazySingleton(() => RegisterUseCase(getIt<IAuthRepository>()));

    // ------------------------------------------------------------------
    // 4. FEATURES - PROFILE
    // ------------------------------------------------------------------

    getIt.registerLazySingleton(() => ProfileRemoteDataSource(getIt<ApiClient>()));
    getIt.registerLazySingleton<IGeocodingService>(() => GeocodingServiceImpl());
    getIt.registerLazySingleton<IZipCodeService>(() => ZipCodeServiceImpl(getIt<ApiClient>()));
    
    getIt.registerLazySingleton<IProfileRepository>(
      () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
    );
    getIt.registerLazySingleton(() => GetProfileUseCase(getIt<IProfileRepository>()));
    getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt<IProfileRepository>()));
    getIt.registerLazySingleton(() => SaveAddressUseCase(getIt<IProfileRepository>()));
    getIt.registerLazySingleton(() => ChangePasswordUseCase(getIt<IProfileRepository>()));

    // ------------------------------------------------------------------
    // 5. FEATURES - NFC & SHOPPING LIST
    // ------------------------------------------------------------------
    
    // DataSources
    getIt.registerLazySingleton(() => NfcParserService(getIt<ApiClient>()));
    getIt.registerLazySingleton(() => ProductService(getIt<ApiClient>()));
    getIt.registerLazySingleton(() => ShoppingListService(getIt<ApiClient>()));

    // Repositories
    // getIt.registerLazySingleton<INfcRepository>(() => NfcRepositoryImpl(getIt()));
    // getIt.registerLazySingleton<IShoppingRepository>(() => ShoppingRepositoryImpl(getIt()));

    // UseCases
    // getIt.registerLazySingleton(() => GetNfcHistory(getIt()));
    // getIt.registerLazySingleton(() => GetShoppingLists(getIt()));

    // ------------------------------------------------------------------
    // 6. PRESENTATION (Blocs / Cubits)
    // ------------------------------------------------------------------
    // We use registerFactory so that each screen has its own fresh instance
    // getIt.registerFactory(() => AuthBloc(getIt<LoginUseCase>()));
    // getIt.registerFactory(() => NfcBloc(getIt<GetNfcHistory>()));
  }
}