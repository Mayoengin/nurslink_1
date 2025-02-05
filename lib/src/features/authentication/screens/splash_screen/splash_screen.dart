import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_flutter_app/src/constants/image_strings.dart';
import 'package:login_flutter_app/src/constants/sizes.dart';
import '../../../../utils/animations/fade_in_animation/animation_design.dart';
import '../../../../utils/animations/fade_in_animation/fade_in_animation_controller.dart';
import '../../../../utils/animations/fade_in_animation/fade_in_animation_model.dart';
import '../../../../constants/text_strings.dart';
const Color tPrimaryColors = Color(0xFF4F0066);

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FadeInAnimationController());
    controller.startSplashAnimation();

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            TFadeInAnimation(
              durationInMs: 1200,
              animate: TAnimatePosition(
                topAfter: 0,
                topBefore: -30,
                leftBefore: -30,
                leftAfter: 0,
              ),
              child: const Image(image: AssetImage(tSplashTopIcon)),
            ),
            TFadeInAnimation(
              durationInMs: 1600,
              animate: TAnimatePosition(
                topBefore: 100,
                topAfter: 100,
                leftAfter: tDefaultSpace,
                leftBefore: -100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tAppName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    tAppTagLine,
                    style: Theme.of(context).textTheme.displayMedium,
                  )
                ],
              ),
            ),
            TFadeInAnimation(
              durationInMs: 2000,
              animate: TAnimatePosition(bottomBefore: 0, bottomAfter: 100),
              child: const Image(image: AssetImage(tSplashImage)),
            ),
            TFadeInAnimation(
              durationInMs: 2000,
              animate: TAnimatePosition(
                  bottomBefore: 0,
                  bottomAfter: 60,
                  rightBefore: tDefaultSpace,
                  rightAfter: tDefaultSpace),
              child: Container(
                width: tSplashContainerSize,
                height: tSplashContainerSize,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: tPrimaryColors),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
