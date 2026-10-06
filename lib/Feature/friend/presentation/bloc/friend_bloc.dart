import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/friend_entities.dart';
import '../../domain/usecases/friend_usecases.dart';
import 'friend_event.dart';
import 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final GetFriendDataUseCase getFriendDataUseCase;
  final ToggleFriendRequestUseCase toggleFriendRequestUseCase;

  FriendBloc({
    required this.getFriendDataUseCase,
    required this.toggleFriendRequestUseCase,
  }) : super(const FriendInitial()) {
    on<FriendStarted>(_onFriendStarted);
    on<FriendSearchChanged>(_onFriendSearchChanged);
    on<FriendRequestToggled>(_onFriendRequestToggled);
  }

  Future<void> _onFriendStarted(
    FriendStarted event,
    Emitter<FriendState> emit,
  ) async {
    emit(const FriendLoading());
    try {
      final data = await getFriendDataUseCase();
      final requests = data['requests'] as List<FriendRequest>;
      final friends = data['friends'] as List<FriendItem>;
      emit(
        FriendLoaded(
          requests: requests,
          allFriends: friends,
          filteredFriends: friends,
        ),
      );
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  void _onFriendSearchChanged(
    FriendSearchChanged event,
    Emitter<FriendState> emit,
  ) {
    if (state is FriendLoaded) {
      final current = state as FriendLoaded;
      final q = event.query.toLowerCase().trim();
      final filtered = q.isEmpty
          ? current.allFriends
          : current.allFriends
              .where((f) => f.name.toLowerCase().contains(q))
              .toList();

      emit(
        FriendLoaded(
          requests: current.requests,
          allFriends: current.allFriends,
          filteredFriends: filtered,
          searchQuery: event.query,
        ),
      );
    }
  }

  Future<void> _onFriendRequestToggled(
    FriendRequestToggled event,
    Emitter<FriendState> emit,
  ) async {
    if (state is FriendLoaded) {
      final current = state as FriendLoaded;
      await toggleFriendRequestUseCase(event.requestId);

      final updatedRequests = current.requests.map((r) {
        if (r.id == event.requestId) {
          return r.copyWith(isSent: !r.isSent);
        }
        return r;
      }).toList();

      emit(
        FriendLoaded(
          requests: updatedRequests,
          allFriends: current.allFriends,
          filteredFriends: current.filteredFriends,
          searchQuery: current.searchQuery,
        ),
      );
    }
  }
}
