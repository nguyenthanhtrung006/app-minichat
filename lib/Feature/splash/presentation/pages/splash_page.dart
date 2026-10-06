import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/langding/page/langding_page.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../data/datasources/splash_local_datasource.dart';
import '../../data/repositories/splash_repository_impl.dart';
import '../../domain/usecases/initialize_app_usecase.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
import '../widgets/splash_background.dart';
import '../widgets/splash_floating_bubble.dart';
import '../widgets/splash_paper_plane.dart';
import '../widgets/splash_progress_bar.dart';

/// The Splash screen view built using Clean Architecture & BLoC.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide dependencies locally using Clean Architecture layers
    return BlocProvider(
      create: (context) {
        final dataSource = SplashLocalDataSourceImpl();
        final repository = SplashRepositoryImpl(localDataSource: dataSource);
        final useCase = InitializeAppUseCase(repository: repository);
        return SplashBloc(initializeAppUseCase: useCase)
          ..add(const SplashStarted());
      },
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final lang = context.l10n;

    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashSuccess) {
          // Navigate to LandingPage with smooth fade transition
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LangdingPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      },
      child: Scaffold(
        body: SplashBackground(
          child: Stack(
            children: [
              // 1. Paper Airplane flying on upper-right cloud layer
              Positioned(
                right: 24,
                bottom: size.height * 0.28,
                child: const SplashPaperPlane(size: 78),
              ),

              // 2. Small floating speech bubble on lower-left cloud layer
              Positioned(
                left: 32,
                bottom: size.height * 0.16,
                child: const SplashFloatingBubble(size: 56),
              ),

              // 3. Main Center Content (Logo, Titles)
              Positioned(
                top: size.height * 0.18,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Logo
                    Image.asset(
                      height: 150,
                      width: 150,
                      'assets/images/logominichat.png',
                    ),

                    const SizedBox(height: 22),

                    // App Title
                    Text(
                      lang.appName,
                      style: GoogleFonts.nunito(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF0F4996).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // App Slogan
                    Text(
                      lang.appSlogan,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.95),
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF0F4996).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Bottom Loading Bar & Status Text
              Positioned(
                bottom: size.height * 0.08,
                left: 0,
                right: 0,
                child: Center(
                  child: BlocBuilder<SplashBloc, SplashState>(
                    builder: (context, state) {
                      double progress = 0.05;
                      String statusText = lang.loading;

                      if (state is SplashLoading) {
                        progress = state.progress;
                        statusText = state.statusText;
                      } else if (state is SplashSuccess) {
                        progress = 1.0;
                      }

                      return SplashProgressBar(
                        progress: progress,
                        statusText: statusText,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
