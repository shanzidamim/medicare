import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:get_storage/get_storage.dart';
import 'package:medicare/data/exceptions/firebase_auth_exceptions.dart';
import 'package:medicare/data/exceptions/firebase_exceptions.dart';
import 'package:medicare/data/exceptions/format_exceptions.dart';

import 'package:medicare/data/exceptions/platform_exceptions.dart';
import 'package:medicare/screen/home/main_tab_screen.dart';
import 'package:medicare/screen/login/splash_screen.dart';

import '../../common/loaders.dart';
import '../../screen/login/widgets/login.dart';
import '../../screen/login/widgets/welcome_screen.dart';
import '../../screen/signup/verify_email.dart';
import '../exceptions/user_repository.dart';




class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage(); // Use this to store data locally (e.g. OnBoarding)
  late final Rx<User?> _firebaseUser;
  var phoneNo = ''.obs;
  var phoneNoVerificationId = ''.obs;
  var isPhoneAutoVerified = false;
  final _auth = FirebaseAuth.instance;
  int? _resendToken;

  ///get authentication
  User? get authUser => _auth.currentUser;


  @override
  void onReady() {
    screenRedirect();
  }


  ///function to show relevant screen
   void screenRedirect() async {
    final user = _auth.currentUser;
    if(user != null){
      if(user.emailVerified) {
        Get.offAll(() => const MainTabScreen());
      } else {
        Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email));
      }
    } else {
      ///local storage

      deviceStorage.writeIfNull('IsFirstTime', true);
      deviceStorage.read('IsFirstTime') != true
          ? Get.offAll(() => const SplashScreen())
          : Get.offAll(const SplashScreen());
    }

  }





  ///function to show relevant screen


/*----------------------------- Email & password sign-in--------------------------------*/
  ///email-authentication - logIN
  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  ///email-authentication - register
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
        print("✅ Firebase: User created successfully: ${credential.user?.uid}");

      return credential;
    } on FirebaseAuthException catch (e) {
      // 🔥 Print full Firebase error info
      print("🔥 FirebaseAuthException: code=${e.code}, message=${e.message}");
      rethrow; // Let SignupController handle it
    } catch (e, stack) {
      print("🔥 General error in registerWithEmailAndPassword: $e");
      rethrow;
    }
  }


  /// [ReAuthenticate] - ReAuthenticate User
  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
    try {
      // Create a credential
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

      // ReAuthenticate
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  ///email- verification - mail verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  ///authentication - authentication user

  ///email authentication - forget password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

/*---------------------------federated identity & social sign in------------------------*/
  ///google authentication - google


  ///facebook authentication - facebook

/* ---------------------------- Phone Number sign-in ---------------------------------*/

  /// [PhoneAuthentication] - LOGIN - Register
  Future<void> loginWithPhoneNo(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _resendToken,
        timeout: const Duration(minutes: 2),
        verificationFailed: (e) async {
          debugPrint('loginWithPhoneNo: verificationFailed => $e');
          await FirebaseCrashlytics.instance.recordError(e, e.stackTrace);

          if (e.code == 'too-many-requests') {
            // Get.offAllNamed(TRoutes.welcome);
            Get.offAll(() => const WelcomeScreen());
            Loaders.warningSnackBar(title: 'Too many attempts', message: 'Oops! Too many tries. Take a short break and try again soon!');
            return;
          } else if (e.code == 'unknown') {
            Get.back(result: false);
            Loaders.warningSnackBar(title: 'SMS not Sent', message: 'An internal error has occurred, We are working on it!');
            return;
          }
          Loaders.warningSnackBar(title: 'Oh Snap', message: e.message ?? '');
        },
        codeSent: (verificationId, resendToken) {
          debugPrint('--------------- codeSent');
          phoneNoVerificationId.value = verificationId;
          _resendToken = resendToken;
          debugPrint('--------------- codeSent: $verificationId');
        },
        verificationCompleted: (credential) async {
          debugPrint('--------------- verificationCompleted');
          var signedInUser = await _auth.signInWithCredential(credential);
          isPhoneAutoVerified = signedInUser.user != null;

          // await screenRedirect(
          //   _auth.currentUser,
          //   pinScreen: true,
          //   stopLoadingWhenReady: true,
          //   phoneNumber: phoneNumber,
          // );
          ///await screenRedirect(_auth.currentUser);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // phoneNoVerificationId.value = verificationId;
          debugPrint('--------------- codeAutoRetrievalTimeout: $verificationId');
        },
      );
      phoneNo.value = phoneNumber;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }


  /*---------------------------federated identity & social sign in------------------------*/



  ///logout user - valid for any authentication
  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAll(() => const LoginScreen());

    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }


  ///deleteuser - remove user auth and firestore account
  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}


