import 'package:flutter/material.dart';
import '../presentation/pages/landing_page.dart';

// Re-export presentation page
export '../presentation/pages/landing_page.dart';

/// Backward compatibility alias for [LandingPage]
class LangdingPage extends StatelessWidget {
  const LangdingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LandingPage();
  }
}
