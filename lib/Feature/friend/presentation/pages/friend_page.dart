import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_search_bar.dart';
import 'package:minichatapp/Feature/common/widgets/app_section_header.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../../sendthedetails/presentation/pages/send_the_details_page.dart';
import '../../data/datasources/friend_remote_datasource.dart';
import '../../data/repositories/friend_repository_impl.dart';
import '../../domain/usecases/friend_usecases.dart';
import '../bloc/friend_bloc.dart';
import '../bloc/friend_event.dart';
import '../bloc/friend_state.dart';
import '../widgets/friend_request_tile.dart';
import '../widgets/friend_tile.dart';

/// Clean Architecture & BLoC Friend Screen.
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

class _FriendView extends StatelessWidget {
  const _FriendView();

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
                          onPressed: () {},
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

            // 3. Friend Content List with BlocBuilder
            Expanded(
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

                    return ListView(
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
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
