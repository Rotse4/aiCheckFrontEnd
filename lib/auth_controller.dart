import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';

class AuthController extends GetxController {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool loading = false.obs;
  RxString errorMessage = ''.obs;
  RxString currentUsername = ''.obs;

  Future<void> init() async {
    final name = await AuthService.instance.getUsername();
    if (name != null) currentUsername.value = name;
  }

  Future<bool> login() async {
    loading.value = true;
    errorMessage.value = '';
    try {
      final auth = await AuthService.instance.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );
      currentUsername.value = auth.username;
      return true;
    } catch (e) {
      errorMessage.value = 'Login failed: $e';
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> register() async {
    loading.value = true;
    errorMessage.value = '';
    try {
      final auth = await AuthService.instance.register(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      currentUsername.value = auth.username;
      return true;
    } catch (e) {
      errorMessage.value = 'Register failed: $e';
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    await AuthService.instance.clearAuth();
    currentUsername.value = '';
  }
}
