import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/social_auth_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
          String? nameError;
          String? emailError;
          String? passwordError;
          bool isSuccess = false;

          if (state is AuthValidationError) {
            nameError = state.nameError;
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
                colors: [Color(0xFF041374), Color(0xFF01010E)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),

                    // Title
                    const Text(
                      'Sign Up',
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
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),

                    // Name Field
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Name',
                      prefixIcon: Icons.person_outline,
                      errorText: nameError,
                      isSuccess: isSuccess,
                    ),
                    const SizedBox(height: 16),

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

                    // Sign Up Button
                    CustomButton(
                      text: 'Sign Up',
                      onPressed: () {
                        context.read<AuthCubit>().signUp(
                          name: _nameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                      },
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 32),

                    // Sign in with text
                    const Text(
                      'Sign In with',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
