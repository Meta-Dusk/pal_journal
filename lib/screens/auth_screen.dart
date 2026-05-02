import 'package:flutter/material.dart';
import 'package:pal_journal/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    String? error;
    if (_isLogin) {
      error = await AuthService.signIn(email, password);
    } else {
      error = await AuthService.signUp(email, password);
    }

    if (mounted) {
      if (error == null) {
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final mainContent = [
      Icon(Icons.lock_outline, size: 80, color: colors.primary),
      const SizedBox(height: 32),
      Text(
        _isLogin ? "Welcome Back" : "Create Account",
        textAlign: .center,
        style: const TextStyle(fontSize: 28, fontWeight: .bold),
      ),
      const SizedBox(height: 32),

      // --- FORM FIELDS ---
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: "Email",
          prefixIcon: const Icon(Icons.email),
          filled: true,
          fillColor: colors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: .circular(12),
            borderSide: .none,
          ),
        ),
      ),
      const SizedBox(height: 16),
      passwordField(colors),
      const SizedBox(height: 24),

      // --- ERROR MESSAGE ---
      if (_errorMessage != null) errorMessage(colors),

      // --- SUBMIT BUTTON ---
      submitButton(colors),
      const SizedBox(height: 16),
      toggleButton(),
    ];

    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const .all(24.0),
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .stretch,
            children: mainContent,
          ),
        ),
      ),
    );
  }

  TextField passwordField(ColorScheme colors) {
    void onPressed() {
      setState(() => _obscurePassword = !_obscurePassword);
    }

    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.password),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: colors.onSurfaceVariant,
          ),
          onPressed: onPressed,
        ),
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: .circular(12),
          borderSide: .none,
        ),
      ),
    );
  }

  Padding errorMessage(ColorScheme colors) {
    return Padding(
      padding: const .only(bottom: 16.0),
      child: Text(
        _errorMessage!,
        style: TextStyle(color: colors.error, fontWeight: .bold),
        textAlign: .center,
      ),
    );
  }

  ElevatedButton submitButton(ColorScheme colors) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        padding: const .symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              _isLogin ? "Log In" : "Sign Up",
              style: const TextStyle(fontSize: 16, fontWeight: .bold),
            ),
    );
  }

  TextButton toggleButton() {
    return TextButton(
      onPressed: () => setState(() {
        _isLogin = !_isLogin;
        _errorMessage = null; // Clear errors when switching modes
      }),
      child: Text(
        _isLogin
            ? "Don't have an account? Sign Up"
            : "Already have an account? Log In",
      ),
    );
  }
}
