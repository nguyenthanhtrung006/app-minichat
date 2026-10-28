import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_search_bar.dart';
import 'package:minichatapp/Feature/common/widgets/app_section_header.dart';
import 'package:minichatapp/Feature/qr/presentation/pages/my_qr_screen.dart';
import 'package:minichatapp/Feature/qr/presentation/pages/qr_scanner_page.dart';
import 'package:minichatapp/core/network/friend_api_client.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../../account/data/datasources/account_remote_datasource.dart';
import '../../../sendthedetails/presentation/pages/send_the_details_page.dart';
import '../../data/datasources/friend_remote_datasource.dart';
import '../../data/repositories/friend_repository_impl.dart';
import '../../domain/usecases/friend_usecases.dart';
import '../bloc/friend_bloc.dart';
import '../bloc/friend_event.dart';
import '../bloc/friend_state.dart';
import '../widgets/friend_request_tile.dart';
import '../widgets/friend_tile.dart';

/// Clean Architecture & BLoC Friend Screen với Pull-to-Refresh & Load More.
class FriendPage extends StatelessWidget {
  const FriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = FriendRemoteDataSourceImpl();
        final repository = FriendRepositoryImpl(remoteDataSource: dataSource);
        final getData = GetFriendDataUseCase(repository: repository);
        final toggleRequest =
            ToggleFriendRequestUseCase(repository: repository);

        return FriendBloc(
          getFriendDataUseCase: getData,
          toggleFriendRequestUseCase: toggleRequest,
        )..add(const FriendStarted());
      },
      child: const _FriendView(),
    );
  }
}

class _FriendView extends StatefulWidget {
  const _FriendView();

  @override
  State<_FriendView> createState() => _FriendViewState();
}

class _FriendViewState extends State<_FriendView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 50) {
      context.read<FriendBloc>().add(const FriendLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 14, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.friendsTitle,
                    style: GoogleFonts.nunito(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const QrScannerPage(),
                              ),
                            );
                            if (context.mounted) {
                              context
                                  .read<FriendBloc>()
                                  .add(const FriendStarted());
                            }
                          },
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Color(0xFF007DFE),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.perm_contact_calendar_rounded,
                          color: Color(0xFF007DFE),
                          size: 24,
                        ),
                        splashRadius: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Reusable Capsule Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppSearchBar(
                hintText: lang.searchFriends,
                onChanged: (val) {
                  context.read<FriendBloc>().add(FriendSearchChanged(val));
                },
              ),
            ),
            const SizedBox(height: 8),

            // 3. Friend Content List with RefreshIndicator & Load More
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF007DFE),
                backgroundColor: Colors.white,
                onRefresh: () async {
                  context.read<FriendBloc>().add(const FriendRefreshed());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: BlocBuilder<FriendBloc, FriendState>(
                  builder: (context, state) {
                    if (state is FriendLoading || state is FriendInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF007DFE),
                        ),
                      );
                    }

                    if (state is FriendError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    }

                    if (state is FriendLoaded) {
                      final requests = state.requests;
                      final friends = state.filteredFriends;

                      if (requests.isEmpty && friends.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                  vertical: 48.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 76,
                                      height: 76,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEFF6FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.people_outline_rounded,
                                        color: Color(0xFF007DFE),
                                        size: 38,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      'Chưa có bạn bè nào',
                                      style: GoogleFonts.nunito(
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Quét mã QR kết bạn hoặc chia sẻ mã QR của bạn để kết nối trực tiếp!',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF64748B),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => const QrScannerPage(),
                                              ),
                                            );
                                            if (context.mounted) {
                                              context
                                                  .read<FriendBloc>()
                                                  .add(const FriendStarted());
                                            }
                                          },
                                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                                          label: Text(
                                            'Quét mã QR',
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF007DFE),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(22),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 18,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        OutlinedButton.icon(
                                          onPressed: () async {
                                            final profile = await AccountRemoteDataSourceImpl()
                                                .getUserProfile();
                                            final myQrData = await FriendApiClient().getMyQr();
                                            if (!context.mounted) return;
                                            final qrData = myQrData?['qrCodeString']?.toString() ??
                                                'minichat://add/${profile.id}?name=${Uri.encodeComponent(profile.fullName)}&avatar=${Uri.encodeComponent(profile.avatarUrl ?? '')}';
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => MyQrScreen(
                                                  qrCodeString: qrData,
                                                  fullName: profile.fullName,
                                                  avatarUrl: profile.avatarUrl,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.qr_code_2_rounded,
                                            size: 18,
                                            color: Color(0xFF007DFE),
                                          ),
                                          label: Text(
                                            'Mã của tôi',
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: const Color(0xFF007DFE),
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Color(0xFFBFDBFE)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(22),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 18,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          // Section 1: Lời mời kết bạn
                          if (state.searchQuery.isEmpty &&
                              requests.isNotEmpty) ...[
                            AppSectionHeader(
                              title: '${lang.friendRequests} (${requests.length})',
                            ),
                            ...requests.map((req) {
                              return FriendRequestTile(
                                request: req,
                                onSendRequest: () {
                                 context
                                      .read<FriendBloc>()
                                      .add(FriendRequestToggled(req.id));
                                },
                              );
                            }),
                            const SizedBox(height: 10),
                          ],

                          // Section 2: Bạn bè
                          AppSectionHeader(
                            title: '${lang.friendsList} (${friends.length})',
                          ),
                          if (friends.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  lang.noFriendsFound,
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...friends.map(
                              (f) => FriendTile(
                                friend: f,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SendTheDetailsPage(
                                        contactName: f.name,
                                        isOnline: f.isOnline,
                                        avatarUrl: f.avatarUrl,
                                        targetUserId: f.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          // Load More spinner
                          if (state.isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF007DFE),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
