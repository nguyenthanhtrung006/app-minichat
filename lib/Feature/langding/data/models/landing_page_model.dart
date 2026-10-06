import '../../domain/entities/landing_page_data.dart';

class LandingPageModel extends LandingPageData {
  const LandingPageModel({
    required super.index,
    required super.title,
    required super.subtitle,
    required super.type,
    super.buttonText,
  });

  factory LandingPageModel.fromJson(Map<String, dynamic> json) {
    return LandingPageModel(
      index: json['index'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      type: json['type'] == 'allInOne'
          ? LandingType.allInOne
          : LandingType.connect,
      buttonText: json['buttonText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'title': title,
      'subtitle': subtitle,
      'type': type.name,
      'buttonText': buttonText,
    };
  }
}
