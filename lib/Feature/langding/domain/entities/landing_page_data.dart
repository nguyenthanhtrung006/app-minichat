import 'package:equatable/equatable.dart';

enum LandingType {
  connect,
  allInOne,
}

/// Represents the data required to render a landing / onboarding slide.
class LandingPageData extends Equatable {
  final int index;
  final String title;
  final String subtitle;
  final LandingType type;
  final String? buttonText;

  const LandingPageData({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.type,
    this.buttonText,
  });

  @override
  List<Object?> get props => [index, title, subtitle, type, buttonText];
}
