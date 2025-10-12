import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final AuthController auth = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    auth.init();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create your account', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('Sign up to start analyzing and saving your history.', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 20),
                        TextField(
                          controller: auth.usernameController,
                          decoration: const InputDecoration(labelText: 'Username'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: auth.emailController,
                          decoration: const InputDecoration(labelText: 'Email (optional)'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: auth.passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                        ),
                        const SizedBox(height: 16),
                        if (auth.errorMessage.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(auth.errorMessage.value, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.loading.value
                                ? null
                                : () async {
                                    final ok = await auth.register();
                                    if (ok && context.mounted) {
                                      Navigator.of(context).pushReplacementNamed('/dashboard');
                                    }
                                  },
                            child: auth.loading.value
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Create Account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
