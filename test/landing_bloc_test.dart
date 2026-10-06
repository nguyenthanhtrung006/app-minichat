import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/langding/domain/entities/landing_page_data.dart';
import 'package:minichatapp/Feature/langding/domain/repositories/landing_repository.dart';
import 'package:minichatapp/Feature/langding/domain/usecases/complete_landing_usecase.dart';
import 'package:minichatapp/Feature/langding/domain/usecases/get_landing_pages_usecase.dart';
import 'package:minichatapp/Feature/langding/presentation/bloc/landing_bloc.dart';
import 'package:minichatapp/Feature/langding/presentation/bloc/landing_event.dart';
import 'package:minichatapp/Feature/langding/presentation/bloc/landing_state.dart';

class MockLandingRepository implements LandingRepository {
  @override
  Future<List<LandingPageData>> getLandingPages() async {
    return const [
      LandingPageData(
        index: 0,
        title: 'Kết nối mọi người\nGần hơn',
        subtitle: 'Nhắn tin • Gọi điện • Kết bạn • Nhóm',
        type: LandingType.connect,
      ),
      LandingPageData(
        index: 1,
        title: 'Tất cả trong một',
        subtitle: 'Trò chuyện, gọi điện, chia sẻ và kết nối với bạn bè thật dễ dàng.',
        type: LandingType.allInOne,
        buttonText: 'Bắt đầu',
      ),
    ];
  }

  @override
  Future<bool> completeLanding() async => true;

  @override
  Future<bool> isLandingCompleted() async => false;
}

void main() {
  group('Landing Clean Architecture & BLoC Tests', () {
    late LandingRepository repository;
    late GetLandingPagesUseCase getPagesUseCase;
    late CompleteLandingUseCase completeUseCase;
    late LandingBloc bloc;

    setUp(() {
      repository = MockLandingRepository();
      getPagesUseCase = GetLandingPagesUseCase(repository: repository);
      completeUseCase = CompleteLandingUseCase(repository: repository);
      bloc = LandingBloc(
        getLandingPagesUseCase: getPagesUseCase,
        completeLandingUseCase: completeUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is LandingInitial', () {
      expect(bloc.state, const LandingInitial());
    });

    test('Loads pages and emits LandingReady on LandingStarted', () async {
      bloc.add(const LandingStarted());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const LandingLoading(),
          isA<LandingReady>()
              .having((s) => s.pages.length, 'pages length', 2)
              .having((s) => s.currentPage, 'current page', 0),
        ]),
      );
    });

    test('Updates current page on LandingPageChanged', () async {
      bloc.add(const LandingStarted());
      await bloc.stream.firstWhere((s) => s is LandingReady);

      bloc.add(const LandingPageChanged(1));

      await expectLater(
        bloc.stream,
        emits(isA<LandingReady>().having((s) => s.currentPage, 'current page', 1)),
      );
    });

    test('Emits LandingFinished on LandingCompletedEvent', () async {
      bloc.add(const LandingStarted());
      await bloc.stream.firstWhere((s) => s is LandingReady);

      bloc.add(const LandingCompletedEvent());

      await expectLater(
        bloc.stream,
        emits(const LandingFinished()),
      );
    });
  });
}
