import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minichatapp/Feature/Forgotpassword/presentation/pages/forgot_password_page.dart';
import 'package:minichatapp/Feature/Register/presentation/pages/register_page.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import 'package:minichatapp/l10n/language_selector_button.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../data/datasources/login_remote_datasource.dart';
import '../../data/repositories/login_repository_impl.dart';
import '../../domain/repositories/login_repository.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_social_usecase.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';

/// The Login screen built with Clean Architecture & BLoC.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = LoginRemoteDataSourceImpl();
        final repository = LoginRepositoryImpl(remoteDataSource: dataSource);
        final emailUseCase = LoginWithEmailUseCase(repository: repository);
        final socialUseCase = LoginWithSocialUseCase(repository: repository);

        return LoginBloc(
          loginWithEmailUseCase: emailUseCase,
          loginWithSocialUseCase: socialUseCase,
        );
      },
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Validation errors
  String? _emailOrPhoneError;
  String? _passwordError;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin(BuildContext context) {
    final lang = context.l10n;
    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password = _passwordController.text;

    String? emailErr;
    String? passErr;

    if (emailOrPhone.isEmpty) {
      emailErr = lang.enterEmailOrPhone;
    }

    if (password.isEmpty) {
      passErr = lang.enterPassword;
    }

    setState(() {
      _emailOrPhoneError = emailErr;
      _passwordError = passErr;
    });

    if (emailErr != null || passErr != null) {
      return;
    }

    context.read<LoginBloc>().add(
          LoginSubmitted(
            emailOrPhone: emailOrPhone,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginFailure) {
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
            } else if (state is LoginSuccess) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const HomePage(),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is LoginLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  // 0. Language Selector with Flag Button at top right
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: const LanguageSelectorButton(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 1. Logo & App Title Header
                  Image.asset(
                    height: 96,
                    width: 96,
                    'assets/images/logominichat.png',
                  ),
                  const SizedBox(height: 14),

                  Text(
                    lang.appName,
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF007DFE),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    lang.appSlogan,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5A6E85),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 2. Input Fields
                  CustomTextField(
                    controller: _emailOrPhoneController,
                    hintText: lang.phoneOrEmail,
                    errorText: _emailOrPhoneError,
                    onChanged: (val) {
                      if (_emailOrPhoneError != null) {
                        setState(() => _emailOrPhoneError = null);
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.smartphone_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: _passwordController,
                    hintText: lang.password,
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
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submitLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007DFE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        shadowColor:
                            const Color(0xFF007DFE).withValues(alpha: 0.35),
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
                              lang.login,
                              style: GoogleFonts.nunito(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. Forgot Password Link
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF007DFE),
                    ),
                    child: Text(
                      lang.forgotPassword,
                      style: GoogleFonts.nunito(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007DFE),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 5. Divider with "Hoặc" / "Or"
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Text(
                          lang.orText,
                          style: GoogleFonts.nunito(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 6. Social Logins
                  SocialLoginButton(
                    type: SocialType.google,
                    text: lang.loginWithGoogle,
                    onPressed: () {
                      context.read<LoginBloc>().add(
                            const LoginWithSocialRequested(
                              SocialProvider.google,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 12),

                  SocialLoginButton(
                    type: SocialType.facebook,
                    text: lang.loginWithFacebook,
                    onPressed: () {
                      context.read<LoginBloc>().add(
                            const LoginWithSocialRequested(
                              SocialProvider.facebook,
                            ),
                          );
                    },
                  ),

                  const SizedBox(height: 28),

                  // 7. Register Footer Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lang.dontHaveAccount,
                        style: GoogleFonts.nunito(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          lang.register,
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
}
