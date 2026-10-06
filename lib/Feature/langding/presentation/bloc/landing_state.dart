import 'package:equatable/equatable.dart';
import '../../domain/entities/landing_page_data.dart';

abstract class LandingState extends Equatable {
  const LandingState();

  @override
  List<Object?> get props => [];
}

class LandingInitial extends LandingState {
  const LandingInitial();
}

class LandingLoading extends LandingState {
  const LandingLoading();
}

class LandingReady extends LandingState {
  final List<LandingPageData> pages;
  final int currentPage;

  const LandingReady({
    required this.pages,
    this.currentPage = 0,
  });

  bool get isLastPage => currentPage == pages.length - 1;

  LandingReady copyWith({
    List<LandingPageData>? pages,
    int? currentPage,
  }) {
    return LandingReady(
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [pages, currentPage];
}

class LandingFinished extends LandingState {
  const LandingFinished();
}

class LandingError extends LandingState {
  final String message;

  const LandingError(this.message);

  @override
  List<Object?> get props => [message];
}
