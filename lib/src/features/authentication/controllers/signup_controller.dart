import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_flutter_app/src/features/authentication/models/user_model.dart';
import 'package:login_flutter_app/src/repository/user_repository/user_repository.dart';
import '../../../repository/authentication_repository/authentication_repository.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  final showPassword = false.obs;
  final isGoogleLoading = false.obs;
  final isFacebookLoading = false.obs;
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // TextField Controllers to get data from TextFields
  final email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final phoneNo = TextEditingController();

  /// Loader
  final isLoading = false.obs;

  Future<void> createUser() async {
    try {
      isLoading.value = true;
      if (!signupFormKey.currentState!.validate()) {
        isLoading.value = false;
        return;
      }

      // Don't use the password directly; instead, use Firebase Auth for user registration.
      final user = UserModel(
        email: email.text.trim(),
        fullName: fullName.text.trim(),
        phoneNo: phoneNo.text.trim(),
        userName: 'SampleUserName', // Replace with actual user data
        latitude: 0.0, // Replace with actual latitude data
        longitude: 0.0, // Replace with actual longitude data
      );

      final auth = AuthenticationRepository.instance;
      // Use Firebase Auth for registration, avoiding handling the password directly.
      await auth.registerWithEmailAndPassword(
        user.email,
        password.text.trim(),
        user.userName,
        user.latitude,
        user.longitude,
      );

      // You might want to clear the password controller after use for security.
      password.clear();

      await UserRepository.instance.createUser(user);
      auth.setInitialScreen(auth.firebaseUser);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> phoneAuthentication(String phoneNo) async {
    try {
      await AuthenticationRepository.instance.phoneAuthentication(phoneNo);
    } catch (e) {
      throw e.toString();
    }
  }
}
