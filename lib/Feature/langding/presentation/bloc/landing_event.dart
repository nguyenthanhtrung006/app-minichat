import 'package:equatable/equatable.dart';

abstract class LandingEvent extends Equatable {
  const LandingEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to initialize and fetch landing slides data.
class LandingStarted extends LandingEvent {
  const LandingStarted();
}

/// Dispatched when the active page index changes (via swipe or indicator).
class LandingPageChanged extends LandingEvent {
  final int pageIndex;

  const LandingPageChanged(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

/// Dispatched when user clicks "Bắt đầu" to complete onboarding.
class LandingCompletedEvent extends LandingEvent {
  const LandingCompletedEvent();
}

/// Dispatched when user requests to advance to the next page.
class LandingNextPageRequested extends LandingEvent {
  const LandingNextPageRequested();
}
