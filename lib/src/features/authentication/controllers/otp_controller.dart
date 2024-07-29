import 'package:get/get.dart';
import '../../../repository/authentication_repository/authentication_repository.dart';
import '../screens/login/login_screen.dart';

class OTPController extends GetxController {
  static OTPController get instance => Get.find();

  void verifyOTP(String otp) async {
    var isVerified = await AuthenticationRepository.instance.verifyOTP(otp);
    isVerified ? Get.offAll(const LoginScreen()) : Get.back();
  }

}