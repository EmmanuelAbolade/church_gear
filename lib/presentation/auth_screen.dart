// lib/presentation/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_bloc/auth_bloc.dart';
import '../data/models/registration_payload.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // 💡 NEW CONTROLLERS ADDED FOR MULTI-TENANT ONBOARDING
  final _pastorNameController = TextEditingController();
  final _churchNameController = TextEditingController();
  
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pastorNameController.dispose();
    _churchNameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_isLoginMode) {
      context.read<AuthBloc>().add(
        LoginWithEmailRequestedEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    } else {
      // CONNECTED DIRECTLY TO REGISTRATION PAYLOAD ENGINE
      context.read<AuthBloc>().add(
        RegisterWithTenantRequestedEvent(
          payload: RegistrationPayload(
            pastorName: _pastorNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            churchName: _churchNameController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication Failed'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      _isLoginMode ? Icons.shield_outlined : Icons.app_registration_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isLoginMode ? 'Welcome to Church Gear' : 'Create Church Workspace',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 32),
                    
                    // CONDITIONAL FIELD: PASTOR'S FULL NAME
                    if (!_isLoginMode) ...[
                      TextFormField(
                        controller: _pastorNameController,
                        decoration: const InputDecoration(
                          labelText: 'Pastor / Admin Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // CONDITIONAL FIELD: CHURCH / TENANT NAME
                    if (!_isLoginMode) ...[
                      TextFormField(
                        controller: _churchNameController,
                        decoration: const InputDecoration(
                          labelText: 'Church Name',
                          prefixIcon: Icon(Icons.church_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your church name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state.status == AuthStatus.loading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(_isLoginMode ? 'Sign In' : 'Register Church Account'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // TOGGLE MODE BUTTON BUTTON
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoginMode = !_isLoginMode;
                        });
                      },
                      child: Text(_isLoginMode 
                        ? 'Need an account? Register your church' 
                        : 'Already have a workspace? Sign In'
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const EnterAsGuestEvent());
                      },
                      child: const Text(
                        'Explore as Guest',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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