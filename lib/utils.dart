import 'package:package_info_plus/package_info_plus.dart';

late PackageInfo packageInfo;
// String appName = packageInfo.appName;
// String packageName = packageInfo.packageName;
// String version = packageInfo.version;

Future<void> readPackageInfo() async {
  packageInfo = await PackageInfo.fromPlatform();
}

String getVersion() {
  return packageInfo.version;
}
