import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/social_auth_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Future.delayed(const Duration(milliseconds: 800), () {
              // TODO: Navigate to HomeScreen
              // Navigator.pushReplacementNamed(context, '/home');
            });
          }
        },
        builder: (context, state) {
          String? emailError;
          String? passwordError;
          bool isSuccess = false;

          if (state is AuthValidationError) {
            emailError = state.emailError;
            passwordError = state.passwordError;
          } else if (state is AuthSuccess) {
            isSuccess = true;
          }

          final isLoading = state is AuthLoading;

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff041374), Color(0xFF01010E)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        48,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),

                        // Title
                        const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        const Text(
                          'Enter your email and password',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          errorText: emailError,
                          isSuccess: isSuccess,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          errorText: passwordError,
                          isSuccess: isSuccess,
                        ),
                        const SizedBox(height: 24),

                        // Sign In Button
                        CustomButton(
                          text: 'Sign in',
                          onPressed: () {
                            context.read<AuthCubit>().signIn(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                          },
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 24),

                        // Don't have account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Dont have an account?  ',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to sign up
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Social Auth Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialAuthButton(
                              imagePath: 'facebook',
                              onPressed: () {
                                context.read<AuthCubit>().signInWithFacebook();
                              },
                            ),
                            const SizedBox(width: 20),
                            SocialAuthButton(
                              imagePath: 'google',
                              onPressed: () {
                                context.read<AuthCubit>().signInWithGoogle();
                              },
                            ),
                          ],
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}