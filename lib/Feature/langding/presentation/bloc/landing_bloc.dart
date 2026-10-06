import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/complete_landing_usecase.dart';
import '../../domain/usecases/get_landing_pages_usecase.dart';
import 'landing_event.dart';
import 'landing_state.dart';

class LandingBloc extends Bloc<LandingEvent, LandingState> {
  final GetLandingPagesUseCase getLandingPagesUseCase;
  final CompleteLandingUseCase completeLandingUseCase;

  LandingBloc({
    required this.getLandingPagesUseCase,
    required this.completeLandingUseCase,
  }) : super(const LandingInitial()) {
    on<LandingStarted>(_onLandingStarted);
    on<LandingPageChanged>(_onLandingPageChanged);
    on<LandingNextPageRequested>(_onLandingNextPageRequested);
    on<LandingCompletedEvent>(_onLandingCompletedEvent);
  }

  Future<void> _onLandingStarted(
    LandingStarted event,
    Emitter<LandingState> emit,
  ) async {
    emit(const LandingLoading());
    try {
      final pages = await getLandingPagesUseCase();
      emit(LandingReady(pages: pages, currentPage: 0));
    } catch (e) {
      emit(LandingError(e.toString()));
    }
  }

  void _onLandingPageChanged(
    LandingPageChanged event,
    Emitter<LandingState> emit,
  ) {
    if (state is LandingReady) {
      final currentState = state as LandingReady;
      emit(currentState.copyWith(currentPage: event.pageIndex));
    }
  }

  void _onLandingNextPageRequested(
    LandingNextPageRequested event,
    Emitter<LandingState> emit,
  ) {
    if (state is LandingReady) {
      final currentState = state as LandingReady;
      if (currentState.currentPage < currentState.pages.length - 1) {
        emit(currentState.copyWith(
          currentPage: currentState.currentPage + 1,
        ));
      } else {
        add(const LandingCompletedEvent());
      }
    }
  }

  Future<void> _onLandingCompletedEvent(
    LandingCompletedEvent event,
    Emitter<LandingState> emit,
  ) async {
    try {
      await completeLandingUseCase();
      emit(const LandingFinished());
    } catch (e) {
      emit(LandingError(e.toString()));
    }
  }
}
