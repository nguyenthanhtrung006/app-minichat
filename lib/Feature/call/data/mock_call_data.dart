import '../domain/entities/call_item.dart';

class MockCallData {
  static const List<CallItem> mockCalls = [
    CallItem(
      id: 'c_1',
      name: 'Nguyễn Văn Nam',
      time: '20:15',
      direction: CallDirection.incoming,
      isVideo: false,
    ),
    CallItem(
      id: 'c_2',
      name: 'Phạm Thị Mai',
      time: '19:48',
      direction: CallDirection.missed,
      isVideo: false,
    ),
    CallItem(
      id: 'c_3',
      name: 'Trần Đức Huy',
      time: '18:32',
      direction: CallDirection.video,
      isVideo: true,
    ),
    CallItem(
      id: 'c_4',
      name: 'Lê Thị Hương',
      time: '16:20',
      direction: CallDirection.outgoing,
      isVideo: false,
    ),
    CallItem(
      id: 'c_5',
      name: 'Hoàng Anh',
      time: '14:17',
      direction: CallDirection.video,
      isVideo: true,
    ),
    CallItem(
      id: 'c_6',
      name: 'Thu Hà',
      time: '11:50',
      direction: CallDirection.missed,
      isVideo: false,
    ),
    CallItem(
      id: 'c_7',
      name: 'Minh Hoàng',
      time: '10:32',
      direction: CallDirection.incoming,
      isVideo: false,
    ),
    CallItem(
      id: 'c_8',
      name: 'Đỗ Minh Tú',
      time: 'Hôm qua',
      direction: CallDirection.outgoing,
      isVideo: false,
    ),
  ];
}
