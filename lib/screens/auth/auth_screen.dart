import 'package:flutter/material.dart';
import 'package:pal_journal/services/auth_service.dart';
import 'breathing_logo.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    String? result = _isLogin
        ? await AuthService.signIn(email, password)
        : await AuthService.signUp(email, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result == null) {
      Navigator.pop(context); // Success! Go back to settings
    } else if (result == "VERIFICATION_SENT") {
      setState(() {
        _isLogin = true; // Switch them to login mode automatically
        _successMessage =
            "Verification link sent! "
            "Please check your email to activate your account.";
        _passwordController.clear();
      });
    } else {
      setState(() => _errorMessage = result);
    }
  }

  Future<void> _submitGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final error = await AuthService.signInWithGoogle();
    if (!mounted) return;

    if (error == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final mainContent = [
      const BreathingLogo(),
      const SizedBox(height: 40),

      Text(
        _isLogin ? "Welcome Back" : "Initialize Sync",
        textAlign: .center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: .bold,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 32),

      // --- MESSAGES ---
      if (_errorMessage != null) ErrorMessage(errorMessage: _errorMessage),
      if (_successMessage != null)
        SuccessMessage(successMessage: _successMessage),

      // --- FORM FIELDS ---
      emailField(colors),
      const SizedBox(height: 16),
      passwordField(colors),
      const SizedBox(height: 24),

      // --- ACTIONS ---
      actionsButton(colors),
      const SizedBox(height: 24),
      StyledSpacer(),
      const SizedBox(height: 24),

      // --- GOOGLE BUTTON ---
      googleButton(colors),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => setState(() {
          _isLogin = !_isLogin;
          _errorMessage = null;
          _successMessage = null;
        }),
        child: Text(
          _isLogin ? "Establish new connection" : "Return to existing node",
          style: TextStyle(color: colors.primary.withValues(alpha: 0.8)),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const .symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .stretch,
            children: mainContent,
          ),
        ),
      ),
    );
  }

  TextField emailField(ColorScheme colors) {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email address",
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: .circular(16),
          borderSide: .none,
        ),
      ),
    );
  }

  TextField passwordField(ColorScheme colors) {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: colors.onSurfaceVariant,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: .circular(16),
          borderSide: .none,
        ),
      ),
    );
  }

  ElevatedButton actionsButton(ColorScheme colors) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitEmail,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: const .symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: .circular(16)),
        elevation: 0,
      ),
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.onPrimary,
              ),
            )
          : Text(
              _isLogin ? "Authenticate" : "Create Node",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: .bold,
                letterSpacing: 1.1,
              ),
            ),
    );
  }

  OutlinedButton googleButton(ColorScheme colors) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _submitGoogle,
      icon: const Icon(
        Icons.g_mobiledata,
        size: 28,
      ), // Built-in Google-ish icon
      label: const Text(
        "Continue with Google",
        style: TextStyle(fontWeight: .bold),
      ),
      style: OutlinedButton.styleFrom(
        padding: const .symmetric(vertical: 14),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: .circular(16)),
      ),
    );
  }
}

class StyledSpacer extends StatelessWidget {
  const StyledSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Divider(color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
        ),
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: Text(
            "OR",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ),
        Expanded(
          child: Divider(color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
        ),
      ],
    );
  }
}

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({super.key, required String? errorMessage})
    : _errorMessage = errorMessage;

  final String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const .all(12),
      margin: const .only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.3),
        borderRadius: .circular(8),
        border: .all(color: colors.error.withValues(alpha: 0.5)),
      ),
      child: Text(
        _errorMessage!,
        style: TextStyle(color: colors.error, fontSize: 13),
        textAlign: .center,
      ),
    );
  }
}

class SuccessMessage extends StatelessWidget {
  const SuccessMessage({super.key, required String? successMessage})
    : _successMessage = successMessage;

  final String? _successMessage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const .all(12),
      margin: const .only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
      ),
      child: Text(
        _successMessage!,
        style: TextStyle(
          color: colors.primary,
          fontSize: 13,
          fontWeight: .bold,
        ),
        textAlign: .center,
      ),
    );
  }
}
