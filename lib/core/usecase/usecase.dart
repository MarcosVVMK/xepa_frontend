import 'package:xepa_frontend/core/utils/typedef.dart';

abstract class UseCase<Type, Params> {
    ResultFuture<Type> call(Params params);
}