import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/Login/presentation/pages/login_page.dart';
import 'package:minichatapp/Feature/common/widgets/app_bottom_dialog.dart';
import 'package:minichatapp/Feature/common/widgets/avatar_picker_bottom_sheet.dart';
import 'package:minichatapp/core/network/auth_api_client.dart';
import 'package:minichatapp/core/storage/token_storage.dart';
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

class _AccountView extends StatefulWidget {
  const _AccountView();

  @override
  State<_AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<_AccountView> {
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _loadSavedAvatar();
  }

  Future<void> _loadSavedAvatar() async {
    final path = await TokenStorage.instance.getAvatarPath();
    if (path != null && mounted) {
      final file = File(path);
      if (file.existsSync()) {
        setState(() {
          _avatarFile = file;
        });
      }
    }
  }

  Future<void> _changeAvatar() async {
    final picked = await AvatarPickerHelper.showAvatarPickerBottomSheet(context);
    if (!mounted || picked == null) return;
    setState(() {
      _avatarFile = picked;
    });

    // 1. Lưu đường dẫn cục bộ để app hiển thị ngay lập tức
    await TokenStorage.instance.saveAvatarPath(picked.path);

    // 2. Gửi file ảnh trực tiếp lên Backend để lưu vào Database
    String? serverAvatarUrl;
    String? uploadError;
    try {
      serverAvatarUrl = await AuthApiClient().uploadAvatar(picked);
    } catch (e) {
      uploadError = e.toString().replaceAll('Exception: ', '');
    }

    if (!mounted) return;

    if (serverAvatarUrl != null && serverAvatarUrl.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Đã cập nhật ảnh đại diện lên Database thành công!',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Nạp lại dữ liệu hồ sơ từ Backend
      context.read<AccountBloc>().add(const AccountStarted());
    } else {
      final msg = uploadError != null && uploadError.isNotEmpty
          ? '⚠️ Chưa thể lưu lên Database ($uploadError).'
          : '⚠️ Chưa thể lưu lên Database (hãy kiểm tra phiên đăng nhập).';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    await AppBottomDialog.show(
      context: context,
      type: AppBottomDialogType.warning,
      title: 'Đăng xuất tài khoản',
      message: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản Mini Chat không?',
      primaryButtonText: 'Đăng xuất',
      secondaryButtonText: 'Hủy bỏ',
      onPrimaryPressed: () async {
        // 1. Xóa Token và phiên đăng nhập
        await AuthApiClient().logout();

        // 2. Chuyển hướng về màn hình Đăng nhập
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

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
                    avatarUrl: profile.avatarUrl,
                    avatarFile: _avatarFile,
                    onCameraTap: _changeAvatar,
                    onEditProfile: _changeAvatar,
                  ),

                  const SizedBox(height: 12),

                  // 2. Navigation Settings Menu Card
                  ProfileMenuCard(
                    onLogout: _showLogoutDialog,
                  ),

                  // 3. Status Update Card
                  const ProfileStatusCard(),

                  const SizedBox(height: 16),

                  // 4. Dedicated Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _showLogoutDialog,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                        label: Text(
                          'Đăng xuất',
                          style: GoogleFonts.nunito(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEF2F2),
                          side: const BorderSide(
                            color: Color(0xFFFECACA),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
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
