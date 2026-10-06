import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetUserProfileUseCase getUserProfileUseCase;

  AccountBloc({required this.getUserProfileUseCase})
      : super(const AccountInitial()) {
    on<AccountStarted>(_onAccountStarted);
  }

  Future<void> _onAccountStarted(
    AccountStarted event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
    try {
      final profile = await getUserProfileUseCase();
      emit(AccountLoaded(profile));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }
}
