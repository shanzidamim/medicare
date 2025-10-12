import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


import 'app.dart';
import 'common/flutter_native_splash.dart';
import 'data/repositories.authentication/authentication_repository.dart';
import 'firebase_options.dart';



void main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  ///--GetX local storage
  await GetStorage.init();
  /// Await native splash
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// Initialize firebase & authentication repository
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then(
        (FirebaseApp value) => Get.put(AuthenticationRepository()),
  );
  runApp(MyApp());
}


