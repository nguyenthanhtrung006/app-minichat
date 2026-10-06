import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minichatapp/l10n/app_localizations.dart';
import '../../data/datasources/forgot_password_remote_datasource.dart';
import '../../data/repositories/forgot_password_repository_impl.dart';
import '../../domain/usecases/send_reset_code_usecase.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';
import '../widgets/forgot_password_header_icon.dart';
import 'package:minichatapp/Feature/Login/presentation/widgets/custom_text_field.dart';

/// The Forgot Password screen built with Clean Architecture & BLoC.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = ForgotPasswordRemoteDataSourceImpl();
        final repository =
            ForgotPasswordRepositoryImpl(remoteDataSource: dataSource);
        final useCase = SendResetCodeUseCase(repository: repository);

        return ForgotPasswordBloc(sendResetCodeUseCase: useCase);
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
  final _emailOrPhoneController = TextEditingController();
  String? _emailOrPhoneError;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final lang = context.l10n;
    final text = _emailOrPhoneController.text.trim();

    if (text.isEmpty) {
      setState(() => _emailOrPhoneError = lang.enterEmailOrPhone);
      return;
    }

    setState(() => _emailOrPhoneError = null);
    context.read<ForgotPasswordBloc>().add(
          SendResetCodeRequested(text),
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
                  Icons.arrow_back_rounded,
                  color: Color(0xFF007DFE),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          lang.forgotPasswordTitle,
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is ForgotPasswordCodeSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${lang.resetCodeSentPrefix} ${state.emailOrPhone}',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: const Color(0xFF007DFE),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ForgotPasswordLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const SizedBox(height: 36),

                  // 1. Hero Mail Icon
                  const ForgotPasswordHeaderIcon(size: 104),

                  const SizedBox(height: 28),

                  // 2. Instructions text
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

                  // 3. Email or Phone Input Field
                  CustomTextField(
                    controller: _emailOrPhoneController,
                    hintText: lang.emailOrPhone,
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

                  const SizedBox(height: 24),

                  // 4. Send Code CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(context),
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

                  // 5. Back to Login link
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

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
