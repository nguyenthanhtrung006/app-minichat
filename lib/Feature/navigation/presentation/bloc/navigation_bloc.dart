import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc({int initialIndex = 0})
      : super(NavigationState(selectedIndex: initialIndex)) {
    on<NavigationTabChanged>((event, emit) {
      if (state.selectedIndex != event.index) {
        emit(NavigationState(selectedIndex: event.index));
      }
    });
  }
}
