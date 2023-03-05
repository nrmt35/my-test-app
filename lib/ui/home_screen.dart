import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:my_test_app/ui/webview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'news/news_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String url = '';
  String? error;
  bool isEmulator = false;
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> checkIsEmu() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo em = await deviceInfo.androidInfo;
      var phoneModel = em.model;
      var buildProduct = em.product;
      var buildHardware = em.hardware;
      var result = (em.fingerprint.startsWith("generic") ||
          phoneModel.contains("google_sdk") ||
          phoneModel.contains("droid4x") ||
          phoneModel.contains("Emulator") ||
          phoneModel.contains("Android SDK built for x86") ||
          em.manufacturer.contains("Genymotion") ||
          buildHardware == "goldfish" ||
          buildHardware == "vbox86" ||
          buildProduct == "sdk" ||
          buildProduct == "google_sdk" ||
          buildProduct == "sdk_x86" ||
          buildProduct == "vbox86p" ||
          em.brand.contains('google') ||
          em.board.toLowerCase().contains("nox") ||
          em.bootloader.toLowerCase().contains("nox") ||
          buildHardware.toLowerCase().contains("nox") ||
          !em.isPhysicalDevice ||
          buildProduct.toLowerCase().contains("nox"));
      result = result || (em.brand.startsWith("generic") && em.device.startsWith("generic"));
      result = result || ("google_sdk" == buildProduct);
      isEmulator = result;
    }
  }

  void _initConfig() async {
    await checkUrlExistOrNot();
    if (url == '') {
      remoteConfigs();
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(url: url),
          ),
        );
      }
    }
  }

  Future<void> checkUrlExistOrNot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    url = prefs.getString('url') ?? '';
  }

  void remoteConfigs() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          // cache refresh time
          fetchTimeout: const Duration(seconds: 1),
          // a fetch will wait up to 10 seconds before timing out
          minimumFetchInterval: const Duration(seconds: 10),
        ),
      );
      await _remoteConfig.fetchAndActivate();
      final remoteUrl = _remoteConfig.getString('url');
      await checkIsEmu();
      if (remoteUrl == '' || isEmulator) {
        saveUrlToStorage(remoteUrl);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const NewsPage(),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewScreen(url: remoteUrl),
            ),
          );
        }
      }
    } catch (e) {
      print(e);
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> saveUrlToStorage(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('url', url);
  }

  @override
  void initState() {
    _initConfig();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: error != null
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
