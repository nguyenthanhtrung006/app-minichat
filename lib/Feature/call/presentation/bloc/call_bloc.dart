import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_call_history_usecase.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final GetCallHistoryUseCase getCallHistoryUseCase;
  int _currentPage = 1;
  static const int _pageSize = 30;

  CallBloc({required this.getCallHistoryUseCase}) : super(const CallInitial()) {
    on<CallStarted>(_onCallStarted);
    on<CallRefreshed>(_onCallRefreshed);
    on<CallLoadMore>(_onCallLoadMore);
  }

  Future<void> _onCallStarted(
    CallStarted event,
    Emitter<CallState> emit,
  ) async {
    emit(const CallLoading());
    try {
      _currentPage = 1;
      final calls = await getCallHistoryUseCase(page: 1, pageSize: _pageSize);
      emit(CallLoaded(calls, hasReachedMax: calls.length < _pageSize));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  Future<void> _onCallRefreshed(
    CallRefreshed event,
    Emitter<CallState> emit,
  ) async {
    try {
      _currentPage = 1;
      final calls = await getCallHistoryUseCase(page: 1, pageSize: _pageSize);
      emit(CallLoaded(calls, hasReachedMax: calls.length < _pageSize));
    } catch (_) {}
  }

  Future<void> _onCallLoadMore(
    CallLoadMore event,
    Emitter<CallState> emit,
  ) async {
    if (state is! CallLoaded) return;
    final currentState = state as CallLoaded;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final nextPage = _currentPage + 1;
      final nextCalls = await getCallHistoryUseCase(
        page: nextPage,
        pageSize: _pageSize,
      );
      _currentPage = nextPage;
      final hasReachedMax = nextCalls.length < _pageSize;
      emit(CallLoaded(
        [...currentState.calls, ...nextCalls],
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
