import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../domain/usecases/initialize_app_usecase.dart';
import 'splash_event.dart';
import 'splash_state.dart';

/// BLoC managing the Splash screen lifecycle & progress stream.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final InitializeAppUseCase initializeAppUseCase;
  StreamSubscription<double>? _progressSubscription;

  SplashBloc({required this.initializeAppUseCase})
      : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashProgressChanged>(_onSplashProgressChanged);
    on<SplashCompleted>(_onSplashCompleted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    final lang = LocaleController.instance;
    emit(SplashLoading(
      progress: 0.05,
      statusText: lang.loading,
    ));

    await _progressSubscription?.cancel();
    _progressSubscription = initializeAppUseCase().listen(
      (progress) {
        add(SplashProgressChanged(progress));
      },
      onDone: () {
        add(const SplashCompleted(isAuthenticated: false));
      },
      onError: (error) {
        emit(SplashFailure(error.toString()));
      },
    );
  }

  void _onSplashProgressChanged(
    SplashProgressChanged event,
    Emitter<SplashState> emit,
  ) {
    final lang = LocaleController.instance;
    emit(SplashLoading(
      progress: event.progress,
      statusText: lang.loading,
    ));
  }

  void _onSplashCompleted(
    SplashCompleted event,
    Emitter<SplashState> emit,
  ) {
    emit(SplashSuccess(isAuthenticated: event.isAuthenticated));
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}
