import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minichatapp/Feature/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:minichatapp/Feature/navigation/presentation/bloc/navigation_event.dart';
import 'package:minichatapp/Feature/navigation/presentation/bloc/navigation_state.dart';
import 'package:minichatapp/Feature/navigation/presentation/widgets/app_bottom_nav_bar.dart';

import '../../../account/presentation/pages/account_page.dart';
import '../../../call/presentation/pages/call_page.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../friend/presentation/pages/friend_page.dart';
import 'package:minichatapp/Feature/qr/presentation/pages/qr_scanner_page.dart';
import '../../../calling/data/services/call_signaling_service.dart';
import '../../../calling/presentation/pages/calling_page.dart';
import '../../../../core/network/signalr_service.dart';

/// Clean Architecture & BLoC Shell screen ("home") hosting persistent tabs.
class HomePage extends StatelessWidget {
  final int initialIndex;

  const HomePage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationBloc(initialIndex: initialIndex),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  static const List<Widget> _pages = [
    ChatPage(),
    FriendPage(),
    CallPage(),
    AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 1. Kết nối chat SignalR nếu chưa kết nối
    if (!SignalRService.instance.isConnected) {
      SignalRService.instance.initSignalR();
    }
    // 2. Kết nối WebRTC CallHub và đăng ký nhận cuộc gọi đến toàn cục
    CallingPage.registerGlobalCallHandler();
    CallSignalingService.instance.initSignalR();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: IndexedStack(
            index: state.selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: state.selectedIndex,
            onTap: (index) {
              context.read<NavigationBloc>().add(NavigationTabChanged(index));
            },
            onQrTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const QrScannerPage(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
