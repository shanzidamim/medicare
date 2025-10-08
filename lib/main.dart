import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';


import 'app.dart';
import 'data/repositories.authentication/authentication_repository.dart';
import 'firebase_options.dart';



  Future<void> main() async {
    /// widgets binding
    final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    ///--GetX local storage
    await GetStorage.init();
    /// Await native splash

    /// Initialize firebase & authentication repository
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then(
          (FirebaseApp value) => Get.put(AuthenticationRepository()),
    );
    ///local all the material design
    runApp(const MyApp());
  }


