import 'package:flutter/material.dart';

import '../../../core/property_store.dart';

const _authOrange = Color(0xFFF57C00);
const _authOrangeSoft = Color(0xFFFFF1DF);
const _authBlack = Color(0xFF111111);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFAF4), Colors.white],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Container(
                width: 430,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFD8B0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Welcome to Rentals',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _authBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to access your personalized saved properties and activity.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6A6A6A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: _authOrangeSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModeButton(
                              title: 'Log In',
                              selected: _isLoginMode,
                              onTap: () => setState(() => _isLoginMode = true),
                            ),
                          ),
                          Expanded(
                            child: _ModeButton(
                              title: 'Sign Up',
                              selected: !_isLoginMode,
                              onTap: () => setState(() => _isLoginMode = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AuthForm(
                      isLoginMode: _isLoginMode,
                      onToggleMode: () =>
                          setState(() => _isLoginMode = !_isLoginMode),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _authOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _authOrange : Colors.transparent,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF777777),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({
    required this.isLoginMode,
    required this.onToggleMode,
  });

  final bool isLoginMode;
  final VoidCallback onToggleMode;

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InputField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _InputField(
          label: 'Password',
          controller: _passwordController,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
        if (!widget.isLoginMode) ...[
          const SizedBox(height: 12),
          _InputField(
            label: 'Confirm Password',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                );
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: Text(
              _submitting
                  ? 'Please wait...'
                  : (widget.isLoginMode ? 'Log In' : 'Create Account'),
              style: const TextStyle(fontSize: 17),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _submitting ? null : widget.onToggleMode,
          child: Text(
            widget.isLoginMode
                ? 'No account yet? Sign up'
                : 'Already have an account? Log in',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: _authBlack,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Enter your email and password.');
      return;
    }

    if (!widget.isLoginMode) {
      if (password.length < 6) {
        _showMessage('Password should be at least 6 characters.');
        return;
      }
      if (_confirmPasswordController.text.trim() != password) {
        _showMessage('Passwords do not match.');
        return;
      }
    }

    setState(() => _submitting = true);

    String? error;
    if (widget.isLoginMode) {
      error = await PropertyStore.instance.signInWithEmail(
        email: email,
        password: password,
      );
    } else {
      error = await PropertyStore.instance.signUpWithEmail(
        email: email,
        password: password,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);

    if (error != null) {
      _showMessage(error);
      return;
    }

    _showMessage(widget.isLoginMode ? 'Logged in successfully.' : 'Account created successfully.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(color: _authBlack),
      ),
    );
  }
}
