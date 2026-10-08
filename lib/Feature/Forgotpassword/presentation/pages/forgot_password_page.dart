import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minichatapp/l10n/app_localizations.dart';
import '../../../common/widgets/app_bottom_dialog.dart';
import '../../data/datasources/forgot_password_remote_datasource.dart';
import '../../data/repositories/forgot_password_repository_impl.dart';
import '../../domain/repositories/forgot_password_repository.dart';
import '../../domain/usecases/send_reset_code_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';
import '../widgets/forgot_password_header_icon.dart';
import '../widgets/otp_input_field.dart';
import 'package:minichatapp/Feature/Login/presentation/widgets/custom_text_field.dart';

/// Trang Quên Mật Khẩu & Xác Thực OTP 3 bước chuyên nghiệp:
/// - Bước 0: Nhập Email nhận mã OTP
/// - Bước 1: Nhập OTP 6 số + Bộ đếm ngược 60s gửi lại OTP
/// - Bước 2: Tạo mật khẩu mới & hoàn tất
class ForgotPasswordPage extends StatelessWidget {
  final ForgotPasswordRepository? repository;

  const ForgotPasswordPage({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = repository ??
            ForgotPasswordRepositoryImpl(
              remoteDataSource: ForgotPasswordRemoteDataSourceImpl(),
            );
        final sendResetCodeUseCase =
            SendResetCodeUseCase(repository: repo);
        final verifyOtpUseCase = VerifyOtpUseCase(repository: repo);
        final resendOtpUseCase = ResendOtpUseCase(repository: repo);
        final resetPasswordUseCase =
            ResetPasswordUseCase(repository: repo);

        return ForgotPasswordBloc(
          sendResetCodeUseCase: sendResetCodeUseCase,
          verifyOtpUseCase: verifyOtpUseCase,
          resendOtpUseCase: resendOtpUseCase,
          resetPasswordUseCase: resetPasswordUseCase,
        );
      },
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  int _currentStep = 0; // 0: Nhập email, 1: Xác thực OTP, 2: Đổi mật khẩu

  // Step 0 - Email
  final _emailController = TextEditingController();
  String? _emailError;

  // Step 1 - OTP
  final _otpController = TextEditingController();
  String? _otpError;
  Timer? _resendTimer;
  int _resendCooldown = 60;

  // Step 2 - Password
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer([int seconds = 60]) {
    _resendTimer?.cancel();
    setState(() => _resendCooldown = seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown > 1) {
        setState(() => _resendCooldown--);
      } else {
        setState(() => _resendCooldown = 0);
        timer.cancel();
      }
    });
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _otpError = null;
        _newPasswordError = null;
        _confirmPasswordError = null;
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  // Submit Step 0: Gửi OTP tới email
  void _submitEmail(BuildContext context) {
    final lang = context.l10n;
    final text = _emailController.text.trim();

    if (text.isEmpty) {
      setState(() => _emailError = lang.enterEmailOrPhone);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text)) {
      setState(() => _emailError = 'Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }

    setState(() => _emailError = null);
    context.read<ForgotPasswordBloc>().add(
          SendResetCodeRequested(text),
        );
  }

  // Submit Step 1: Xác thực OTP
  void _submitOtp(BuildContext context) {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _otpError = 'Vui lòng nhập đủ 6 chữ số mã OTP.');
      return;
    }

    setState(() => _otpError = null);
    context.read<ForgotPasswordBloc>().add(
          VerifyOtpRequested(
            email: _emailController.text.trim(),
            otp: otp,
          ),
        );
  }

  // Gửi lại mã OTP
  void _resendOtp(BuildContext context) {
    if (_resendCooldown > 0) return;
    setState(() => _otpError = null);
    context.read<ForgotPasswordBloc>().add(
          ResendOtpRequested(_emailController.text.trim()),
        );
  }

  // Submit Step 2: Đặt mật khẩu mới
  void _submitNewPassword(BuildContext context) {
    final lang = context.l10n;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    String? newPassError;
    String? confirmPassError;

    if (newPass.length < 6) {
      newPassError = lang.passwordMinLength;
    }

    if (confirmPass.isEmpty) {
      confirmPassError = lang.enterConfirmPassword;
    } else if (confirmPass != newPass) {
      confirmPassError = lang.passwordNotMatch;
    }

    setState(() {
      _newPasswordError = newPassError;
      _confirmPasswordError = confirmPassError;
    });

    if (newPassError != null || confirmPassError != null) return;

    context.read<ForgotPasswordBloc>().add(
          ResetPasswordRequested(
            email: _emailController.text.trim(),
            otp: _otpController.text.trim(),
            newPassword: newPass,
            confirmPassword: confirmPass,
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
              onTap: _handleBack,
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
                  Icons.arrow_back_rounded,
                  color: Color(0xFF007DFE),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          _currentStep == 0
              ? lang.forgotPasswordTitle
              : _currentStep == 1
                  ? lang.otpVerification
                  : 'Đặt lại mật khẩu',
          style: GoogleFonts.nunito(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordFailure) {
              if (_currentStep == 1) {
                setState(() => _otpError = state.errorMessage);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else if (state is ForgotPasswordCodeSent) {
              setState(() {
                _currentStep = 1;
                _otpError = null;
              });
              _startResendTimer(60);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${lang.resetCodeSentPrefix} ${state.emailOrPhone}',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: const Color(0xFF007DFE),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else if (state is ForgotPasswordResendOtpSuccess) {
              _startResendTimer(state.cooldownSeconds);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: const Color(0xFF16A34A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else if (state is ForgotPasswordOtpVerified) {
              setState(() {
                _currentStep = 2;
                _otpError = null;
              });
            } else if (state is ForgotPasswordResetSuccess) {
              AppBottomDialog.showSuccess(
                context: context,
                title: 'Đặt lại mật khẩu thành công!',
                message:
                    'Mật khẩu tài khoản của bạn đã được cập nhật thành công. Vui lòng đăng nhập với mật khẩu mới.',
                primaryButtonText: 'Đăng nhập ngay',
                onPrimaryPressed: () {
                  Navigator.of(context).pop();
                },
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ForgotPasswordLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Thanh Stepper hiển thị tiến trình 3 bước
                  _buildStepIndicator(),

                  const SizedBox(height: 28),

                  // Nội dung tương ứng theo bước
                  if (_currentStep == 0)
                    _buildEmailStep(context, isLoading)
                  else if (_currentStep == 1)
                    _buildOtpStep(context, isLoading)
                  else
                    _buildPasswordStep(context, isLoading),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Widget thanh tiến trình 3 bước (1: Email -> 2: OTP -> 3: Mật khẩu)
  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepBadge(
          stepIndex: 0,
          label: 'Nhập email',
          isActive: _currentStep >= 0,
          isDone: _currentStep > 0,
        ),
        _buildStepConnector(isPassed: _currentStep >= 1),
        _buildStepBadge(
          stepIndex: 1,
          label: 'Mã OTP',
          isActive: _currentStep >= 1,
          isDone: _currentStep > 1,
        ),
        _buildStepConnector(isPassed: _currentStep >= 2),
        _buildStepBadge(
          stepIndex: 2,
          label: 'Mật khẩu mới',
          isActive: _currentStep >= 2,
          isDone: false,
        ),
      ],
    );
  }

  Widget _buildStepBadge({
    required int stepIndex,
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    Color bg = isDone
        ? const Color(0xFF16A34A)
        : (isActive ? const Color(0xFF007DFE) : const Color(0xFFF1F5F9));
    Color fg = (isActive || isDone) ? Colors.white : const Color(0xFF94A3B8);

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: bg.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                    '${stepIndex + 1}',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isPassed}) {
    return Container(
      width: 44,
      height: 2.5,
      margin: const EdgeInsets.only(bottom: 18, left: 6, right: 6),
      decoration: BoxDecoration(
        color: isPassed ? const Color(0xFF007DFE) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Giao diện Bước 0: Nhập Email
  Widget _buildEmailStep(BuildContext context, bool isLoading) {
    final lang = context.l10n;

    return Column(
      children: [
        const SizedBox(height: 12),
        const ForgotPasswordHeaderIcon(size: 104),
        const SizedBox(height: 24),
        Text(
          lang.forgotPasswordInstruction,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _emailController,
          hintText: lang.emailOrPhone,
          errorText: _emailError,
          onChanged: (val) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            Icons.mail_outline_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _submitEmail(context),
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
                    lang.sendCode,
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Text(
            lang.backToLogin,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF007DFE),
            ),
          ),
        ),
      ],
    );
  }

  /// Giao diện Bước 1: Nhập OTP & Đếm ngược 60s
  Widget _buildOtpStep(BuildContext context, bool isLoading) {
    final lang = context.l10n;

    return Column(
      children: [
        const SizedBox(height: 8),

        // Icon khiên bảo mật OTP
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.mark_email_read_rounded,
              size: 46,
              color: Color(0xFF007DFE),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Nhập mã xác thực',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 8),

        // Email đã gửi mã + nút đổi email
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.nunito(
              fontSize: 14.5,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
            children: [
              const TextSpan(text: 'Mã xác thực gồm 6 số đã được gửi đến\n'),
              TextSpan(
                text: _emailController.text,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Nút đổi email
        GestureDetector(
          onTap: () {
            setState(() {
              _currentStep = 0;
              _otpError = null;
            });
          },
          child: Text(
            lang.changeEmail,
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF007DFE),
              decoration: TextDecoration.underline,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // 6 ô nhập mã OTP
        OtpInputField(
          controller: _otpController,
          hasError: _otpError != null,
          onChanged: (_) {
            if (_otpError != null) {
              setState(() => _otpError = null);
            }
          },
          onCompleted: (_) => _submitOtp(context),
        ),

        // Báo lỗi OTP (nếu có)
        if (_otpError != null) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFEF4444), size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _otpError!,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // Bộ đếm ngược 60 giây và Nút gửi lại OTP (Chống spam < 60s)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chưa nhận được mã? ',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            if (_resendCooldown > 0)
              Text(
                '${lang.resendOtpIn} (${_resendCooldown}s)',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                ),
              )
            else
              GestureDetector(
                onTap: isLoading ? null : () => _resendOtp(context),
                child: Text(
                  lang.resendOtp,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF007DFE),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 28),

        // Nút Tiếp tục xác thực OTP
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _submitOtp(context),
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
                    'Xác nhận mã OTP',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        GestureDetector(
          onTap: _handleBack,
          child: Text(
            'Quay lại',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  /// Giao diện Bước 2: Tạo mật khẩu mới
  Widget _buildPasswordStep(BuildContext context, bool isLoading) {
    final lang = context.l10n;

    return Column(
      children: [
        const SizedBox(height: 8),

        // Icon chìa khóa bảo mật
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFA7F3D0), width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.lock_reset_rounded,
              size: 46,
              color: Color(0xFF16A34A),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Tạo mật khẩu mới',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Vui lòng nhập mật khẩu mới cho tài khoản của bạn (tối thiểu 6 ký tự).',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
            height: 1.45,
          ),
        ),

        const SizedBox(height: 28),

        // Ô nhập Mật khẩu mới
        CustomTextField(
          controller: _newPasswordController,
          hintText: lang.newPassword,
          errorText: _newPasswordError,
          obscureText: _obscureNewPassword,
          onChanged: (_) {
            if (_newPasswordError != null) {
              setState(() => _newPasswordError = null);
            }
          },
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNewPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF94A3B8),
              size: 20,
            ),
            onPressed: () {
              setState(() => _obscureNewPassword = !_obscureNewPassword);
            },
          ),
        ),

        const SizedBox(height: 18),

        // Ô nhập Xác nhận mật khẩu mới
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: lang.confirmNewPassword,
          errorText: _confirmPasswordError,
          obscureText: _obscureConfirmPassword,
          onChanged: (_) {
            if (_confirmPasswordError != null) {
              setState(() => _confirmPasswordError = null);
            }
          },
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF94A3B8),
              size: 20,
            ),
            onPressed: () {
              setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
          ),
        ),

        const SizedBox(height: 28),

        // Nút Cập nhật mật khẩu
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _submitNewPassword(context),
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
                    'Đổi mật khẩu',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        GestureDetector(
          onTap: _handleBack,
          child: Text(
            'Quay lại',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}
