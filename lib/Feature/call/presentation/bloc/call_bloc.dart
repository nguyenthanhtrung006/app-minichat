import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_call_history_usecase.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final GetCallHistoryUseCase getCallHistoryUseCase;

  CallBloc({required this.getCallHistoryUseCase}) : super(const CallInitial()) {
    on<CallStarted>(_onCallStarted);
  }

  Future<void> _onCallStarted(
    CallStarted event,
    Emitter<CallState> emit,
  ) async {
    emit(const CallLoading());
    try {
      final calls = await getCallHistoryUseCase();
      emit(CallLoaded(calls));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }
}
