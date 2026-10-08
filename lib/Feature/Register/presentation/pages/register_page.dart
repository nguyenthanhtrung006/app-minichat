import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/Feature/common/widgets/avatar_picker_bottom_sheet.dart';
import 'package:minichatapp/core/storage/token_storage.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../data/datasources/register_remote_datasource.dart';
import '../../data/repositories/register_repository_impl.dart';
import '../../domain/entities/register_params.dart';
import '../../domain/usecases/register_usecase.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import 'package:minichatapp/Feature/Login/presentation/widgets/custom_text_field.dart';
import 'package:minichatapp/Feature/Login/presentation/pages/login_page.dart';
import 'package:minichatapp/Feature/common/widgets/app_bottom_dialog.dart';
import 'package:minichatapp/core/network/auth_api_client.dart';

/// The Register screen built with Clean Architecture & BLoC.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = RegisterRemoteDataSourceImpl();
        final repository = RegisterRepositoryImpl(remoteDataSource: dataSource);
        final useCase = RegisterUseCase(repository: repository);

        return RegisterBloc(registerUseCase: useCase);
      },
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _fullNameController = TextEditingController();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validation error messages
  String? _fullNameError;
  String? _emailOrPhoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  File? _avatarFile;

  Future<void> _pickAvatar() async {
    final picked = await AvatarPickerHelper.showAvatarPickerBottomSheet(context);
    if (!mounted || picked == null) return;
    setState(() {
      _avatarFile = picked;
    });
    await TokenStorage.instance.saveAvatarPath(picked.path);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitRegister(BuildContext context) {
    final lang = context.l10n;
    final fullName = _fullNameController.text.trim();
    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? fullNameErr;
    String? emailOrPhoneErr;
    String? passwordErr;
    String? confirmPasswordErr;

    if (fullName.isEmpty) {
      fullNameErr = lang.enterFullName;
    }

    if (emailOrPhone.isEmpty) {
      emailOrPhoneErr = lang.enterEmailOrPhone;
    } else if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(emailOrPhone)) {
      emailOrPhoneErr = 'Email không hợp lệ (Ví dụ: user@gmail.com)';
    }

    if (password.isEmpty) {
      passwordErr = lang.enterPassword;
    } else if (password.length < 6) {
      passwordErr = lang.passwordMinLength;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordErr = lang.enterConfirmPassword;
    } else if (password != confirmPassword) {
      confirmPasswordErr = lang.passwordNotMatch;
    }

    setState(() {
      _fullNameError = fullNameErr;
      _emailOrPhoneError = emailOrPhoneErr;
      _passwordError = passwordErr;
      _confirmPasswordError = confirmPasswordErr;
    });

    if (fullNameErr != null ||
        emailOrPhoneErr != null ||
        passwordErr != null ||
        confirmPasswordErr != null) {
      return;
    }

    context.read<RegisterBloc>().add(
          RegisterSubmitted(
            RegisterParams(
              fullName: fullName,
              emailOrPhone: emailOrPhone,
              password: password,
              confirmPassword: confirmPassword,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF007DFE),
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          lang.registerTitle,
          style: GoogleFonts.nunito(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<RegisterBloc, RegisterState>(
          listener: (context, state) async {
            if (state is RegisterFailure) {
              await AppBottomDialog.showError(
                context: context,
                title: 'Đăng ký thất bại',
                message: state.errorMessage,
                primaryButtonText: 'Thử lại',
              );
            } else if (state is RegisterSuccess) {
              final registeredEmail = _emailOrPhoneController.text.trim();

              // Nếu người dùng đã chọn ảnh đại diện lúc đăng ký, tải ngay lên Database
              if (_avatarFile != null) {
                try {
                  debugPrint('🚀 [RegisterPage]: Tải ảnh đại diện lên Database cho tài khoản mới...');
                  await AuthApiClient().uploadAvatar(_avatarFile!);
                  debugPrint('✅ [RegisterPage]: Tải ảnh đại diện lên Database thành công!');
                } catch (e) {
                  debugPrint('⚠️ [RegisterPage]: Chưa thể tải avatar lên server: $e');
                }
              }

              // Xóa token đăng ký tạm để người dùng đăng nhập chính thức
              await TokenStorage.instance.deleteToken();

              if (!context.mounted) return;
              // Hiển thị Dialog dưới dạng Bottom Sheet theo yêu cầu người dùng
              await AppBottomDialog.showSuccess(
                context: context,
                title: 'Đăng ký tài khoản thành công!',
                message:
                    'Tài khoản $registeredEmail đã được tạo thành công.\nVui lòng đăng nhập để bắt đầu trải nghiệm!',
                primaryButtonText: 'Đăng nhập ngay',
              );

              if (!context.mounted) return;
              // Quay lại trang đăng nhập (LoginPage) và truyền lại email vừa đăng ký
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(registeredEmail);
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            }
          },
          builder: (context, state) {
            final isLoading = state is RegisterLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 0. Avatar Picker
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF007DFE).withValues(alpha: 0.2),
                                width: 3,
                              ),
                            ),
                            child: AppAvatar(
                              name: _fullNameController.text.isNotEmpty
                                  ? _fullNameController.text
                                  : 'Mini Chat',
                              size: 84,
                              imageFile: _avatarFile,
                              showCameraBadge: true,
                              onCameraTap: _pickAvatar,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ảnh đại diện',
                          style: GoogleFonts.nunito(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 1. Full name
                  _buildLabel(lang.fullName),
                  _buildCapsuleInput(
                    controller: _fullNameController,
                    hintText: lang.fullNameHint,
                    errorText: _fullNameError,
                    onChanged: (val) {
                      if (_fullNameError != null) {
                        setState(() => _fullNameError = null);
                      }
                    },
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2. Email or Phone
                  _buildLabel(lang.phoneOrEmail),
                  _buildCapsuleInput(
                    controller: _emailOrPhoneController,
                    hintText: lang.phoneOrEmailHint,
                    errorText: _emailOrPhoneError,
                    onChanged: (val) {
                      if (_emailOrPhoneError != null) {
                        setState(() => _emailOrPhoneError = null);
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Password
                  _buildLabel(lang.password),
                  _buildCapsuleInput(
                    controller: _passwordController,
                    hintText: lang.passwordHint,
                    errorText: _passwordError,
                    onChanged: (val) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4. Confirm Password
                  _buildLabel(lang.confirmPassword),
                  _buildCapsuleInput(
                    controller: _confirmPasswordController,
                    hintText: lang.confirmPasswordHint,
                    errorText: _confirmPasswordError,
                    onChanged: (val) {
                      if (_confirmPasswordError != null) {
                        setState(() => _confirmPasswordError = null);
                      }
                    },
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 36),

                  // 5. Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submitRegister(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007DFE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        shadowColor: const Color(0xFF007DFE).withValues(alpha: 0.35),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            )
                          : Text(
                              lang.register,
                              style: GoogleFonts.nunito(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 6. Already have an account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lang.alreadyHaveAccount,
                        style: GoogleFonts.nunito(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Text(
                          lang.login,
                          style: GoogleFonts.nunito(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF007DFE),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildCapsuleInput({
    required TextEditingController controller,
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      errorText: errorText,
    );
  }
}
