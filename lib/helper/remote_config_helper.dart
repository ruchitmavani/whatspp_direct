import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatspp_direct/shared_prefs/shared_prefs.dart';

class RemoteConfigHelper {
  static final remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> init() async {
    try {
      await remoteConfig.ensureInitialized();
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 10),
        ),
      );
      await remoteConfig.fetchAndActivate();
    } on FirebaseException catch (e, ee) {
      log(
        'Unable to initialize Firebase Remote Config',
        error: e,
        stackTrace: ee,
      );
    }
  }

  static bool checkUpdate(
      {required String optionalVersion,
      required String currentVersion,
      required String requiredVersion}) {
    final listOfCurrentVersion =
        currentVersion.trim().split('.').map(int.parse).toList();
    final optionalVersionList =
        optionalVersion.trim().split('.').map(int.parse).toList();
    final requiredVersionList =
        requiredVersion.trim().split('.').map((e) => int.parse(e)).toList();

    var result = false;
    for (var i = 0; i < optionalVersionList.length; i++) {
      if ((listOfCurrentVersion[i] < optionalVersionList[i]) ||
          listOfCurrentVersion[i] < requiredVersionList[i]) {
        result = true;
        break;
      } else {
        result = false;
      }
    }
    return result;
  }

  static bool checkVersion(
      {required String optionalVersion, required String requiredVersion}) {
    final optionalVersionList =
        optionalVersion.trim().split('.').map(int.parse).toList();
    final requiredVersionList =
        requiredVersion.trim().split('.').map((e) => int.parse(e)).toList();

    var result = false;

    for (var i = 0; i < optionalVersionList.length; i++) {
      if (requiredVersionList[i] < optionalVersionList[i]) {
        result = true;
        break;
      } else if (requiredVersionList[i] == optionalVersionList[i]) {
        result = false;
      } else {
        result = false;
      }
    }
    return result;
  }

  static Future<void> appForceUpdate(BuildContext context) async {
    try {
      final nav = Navigator.of(context);
      final info = await PackageInfo.fromPlatform();
      await remoteConfig.fetchAndActivate();
      final json = remoteConfig.getString('app_force_update');
      final jsonToMap = jsonDecode(json) as Map<String, dynamic>?;
      if (jsonToMap != null && jsonToMap.isNotEmpty) {
        final optionalVersion = jsonToMap['optionalVersion'] as String?;
        final requiredVersion = jsonToMap['requiredVersion'] as String?;
        if ((optionalVersion != null && optionalVersion.isNotEmpty) ||
            (requiredVersion != null && requiredVersion.isNotEmpty)) {
          bool isUpdate = checkUpdate(
              optionalVersion: optionalVersion!,
              currentVersion: info.version,
              requiredVersion: requiredVersion!);
          final now = DateTime.now();
          bool isOptional = checkVersion(
              optionalVersion: optionalVersion,
              requiredVersion: requiredVersion);
          if (isUpdate) {
            sharedPrefs.versions = jsonEncode(jsonToMap);
            print(now);
            print(DateTime.fromMillisecondsSinceEpoch(
                int.parse(sharedPrefs.updateLater)));
            if (now.difference(DateTime.fromMillisecondsSinceEpoch(
                        int.parse(sharedPrefs.updateLater))) >=
                    const Duration(days: 3) ||
                !isOptional) {
              await nav.push<void>(
                TransparentRoute(
                  builder: (context) {
                    return UpdateDialog(
                      optionalVersion: optionalVersion,
                      requiredVersion: requiredVersion,
                      isOptional: isOptional,
                    );
                  },
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (sharedPrefs.versions.isNotEmpty) {
        final jsonMap = jsonDecode(sharedPrefs.versions);
        bool isOptional = checkVersion(
            optionalVersion: jsonMap['optionalVersion'],
            requiredVersion: jsonMap['requiredVersion']);
        await Navigator.of(context).push<void>(
          TransparentRoute(
            builder: (context) {
              return UpdateDialog(
                optionalVersion: jsonMap['optionalVersion'],
                requiredVersion: jsonMap['requiredVersion'],
                isOptional: isOptional,
              );
            },
          ),
        );
      }
      print(
          '=============================================appForceUpdate are not working-----$e');
    }
  }
}

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    required this.requiredVersion,
    super.key,
    required this.optionalVersion,
    required this.isOptional,
  });

  final String requiredVersion;
  final String optionalVersion;
  final bool isOptional;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  Future<void> launchStore() async {
    final info = await PackageInfo.fromPlatform();
    final appPackageName = info.packageName;
    await launchUrl(
      Uri.parse(
          'https://play.google.com/store/apps/details?id=$appPackageName'),
      mode: LaunchMode.externalApplication,
    );
    sharedPrefs.updateLater = '';
  }

  void updateLater() {
    sharedPrefs.updateLater = DateTime.now().millisecondsSinceEpoch.toString();
    Navigator.pop(context);
  }

  // bool checkVersion() {
  //   final optionalVersionList =
  //       widget.optionalVersion.trim().split('.').map(int.parse).toList();
  //   final requiredVersionList = widget.requiredVersion
  //       .trim()
  //       .split('.')
  //       .map((e) => int.parse(e))
  //       .toList();
  //
  //   var result = false;
  //
  //   for (var i = 0; i < optionalVersionList.length; i++) {
  //     if (requiredVersionList[i] < optionalVersionList[i]) {
  //       result = true;
  //       break;
  //     } else if (requiredVersionList[i] == optionalVersionList[i]) {
  //       result = false;
  //     } else {
  //       result = false;
  //     }
  //   }
  //   return result;
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text(
            'App Update Available',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 19, color: Colors.black),
          ),
          content: Text(
            !widget.isOptional
                ? 'Please update the app to continue'
                : 'A newer version of the app is available',
            style: TextStyle(color: Colors.black.withOpacity(.55)),
          ),
          actions: [
            if (!widget.isOptional) ...{
              TextButton(
                onPressed: () async => launchStore(),
                child: const Text(
                  'Update Now',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            } else ...{
              TextButton(
                onPressed: updateLater,
                child: const Text(
                  'Later',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async => launchStore(),
                child: const Text(
                  'Update Now',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({required this.builder, super.settings})
      : super(fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final result = builder(context);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: result,
      ),
    );
  }
}
