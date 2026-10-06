import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_card.dart';
import '../widgets/profile_status_card.dart';

/// Clean Architecture & BLoC Account Screen.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = AccountRemoteDataSourceImpl();
        final repository =
            AccountRepositoryImpl(remoteDataSource: dataSource);
        final getProfile = GetUserProfileUseCase(repository: repository);

        return AccountBloc(getUserProfileUseCase: getProfile)
          ..add(const AccountStarted());
      },
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading || state is AccountInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF007DFE),
              ),
            );
          }

          if (state is AccountError) {
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

          if (state is AccountLoaded) {
            final profile = state.profile;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // 1. Top Cover, Avatar, Name & Stats
                  ProfileHeader(
                    fullName: profile.fullName,
                    username: profile.username,
                    bio: profile.bio,
                    friendsCount: profile.friendsCount,
                    postsCount: profile.postsCount,
                    groupsCount: profile.groupsCount,
                    onEditProfile: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(lang.editProfileSnackBar),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // 2. Navigation Settings Menu Card
                  const ProfileMenuCard(),

                  // 3. Status Update Card
                  const ProfileStatusCard(),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
