import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/splash/data/datasources/splash_local_datasource.dart';
import 'package:minichatapp/Feature/splash/data/repositories/splash_repository_impl.dart';
import 'package:minichatapp/Feature/splash/domain/repositories/splash_repository.dart';
import 'package:minichatapp/Feature/splash/domain/usecases/initialize_app_usecase.dart';
import 'package:minichatapp/Feature/splash/presentation/bloc/splash_bloc.dart';
import 'package:minichatapp/Feature/splash/presentation/bloc/splash_event.dart';
import 'package:minichatapp/Feature/splash/presentation/bloc/splash_state.dart';

// Mock repository for fast unit testing
class MockSplashRepository implements SplashRepository {
  @override
  Stream<double> initializeApp() async* {
    yield 0.2;
    yield 0.6;
    yield 1.0;
  }

  @override
  Future<bool> checkAuthStatus() async {
    return false;
  }
}

void main() {
  group('Splash Clean Architecture & BLoC Tests', () {
    late SplashRepository repository;
    late InitializeAppUseCase useCase;
    late SplashBloc bloc;

    setUp(() {
      repository = MockSplashRepository();
      useCase = InitializeAppUseCase(repository: repository);
      bloc = SplashBloc(initializeAppUseCase: useCase);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is SplashInitial', () {
      expect(bloc.state, const SplashInitial());
    });

    test('Emits SplashLoading and SplashSuccess when SplashStarted is dispatched',
        () async {
      final expectedStates = [
        const SplashLoading(progress: 0.05),
        const SplashLoading(progress: 0.2),
        const SplashLoading(progress: 0.6),
        const SplashLoading(progress: 1.0),
        const SplashSuccess(isAuthenticated: false),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const SplashStarted());
    });

    test('SplashLocalDataSourceImpl yields progresses up to 1.0', () async {
      final localDataSource = SplashLocalDataSourceImpl();
      final repositoryImpl = SplashRepositoryImpl(localDataSource: localDataSource);

      final progressValues = await repositoryImpl.initializeApp().toList();
      expect(progressValues.last, 1.0);
    });
  });
}
