import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minichatapp/l10n/app_localizations.dart';
import '../../../Login/presentation/pages/login_page.dart';
import '../../data/datasources/landing_local_datasource.dart';
import '../../data/repositories/landing_repository_impl.dart';
import '../../domain/entities/landing_page_data.dart';
import '../../domain/usecases/complete_landing_usecase.dart';
import '../../domain/usecases/get_landing_pages_usecase.dart';
import '../bloc/landing_bloc.dart';
import '../bloc/landing_event.dart';
import '../bloc/landing_state.dart';
import '../widgets/connect_illustration_header.dart';
import '../widgets/features_grid_header.dart';
import '../widgets/landing_action_button.dart';
import '../widgets/landing_next_button.dart';

/// The Landing / Onboarding screen built using Clean Architecture & BLoC.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = LandingLocalDataSourceImpl();
        final repository = LandingRepositoryImpl(localDataSource: dataSource);
        final getPages = GetLandingPagesUseCase(repository: repository);
        final completeLanding = CompleteLandingUseCase(repository: repository);

        return LandingBloc(
          getLandingPagesUseCase: getPages,
          completeLandingUseCase: completeLanding,
        )..add(const LandingStarted());
      },
      child: const _LandingView(),
    );
  }
}

class _LandingView extends StatefulWidget {
  const _LandingView();

  @override
  State<_LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<_LandingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.50;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocConsumer<LandingBloc, LandingState>(
        listener: (context, state) {
          if (state is LandingFinished) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LandingLoading || state is LandingInitial) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF007DFE),
                ),
              ),
            );
          }

          if (state is LandingReady) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: PageView.builder(
                controller: _pageController,
                itemCount: state.pages.length,
                onPageChanged: (index) {
                  context.read<LandingBloc>().add(LandingPageChanged(index));
                },
                itemBuilder: (context, index) {
                  final pageData = state.pages[index];

                  if (pageData.type == LandingType.connect) {
                    return _buildConnectPage(
                      context,
                      pageData: pageData,
                      headerHeight: headerHeight,
                    );
                  } else {
                    return _buildAllInOnePage(
                      context,
                      pageData: pageData,
                      headerHeight: headerHeight,
                    );
                  }
                },
              ),
            );
          }

          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    );
  }

  /// Page 1: "Kết nối mọi người Gần hơn"
  Widget _buildConnectPage(
    BuildContext context, {
    required LandingPageData pageData,
    required double headerHeight,
  }) {
    final lang = context.l10n;

    return Column(
      children: [
        // 1. Top Illustration Header
        ConnectIllustrationHeader(height: headerHeight),

        // 2. Middle Text Area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  lang.landingTitle1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF007DFE),
                    height: 1.25,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  lang.landingSubtitle1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A6E85),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Bottom Small "Tiếp theo -->" Button on Right Corner
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: Align(
              alignment: Alignment.centerRight,
              child: LandingNextButton(
                text: lang.next,
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Page 2: "Tất cả trong một"
  Widget _buildAllInOnePage(
    BuildContext context, {
    required LandingPageData pageData,
    required double headerHeight,
  }) {
    final lang = context.l10n;

    return Column(
      children: [
        // 1. Top Features Grid Header
        FeaturesGridHeader(height: headerHeight),

        // 2. Middle Text Area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  lang.landingTitle2,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF007DFE),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  lang.landingSubtitle2,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A6E85),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Bottom "Bắt đầu" CTA Button
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: LandingActionButton(
              text: lang.start,
              onPressed: () {
                context.read<LandingBloc>().add(const LandingCompletedEvent());
              },
            ),
          ),
        ),
      ],
    );
  }
}
