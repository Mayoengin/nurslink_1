import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:login_flutter_app/src/features/authentication/screens/mail_verification/mail_verification.dart';
import 'package:login_flutter_app/src/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:login_flutter_app/src/features/core/screens/dashboard/dashboard.dart';
import 'exceptions/t_exceptions.dart';

/// -- README(Docs[6]) -- Bindings
class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  late final Rx<User?> _firebaseUser;
  final _auth = FirebaseAuth.instance;
  final _phoneVerificationId = ''.obs;

  /// Getters
  User? get firebaseUser => _firebaseUser.value;
  String get getUserID => firebaseUser?.uid ?? "";
  String get getUserEmail => firebaseUser?.email ?? "";
  String get getDisplayName => firebaseUser?.displayName ?? "";
  String get getPhoneNo => firebaseUser?.phoneNumber ?? "";

  /// Loads when app Launch from main.dart
  @override
  void onReady() {
    _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.bindStream(_auth.userChanges());
    FlutterNativeSplash.remove();
    setInitialScreen(_firebaseUser.value);
    // ever(_firebaseUser, _setInitialScreen);
  }

  Future<void> setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAll(() => const WelcomeScreen());
    } else if (user.emailVerified) {
      Position? userLocation = await getUserLocation();
      String locationString = userLocation != null
          ? '${userLocation.latitude},${userLocation.longitude}'
          : ''; // Set a default value or handle accordingly if userLocation is null

      if (locationString.isNotEmpty) {
        // Pass user location to the Dashboard
        Get.offAll(() => Dashboard(
          userLocation: locationString,
          userName: getDisplayName,
        ));
      } else {
        // Handle case where user location is not available
      }
    } else {
      Get.offAll(() => const MailVerification());
    }
  }
  /* ---------------------------- Email & Password sign-in ---------------------------------*/

  /// [EmailAuthentication] - LOGIN
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code); // Throw custom [message] variable
      throw result.message;
    } catch (_) {
      const result = TExceptions();
      throw result.message;
    }
  }

  Future<void> registerWithEmailAndPassword(
      String email,
      String password,
      String userName,
      double latitude,
      double longitude,
      ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Once the user is created, update their document in Firestore with additional details
        await updateUserDetails(userCredential.user!.uid, email, userName, latitude, longitude);
      }
    } on FirebaseAuthException catch (e) {
      final ex = TExceptions.fromCode(e.code);
      throw ex.message;
    } catch (_) {
      const ex = TExceptions();
      throw ex.message;
    }
  }

  Future<void> updateUserDetails(String uid, String email, String userName, double latitude, double longitude) async {
    try {
      // Get reference to the user's document in Firestore using UID
      DocumentReference userDoc = FirebaseFirestore.instance.collection('Users').doc(uid);

      // Update user document with email, name, and location
      await userDoc.set({
        'email': email,
        'userName': userName,
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      print('Error updating user details: $e');
      // Handle error appropriately
    }
  }
  /// [EmailVerification] - MAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      final ex = TExceptions.fromCode(e.code);
      throw ex.message;
    } catch (_) {
      const ex = TExceptions();
      throw ex.message;
    }
  }

  /* ---------------------------- Federated identity & social sign-in ---------------------------------*/

  /// [GoogleAuthentication] - GOOGLE
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      final ex = TExceptions.fromCode(e.code);
      throw ex.message;
    } catch (_) {
      const ex = TExceptions();
      throw ex.message;
    }
  }

  ///[FacebookAuthentication] - FACEBOOK
  Future<UserCredential> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login(permissions: ['email']);

      // Create a credential from the access token
      final AccessToken accessToken = loginResult.accessToken!;
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);

      // Once signed in, return the UserCredential
      return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } on FormatException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Something went wrong. Try again!';
    }
  }

  /// [PhoneAuthentication] - LOGIN
  loginWithPhoneNo(String phoneNumber) async {
    try {
      await _auth.signInWithPhoneNumber(phoneNumber);
    } on FirebaseAuthException catch (e) {
      final ex = TExceptions.fromCode(e.code);
      throw ex.message;
    } catch (e) {
      throw e.toString().isEmpty ? 'Unknown Error Occurred. Try again!' : e.toString();
    }
  }

  /// [PhoneAuthentication] - REGISTER
  Future<void> phoneAuthentication(String phoneNo) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
        },
        codeSent: (verificationId, resendToken) {
          _phoneVerificationId.value = verificationId;
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _phoneVerificationId.value = verificationId;
        },
        verificationFailed: (e) {
          final result = TExceptions.fromCode(e.code);
          throw result.message;
        },
      );
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code);
      throw result.message;
    } catch (e) {
      throw e.toString().isEmpty ? 'Unknown Error Occurred. Try again!' : e.toString();
    }
  }

  /// [PhoneAuthentication] - VERIFY PHONE NO BY OTP
  Future<bool> verifyOTP(String otp) async {
    var credentials = await _auth.signInWithCredential(
      PhoneAuthProvider.credential(verificationId: _phoneVerificationId.value, smsCode: otp),
    );
    return credentials.user != null ? true : false;
  }

  /* ---------------------------- ./end Federated identity & social sign-in ---------------------------------*/

  /// [LogoutUser] - Valid for any authentication.
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const WelcomeScreen());
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } on FormatException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Unable to logout. Try again.';
    }
  }

  Future<Position?> getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location Permissions are denied');
        }
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
  Future<void> updateUserLocation(double latitude, double longitude) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        DocumentReference userDoc = FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);

        await userDoc.set({
          'email': currentUser.email,
          'latitude': latitude,
          'longitude': longitude,
        }, SetOptions(merge: true));
        print('User location updated successfully.');
      } catch (e) {
        print('Error updating user location: $e');
      }
    }
  }

}