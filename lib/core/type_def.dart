import 'package:fpdart/fpdart.dart';
import 'package:leaf_and_quill_app/core/errors/failures.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
