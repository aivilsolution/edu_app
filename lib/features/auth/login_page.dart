import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_app/features/auth/bloc/auth_cubit.dart';
import 'package:edu_app/features/auth/bloc/auth_state.dart';
import '../auth/login_info.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fua;


class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email and password cannot be empty';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await LoginInfo.instance.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted && widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated && widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        }

        if (state.errorMessage != null) {
          setState(() {
            _errorMessage = state.errorMessage;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                const SizedBox(height: 30),

                
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 8),

                
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Login'),
                ),

                
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Or continue with'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                
                SizedBox(
                  height: 200,
                  child: fua.LoginView(
                    action: fua.AuthAction.signIn,
                    providers: LoginInfo.authProviders,
                    showAuthActionSwitch: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
