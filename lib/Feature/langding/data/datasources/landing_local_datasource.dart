import '../../domain/entities/landing_page_data.dart';
import '../models/landing_page_model.dart';

abstract class LandingLocalDataSource {
  Future<List<LandingPageModel>> getLandingPages();
  Future<bool> markLandingComplete();
  Future<bool> isLandingComplete();
}

class LandingLocalDataSourceImpl implements LandingLocalDataSource {
  bool _isCompleted = false;

  @override
  Future<List<LandingPageModel>> getLandingPages() async {
    // Return the onboarding pages defined by the design
    return const [
      LandingPageModel(
        index: 0,
        title: 'Kết nối mọi người\nGần hơn',
        subtitle: 'Nhắn tin • Gọi điện • Kết bạn • Nhóm',
        type: LandingType.connect,
        buttonText: 'Tiếp theo',
      ),
      LandingPageModel(
        index: 1,
        title: 'Tất cả trong một',
        subtitle: 'Trò chuyện, gọi điện, chia sẻ và\nkết nối với bạn bè thật dễ dàng.',
        type: LandingType.allInOne,
        buttonText: 'Bắt đầu',
      ),
    ];
  }

  @override
  Future<bool> markLandingComplete() async {
    _isCompleted = true;
    return true;
  }

  @override
  Future<bool> isLandingComplete() async {
    return _isCompleted;
  }
}
