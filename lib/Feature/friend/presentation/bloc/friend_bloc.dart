import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/friend_remote_datasource.dart';
import '../../domain/entities/friend_entities.dart';
import '../../domain/usecases/friend_usecases.dart';
import 'friend_event.dart';
import 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final GetFriendDataUseCase getFriendDataUseCase;
  final ToggleFriendRequestUseCase toggleFriendRequestUseCase;

  StreamSubscription? _friendsSub;
  StreamSubscription? _requestsSub;

  FriendBloc({
    required this.getFriendDataUseCase,
    required this.toggleFriendRequestUseCase,
  }) : super(const FriendInitial()) {
    on<FriendStarted>(_onFriendStarted);
    on<FriendRefreshed>(_onFriendRefreshed);
    on<FriendLoadMore>(_onFriendLoadMore);
    on<FriendSearchChanged>(_onFriendSearchChanged);
    on<FriendRequestToggled>(_onFriendRequestToggled);
    on<FriendAdded>(_onFriendAdded);
    on<FriendStreamUpdated>(_onFriendStreamUpdated);

    // Lắng nghe cập nhật realtime từ FriendRemoteDataSource (quét QR, SignalR, ...)
    _friendsSub =
        FriendRemoteDataSourceImpl.instance.friendsStream.listen((friends) {
      if (state is FriendLoaded) {
        final current = state as FriendLoaded;
        add(FriendStreamUpdated(friends: friends, requests: current.requests));
      }
    });

    _requestsSub =
        FriendRemoteDataSourceImpl.instance.requestsStream.listen((requests) {
      if (state is FriendLoaded) {
        final current = state as FriendLoaded;
        add(FriendStreamUpdated(
            friends: current.allFriends, requests: requests));
      }
    });
  }

  @override
  Future<void> close() {
    _friendsSub?.cancel();
    _requestsSub?.cancel();
    return super.close();
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

  Future<void> _onFriendRefreshed(
    FriendRefreshed event,
    Emitter<FriendState> emit,
  ) async {
    try {
      await FriendRemoteDataSourceImpl.instance.syncWithDatabase();
      final data = await getFriendDataUseCase();
      final requests = data['requests'] as List<FriendRequest>;
      final friends = data['friends'] as List<FriendItem>;
      final query =
          state is FriendLoaded ? (state as FriendLoaded).searchQuery : '';
      final q = query.toLowerCase().trim();
      final filtered = q.isEmpty
          ? friends
          : friends.where((f) => f.name.toLowerCase().contains(q)).toList();
      emit(
        FriendLoaded(
          requests: requests,
          allFriends: friends,
          filteredFriends: filtered,
          searchQuery: query,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onFriendLoadMore(
    FriendLoadMore event,
    Emitter<FriendState> emit,
  ) async {
    if (state is! FriendLoaded) return;
    final current = state as FriendLoaded;
    if (current.hasReachedMax || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(current.copyWith(isLoadingMore: false, hasReachedMax: true));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
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

  Future<void> _onFriendAdded(
    FriendAdded event,
    Emitter<FriendState> emit,
  ) async {
    await FriendRemoteDataSourceImpl.instance.addFriend(event.friend);
  }

  void _onFriendStreamUpdated(
    FriendStreamUpdated event,
    Emitter<FriendState> emit,
  ) {
    final query =
        state is FriendLoaded ? (state as FriendLoaded).searchQuery : '';
    final q = query.toLowerCase().trim();
    final filtered = q.isEmpty
        ? event.friends
        : event.friends.where((f) => f.name.toLowerCase().contains(q)).toList();

    emit(
      FriendLoaded(
        requests: event.requests,
        allFriends: event.friends,
        filteredFriends: filtered,
        searchQuery: query,
      ),
    );
  }
}
