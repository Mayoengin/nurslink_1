import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:login_flutter_app/src/common_widgets/form/form_header_widget.dart';
import 'package:login_flutter_app/src/common_widgets/form/social_footer.dart';
import 'package:login_flutter_app/src/constants/image_strings.dart';
import 'package:login_flutter_app/src/constants/text_strings.dart';
import '../../../../common_widgets/form/form_divider_widget.dart';
import '../../../../constants/sizes.dart';
import '../../../../repository/authentication_repository/authentication_repository.dart';
import 'widgets/login_form_widget.dart';
// Assuming this is the correct import for LocationPage

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDefaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormHeaderWidget(
                  image: tWelcomeScreenImage,
                  title: tLoginTitle,
                  subTitle: tLoginSubTitle,
                ),
                const LoginFormWidget(),
                const TFormDividerWidget(),
                SocialFooter(
                  text1: tDontHaveAnAccount,
                  text2: tSignup,
// Inside the onPressed method in your LoginScreen
                  onPressed: () async {
                    Position? userLocation = await AuthenticationRepository.instance.getUserLocation();

                    if (userLocation != null) {
                      await AuthenticationRepository.instance.setInitialScreen(
                        AuthenticationRepository.instance.firebaseUser,
                      );
                    } else {
                      // Handle case where user location is not available
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
